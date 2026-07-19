# Goal 00: Baseline And Contract Lock

**Status**: selected
**Campaign**: [`../CAMPAIGN.md`](../CAMPAIGN.md)
**Delivery**: [`../deliveries/00-baseline-contract-lock-delivery.md`](../deliveries/00-baseline-contract-lock-delivery.md)
**Target repos**: `triga`, `radix`, `faber`, `examples`
**Lowers to**: `delivery` -> `factory`
**Batching posture**: discovery-first

## Purpose

Convert the current partial graphics and browser surfaces into one verified
ownership and artifact contract for the first indexed WebGPU draw.

## Invariant

Every fact required to create and execute the first render pipeline has one
named owner and one emitted or source-level representation.

## Ground Truth And Implementation Path

- Start at `radix/crates/radix/src/driver/mod.rs`, `mir/device.rs`,
  `mir/abi.rs`, `mir/wgsl_text.rs`, and `tool/commands/reflection.rs`.
- Trace the browser consumer through `radix/hosts/webgpu-browser/public/src/`
  and `radix/scripta/webgpu-browser-proof`.
- Trace browser packaging through `faber/src/package/product.rs`,
  `manifest.rs`, and the adjacent tests in `faber/src/package_test.rs`.
- Trace Triga facts through `src/geometry.fab`, `src/triga.fab`,
  `src/scene.fab`, and `exempla/triga-stage4-source-facts.fab`.
- Save the locked contract and red-evidence inventory in the Goal 00 delivery
  artifact. Do not create a second campaign or shader design document.

At goal creation, Radix admits `Compute` and `Vertex` in
`MirKernelShaderStage`; its source vertex path accepts an empty `@ vertex`
body, and the browser reflection consumer requires a single compute kernel.
Treat older prose that claims a complete fragment path as stale until live
source and tests prove otherwise.

## Scope

- Inventory current Faber browser package output, Radix device roles, graphics
  reflection, WGSL entry emission, WebGPU descriptors, and Triga layout facts.
- Trace the current compute browser proof and both three.js presentation paths.
- Define the artifact set for vertex WGSL, fragment WGSL, pipeline reflection,
  geometry data, index data, camera/material parameters, and draw commands.
- Assign each fact to Faber source, Triga source, Radix MIR/reflection, or the
  browser platform host.
- Add red or unsupported fixtures for missing source lowering, reflection,
  direct render execution, and third-party-runtime exclusion.
- Record exact downstream validation commands and browser evidence boundaries.

## Non-Goals

- Implement shader lowering or a WebGPU renderer.
- Design voxel storage or gameplay.
- Invent new syntax before proving the existing annotation model insufficient.
- Treat current campaign prose as executable evidence.

## Gate

- A checked contract map covers every required first-draw fact.
- Missing facts have one owner and one downstream goal.
- Red fixtures fail for the intended missing capability, not setup errors.
- The compute WebGPU path and current Triga source gates remain accounted for.
- No accepted path depends on a host parsing WGSL or knowing Triga field names.

## Validation

Validation must inspect live source and generated artifacts. It must separate
static admission, generated artifact freshness, and actual browser GPU
execution.

## Stop Conditions

- The contract introduces two owners for the same binding or pipeline fact.
- A three.js default is adopted without an explicit Faber, Triga, or Radix
  representation.
- Discovery becomes implementation before the boundary and red evidence are
  recorded.
