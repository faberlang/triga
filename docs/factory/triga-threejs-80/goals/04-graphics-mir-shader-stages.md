# Goal 04: Graphics MIR And Shader Stages

**Status**: in progress — Triga vertex/layout contract v1 is complete with
unique shader locations and ordered CPU-side location/format/offset/stride/step
reflection facts; handoff is now to Radix Stage 4 graphics MIR, reflection
agreement, shader stages, and host consumption
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
- Next residual: lower one matching vertex input through graphics MIR and prove
  emitted reflection agrees with these facts without inspecting attribute names.
- Fragment stage variant added to `MirKernelShaderStage`; minimal
  `emit_wgsl_fragment_entry_contract` emits a solid-color `@fragment` entry with
  fail-closed rejection for compute and vertex stages, and vertex entry now also
  rejects fragment reflection. Varying/interstage IO and typed color-target
  formats are follow-on work.
- Remaining Stage 4 gate items: typed vertex/fragment IO (varyings), pipeline
  reflection for resources and draw prerequisites, and fail-closed WGSL for
  unsupported type/resource combinations.

## Stop Conditions

- Vertex/fragment code is added as special cases inside the compute emitter.
- The host must parse WGSL or know Triga field names to build a pipeline.
- Shader-stage syntax is invented inside a delivery spec without language
  approval and EBNF/reader/exemplar work.
- Only WGSL behavior is considered for a shared MIR change.
