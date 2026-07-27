# HV-04C Delivery: Host Graphics Storage Update Operation (Extracted Unit)

**Parent goal**: [`../goals/04-indexed-cube-crossover.md`](../goals/04-indexed-cube-crossover.md)
**Parent delivery**: [`04-indexed-cube-crossover-delivery.md`](04-indexed-cube-crossover-delivery.md)
**Factory admission**: READY — HV-02 and HV-04A complete on tip
**Primary repo**: `hosts`
**Write scope**: `hosts/webgpu-browser/public/src/webgpu-runtime.js` plus host tests under `hosts/webgpu-browser/`
**Re-grounded**: 2026-07-26 (planner-1 lowering from Vivi task `1f9489a7`)
**Status**: HV-04C-A complete on hosts main tip (`9cdd3c9`).
  `updateGraphicsStorage` exported; 7 focused test cases pass
  (`graphics-storage-update-check.mjs`); `product-boundary-check.mjs`
  still passes. Audit: CLEAN PASS (auditor-1, need `cd407db8`).

## Interpreted Unit

Extract the public, reflection-addressed graphics storage update operation from
Hello Voxel Goal 04 into a standalone, reusable host capability. The operation
resolves a declared graphics storage resource from admitted reflection,
validates input-role and byte bounds before any queue effect, and uses
`device.queue.writeBuffer` to update the resource before submission. It is
**generic** — no cube-specific, application-specific, or Hello-Voxel-specific
names, fields, or behavior — so a different campaign can substitute its own
Faber-authored workload.

This unit is **not** the full HV-04C visible proof. It ships only the host
operation and its focused tests. The Hello Voxel HV-04C gate remains open after
this unit completes; the two-frame pixel proof belongs to the remaining HV-04C
work that consumes this operation.

## Normalized Spec

Add one exported function `updateGraphicsStorage` to `webgpu-runtime.js`:

1. **Resolve by reflection**. Accept `resources` (the frozen object returned by
   `createGraphicsResources`), whose `storageBuffers` Map is keyed by
   `resourceIndex`. Accept a `descriptor` with `resourceIndex` (number) and/or
   `sourceName` (string). When `sourceName` is given, scan the admitted
   `descriptor.bindGroups` entries to find the matching `resourceIndex`. Reject
   unknown resources with a `FaberKernelContractError` before any queue effect.

2. **Validate input role**. Scan `descriptor.bindGroups` entries for the
   resolved `resourceIndex`. If no entry has `role === "input"`, reject with a
   `FaberKernelContractError` before any queue effect. Non-input resources
   (output, uniform, or absent) are rejected.

3. **Validate byte bounds**. Accept a `data` payload (expected `Float32Array`,
   matching the existing host contract at line 1620-1623 of
   `writeGraphicsStorageInput`). Reject writes where `data.byteLength >
   entry.bufferByteLen` with a `FaberKernelContractError` before
   `GPUQueue.writeBuffer`.

4. **Write to the GPU buffer**. Call `device.queue.writeBuffer` with the
   resolved `storageBuffers` entry's `.buffer`, offset `0`, and the validated
   `data`.

5. **Increment generation**. Advance the `generation` counter on the
   `storageBuffers` entry so callers can detect updates (consistent with the
   existing `generation` field at line 1608).

6. **Return a frozen status object** `{ status: 0, resourceIndex, generation }`
   for caller-observable evidence.

The operation does **not** create buffers, bind groups, pipelines, or encoders.
It does not submit work to the queue. It writes data to an existing buffer;
submission is the caller's responsibility (typically before `runGraphicsFrame`).

## Repo-Aware Baseline

### Host gap (verified against live source)

- **`createGraphicsResources`** (line 1127–1192): creates `storageBuffers` via
  the private `createStorageBuffers` and returns them in a frozen object. It
  initializes input-role buffers once via `mappedAtCreation`. After creation,
  `storageBuffers` is a read-only Map for external callers.

- **`createStorageBuffers`** (line 1585–1614): private function (no `export`
  keyword). Creates input-role buffers with `mappedAtCreation: true` and writes
  initial data via `writeGraphicsStorageInput`. Returns a
  `Map<number, {buffer, generation, logicalId}>`.

- **`writeGraphicsStorageInput`** (line 1617–1635): private. Validates
  `Float32Array` type and `byteLength ≤ bufferByteLen`, then copies through
  `getMappedRange`. This is the only existing path that writes to graphics
  storage — and it only runs at creation time.

- **`placementCopyIn`** (line 596–611): operates on `resources.buffers`
  (compute resource Map), **not** `resources.storageBuffers` (graphics storage
  Map). It uses `device.queue.writeBuffer` but targets compute buffers. It
  cannot update a graphics storage buffer.

- **`runGraphicsFrame`** (line 1203): submits the render pass and increments
  `frameState.submittedFrameCount`. It reads `storageBuffers` through
  bind groups but does not write to them.

- **Conclusion**: No exported function updates a graphics storage buffer after
  creation. The gap is real and narrow: one `device.queue.writeBuffer` call
  against the correct Map with role and bounds validation before effects.

### Reflection shape (admitted by the existing descriptor)

The `descriptor` passed to `createGraphicsResources` has a `bindGroups` array.
Each group has `entries`, and each entry has:

| Field | Type | Meaning |
| --- | --- | --- |
| `resourceIndex` | `number` | Key into `storageBuffers` Map |
| `role` | `string` | `"input"`, `"output"`, or absent |
| `sourceName` | `string\|null` | Source-local name from reflection |
| `bufferByteLen` | `number` | Declared buffer size in bytes |
| `binding` | `number` | WGSL binding index |

The existing HV-02 generated `graphics-reflection.json` declares one input
storage resource (`role: "input"`, `source_name: "transform"`,
`resource_index: 0`, `buffer_byte_len: 256`). This is the transform payload
from the 32-float, 128-byte HV-04A contract (model + view-projection).

### Existing test pattern

Host tests follow the `product-boundary-check.mjs` pattern: Node.js + fake
device stubs. The fake device pattern from `placement-contract-oracle.mjs`
(lines 181–375) is the reference: it stubs `createBuffer`, `queue.writeBuffer`,
`createShaderModule`, etc., and tracks buffer state through a `Map<number,
{backing, mapped, size, usage, destroyed}>`. The new tests will reuse this
pattern against the HV-02 static indexed-render reflection fixtures already in
`hosts/webgpu-browser/public/generated/`.

### Dependencies (all complete on tip)

- **HV-02**: reflection-driven static indexed render — `168edcb`, `5b77ef8`,
  `cb3fbde` on hosts main tip. Provides `createGraphicsResources` (the
  `resources` object), `runGraphicsFrame`, and the generated reflection
  fixtures.
- **HV-04A**: Triga transform-payload contract (32-float, 128-byte model-then-
  view-projection) — complete. Establishes the reflection shape for the
  transform storage resource the new operation will update.

## Stage Graph

### HV-04C-A — Host Graphics Storage Update Operation

**Depends on**: HV-02 and HV-04A (complete on tip)
**Output**: one public function `updateGraphicsStorage` added to `webgpu-runtime.js`.
**Write scope**: `hosts/webgpu-browser/public/src/webgpu-runtime.js` (single
function appended before the per-chunk lifecycle section at line ~1638).
**Gate**: focused host tests pass:
  1. Successful reflected storage update (by `resourceIndex` and by `sourceName`).
  2. Unknown resource rejection (invalid `resourceIndex`, unknown `sourceName`).
  3. Non-input resource rejection (output-role entry).
  4. Out-of-bounds write rejection (`data.byteLength > bufferByteLen`).
  All rejections must fire before any `device.queue.writeBuffer` or
  `device.queue.submit` call.
**Evidence**: test file at `hosts/webgpu-browser/public/src/graphics-storage-update-check.mjs`
(Naming deferred to implementor; must be `.mjs` sibling of
`product-boundary-check.mjs`).
**Non-goals**: No browser render, no pixel evidence, no cube application, no
Faber-authored transform payload. Tests use hand-constructed `Float32Array`
data against the HV-02 generated reflection fixtures.

## Implementation Work

| Unit | Done when | Non-goals |
| --- | --- | --- |
| HV-04C-A | `updateGraphicsStorage` exported; four focused tests pass | No visible proof, no cube app, no end-to-end render |

Only one unit: one function plus its focused tests. This is a coherent vertical
slice of the host operation alone.

## Checkpoints And Gates

- **Checkpoint**: The host operation is reusable by a different campaign.
  Hello Voxel HV-04C visible proof stays open.
- **Batching / Split Decision**: one batch — the function and its tests ship
  together. No further split. The visible-proof portion of HV-04C (browser
  render with two-frame pixel evidence) is a separate unit that consumes this
  operation.
- **Release decision**: `defer-release`. This is an internal host capability
  addition. No user-visible release artifact.
- **Honest partial progress**: HV-04C in the Hello Voxel campaign does NOT
  fully close when this unit ships. The host operation ships and becomes
  reusable; the Hello Voxel visible-proof gate stays open. The remaining
  HV-04C work (HV-04B cube application + two-frame pixel proof) is a separate
  implementation unit.

## Validation

- Run `node hosts/webgpu-browser/public/src/graphics-storage-update-check.mjs`.
- Verify the existing `product-boundary-check.mjs` still passes (the new export
  must not break existing boundary checks — add an export-existence assertion
  in that check, or keep it separate and validate in the new check file).
- No browser GPU required. Fake-device stubs sufficient.
- No pixel or canvas evidence required.

## Companion Skill Plan

- `polish`: `hosts/webgpu-browser/public/src/webgpu-runtime.js` (new function
  only — single-pass cleanup of the added code).
- `correctness`: resource-index resolution, role validation ordering (reject
  before `writeBuffer`), generation increment on success, byte-bounds check
  before queue effects.

## Open Questions

None blocking. The operation is narrow, the gap is verified, the reflection
shape is stable, and the test pattern is established.

### Explicitly Out Of Scope

- HV-04B (Faber cube application).
- The visible two-frame pixel proof portion of HV-04C.
- End-to-end Faber→WebGPU visible rendering evidence.
- Adding tests to `product-boundary-check.mjs` (the new operation gets its own
  focused check file; the existing boundary check may add an export-existence
  assertion if the implementor prefers, but that is not required).
- Any voxel, chunk, or Goal 05+ work.
