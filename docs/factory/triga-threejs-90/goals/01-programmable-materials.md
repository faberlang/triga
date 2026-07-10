# Goal 01: Programmable Materials

**Status**: parked surface brief
**Campaign**: [`../CAMPAIGN.md`](../CAMPAIGN.md)
**Reserved increment**: 3.0 points
**Likely owners**: `triga`, `radix` MIR GPU/reflection, graphics host/runtime, `examples`
**Depends on**: successor Stage 0 and verified Three.js 80 graphics/material contracts
**Lowers to**: `delivery` → `factory` only after campaign activation

## Purpose

Make rendering behavior authorable and composable in Faber while exercising
typed multi-stage lowering, resource reflection, specialization, caching, and
diagnostics beyond a fixed catalog of materials.

## Surface Area

- A bounded Faber-native material composition model rather than total TSL or
  three.js node coverage.
- Typed values and operations shared across vertex, fragment, and relevant
  compute participation.
- Custom vertex deformation and fragment appearance over declared geometry,
  uniforms, textures, samplers, and storage resources.
- Composition, reuse, specialization identity, pipeline caching, and stable
  material/resource ownership.
- Stage legality, type/resource mismatch diagnostics, deterministic lowering,
  and fail-closed target capability checks.
- Workloads that demonstrate user-defined behavior without public shader
  strings or host-side program assembly.

## Boundary

This is a surface brief, not an implementation design or acceptance contract.
The later delivery spec must choose the representation from live Faber and MIR
facts and must explicitly exclude arbitrary shader-language embedding and total
node-library parity.
