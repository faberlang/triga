# Goal 02: Reflection-Driven WebGPU Graphics Host

**Status**: planned
**Campaign**: [`../CAMPAIGN.md`](../CAMPAIGN.md)
**Delivery**: [`../deliveries/02-direct-webgpu-graphics-host-delivery.md`](../deliveries/02-direct-webgpu-graphics-host-delivery.md)
**Target repos**: `radix`
**Depends on**: Goal 01
**Lowers to**: `delivery` -> `factory`
**Batching posture**: discovery-first, then batch descriptor families

## Purpose

Extend the existing browser WebGPU product boundary from compute dispatch to an
executed indexed graphics render pass.

## Invariant

The browser host owns WebGPU lifecycle and consumes compiler descriptors; it
does not own shader, scene, material, geometry-layout, or draw policy.

## Locked Host Boundary

- Extend `radix/hosts/webgpu-browser/`; do not create a second browser host.
- Split descriptor admission from WebGPU effects. Keep pure parsing and
  validation in a focused module beside `faber-kernel.js`; keep device and
  command effects beside `webgpu-runtime.js`.
- Consume separate vertex and fragment WGSL artifacts plus one graphics
  reflection document. Consume vertex, index, and transform payloads as explicit
  generated product artifacts.
- Configure `bgra8unorm` only when it matches the browser preferred canvas
  format. Otherwise fail with `kind=webgpu` for this bounded proof.
- Allocate a `depth24plus` texture at the current physical canvas size. Replace
  it after resize and destroy the old texture.
- Expose `window.faberWebGpuGraphicsProof` with artifact identity, pipeline
  admitted state, submitted frame count, and structured failure kind.

## Ground Truth And Implementation Path

- Reuse device acquisition and buffer helpers from
  `hosts/webgpu-browser/public/src/webgpu-runtime.js` where their ownership is
  identical.
- Generalize the compute-only checks in `public/src/faber-kernel.js` without
  weakening existing compute admission.
- Add graphics-specific static and Node checks beside
  `product-boundary-check.mjs`.
- Extend `scripta/webgpu-browser-proof` to generate and validate both compute and
  graphics artifacts. Preserve its explicit separation between static checks
  and manual/browser GPU execution.
- Remove three.js presentation only at Goal 08 after the direct path passes.

## Scope

- Load generated vertex WGSL, fragment WGSL, reflection, and explicit resource
  payloads.
- Acquire the adapter and device, configure the canvas context, and select only
  formats admitted by reflection and platform negotiation.
- Create shader modules, bind-group layouts, pipeline layouts, render pipelines,
  vertex buffers, index buffers, uniform/storage buffers, and depth resources.
- Encode and submit an indexed render pass.
- Handle resize, depth-resource replacement, device loss, unsupported WebGPU,
  stale artifacts, and invalid descriptors.
- Expose stable structural and browser-inspectable proof results.
- Share compute and graphics runtime primitives where ownership is identical.

## Non-Goals

- Scene traversal, voxel meshing, camera behavior, or gameplay.
- A general renderer abstraction or three.js-compatible API.
- WebGL fallback.
- Pipeline decisions based on WGSL parsing or JavaScript defaults.

## Gate

- The host executes a direct indexed WebGPU render pass.
- Pipeline and resource creation follow generated reflection.
- Missing or unsupported descriptors fail before submission.
- Resize and device-loss paths have focused evidence.
- The graphics path imports no third-party renderer.
- The existing compute add-one proof remains functional or has an explicit
  clean replacement using shared runtime code.

## Validation

Run static descriptor admission, focused non-GPU boundary tests, artifact
freshness checks, and an actual browser WebGPU render. Static checks cannot
substitute for the render-pass result.

## Stop Conditions

- The host parses shader text to discover bindings or entrypoints.
- JavaScript chooses topology, layouts, depth policy, or draw counts that Radix
  or application data should own.
- Three.js remains hidden behind a new adapter name.
- Compute compatibility is preserved through duplicate runtime implementations.
