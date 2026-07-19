# Goal 01: Source Graphics Pipeline

**Status**: planned
**Campaign**: [`../CAMPAIGN.md`](../CAMPAIGN.md)
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

## Stop Conditions

- Vertex or fragment behavior is added as a special case inside the compute
  emitter.
- The implementation adds a second graphics reflection model.
- The first browser host must infer a missing compiler-owned fact.
- A new annotation is added without the required language-design route.
