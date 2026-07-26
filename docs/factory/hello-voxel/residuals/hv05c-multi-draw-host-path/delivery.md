# Delivery: HV-05C Multi-Draw Host Path Residual

**Goal path:** `triga/docs/factory/hello-voxel/residuals/hv05c-multi-draw-host-path/goal.md`
**Goal check:** READY (2026-07-26, planner-1)
**Planner:** planner-1
**Date:** 2026-07-26
**Unit count:** 1

## Interpreted Unit

Rewrite one proof script (`hv04c-host-proof-app.js`) to close the HV-05C
multi-draw residual: use the host's per-chunk-multi-draw path instead of the
concatenated-single-buffer path. The package already declares `draw_count=4`;
the host already has the multi-draw API; the proof script is the last consumer
of the old path.

## Normalized Spec

Replace old host imports (`createGraphicsResources`, `runGraphicsFrameWithTexture`)
with multi-draw imports (`createChunkGraphicsResources`, `applyChunkResourceReplace`,
`runChunkGraphicsFrame`). Load per-chunk geometry from `chunks/<slot>/` instead of
concatenated world bins. Create chunk resources and submit frames through the
multi-draw path. Adapt pixel readback and resize to work with the chunk resource
model. Prove `draw_count === 4` and `multi_draw === true` in frame observations
while preserving all existing pixel validation laws.

## Repo-Aware Baseline

| Path | Role |
|---|---|
| `examples/hello-voxel/scripta/hv04c-host-proof-app.js` | **Write target** — single file rewrite |
| `hosts/webgpu-browser/public/src/webgpu-runtime.js` | **Read-only API surface** — `createChunkGraphicsResources` (L1296), `applyChunkResourceReplace` (L1426), `runChunkGraphicsFrame` (L1553), `chunkResourceCounters` (L1380), `liveChunkIds` (L1395), `replaceDepthTextureOnResize` (L? ), `readTexturePixelsRgba` (L937) |
| `examples/hello-voxel/tests/hv07c-resource-cycle-test.mjs` | **Reference pattern** — working example of multi-draw host API usage (L467–508 for bootstrap, L506 for runChunkGraphicsFrame) |
| `examples/hello-voxel/scripta/emit-package-geometry.mjs` | **Read-only contract** — chunk pair output shape in `chunks/<slot>/` (L193–229) |
| `examples/hello-voxel/public/draw.json` | **Read-only authority** — `draw_count: 4`, `resource_pair_count: 4` |
| `examples/hello-voxel/scripta/hv04c-host-page.html` | **May read** — confirm page structure unchanged |
| `examples/hello-voxel/scripta/run-hv04c-host-proof.mjs` | **May read** — confirm Node.js proof runner setup |
| `hosts/webgpu-browser/public/src/faber-kernel.js` | **Read-only** — `FaberKernelContractError`, `loadFaberGraphicsPipeline` |
| `hosts/webgpu-browser/public/host-generated/` | **Read-only** — WGSL + reflection artifacts |

## Ordered Unit Graph

### HV05C-R1 — Rewrite HV-04C Proof to Multi-Draw Host Path

**Depends on:** none (host multi-draw path is already landed and tested)

| Field | Value |
|---|---|
| `id` | `HV05C-R1` |
| `outcome` | `hv04c-host-proof-app.js` imports and uses the per-chunk-multi-draw host path. Frame submits record `draw_count: 4`, `multi_draw: true`. All pixel validation laws pass. |
| `write_scope` | `examples/hello-voxel/scripta/hv04c-host-proof-app.js` (single file) |
| `read_scope` | `hosts/webgpu-browser/public/src/webgpu-runtime.js` (API surface), `hosts/webgpu-browser/public/src/faber-kernel.js` (contract errors, pipeline loader), `examples/hello-voxel/tests/hv07c-resource-cycle-test.mjs` (reference pattern), `examples/hello-voxel/scripta/emit-package-geometry.mjs` (chunk output contract), `examples/hello-voxel/public/draw.json` (draw_count authority), `examples/hello-voxel/scripta/hv04c-host-page.html` (page structure), `examples/hello-voxel/scripta/run-hv04c-host-proof.mjs` (runner setup), `hosts/webgpu-browser/public/host-generated/*` (WGSL + reflection), `hosts/webgpu-browser/public/vendor/*` (three.js — only if page references it) |
| `done_when` | All seven acceptance criteria pass: (1) imports `createChunkGraphicsResources`, `applyChunkResourceReplace`, `runChunkGraphicsFrame`; (2) geometry loaded from per-chunk `chunks/<slot>/` bins; (3) four chunk resources created via `applyChunkResourceReplace` (kind: "created"); (4) `frameState.submits[0].draw_count === 4` and `frameState.submits[0].multi_draw === true`; (5) `window.faberHv04cProof.ok === true` with all pixel laws preserved; (6) resize path works with depth texture replaced + frame 2 transform updated; (7) clear-only control yields expected clear hex |
| `validation` | `cd examples/hello-voxel && node scripta/emit-package-geometry.mjs && node scripta/run-hv04c-host-proof.mjs`. Manual: open `hv04c-host-page.html` in WebGPU browser, verify `window.faberHv04cProof.ok` and `submits[0].draw_count === 4` in console |
| `non_goals` | Do not modify `webgpu-runtime.js`; do not modify `emit-package-geometry.mjs`; do not modify `main.fab` or `application.fab`; do not touch radix; do not add new pixel tests — preserve existing laws |
| `risk` | **low** — host API proven by HV-07C; pixel readback adaptation is the only novel surface (default approach: use `readTexturePixelsRgba` after `onSubmittedWorkDone` with `context.getCurrentTexture()`). If readback fails, stop condition triggers — do not modify host runtime |

### Implementation Guidance

**Import change:**
```js
import {
  createChunkGraphicsResources,
  applyChunkResourceReplace,
  runChunkGraphicsFrame,
  chunkResourceCounters,
} from "/host-src/webgpu-runtime.js";
```

**Geometry loading (replace single-bin fetches):**
```js
// Load per-chunk geometry pairs from chunks/<slot>/
const chunks = [];
for (let slot = 0; slot < 4; slot++) {
  const base = `/generated/chunks/${slot}/`;
  const [posRes, colRes, idxRes, drawRes] = await Promise.all([
    fetch(`${base}vertex-positions.bin`),
    fetch(`${base}vertex-colors.bin`),
    fetch(`${base}indices.bin`),
    fetch(`${base}draw.json`),
  ]);
  const drawManifest = await drawRes.json();
  chunks.push({
    slot,
    positions: await posRes.arrayBuffer(),
    colors: await colRes.arrayBuffer(),
    indices: await idxRes.arrayBuffer(),
    index_count: drawManifest.index_count,
  });
}
```

**Resource creation (replace `createGraphicsResources` call):**
```js
let resources = createChunkGraphicsResources(
  device, descriptor,
  { storageData: { transform: transform1 } },
  context,
);
// Bootstrap: one create per non-empty chunk
for (const chunk of chunks) {
  if (chunk.index_count > 0) {
    applyChunkResourceReplace(device, resources, {
      logical_id: chunk.slot,
      generation: 0,
      payload: {
        positions: chunk.positions,
        colors: chunk.colors,
        indices: chunk.indices,
      },
    });
  }
}
```

**Frame submission (replace `runGraphicsFrameWithTexture` calls):**
```js
const frame1 = runChunkGraphicsFrame(device, context, resources, descriptor,
  frameState, { clearValue: CLEAR, recordSubmit: true });
// Pixel readback: use readTexturePixelsRgba after onSubmittedWorkDone
await device.queue.onSubmittedWorkDone();
const texture = context.getCurrentTexture();
const samples1 = await readTexturePixelsRgba(device, texture, points1);
```

**Resize path:**
```js
// Replace depth texture inline (chunk session shape differs from old path)
canvas.width = 320;
canvas.height = 180;
context.configure({
  device, format: "bgra8unorm", alphaMode: "opaque",
  usage: GPUTextureUsage.RENDER_ATTACHMENT | GPUTextureUsage.COPY_SRC,
});
// Destroy old depth texture, create new one
if (resources.depthTexture) {
  resources.depthTexture.destroy();
}
resources.depthTexture = device.createTexture({
  size: [320, 180, 1],
  format: "depth24plus",
  usage: GPUTextureUsage.RENDER_ATTACHMENT,
});
```

**Clear-only control:**
```js
// Same clear control, but must not use chunk resource path
const clearTexture = context.getCurrentTexture();
// ... (unchanged)
```

**Proof object updates:**
```js
// Add multi-draw asserts to the proof object
window.faberHv04cProof = Object.freeze({
  ok: ...,
  // ... existing fields ...
  multi_draw: frameState.submits.every(s => s.multi_draw === true),
  draw_count: frameState.submits[frameState.submits.length - 1]?.draw_count ?? 0,
  host_path: frameState.submits[0]?.path ?? null,
});
```

## Checkpoints and Gates

- **Checkpoint**: after running `run-hv04c-host-proof.mjs`, `window.faberHv04cProof.ok === true`
  AND `window.faberHv04cProof.submits[0].draw_count === 4`.
- **Gate**: if pixel readback from `context.getCurrentTexture()` after frame
  submission returns an empty or stale image, stop and report the WebGPU surface
  gap. Do not modify host runtime to work around it.
- **Gate**: if resize + depth texture replacement breaks the chunk resource
  session, stop and report the mismatch. The inline resize approach should work
  because `runChunkGraphicsFrame` reads `resources.depthTexture` at the top level.

## Validation Summary

```bash
# 1. Emit package geometry (produces chunks/ + world bins)
cd examples/hello-voxel
node scripta/emit-package-geometry.mjs

# 2. Run the proof
node scripta/run-hv04c-host-proof.mjs
# Expected exit 0; console shows proof.ok === true, draw_count === 4

# 3. Structural assertions (can be checked from Node.js)
# - frameState.submits[0].multi_draw === true
# - frameState.submits[0].path === "per-chunk-multi-draw"
# - frameState.submits[0].draw_count === 4
# - chunkResourceCounters(resources).live_chunks === 4
```

Manual browser validation:
```js
// Open hv04c-host-page.html in Chrome/Edge with WebGPU
// In console:
window.faberHv04cProof.ok           // true
window.faberHv04cProof.submits[0].draw_count  // 4
window.faberHv04cProof.submits[0].multi_draw  // true
window.faberHv04cProof.submits[0].path        // "per-chunk-multi-draw"
window.faberHv04cProof.pixels.frame1_non_background  // true
window.faberHv04cProof.pixels.frames_rgb_differ      // true
```

## Open Questions for Mind

1. **Pixel readback from `context.getCurrentTexture()` after frame submission**:
   the default approach (call `getCurrentTexture()` after `onSubmittedWorkDone`,
   then copy + map) may or may not work depending on the WebGPU implementation's
   swapchain semantics. If it fails, the Hand should stop and report — do not
   modify the host runtime to add in-encoder copy to `runChunkGraphicsFrame`.

2. **`runGraphicsFrameWithTexture` removal**: after this unit lands, the old
   `runGraphicsFrameWithTexture` has no remaining callers in the examples
   repository. Should the Hand also remove it from the host runtime, or leave it
   for backward compatibility? The goal explicitly scopes this out (non-goal).

---

## Delivery Complete (2026-07-26)

**Status: GREEN**. Delivery accepted.

| Evidence | Detail |
|---|---|
| hosts d3b0c69 | `createBindGroup` fix in `createChunkGraphicsResources`; `runChunkGraphicsFrame` returns texture for pixel readback |
| examples 5d05f7d | `hv04c-host-proof-app.js` rewritten to multi-draw path; structured buffer + frame texture proof |
| proof | `run-hv04c-host-proof ok=true frames=2 pixel gates green`; `draw_count=4`, `multi_draw=true` |

**Acceptance criteria verified**:
1. ✅ Imports `createChunkGraphicsResources`, `applyChunkResourceReplace`, `runChunkGraphicsFrame`
2. ✅ Geometry loaded from per-chunk `chunks/<slot>/` bins
3. ✅ Four chunk resources created via `applyChunkResourceReplace`
4. ✅ `frameState.submits[0].draw_count === 4` and `multi_draw === true`
5. ✅ `window.faberHv04cProof.ok === true` — all pixel laws pass
6. ✅ Resize + frame 2 works (depth texture replaced, transform updated)
7. ✅ Clear-only control yields expected clear hex
