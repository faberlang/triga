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
- Next residual: lower one matching vertex input through graphics MIR and prove
  emitted reflection agrees with these facts without inspecting attribute names.

## Stop Conditions

- Vertex/fragment code is added as special cases inside the compute emitter.
- The host must parse WGSL or know Triga field names to build a pipeline.
- Shader-stage syntax is invented inside a delivery spec without language
  approval and EBNF/reader/exemplar work.
- Only WGSL behavior is considered for a shared MIR change.
