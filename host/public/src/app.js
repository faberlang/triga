import { FaberKernelContractError, loadFaberGraphicsPipeline } from "./contract/artifact-admission.js";
import {
  acquireWebGpuDevice,
  createGraphicsResources,
  onDeviceLost,
  replaceDepthTextureOnResize,
  runGraphicsFrame,
} from "./backend/webgpu-runtime.js";

const elements = {
  scene: document.querySelector("#scene"),
  status: document.querySelector("#status-value"),
  pipeline: document.querySelector("#pipeline-name"),
  frames: document.querySelector("#frame-count"),
};

window.trigaHostProof = Object.freeze({ ok: false, status: "starting" });

main().catch((error) => {
  const proof = proofFailure(error);
  setStatus("error", proof.error);
  window.trigaHostProof = proof;
});

async function main() {
  setStatus("pending", "Loading");

  const [wgslResponse, reflectionResponse, positionsResponse, colorsResponse, indicesResponse, transformResponse, drawResponse] =
    await Promise.all([
      fetch("./generated/graphics.wgsl"),
      fetch("./generated/graphics-reflection.json"),
      fetch("./generated/graphics-vertex-positions.bin"),
      fetch("./generated/graphics-vertex-colors.bin"),
      fetch("./generated/graphics-indices.bin"),
      fetch("./generated/graphics-transform.bin"),
      fetch("./generated/draw.json"),
    ]);

  for (const [label, response] of [
    ["wgsl", wgslResponse],
    ["reflection", reflectionResponse],
    ["positions", positionsResponse],
    ["colors", colorsResponse],
    ["indices", indicesResponse],
    ["transform", transformResponse],
    ["draw", drawResponse],
  ]) {
    if (!response.ok) {
      throw new FaberKernelContractError(label, `failed to fetch graphics ${label}`, "artifact-fetch");
    }
  }

  const wgsl = await wgslResponse.text();
  const reflection = await reflectionResponse.json();
  const drawManifest = await drawResponse.json();
  const descriptor = loadFaberGraphicsPipeline({ wgsl, reflection, drawManifest });

  const { device } = await acquireWebGpuDevice();
  onDeviceLost(device, (info) => {
    window.trigaHostProof = Object.freeze({
      ok: false,
      status: "error",
      kind: info.kind,
      reason: info.reason,
      message: info.message,
    });
    setStatus("error", info.message);
  });

  const canvas = document.querySelector("#gpu-canvas");
  if (!canvas) {
    throw new FaberKernelContractError("canvas", "visible #gpu-canvas is missing", "product");
  }
  const context = canvas.getContext("webgpu");
  if (!context) {
    throw new FaberKernelContractError("canvas", "WebGPU canvas context is unavailable", "webgpu");
  }

  context.configure({
    device,
    format: "bgra8unorm",
    alphaMode: "opaque",
  });
  sizeCanvas(canvas);

  const payloads = {
    vertexBuffers: [
      { slot: 0, data: await positionsResponse.arrayBuffer() },
      { slot: 1, data: await colorsResponse.arrayBuffer() },
    ],
    indexData: new Uint32Array(await indicesResponse.arrayBuffer()),
    storageData: {
      transform: new Float32Array(await transformResponse.arrayBuffer()),
    },
  };

  let resources = createGraphicsResources(device, descriptor, payloads, context);
  const frameState = { submittedFrameCount: 0 };

  const draw = () => {
    runGraphicsFrame(device, context, resources, descriptor, frameState);
    elements.frames.textContent = String(frameState.submittedFrameCount);
  };

  draw();

  window.addEventListener("resize", () => {
    sizeCanvas(canvas);
    resources = replaceDepthTextureOnResize(device, resources, canvas.width, canvas.height);
    draw();
  });

  elements.pipeline.textContent = `${descriptor.kernels[0].entryName} / ${descriptor.kernels[1].entryName}`;
  setStatus("ok", "Ready");
  window.trigaHostProof = Object.freeze({
    ok: true,
    status: "ready",
    kind: "ok",
    submittedFrameCount: frameState.submittedFrameCount,
    vertexCount: descriptor.pipeline.vertexCount,
    indexFormat: descriptor.draw.indexFormat,
    visibleCanvas: canvas.style.display !== "none" && canvas.width > 0 && canvas.height > 0,
  });
}

function sizeCanvas(canvas) {
  const rect = canvas.getBoundingClientRect();
  const dpr = Math.min(window.devicePixelRatio || 1, 2);
  canvas.width = Math.max(1, Math.floor(rect.width * dpr));
  canvas.height = Math.max(1, Math.floor(rect.height * dpr));
}

function setStatus(state, text) {
  elements.status.dataset.state = state;
  elements.status.textContent = text;
}

function proofFailure(error) {
  const kind =
    error instanceof FaberKernelContractError
      ? error.kind
      : typeof error?.kind === "string"
        ? error.kind
        : "product";
  return Object.freeze({
    ok: false,
    status: "error",
    kind,
    path: error?.path ?? null,
    error: error?.message ?? String(error),
  });
}
