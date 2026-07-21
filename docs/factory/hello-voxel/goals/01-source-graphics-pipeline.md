# Goal 01: Source Graphics Pipeline

**Status**: in-progress
**Last updated**: 2026-07-21 (hand-1 acceptance verification after cc75ccc4a fragment extraction)
**Campaign**: [`../CAMPAIGN.md`](../CAMPAIGN.md)
**Delivery**: [`../deliveries/01-source-graphics-pipeline-delivery.md`](../deliveries/01-source-graphics-pipeline-delivery.md)
**Target repos**: `radix`, `triga`, `examples`
**Depends on**: Goal 00
**Lowers to**: `delivery` -> `factory`
**Batching posture**: discovery-first

## Purpose

Make one Faber-authored vertex and fragment pair an executable compiler input
rather than a manually constructed MIR ABI fixture.

## Invariant

Faber source owns shader intent; Radix validates and lowers that intent into
shared graphics MIR, WGSL, and reflection without a parallel Triga compiler.

## Locked First-Pipeline Contract

- Vertex buffers are structure-of-arrays: `position` at location 0 as
  `float32x3`, and `color` at location 1 as `float32x3`. Each has offset 0,
  stride 12, and vertex step mode.
- Indices are `u32`; topology is `triangle-list`; front-face culling is disabled
  for the first proof; one instance is drawn.
- Group 0 binding 0 is a read-only storage buffer containing 32 `f32` values:
  a column-major model matrix followed by a column-major view-projection matrix.
- The vertex stage emits builtin position and location-0 RGB color. The fragment
  stage consumes location-0 color and emits location-0 RGBA with alpha 1.
- The color target is `bgra8unorm`. Depth is `depth24plus`, writes are enabled,
  and comparison is `less`.
- Draw reflection carries indexed status, index format, index count, first index,
  base vertex, and instance count. No host default supplies these values.

## Ground Truth And Implementation Path

- Extend the canonical annotation/HIR path in
  `radix/crates/radix/src/hir/lower/`, `hir/nodes.rs`, and
  `semantic/passes/typecheck.rs`.
- Extend `mir/device.rs` and `mir/lower.rs` so vertex and fragment roles are
  real lowered functions, not driver-only source facts.
- Extend the shared ABI and JSON reflection in `mir/abi.rs` and
  `tool/commands/reflection.rs`.
- Extend WGSL emission in `mir/wgsl_text.rs`; keep compute emission on the same
  shared MIR path.
- Drive the implementation with a Faber fixture under Radix's existing fixture
  conventions and compare locations 0 and 1 with `triga/src/geometry.fab`.
- Update `radix/EBNF.md` and reader/exemplar surfaces only if current annotation
  grammar cannot express the locked contract.

## Scope

- Admit source-level vertex and fragment roles through the canonical HIR-to-MIR
  device-role path.
- Lower typed vertex inputs, interstage varyings, fragment outputs, and the
  resource subset required by the indexed-cube crossover.
- Emit valid WGSL entrypoints from the lowered program.
- Emit reflection for entry names, shader stages, vertex layouts, bindings,
  stage visibility, pipeline layout, color target, topology, depth state, index
  format, and draw requirements.
- Prove reflection agrees with Triga's declared position layout.
- Reject duplicate locations, varying mismatches, illegal resources, unsupported
  types, missing outputs, and target-incompatible shader roles.
- Preserve existing compute shader lowering and reflection.

## Non-Goals

- General shader language parity.
- PBR, lighting, textures, shadow maps, or compute-driven rendering.
- Handwritten WGSL fixtures as final success evidence.
- Browser resource creation or draw submission.

## Gate

- One Faber fixture emits vertex and fragment WGSL from source-level roles.
- Reflection contains every Goal 00 fact assigned to Radix for the first draw.
- WGSL validates through the existing admitted validator path.
- Negative fixtures fail before emission with actionable diagnostics.
- Existing compute WGSL and WebGPU reflection tests remain valid.

## Validation

Use focused Radix tests for HIR/MIR role lowering, ABI reflection, WGSL emission,
negative diagnostics, and compute regression coverage. Use a Triga source-fact
fixture for layout agreement.

## Progress (2026-07-21)

### Complete

- `@ vertex` and `@ fragment` annotations parse correctly through the HIR
  lowering path (`hir/lower/decl.rs` sets `is_vertex`/`is_fragment` flags).
- `MirInputStepMode` and `Bgra8Unorm` landed in radix-mir ABI (ea95b924d).
- `MirKernelReflection::source_vertex_entry_from_triga_layout_facts` constructs
  vertex reflections from Triga `adfirma`-encoded layout facts.
- `emit_wgsl_vertex_entry_contract` produces valid WGSL vertex entrypoints.
- `MirKernelReflection::source_fragment_entry` and
  `emit_wgsl_fragment_entry_contract` exist in the ABI/codegen layer.
- `triga-hello-voxel-shaders.fab` exemplar created: one `@ vertex` + one
  `@ fragment` function with vertex layout facts for position (loc 0,
  Float32x3) and color (loc 1, Float32x3), plus fragment output and pipeline
  fact encodings.
- Vertex WGSL emits correctly: position and color inputs, builtin position output.
- **Fragment source-level extraction landed (cc75ccc4a).** `GraphicsSourceFacts`
  now has `fragment_entries`, `triga_varying_facts`, and
  `triga_fragment_output_facts`. Driver has `emit_wgsl_fragment_source_output`
  wired. End-to-end `faber emit -t wgsl-text` produces valid combined
  vertex+fragment WGSL from the exemplar.
- **Varying pass-through emits correctly.** Vertex output `color: vec3<f32>` at
  location 0 passes to fragment input `color: vec3<f32>` at location 0 with
  matching `@interpolate(perspective)` decorations.

### Gaps (after cc75ccc4a)

1. **Pipeline-level reflection facts not extracted.** `MirGraphicsPipelineReflection`
   in the ABI supports `color_target_formats`, `depth_stencil` (depth24plus,
   write enabled, compare less), `primitive_topology` (triangle-list), and
   stencil state, but `GraphicsSourceFacts` has no corresponding
   `triga_pipeline_facts` extraction field. The per-kernel vertex/fragment
   reflection emits correctly; the pipeline-wide metadata does not. Needs
   Triga-side `adfirma` encoding convention and radix-side extraction.

2. **Draw requirements not in reflection.** Indexed draw facts (index format,
   index count, first index, base vertex, instance count) are not reflected.

3. **Resource binding extraction.** The transform buffer (group 0 binding 0,
   read-only storage) needs Triga-side declaration and radix-side extraction.

4. **Fragment output default alpha is 0.0, not 1.0.** The empty `@ fragment`
   body produces `out.color = vec4<f32>(0.0)` — contract requires alpha 1.0.
   Once fragment output facts are extracted, the WGSL emitter should use
   contract values.

### Next units (HV-01C)

- Add `triga_pipeline_facts` to `GraphicsSourceFacts` (color target, depth/stencil,
  primitive topology) and wire Triga adfirma extraction.
- Add draw requirement reflection (indexed, index format, index count, etc.).
- Add resource binding extraction from Triga adfirma encoding.
- Fix fragment output default alpha to 1.0 once fragment output facts are extracted.

## Stop Conditions

- Vertex or fragment behavior is added as a special case inside the compute
  emitter.
- The implementation adds a second graphics reflection model.
- The first browser host must infer a missing compiler-owned fact.
- A new annotation is added without the required language-design route.
