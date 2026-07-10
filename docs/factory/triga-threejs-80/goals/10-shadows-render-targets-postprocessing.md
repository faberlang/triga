# Goal 10: Shadows, Render Targets, And Post-Processing

**Status**: planned
**Campaign**: [`../CAMPAIGN.md`](../CAMPAIGN.md)
**Target repos**: `triga`, `radix`, browser host, `examples`
**Depends on**: Goals 05–07
**Lowers to**: `delivery` → `factory`
**Batching posture**: discovery-first for multipass/reflection model; batch-by-default for compatible passes

## Purpose

Exercise multipass graphics, attachment lifetimes, depth resources, pipeline
variants, scene re-rendering, and texture feedback through two high-value
three.js workflows: shadow mapping and render-target post-processing.

## Invariant

Pass dependencies, attachments, formats, load/store behavior, and resource
transitions are explicit compiler/host contract facts; host scheduling does not
infer a render graph from object names or shader text.

## Scope

- Add render-target and depth-texture domain concepts without leaking browser
  handles into Triga.
- Define the minimal typed graphics reflection and host behavior for multiple
  render passes, attachment reuse, resize, and deterministic pass ordering.
- Implement shadow-map rendering for an initial directional or spot light and
  extend to another light family only through the established path.
- Support cast/receive policy, shadow camera/frustum, bias, filtering subset,
  and material depth behavior required by the capstone.
- Implement one deterministic post-processing chain using an offscreen target
  and one or more simple full-screen effects.
- Validate resource aliasing, format compatibility, pass cycles, stale sizes,
  and unsupported multisample/depth combinations.

Out of scope: exhaustive effect composer parity, deferred rendering, every
shadow algorithm, temporal upscalers, and production render-graph optimization.

## Gate

- The multipass capstone renders dynamic shadowed geometry and an offscreen
  post-processing effect through direct WebGPU.
- Reflection and host execution agree on attachment formats, sizes, pass order,
  and resource use without WGSL parsing.
- Resize and resource disposal/recreation are deterministic.
- Invalid pass/resource graphs fail before command submission.

## Stop Conditions

- Multipass order exists only as imperative browser code with no typed contract.
- Shadow state is hidden in material or light name conventions.
- Read/write hazards or attachment formats are guessed by the host.
- Post-processing scope becomes an addon catalog before the first chain passes.
