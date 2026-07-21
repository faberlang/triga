# HV-02 Delivery: Reflection-Driven WebGPU Graphics Host

**Parent goal**: [`../goals/02-direct-webgpu-graphics-host.md`](../goals/02-direct-webgpu-graphics-host.md)
**Campaign**: [`../CAMPAIGN.md`](../CAMPAIGN.md)
**Primary repo**: `hosts` (sibling monorepo at the container root; **not** under `radix`)
**Depends on**: HV-01 (verified producing artifacts 2026-07-21; see Cross-Goal Dependency)
**Factory admission**: READY for HV-02A after the draw-fact source decision below
**Last grounded**: 2026-07-21 (head-ceo pass against a fresh `faber` build and live reflection)

## Grounding Note (read first)

This spec replaces the 2026-07-19 draft. The 2026-07-21 pass rebuilt `faber`
from current `radix` HEAD (`98db3a504`, which includes `cc75ccc4a` and
`50d300b98`) and emitted the HV-01 exemplar
`triga/exempla/triga-hello-voxel-shaders.fab` directly. All reflection fields
cited below were read from that live output, not from prose.

Two corrections to the prior draft and the goal doc are grounded here:

1. **Host path.** The browser product lives at `hosts/webgpu-browser/`, a
   sibling monorepo. The goal doc's `radix/hosts/webgpu-browser/` path is
   stale. Every write path in this spec uses the correct container-relative
   path `hosts/webgpu-browser/`.
2. **Reflection adapter shape is shared.** The graphics reflection emits the
   same `launch.webgpu_adapter` descriptor shape (`pipeline_layout_descriptor`,
   `bind_group_layout_descriptors`, `bind_group_descriptors`) that the compute
   proof already parses. HV-02A therefore generalizes the existing compute
   parser instead of writing a parallel graphics parser.

## Interpreted Unit

Extend the existing browser WebGPU product from compute-only dispatch to one
reflection-driven indexed graphics render path, without adding a second host,
a second renderer, or any scene/material/voxel/draw policy in JavaScript.

The host owns WebGPU lifecycle only: device, canvas context, shader modules,
layouts, pipeline, buffers, depth target, render pass, resize, and device loss.
Shader, scene, material, geometry-layout, and draw policy come from generated
reflection and explicit payloads.

## Normalized Spec

- Admit the HV-01 graphics reflection and payloads beside the compute
  descriptor, without weakening existing compute admission.
- Consume vertex inputs, the transform binding, color target, primitive
  topology, depth state, and pipeline layout from reflection.
- Consume vertex, index, and transform data from explicit generated payload
  artifacts. Derive `index_count` from the index payload byte length.
- Create the render pipeline, vertex buffers, index buffer, transform buffer,
  depth texture, and bind groups from the admitted descriptor.
- Encode and submit one indexed render pass to a `bgra8unorm` canvas backed by
  a `depth24plus` target.
- Handle physical canvas resize (replace and destroy the depth texture), canvas
  format mismatch (fail with `kind=webgpu`), device loss, stale artifacts, and
  malformed descriptors.
- Expose `window.faberWebGpuGraphicsProof` with artifact identity, pipeline
  admitted state, submitted frame count, and structured failure kind.
- Preserve the existing compute add-one proof through shared runtime code; do
  not duplicate the compute runtime.

## Repo-Aware Baseline

All paths are container-relative. The product lives in the `hosts` sibling
monorepo.

### Existing host modules (extend, do not duplicate)

| Module | Current role | HV-02 change |
| --- | --- | --- |
| `hosts/webgpu-browser/public/src/app.js` | Imports `three/webgpu`; fetches compute artifacts; runs the compute kernel; sets `window.faberWebGpuProof` | Add a graphics entry that fetches graphics artifacts, admits the descriptor, and runs the render loop. Keep the compute proof or replace it with a shared-runtime equivalent. |
| `hosts/webgpu-browser/public/src/faber-kernel.js` | Pure compute descriptor parser/validator. Hardcodes `shader_visibility: "compute"` (`parseLayoutEntry`, `parseBindGroupEntry`) and `kernels.length === 1` | Generalize visibility to per-stage `vertex`/`fragment` from reflection. Admit two kernels (vertex + fragment) plus the `pipeline` block. Add a `loadGraphicsPipeline` path beside `loadFaberKernel`. Do not weaken the compute path. |
| `hosts/webgpu-browser/public/src/webgpu-runtime.js` | `acquireWebGpuDevice`, `createWebGpuResources`, `runKernel`, buffer/bind-group/pipeline-layout creation. Compute-only dispatch | Reuse `acquireWebGpuDevice` and buffer/bind-group helpers where ownership is identical. Add render pipeline, vertex/index buffers, depth texture, render pass, resize, and device-loss behavior in a focused graphics sibling or extended module. |
| `hosts/webgpu-browser/public/src/product-boundary-check.mjs` | Pure Node boundary tests for the compute contract | Add graphics descriptor admission, unsupported-environment, stale-artifact, and malformed-descriptor cases. Static checks must not claim GPU execution. |
| `hosts/webgpu-browser/public/faber-webgpu-product.json` and `public/generated/` | Compute artifact manifest and `kernel.wgsl` + `reflection.json` | Add graphics manifest entries and generated vertex/fragment WGSL, graphics reflection, and vertex/index/transform payloads. |
| `hosts/scripta/webgpu-browser-proof` | Bash script: `generate \| check \| serve`. Builds `radix` bin, emits `fixtures/add-one.fab` to `public/generated/` | Extend `generate` to also emit the HV-01 graphics exemplar artifacts and payloads. Preserve the static-check vs manual/browser-GPU split. |

### Verified HV-01 artifact shape (read from live reflection)

The HV-01 exemplar emits (confirmed 2026-07-21 against a fresh build):

- **WGSL**: one module containing `@vertex fn hello_voxel_vertex` and
  `@fragment fn hello_voxel_fragment`. Vertex output is builtin `position` plus
  a `@location(0) @interpolate(perspective) color: vec3<f32>` varying. Fragment
  output is `@location(0) color: vec4<f32>` with alpha `1.0`.
- **Reflection `kernels`**: two entries, `shader_stage: vertex` and
  `shader_stage: fragment`.
- **Vertex inputs**: `position` location 0 `float32x3` stride 12; `color`
  location 1 `float32x3` stride 12. Both `step_mode: vertex`.
- **Transform binding**: group 0 binding 0, `storage-buffer`, role `input`,
  access `read`, `buffer_binding_type: read-only-storage`,
  `buffer_byte_len: 256` (64 `f32`). The host allocates and uploads exactly the
  reflected byte length.
- **Pipeline block**: `color_target_formats: ["bgra8unorm"]`,
  `primitive_topology: "triangle-list"`, `vertex_count: 36`,
  `depth_stencil: { depth_write_enabled: true, depth_compare: "less", ... }`.
- **Adapter descriptor**: identical shape to the compute adapter
  (`pipeline_layout_descriptor`, `bind_group_layout_descriptors`,
  `bind_group_descriptors`) with `visibility: vertex`/`fragment`.

### Payload artifacts (generated by the proof script)

- **vertex payload**: structure-of-arrays position then color, 36 vertices,
  24 bytes per vertex (12 position + 12 color). Byte count is an oracle from
  Triga geometry facts; the host uploads the reflected stride × vertex count.
- **index payload**: `u32` indices, 36 entries, 144 bytes. The host derives
  `index_count = indexByteLen / 4`.
- **transform payload**: 256 bytes (the reflected `buffer_byte_len`), holding
  the column-major model matrix then the column-major view-projection matrix.

## Cross-Goal Dependency (HV-01 draw reflection)

The HV-01 goal Gate requires reflection to carry indexed-draw fields — index
format, index count, first index, base vertex, instance count — and states that
no host default supplies these values. The live reflection does **not** yet
carry them. It carries `pipeline.vertex_count: 36` only.

Triga source already owns these facts: `geometry.GeometryDrawCommand` carries
`index_count`, `instance_count`, `base_vertex`; the first-draw facts file locks
`base_vertex ≡ 0` and `instance_count ≡ 1`; indices are `u32`.

HV-02 resolves this without putting draw policy in the runtime host:

- `index_count`: derived from the index payload byte length. This is explicit
  artifact consumption, not inference.
- `index_format`, `instance_count`, `base_vertex`, `first_index`: consumed from
  a generated **draw manifest** emitted by `scripta/webgpu-browser-proof` from
  Triga draw-command facts. The runtime host reads them; it does not choose
  them.

**Decision required (default below).** Either (a) HV-01 completes draw
reflection and the host reads these fields from `pipeline`, or (b) the proof
generator emits a `draw.json` manifest and the host consumes it. Default: **(b)
draw manifest**, because it keeps the runtime host free of draw policy and does
not block HV-02 on further Radix reflection work. If Mind prefers (a), HV-02A
shrinks and HV-01 reopens for draw-reflection extraction.

## Stage Graph

### HV-02A - Graphics Descriptor Admission

**Output**: a pure parser/validator for the HV-01 graphics reflection, payload
manifest, and draw manifest, with typed error paths and no WebGPU effects.
**Write scope**: `hosts/webgpu-browser/public/src/faber-kernel.js` (or a focused
graphics-admission sibling) and Node tests in `product-boundary-check.mjs`.
**Gate**: every required reflection and payload field is consumed or rejected;
unknown/missing values reject with a typed kind; vertex and fragment visibility
admit; compute descriptor tests remain green.
**Non-goals**: no WebGPU device, buffer, or pipeline effects.

### HV-02B - WebGPU Graphics Effects

**Depends on**: HV-02A
**Output**: render pipeline, vertex/index/transform buffers, depth texture,
bind groups, indexed render pass, resize depth replacement, device-loss
handling, and submitted-frame accounting, all driven by the admitted descriptor.
**Write scope**: `hosts/webgpu-browser/public/src/webgpu-runtime.js` or a
focused graphics-effects sibling plus Node runtime tests.
**Gate**: one indexed render pass submits from admitted descriptors with no
third-party renderer import; resize replaces and destroys the depth texture;
device loss is reported with a structured kind.
**Non-goals**: no scene, camera, voxel, material, or draw-policy logic.

### HV-02C - Product Harness And Evidence

**Depends on**: HV-02B
**Output**: generated graphics WGSL, reflection, payloads, and draw manifest;
product manifest entries; extended `scripta/webgpu-browser-proof`
`generate`/`check`/`serve`; browser proof state; serve instructions.
**Write scope**: host manifest/page/app, generated fixtures, proof script, docs.
**Gate**: static checks distinguish themselves from actual GPU execution; a
browser run records a submitted graphics frame on
`window.faberWebGpuGraphicsProof`; a bounded source scan finds no third-party
renderer import in the graphics modules.
**Non-goals**: no final three.js removal (that is Goal 08).

## Implementation Work

| Unit | Done when | Non-goals |
| --- | --- | --- |
| HV-02A | Graphics reflection, payloads, and draw manifest admit or reject deterministically; compute admission unchanged | No WebGPU effects |
| HV-02B | An indexed render submits from admitted descriptors; resize and device loss have focused evidence | No scene/game logic; no draw policy |
| HV-02C | Product generation and proof are reproducible; static vs GPU evidence is separated | No three.js cleanup |

Pure parser tests (HV-02A) can proceed in parallel with payload/manifest
generation once the schema is fixed. HV-02B is serialized after HV-02A. HV-02C
is serialized after HV-02B.

## Checkpoints And Gates

- **Checkpoint**: direct indexed graphics submission is available to HV-04.
- **Batching / Split Decision**: split parser (HV-02A), WebGPU effects
  (HV-02B), and product proof (HV-02C) at the validation/effect boundary.
  Within HV-02B, batch descriptor-family resource creation after the first
  pipeline pattern passes.
- **Release decision**: `defer-release`. No release is implied. A Faber-authored
  visible application does not exist until HV-04; three.js removal waits for
  HV-08.
- **Proxy-success bar**: a canvas clear, device acquisition, or pipeline
  creation reported without an executed indexed render pass does not pass.

## Validation

- `node hosts/webgpu-browser/public/src/product-boundary-check.mjs` (static
  admission, malformed descriptor, stale artifact, unsupported environment).
- New graphics descriptor and runtime Node tests beside the compute tests.
- `./scripta/webgpu-browser-proof check` (artifact freshness and static checks).
- `./scripta/webgpu-browser-proof serve`, then a WebGPU-capable browser
  assertion on `window.faberWebGpuGraphicsProof` (submitted frame count > 0).
- Bounded source scan for third-party renderer imports in the graphics modules
  (the graphics path must import no renderer).

## Companion Skill Plan

- `red-green`: descriptor admission, unsupported-environment, stale-artifact,
  and malformed-descriptor cases.
- `correctness`: buffer sizes against reflected byte lengths, depth replacement
  on resize, submission ordering, device-loss reporting.
- `cleanliness`: keep pure admission (`faber-kernel.js`) separate from browser
  effects (`webgpu-runtime.js`); no duplicate compute runtime.
- `polish`: modified JavaScript, the proof script, the manifest, and primary
  docs.

## Open Questions

1. **Separate WGSL files vs one combined module.** The compiler emits one WGSL
   module with both `@vertex` and `@fragment` entrypoints. WebGPU consumes this
   natively via per-stage `entryPoint`. The goal doc says "separate vertex and
   fragment WGSL artifacts." Default: consume one combined module and reference
   entrypoints by name from reflection (avoids WGSL parsing). If Mind requires
   two files, HV-01 or the proof generator must split emission.
2. **Draw-fact source (see Cross-Goal Dependency).** Default: generated
   `draw.json` manifest. Alternative: HV-01 completes draw reflection.
3. **Transform buffer byte length.** Reflection reports 256 bytes (64 `f32`);
   the locked prose contract says 128 bytes (32 `f32`). The host consumes the
   reflected value as truth. Flag for HV-01 to reconcile prose vs reflection.
4. **Compute proof disposition.** Keep the compute add-one proof alongside
   graphics, or replace it with a shared-runtime compute proof. Default: keep
   both through shared runtime primitives; do not duplicate.
5. **Browser automation availability.** Actual WebGPU pixel/pointer evidence
   depends on a repeatable browser surface. Record unavailable execution
   honestly; static checks cannot substitute for the render-pass result.
