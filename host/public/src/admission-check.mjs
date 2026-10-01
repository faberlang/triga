#!/usr/bin/env node
import { readFile } from "node:fs/promises";
import path from "node:path";
import { fileURLToPath, pathToFileURL } from "node:url";

const here = path.dirname(fileURLToPath(import.meta.url));
const generatedDir = path.resolve(here, "../generated");
const admissionUrl = pathToFileURL(path.join(here, "contract/artifact-admission.js")).href;
const runtimeUrl = pathToFileURL(path.join(here, "backend/webgpu-runtime.js")).href;

const admission = await import(admissionUrl);
const runtime = await import(runtimeUrl);
const { FaberKernelContractError, loadFaberGraphicsPipeline } = admission;

let failed = 0;

function require(condition, message) {
  if (!condition) {
    failed += 1;
    console.error(`FAIL: ${message}`);
  }
}

function expectReject(label, fn) {
  try {
    fn();
    failed += 1;
    console.error(`FAIL: ${label} (expected reject)`);
  } catch (error) {
    if (!(error instanceof FaberKernelContractError)) {
      failed += 1;
      console.error(`FAIL: ${label} (wrong error: ${error})`);
    }
  }
}

const wgsl = await readFile(path.join(generatedDir, "graphics.wgsl"), "utf8");
const reflection = JSON.parse(await readFile(path.join(generatedDir, "graphics-reflection.json"), "utf8"));
const draw = JSON.parse(await readFile(path.join(generatedDir, "draw.json"), "utf8"));

const desc = loadFaberGraphicsPipeline({ wgsl, reflection, drawManifest: draw });
require(desc.kernels.length === 2, "expected vertex + fragment kernels");
require(desc.kernels[0].shaderStage === "vertex", "first kernel must be vertex");
require(desc.kernels[1].shaderStage === "fragment", "second kernel must be fragment");
require(desc.kernels[0].vertexInputs.length === 2, "expected position + color inputs");
require(desc.kernels[0].vertexBufferLayouts[0].arrayStride === 12, "position stride must be 12");
require(desc.pipeline.primitiveTopology === "triangle-list", "topology must be triangle-list");
require(desc.pipeline.vertexCount === 36, "pipeline vertex_count must be 36");
require(desc.draw.indexCount === 36, "draw index_count must be 36");
require(desc.draw.indexFormat === "uint32", "index format must be uint32");
const transform = desc.bindGroups[0].entries[0];
require(transform.sourceName === "transform", "first binding must be transform");
require(transform.elementCount === 32, "transform element_count must be 32");
require(transform.bufferByteLen === 128, "transform buffer must be 128 bytes");
const transformBin = await readFile(path.join(generatedDir, "graphics-transform.bin"));
require(transformBin.byteLength === 128, "graphics-transform.bin must be 128 bytes");
require(typeof admission.loadFaberKernel === "undefined", "compute loadFaberKernel must not be exported");
require(typeof runtime.createWebGpuResources === "undefined", "compute createWebGpuResources must not be exported");
require(typeof runtime.runKernel === "undefined", "compute runKernel must not be exported");
require(typeof runtime.createGraphicsResources === "function", "createGraphicsResources must export");
require(typeof runtime.runGraphicsFrame === "function", "runGraphicsFrame must export");

expectReject("missing pipeline", () => {
  const bad = structuredClone(reflection);
  delete bad.pipeline;
  loadFaberGraphicsPipeline({ wgsl, reflection: bad, drawManifest: draw });
});

expectReject("wrong kernel count", () => {
  const bad = structuredClone(reflection);
  bad.kernels = [bad.kernels[0]];
  loadFaberGraphicsPipeline({ wgsl, reflection: bad, drawManifest: draw });
});

expectReject("bad index format", () => {
  loadFaberGraphicsPipeline({
    wgsl,
    reflection,
    drawManifest: { ...draw, index_format: "uint8" },
  });
});

if (failed !== 0) {
  console.error(`admission-check: ${failed} failure(s)`);
  process.exit(1);
}

console.log("admission-check: green");
console.log(`  vertex=${desc.kernels[0].entryName} fragment=${desc.kernels[1].entryName}`);
console.log(`  vertex_count=${desc.pipeline.vertexCount} index_count=${desc.draw.indexCount}`);
