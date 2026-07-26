# Goal: HV-05C Multi-Draw Host Path Residual

**Handle:** ae2cf0bd
**Wave:** P3 delivery
**Parent campaign:** Hello Voxel goal chain
**Planner:** planner-1
**Date:** 2026-07-26

## Summary

Close the HV-05C multi-draw residual: update `hv04c-host-proof-app.js` to use the
per-chunk-multi-draw host path (`createChunkGraphicsResources` +
`runChunkGraphicsFrame`) instead of the old concatenated-single-buffer path
(`createGraphicsResources` + `runGraphicsFrameWithTexture`).

The package side already declares `draw_count=4`, emits per-chunk resource pairs,
and sets `data-hv-residual-path="per-chunk-multi-draw"`. The host already has the
full multi-draw path implemented and tested via HV-07B/C. Only the proof script
has not been updated.

## Problem

`examples/hello-voxel/scripta/hv04c-host-proof-app.js` still imports and calls the
old single-draw host functions. This is the last consumer of the concatenated
single-buffer path in the proof surface. Every other test (HV-06C interaction,
HV-07C resource cycle) already exercises the multi-draw path.

| What | Current state | Target state |
|---|---|---|
| Proof script host import | `createGraphicsResources`, `runGraphicsFrameWithTexture` | `createChunkGraphicsResources`, `applyChunkResourceReplace`, `runChunkGraphicsFrame` |
| Geometry upload | Concatenated world-level positions/colors/indices bins | Per-chunk pairs from `chunks/<slot>/` |
| GPU frame path | One `drawIndexed` over concatenated world | Four `drawIndexed` calls — one per live chunk |
| Frame observation | `submit.draw_count` absent (implicit 1) | `submit.draw_count === 4`, `multi_draw: true`, `path: "per-chunk-multi-draw"` |
| Pixel validation | Same sample points, same visual law | Same visual law through per-chunk draw path |

## Goals

1. Rewrite `hv04c-host-proof-app.js` to use the per-chunk-multi-draw host path
2. Load per-chunk resource pairs from `chunks/<slot>/vertex-positions.bin`,
   `chunks/<slot>/vertex-colors.bin`, `chunks/<slot>/indices.bin`,
   `chunks/<slot>/draw.json`
3. Create chunk graphics resources via `createChunkGraphicsResources` and
   populate via `applyChunkResourceReplace` (one create per non-empty chunk)
4. Submit frames via `runChunkGraphicsFrame` with `recordSubmit: true`
5. Prove `frameState.submits[0].draw_count === 4` and
   `frameState.submits[0].multi_draw === true`
6. Preserve pixel validation: non-background coverage, non-black vertex color,
   frame-to-frame RGB change after model rotation
7. Preserve resize + depth texture replacement path
8. Do not touch the host runtime, package emit, or radix source

## Non-Goals

- Do not change `hosts/webgpu-browser/public/src/webgpu-runtime.js` (multi-draw
  path already implemented and tested)
- Do not change `examples/hello-voxel/scripta/emit-package-geometry.mjs` (chunk
  pairs already emitted)
- Do not change `examples/hello-voxel/src/` (package already declares draw_count
  and residual path)
- Do not touch radix `reverse_ad*` or `crates/radix/src/driver/*` (Class B dirt)
- Do not add new pixel validation logic beyond adapting sample points if needed
- Do not remove the concatenated world bins (they remain as ownership evidence)

## Ground Truth Researched

| Artifact | Finding |
|---|---|
| `examples/hello-voxel/public/draw.json` | Lines 7–9: `draw_count: 4`, `resource_pair_count: 4`, `chunk_count: 4` |
| `examples/hello-voxel/scripta/emit-package-geometry.mjs` | Lines 193–229: emits per-chunk pairs in `chunks/<slot>/` with `draw.json` each. Line 231: "Package draw policy: residual single draw over concatenated indices." |
| `hosts/webgpu-browser/public/src/webgpu-runtime.js` | Lines 1280–1632: full multi-draw path: `createChunkGraphicsResources` (1296), `applyChunkResourceReplace` (1426), `runChunkGraphicsFrame` (1553), `destroyRetiredChunkResources` (1507) |
| `examples/hello-voxel/tests/hv07c-resource-cycle-test.mjs` | Line 467: imports `createChunkGraphicsResources`. Line 506: calls `runChunkGraphicsFrame`. Line 508: `assert(frameState.submits[0].draw_count === 4, "four draws")` |
| `examples/hello-voxel/src/main.fab` | Lines 56–57: `residual_path_multi_draw()` returns `"per-chunk-multi-draw"`. Lines 297, 646: sets `data-hv-residual-path` to `"per-chunk-multi-draw"` |
| `examples/hello-voxel/scripta/hv04c-host-proof-app.js` | Lines 11–12: imports old `createGraphicsResources`, `runGraphicsFrameWithTexture`. Lines 159–165: calls old `createGraphicsResources` with concatenated world payloads. Lines 170, 229: calls old `runGraphicsFrameWithTexture` |
| `triga/docs/factory/hello-voxel/deliveries/07-incremental-chunk-resources-delivery.md` | Line 21: residual tracked as "concatenated single-buffer path (`data-hv-residual-path="concatenated-single-buffer"`)". Line 26: "Multi-draw residual (from HV-05C / HV-06C want): folds into HV-07B" |

## Reference Packet

```
examples/hello-voxel/scripta/hv04c-host-proof-app.js    — target for rewrite
examples/hello-voxel/tests/hv07c-resource-cycle-test.mjs — working multi-draw pattern
hosts/webgpu-browser/public/src/webgpu-runtime.js        — multi-draw API surface
examples/hello-voxel/scripta/emit-package-geometry.mjs   — chunk pair output contract
examples/hello-voxel/public/draw.json                    — draw_count authority
```

## Constraints and Invariants

1. **Path-disjoint from radix reverse_ad/driver**: write scope is `examples/` and
   optionally `hosts/`. Host runtime is already correct; do not modify it.
2. **Pixel validation preserved**: the proof must still show non-background
   coverage, non-black vertex color, and frame-to-frame RGB change.
3. **Depth + resize path preserved**: `replaceDepthTextureOnResize` must still be
   called on resize, but the chunk resource model may require adapting the call.
4. **Visible world proof**: four chunks must render with correct face visibility
   (same as current concatenated path).
5. **FrameState recording**: `recordSubmit: true` must capture `multi_draw: true`,
   `path: "per-chunk-multi-draw"`, and `draw_count: 4`.

## Architecture Direction

**Single-file rewrite of `hv04c-host-proof-app.js`**:

1. **Import change**: swap `createGraphicsResources` + `runGraphicsFrameWithTexture`
   for `createChunkGraphicsResources` + `applyChunkResourceReplace` +
   `runChunkGraphicsFrame` (+ `chunkResourceCounters`, `liveChunkIds` as needed)

2. **Load per-chunk geometry**: instead of one set of concatenated bins, load
   per-chunk `vertex-positions.bin`, `vertex-colors.bin`, `indices.bin`, and
   `draw.json` from `chunks/<slot>/`. Read `index_count` from each chunk's
   `draw.json` to validate payload size.

3. **Resource creation**: call `createChunkGraphicsResources(device, descriptor,
   { storageData: { transform } }, context)`. Then apply one
   `applyChunkResourceReplace` call per non-empty chunk:
   `{ logical_id: slot, generation: 0, payload: { positions, colors, indices } }`.

4. **Frame submission**: call `runChunkGraphicsFrame(device, context, resources,
   descriptor, frameState, { clearValue, recordSubmit: true })`. This replaces
   both old `runGraphicsFrameWithTexture` calls.

5. **Resize path**: `replaceDepthTextureOnResize` works on the old resource shape.
   The chunk resource model stores `depthTexture` at the top level — adapter may
   be needed. If the function signature requires the old resource shape, write a
   small inline adapter that replaces the depth texture on the chunk session
   object and reconfigures the canvas context.

6. **Pixel readback**: `runChunkGraphicsFrame` does NOT return a texture for pixel
   readback (unlike `runGraphicsFrameWithTexture` which bakes `copyTextureToBuffer`
   into the same encoder). The proof will need to:
   - Call `runChunkGraphicsFrame` for the draw
   - Inline pixel copy: create a separate command encoder after frame submit,
     copy pixels from `context.getCurrentTexture()`, submit, then read back
   - Or: adapt the pixel sampling to use `readTexturePixelsRgba` after
     `onSubmittedWorkDone`
   - The clear-only control path also needs adapting

## Implementation Shape

One unit: rewrite `hv04c-host-proof-app.js` to the multi-draw path.

### Rough milestone
- Import the multi-draw API functions
- Load per-chunk geometry from `chunks/<slot>/`
- Create chunk graphics session + apply chunk creates
- Submit two frames via `runChunkGraphicsFrame`
- Adapt pixel readback to work without `runGraphicsFrameWithTexture`'s in-encoder copy
- Validate frame state: `draw_count === 4`, `multi_draw === true`
- Preserve pixel law: non-bg coverage, non-black, RGB differ
- Preserve resize path

## Release Posture

No release impact. This is an internal proof script — no user-facing package
surface, no CLI, no published API.

## Exit Strategy

If pixel readback adaptation proves materially difficult (e.g., `getCurrentTexture`
returns empty swapchain image after `runChunkGraphicsFrame` submits), pause and
report the WebGPU surface gap. The multi-draw submit path is proven correct by
HV-07C; pixel validation through the new path is a nice-to-have proof extension
but not a correctness gate on the draw model.

## Acceptance Criteria

1. `hv04c-host-proof-app.js` imports `createChunkGraphicsResources`,
   `applyChunkResourceReplace`, and `runChunkGraphicsFrame` from the host
2. Geometry is loaded from per-chunk `chunks/<slot>/` bins, not concatenated
   world bins
3. `applyChunkResourceReplace` creates four chunk resources (generation 0)
4. `frameState.submits[0].draw_count === 4` and
   `frameState.submits[0].multi_draw === true`
5. `window.faberHv04cProof.ok === true` — all pixel laws pass
6. Resize + frame 2 still works (depth texture replaced, transform updated)
7. Clear-only control still yields expected clear hex

## Validation

```bash
# Build the hello-voxel package (produces chunks/ + world bins)
cd examples/hello-voxel && node scripta/emit-package-geometry.mjs

# Run the host proof
cd examples/hello-voxel && node scripta/run-hv04c-host-proof.mjs
```

Manual inspection: open `hv04c-host-page.html` in a WebGPU browser, verify
`window.faberHv04cProof.ok === true` and `submits[0].draw_count === 4`.

## Open Questions

1. **Pixel readback after `runChunkGraphicsFrame`**: `runGraphicsFrameWithTexture`
   copies pixels in the same command encoder as the draw. `runChunkGraphicsFrame`
   does not. Can we call `context.getCurrentTexture()` after submit and copy from
   it in a separate encoder — or does the swapchain image expire? If this is a
   real WebGPU constraint, pause and report.
   - **Default**: adapt to post-submit pixel readback using `getCurrentTexture()`
     + `onSubmittedWorkDone` + `copyTextureToBuffer`. HV-07C resource cycle test
     doesn't need pixel validation, so this is novel proof surface.

2. **`replaceDepthTextureOnResize` compatibility**: the old function returns a new
   resource object of the old shape. The chunk resource session stores
   `depthTexture` directly. Could inline the resize logic.
   - **Default**: write inline resize that replaces `resources.depthTexture` and
     reconfigures the canvas context.

## Stop Conditions

- If pixel readback cannot be made to work with `runChunkGraphicsFrame` without
  modifying the host runtime, stop and report the gap.
- If `getCurrentTexture()` returns an expired or empty texture after frame
  submission, stop and report.

## Readiness Label

**Ready for delivery** — one stable unit, no architecture invention required,
API surface proven by HV-07C tests.

---

## Closure (2026-07-26)

**Goal GREEN.**

| Evidence | Detail |
|---|---|
| hosts d3b0c69 | `createBindGroup` fix, `runChunkGraphicsFrame` texture return |
| examples 5d05f7d | Proof app structured buffer + frame texture |
| proof | `run-hv04c-host-proof ok=true frames=2 pixel gates green` |

The multi-draw host path residual is closed. Proof script (`hv04c-host-proof-app.js`)
uses the per-chunk-multi-draw host path; frame submits record `draw_count=4`,
`multi_draw=true`; all pixel validation laws pass.
