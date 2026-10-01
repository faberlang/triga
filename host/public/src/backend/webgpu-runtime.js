import { FaberKernelContractError } from "../contract/artifact-admission.js";

const BUFFER_USAGE = {
  input: () => GPUBufferUsage.STORAGE | GPUBufferUsage.COPY_DST,
  output: () => GPUBufferUsage.STORAGE | GPUBufferUsage.COPY_SRC,
  vertex: () => GPUBufferUsage.VERTEX | GPUBufferUsage.COPY_DST,
  index: () => GPUBufferUsage.INDEX | GPUBufferUsage.COPY_DST,
};

const EXPECTED_CANVAS_FORMAT = "bgra8unorm";
const DEPTH_FORMAT = "depth24plus";
const GRAPHICS_SAMPLE_COUNT = 4;

export async function acquireWebGpuDevice({
  navigator: nav = globalThis.navigator,
} = {}) {
  if (!nav?.gpu) {
    throw new FaberKernelContractError(
      "navigator.gpu",
      "WebGPU is unavailable in this browser",
      "webgpu",
    );
  }

  const adapter = await nav.gpu.requestAdapter();
  if (!adapter) {
    throw new FaberKernelContractError(
      "navigator.gpu.requestAdapter",
      "no WebGPU adapter available",
      "webgpu",
    );
  }

  const device = await adapter.requestDevice();
  return { adapter, device };
}

export function createGraphicsResources(device, descriptor, payloads, canvasContext) {
  const currentTexture = canvasContext.getCurrentTexture();
  if (currentTexture.format !== EXPECTED_CANVAS_FORMAT) {
    throw new FaberKernelContractError(
      "canvasContext",
      `expected ${EXPECTED_CANVAS_FORMAT} canvas format, got ${currentTexture.format}`,
      "webgpu",
    );
  }

  const shaderModule = device.createShaderModule({ code: descriptor.wgsl });
  const storageBuffers = createStorageBuffers(device, descriptor, payloads.storageData ?? {});
  const textures = createBoundTextures(device, descriptor, payloads.textureImages ?? {});
  const samplers = createBoundSamplers(device, descriptor);
  const bindGroupLayouts = createGraphicsBindGroupLayouts(device, descriptor);
  const pipelineLayout = createPipelineLayout(device, descriptor, bindGroupLayouts);
  const bindGroups = createBindGroups(device, descriptor, bindGroupLayouts, storageBuffers, textures, samplers);
  const vertexBuffers = createVertexBuffers(device, descriptor, payloads.vertexBuffers ?? []);
  const { indexBuffer, indexCount } = createIndexBuffer(device, descriptor, payloads.indexData);
  const depthTexture = createDepthTexture(
    device,
    currentTexture.width,
    currentTexture.height,
    GRAPHICS_SAMPLE_COUNT,
  );
  const msaaTexture = createMsaaColorTexture(
    device,
    currentTexture.width,
    currentTexture.height,
    currentTexture.format,
    GRAPHICS_SAMPLE_COUNT,
  );

  const pipeline = device.createRenderPipeline({
    layout: pipelineLayout,
    vertex: {
      module: shaderModule,
      entryPoint: descriptor.kernels[0].entryName,
      buffers: descriptor.kernels[0].vertexBufferLayouts.map((layout) => ({
        arrayStride: layout.arrayStride,
        stepMode: layout.stepMode,
        attributes: layout.attributes.map((attr) => ({
          shaderLocation: attr.shaderLocation,
          format: attr.format,
          offset: attr.offset,
        })),
      })),
    },
    fragment: {
      module: shaderModule,
      entryPoint: descriptor.kernels[1].entryName,
      targets: descriptor.pipeline.colorTargetFormats.map((fmt) => ({
        format: fmt,
      })),
    },
    primitive: {
      topology: descriptor.pipeline.primitiveTopology,
      cullMode: "none",
    },
    depthStencil: {
      depthWriteEnabled: descriptor.pipeline.depthStencil.depthWriteEnabled,
      depthCompare: descriptor.pipeline.depthStencil.depthCompare,
      format: DEPTH_FORMAT,
    },
    multisample: {
      count: GRAPHICS_SAMPLE_COUNT,
    },
  });

  return Object.freeze({
    storageBuffers,
    vertexBuffers,
    indexBuffer,
    indexCount,
    bindGroupLayouts,
    pipelineLayout,
    shaderModule,
    pipeline,
    bindGroups,
    depthTexture,
    msaaTexture,
    sampleCount: GRAPHICS_SAMPLE_COUNT,
  });
}

export function runGraphicsFrame(device, context, resources, descriptor, frameState, options = {}) {
  const textureView = context.getCurrentTexture().createView();
  const clearValue = options.clearValue ?? { r: 0.12, g: 0.13, b: 0.15, a: 1.0 };

  const commandEncoder = device.createCommandEncoder();
  const renderPass = commandEncoder.beginRenderPass({
    colorAttachments: [msaaColorAttachment(resources, textureView, clearValue, "clear")],
    depthStencilAttachment: {
      view: resources.depthTexture.createView(),
      depthClearValue: 1.0,
      depthLoadOp: "clear",
      depthStoreOp: "store",
    },
  });

  renderPass.setPipeline(resources.pipeline);
  for (const vb of resources.vertexBuffers) {
    renderPass.setVertexBuffer(vb.slot, vb.buffer);
  }
  renderPass.setIndexBuffer(resources.indexBuffer, descriptor.draw.indexFormat, 0);
  for (const group of resources.bindGroups) {
    renderPass.setBindGroup(group.bindGroupIndex, group.bindGroup);
  }

  const firstIndex = descriptor.draw.firstIndex;
  const indexCount = descriptor.draw.indexCount;
  const instanceCount = descriptor.draw.instanceCount;
  const baseVertex = descriptor.draw.baseVertex;
  if (firstIndex + indexCount > resources.indexCount) {
    throw new FaberKernelContractError(
      "drawManifest",
      `first_index ${firstIndex} + index_count ${indexCount} exceeds buffer index count ${resources.indexCount}`,
    );
  }

  renderPass.drawIndexed(indexCount, instanceCount, firstIndex, baseVertex, 0);
  renderPass.end();
  device.queue.submit([commandEncoder.finish()]);
  frameState.submittedFrameCount = (frameState.submittedFrameCount ?? 0) + 1;
}

export function replaceDepthTextureOnResize(device, resources, width, height) {
  if (resources.depthTexture) {
    resources.depthTexture.destroy();
  }
  const sampleCount = resources.sampleCount ?? 1;
  const depthTexture = createDepthTexture(device, width, height, sampleCount);
  let msaaTexture = resources.msaaTexture;
  if (msaaTexture) {
    msaaTexture.destroy();
    msaaTexture = createMsaaColorTexture(device, width, height, msaaTexture.format, sampleCount);
  }
  return Object.freeze({
    ...resources,
    depthTexture,
    msaaTexture,
  });
}

export function onDeviceLost(device, callback) {
  device.lost.then((info) => {
    callback(
      Object.freeze({
        kind: "device-lost",
        reason: info.reason,
        message: info.message,
      }),
    );
  });
}

function msaaColorAttachment(resources, canvasView, clearValue, loadOp) {
  if (resources.msaaTexture) {
    return {
      view: resources.msaaTexture.createView(),
      resolveTarget: canvasView,
      clearValue,
      loadOp,
      storeOp: "store",
    };
  }
  return { view: canvasView, clearValue, loadOp, storeOp: "store" };
}

function createGraphicsBindGroupLayouts(device, descriptor) {
  const layouts = new Map();
  for (const layout of descriptor.bindGroupLayouts) {
    const entries = layout.entries.map((entry) => layoutEntryForBinding(entry));
    layouts.set(layout.bindGroupIndex, device.createBindGroupLayout({ entries }));
  }
  return layouts;
}

function layoutEntryForBinding(entry) {
  if (entry.kind === "texture") {
    return {
      binding: entry.binding,
      visibility: GPUShaderStage.FRAGMENT,
      texture: {
        sampleType: "float",
        viewDimension: "2d",
        multisampled: false,
      },
    };
  }
  if (entry.kind === "sampler") {
    return {
      binding: entry.binding,
      visibility: GPUShaderStage.FRAGMENT,
      sampler: { type: "filtering" },
    };
  }
  return {
    binding: entry.binding,
    visibility: GPUShaderStage.VERTEX | GPUShaderStage.FRAGMENT,
    buffer: {
      type: entry.bufferType,
      hasDynamicOffset: false,
      minBindingSize: entry.minBindingSize,
    },
  };
}

function createPipelineLayout(device, descriptor, bindGroupLayouts) {
  const orderedLayouts = descriptor.pipelineLayout.bindGroupLayoutIndexes.map((index) => {
    const layout = bindGroupLayouts.get(index);
    if (!layout) {
      throw new FaberKernelContractError("pipelineLayout.bindGroupLayoutIndexes", `missing layout ${index}`);
    }
    return layout;
  });
  return device.createPipelineLayout({ bindGroupLayouts: orderedLayouts });
}

function createBindGroups(device, descriptor, bindGroupLayouts, buffers, textures, samplers) {
  return descriptor.bindGroups.map((group) => {
    const layout = bindGroupLayouts.get(group.bindGroupIndex);
    if (!layout) {
      throw new FaberKernelContractError("bindGroupLayouts", `missing layout ${group.bindGroupIndex}`);
    }
    const entries = group.entries.map((entry) => bindGroupEntry(entry, buffers, textures, samplers));
    return Object.freeze({
      bindGroupIndex: group.bindGroupIndex,
      bindGroup: device.createBindGroup({ layout, entries }),
    });
  });
}

function bindGroupEntry(entry, buffers, textures, samplers) {
  if (entry.kind === "texture") {
    const texture = textures.get(entry.sourceName);
    if (!texture) {
      throw new FaberKernelContractError("payloads.textureImages", `missing texture ${entry.sourceName}`);
    }
    return { binding: entry.binding, resource: texture.createView() };
  }
  if (entry.kind === "sampler") {
    const sampler = samplers.get(entry.sourceName);
    if (!sampler) {
      throw new FaberKernelContractError("samplers", `missing sampler ${entry.sourceName}`);
    }
    return { binding: entry.binding, resource: sampler };
  }
  const resource = buffers.get(entry.resourceIndex);
  if (!resource) {
    throw new FaberKernelContractError("buffers", `missing resource ${entry.resourceIndex}`);
  }
  return {
    binding: entry.binding,
    resource: {
      buffer: resource.buffer,
      offset: entry.bufferByteOffset,
      size: entry.bindingByteLen,
    },
  };
}

function createVertexBuffers(device, descriptor, vertexPayloads) {
  const vertexKernel = descriptor.kernels[0];
  const buffers = [];
  for (const payload of vertexPayloads) {
    const layout = vertexKernel.vertexBufferLayouts.find((vbl) => vbl.bufferIndex === payload.slot);
    if (!layout) {
      throw new FaberKernelContractError(
        "payloads.vertexBuffers",
        `no vertex buffer layout for slot ${payload.slot}`,
      );
    }
    const data = payload.data instanceof ArrayBuffer
      ? new Uint8Array(payload.data)
      : new Uint8Array(payload.data.buffer, payload.data.byteOffset, payload.data.byteLength);
    if (layout.arrayStride <= 0 || data.byteLength < layout.arrayStride) {
      throw new FaberKernelContractError(
        "payloads.vertexBuffers",
        `expected at least one vertex (${layout.arrayStride} bytes) for slot ${payload.slot}, got ${data.byteLength}`,
      );
    }
    if (data.byteLength % layout.arrayStride !== 0) {
      throw new FaberKernelContractError(
        "payloads.vertexBuffers",
        `slot ${payload.slot} byte length ${data.byteLength} is not a multiple of stride ${layout.arrayStride}`,
      );
    }
    const buffer = device.createBuffer({
      size: data.byteLength,
      usage: BUFFER_USAGE.vertex(),
      mappedAtCreation: true,
    });
    new Uint8Array(buffer.getMappedRange()).set(data);
    buffer.unmap();
    buffers.push(Object.freeze({ slot: payload.slot, buffer }));
  }
  return Object.freeze(buffers);
}

function createIndexBuffer(device, descriptor, indexData) {
  if (!indexData) {
    throw new FaberKernelContractError("payloads.indexData", "index data is required for indexed draw");
  }
  const data = indexData instanceof ArrayBuffer
    ? new Uint8Array(indexData)
    : new Uint8Array(indexData.buffer, indexData.byteOffset, indexData.byteLength);
  const indexByteSize = descriptor.draw.indexFormat === "uint16" ? 2 : 4;
  const indexCount = Math.floor(data.byteLength / indexByteSize);
  if (indexCount === 0) {
    throw new FaberKernelContractError(
      "payloads.indexData",
      `index data too short for ${descriptor.draw.indexFormat} format`,
    );
  }
  const buffer = device.createBuffer({
    size: data.byteLength,
    usage: BUFFER_USAGE.index(),
    mappedAtCreation: true,
  });
  new Uint8Array(buffer.getMappedRange()).set(data);
  buffer.unmap();
  return Object.freeze({ indexBuffer: buffer, indexCount });
}

function createDepthTexture(device, width, height, sampleCount = 1) {
  return device.createTexture({
    size: { width, height },
    format: DEPTH_FORMAT,
    sampleCount,
    usage: GPUTextureUsage.RENDER_ATTACHMENT,
  });
}

function createMsaaColorTexture(device, width, height, format, sampleCount) {
  return device.createTexture({
    size: { width, height },
    format,
    sampleCount,
    usage: GPUTextureUsage.RENDER_ATTACHMENT,
  });
}

function createBoundTextures(device, descriptor, textureImages) {
  const textures = new Map();
  for (const entry of descriptor.bindGroups.flatMap((group) => group.entries)) {
    if (entry.kind !== "texture" || textures.has(entry.sourceName)) {
      continue;
    }
    const image = textureImages[entry.sourceName];
    if (!image || typeof image.width !== "number" || typeof image.height !== "number") {
      throw new FaberKernelContractError(
        `payloads.textureImages.${entry.sourceName}`,
        "expected an image source with width and height",
      );
    }
    const texture = device.createTexture({
      size: { width: image.width, height: image.height },
      format: "rgba8unorm",
      usage: GPUTextureUsage.TEXTURE_BINDING | GPUTextureUsage.COPY_DST | GPUTextureUsage.RENDER_ATTACHMENT,
    });
    device.queue.copyExternalImageToTexture(
      { source: image },
      { texture },
      { width: image.width, height: image.height },
    );
    textures.set(entry.sourceName, texture);
  }
  return textures;
}

function createBoundSamplers(device, descriptor) {
  const samplers = new Map();
  for (const entry of descriptor.bindGroups.flatMap((group) => group.entries)) {
    if (entry.kind !== "sampler" || samplers.has(entry.sourceName)) {
      continue;
    }
    samplers.set(
      entry.sourceName,
      device.createSampler({
        magFilter: "nearest",
        minFilter: "nearest",
        addressModeU: "clamp-to-edge",
        addressModeV: "clamp-to-edge",
      }),
    );
  }
  return samplers;
}

function createStorageBuffers(device, descriptor, storageData) {
  const buffers = new Map();
  for (const group of descriptor.bindGroups) {
    for (const entry of group.entries) {
      if (entry.kind === "texture" || entry.kind === "sampler") {
        continue;
      }
      if (buffers.has(entry.resourceIndex)) {
        continue;
      }
      validateBufferSize(device, entry.bufferByteLen, `createStorageBuffers.resource[${entry.resourceIndex}]`);
      const needsInit = entry.role === "input" || entry.role === "uniform";
      const buffer = device.createBuffer({
        size: entry.bufferByteLen,
        usage: bufferUsageForRole(entry.role),
        mappedAtCreation: needsInit,
      });
      if (needsInit) {
        writeGraphicsStorageInput(buffer, entry, storageData);
      }
      buffers.set(entry.resourceIndex, {
        buffer,
        generation: 0,
        logicalId: entry.resourceIndex,
      });
    }
  }
  return buffers;
}

function writeGraphicsStorageInput(buffer, entry, storageData) {
  const inputName = entry.sourceName ?? `resource_${entry.resourceIndex}`;
  const value = storageData[inputName];
  if (!(value instanceof Float32Array)) {
    throw new FaberKernelContractError(`payloads.storageData.${inputName}`, "expected Float32Array");
  }
  if (value.byteLength > entry.bufferByteLen) {
    throw new FaberKernelContractError(
      `payloads.storageData.${inputName}`,
      `expected at most ${entry.bufferByteLen} bytes, got ${value.byteLength}`,
    );
  }
  const target = new Uint8Array(buffer.getMappedRange());
  target.set(new Uint8Array(value.buffer, value.byteOffset, value.byteLength));
  buffer.unmap();
}

function bufferUsageForRole(role) {
  const usage = BUFFER_USAGE[role];
  if (!usage) {
    throw new FaberKernelContractError("binding.role", `unsupported role ${role}`);
  }
  return usage();
}

function validateBufferSize(device, size, label) {
  const maxSize = device?.limits?.maxBufferSize;
  if (maxSize !== undefined && size > maxSize) {
    throw new FaberKernelContractError(
      label,
      `buffer size ${size} exceeds device limit maxBufferSize ${maxSize}`,
      "webgpu",
    );
  }
}
