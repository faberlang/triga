# Goal 04: Graphics MIR And Shader Stages

**Status**: in progress — Radix graphics MIR now covers vertex and fragment
WGSL entry contracts, typed interstage varyings with cross-stage compatibility
validation, a graphics pipeline reflection seam (color targets, topology,
depth/stencil with stencil masks, vertex count), and multi-target fragment
output emission. Remaining: source-level MIR lowering from
@vertex/@fragment annotations and full resource reflection in pipeline
context.
**Campaign**: [`../CAMPAIGN.md`](../CAMPAIGN.md)
**Target repo**: `radix`; `triga` and `examples` provide the forcing workloads
**Depends on**: Goals 00–01 and the Goal 03 vertex attribute contract
**Related authority**: MIR GPU Goal 08, shader-stage model
**Lowers to**: `delivery` → `factory`
**Batching posture**: discovery-first

## Purpose

Reopen the existing deferred MIR GPU shader-stage track with concrete Triga
requirements, extending the compute-only GPU foundation into typed graphics
pipelines without embedding rendering behavior in emitters.

## Invariant

Shader stage, stage IO, builtins, resources, layouts, and pipeline facts are
typed above WGSL emission; the emitter prints admitted MIR and the host consumes
compiler reflection without reconstructing intent.

## Scope

- Update the existing MIR GPU campaign/ledger rather than creating a parallel
  shader-stage architecture.
- Select the smallest source-level surface for vertex and fragment entrypoints
  using existing annotations and types unless a separate language decision
  proves new syntax necessary.
- Represent vertex inputs, instance inputs, varyings/interpolation, builtins,
  fragment outputs, uniforms, storage resources, textures, samplers, depth, and
  render-target formats as shared typed facts.
- Extend device legality, MIR lowering, WGSL emission, diagnostics, reflection,
  and target capability reporting for the admitted graphics subset.
- Produce pipeline-layout, vertex-buffer, color/depth target, primitive-state,
  and draw-facing reflection needed by a host without describing browser
  lifecycle inside MIR.
- Require a systems-target impact matrix for LLVM, Wasm/scena, frozen Metal,
  CUDA, and unsupported paths.

Out of scope: scene traversal, browser adapter/device acquisition, material
graph completeness, production web packaging, and a general shader DSL.

## Gate

- One Faber fixture lowers to typed vertex and fragment MIR and valid WGSL.
- Reflection fully describes stage IO, vertex layouts, resources, pipeline
  targets, and draw prerequisites required by Goal 05.
- Mismatched varyings, unsupported types, illegal resources, missing outputs,
  and target-incompatible capabilities fail before emission.
- Existing compute kernels and reflection remain valid or migrate by a clean,
  explicitly recorded contract change.
- The MIR GPU Stage 8 artifact and progress ledger reflect the implementation
  state and next blocker.

## Progress

- Triga's structure-of-arrays attribute contract carries an explicit shader
  location and rejects duplicate locations before reflection or upload.
- `attribute_vertex_layout` exposes the declared location, typed scalar/vector
  format, zero byte offset, derived byte stride, and per-vertex step mode as the
  CPU comparison seam for the first Radix reflection fixture.
- `geometry_vertex_layouts` exposes the complete ordered vertex-buffer contract
  only for valid geometry, without requiring reflection or the host to inspect
  attribute names.
- Triga vertex/layout contract v1 is complete; the remaining Stage 4 work is
  owned by the Radix graphics MIR handoff.
- `geometry_vertex_layout_location`, `geometry_vertex_layout_format_code`,
  `geometry_vertex_layout_offset_bytes`, and
  `geometry_vertex_layout_stride_bytes` provide provider-friendly scalar access
  to source-owned layout facts without exposing `VertexFormat` as a direct
  provider-interface parameter; `geometry_vertex_layout_matches` packages the
  same facts as an executable Triga-side acceptance predicate.
- `exempla/triga-stage4-source-facts.fab` is the Triga-owned Stage 4 handoff
  fixture: it fixes the source-side position/normal/uv locations, format codes,
  offsets, and strides that Radix reflection must match.
- Current material source facts remain in `src/triga.fab`: material side,
  transparency, opacity, alpha test, depth test/write, base color, roughness,
  metalness, emissive color, and emissive intensity. These are Stage 6 shader
  inputs, not Stage 4 shader-lowering claims.
- Fragment stage variant added to `MirKernelShaderStage`; minimal
  `emit_wgsl_fragment_entry_contract` emits a solid-color `@fragment` entry with
  fail-closed rejection for compute and vertex stages, and vertex entry now also
  rejects fragment reflection.
- Varying/interstage IO (radix `6a93ac2e4`): `MirVaryingReflection` connects
  vertex output to fragment input through typed `@location(N)` members with
  `v_` prefix and pass-through from matched vertex inputs. Both vertex and
  fragment emitters validate unique varying locations.
- Cross-stage varying compatibility (radix `7a4c44809`):
  `validate_varying_compatibility(vertex, fragment)` checks bijective
  location/name/format agreement; mismatched varyings fail before emission.
- Graphics pipeline reflection (radix `0b2282c35`):
  `MirGraphicsPipelineReflection` carries color target formats, primitive
  topology, vertex count, vertex input count, and varying count — the
  draw-prerequisite seam consumed by Goal 05.
- Depth/stencil state (radix `5eaee949b`):
  `MirDepthStencilState { depth_write_enabled, depth_compare }` with
  `MirDepthCompareFunction` (8 variants). Optional via `.with_depth_stencil()`
  builder; defaults to `None`.
- Multi-target color attachments (radix `c4a29f425`):
  `graphics_pipeline_reflection` accepts `color_targets: &[MirColorTargetFormat]`;
  fail-closed for empty.
- Varying compatibility in pipeline constructor (radix `c4a29f425`):
  `graphics_pipeline_reflection` now calls `validate_varying_compatibility`
  internally — mismatched vertex/fragment varyings fail before pipeline creation
  (resolves CXO `a627e820` bullet 1).
- Multi-location fragment WGSL emission (radix `1ba3a660d`):
  `emit_wgsl_fragment_entry_contract_with_targets(reflection, count)` emits
  `@location(N) color_N` per target. Single-target `emit_wgsl_fragment_entry_contract`
  delegates with count=1 (byte-identical output). Fail-closed on zero targets.
- Host-configurable topology (radix `d7f633b3d`):
  `.with_topology()` builder overrides default `TriangleList`.
- Remaining Stage 4 gate items: MIR lowering from Faber `@vertex`/`@fragment`
  annotations (reflection is test-constructed, not source-lowered); combined
  pipeline-layout descriptors with stage visibility (resource counts are now
  surfaced on `MirGraphicsPipelineReflection` via `vertex_resource_count` /
  `fragment_resource_count` (radix `e55263119`); full bindings remain on
  per-stage `launch_plan()`).

## Gate Check (2026-07-18)

Stage 4 is **not complete**. The gate is not met because source-level MIR
lowering from `@vertex`/`@fragment` annotations does not exist — all
reflection and WGSL emission is test-constructed, not lowered from Faber
source. The reflection and WGSL emission subset is closed; source lowering
and full resource integration remain.

| Gate item | Status | Evidence |
| --- | --- | --- |
| Faber fixture lowers to typed vertex + fragment MIR and valid WGSL | **OPEN** | Reflection is test-constructed; no MIR lowering from `@vertex`/`@fragment` source. WGSL validates with naga when available. |
| Reflection describes stage IO, vertex layouts, resources, pipeline targets, draw prerequisites | **PARTIAL** | Stage IO (varyings), vertex layouts (inputs), pipeline targets (color formats), draw prerequisites (topology, vertex count, depth/stencil) are done. Resource counts surfaced on pipeline reflection (`e55263119`); full bindings remain on per-stage `launch_plan()`. Combined pipeline-layout descriptors with stage visibility are a future unit. |
| Mismatched varyings, unsupported types, illegal resources, missing outputs fail before emission | **PARTIAL** | Varying mismatch fails via `validate_varying_compatibility` and pipeline constructor. Duplicate locations, wrong stages, empty inputs/targets fail closed. Unsupported types and illegal resources in graphics context not yet tested. |
| Existing compute kernels and reflection remain valid | **MET** | Compute WGSL emission, ABI, and launch plan unchanged. Graphics types are additive. |
| MIR GPU Stage 8 artifact and progress ledger reflect state | **MET** | This goal doc and CAMPAIGN.md are current. |

**Closed reflection subset:** vertex/fragment WGSL entry contracts, interstage
varyings with cross-stage validation, pipeline reflection (color targets,
topology, depth/stencil with stencil read/write masks and per-face ops,
vertex count), and fail-closed stage/target/input validation.

**Open residual owners:**
- Source-level MIR lowering (Radix — blocks gate item 1)
- Combined pipeline-layout descriptors with stage visibility (Radix —
  resource counts partial `e55263119`; full bindings on per-stage `launch_plan()`)

## Stop Conditions

- Vertex/fragment code is added as special cases inside the compute emitter.
- The host must parse WGSL or know Triga field names to build a pipeline.
- Shader-stage syntax is invented inside a delivery spec without language
  approval and EBNF/reader/exemplar work.
- Only WGSL behavior is considered for a shared MIR change.
