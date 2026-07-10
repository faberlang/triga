# Goal 05: Direct WebGPU Host And First Scene

**Status**: planned
**Campaign**: [`../CAMPAIGN.md`](../CAMPAIGN.md)
**Target repos**: `radix` browser host, `triga`, `faber`, `examples`
**Depends on**: Goals 01–04
**Lowers to**: `delivery` → `factory`
**Batching posture**: discovery-first

## Purpose

Prove the architectural crossover from Faber compute artifacts displayed by
three.js to a Faber-authored scene rendered directly through WebGPU.

## Invariant

Faber owns scene and shader intent plus compiler reflection; the browser host
owns WebGPU lifecycle but performs no private scene modeling, shader inference,
or layout reconstruction.

## Scope

- Extend or replace the current proof-tier browser host to consume graphics
  WGSL and reflection alongside existing compute artifacts.
- Acquire canvas/adapter/device, create buffers/textures/layouts/pipelines,
  encode a render pass, submit work, and expose deterministic result evidence.
- Connect a Triga scene, camera, indexed geometry, transform, and basic material
  to the artifact/build path chosen by `faber` and Radix.
- Remove three.js from the visible render path and runtime dependency set for
  the proof while retaining only minimal browser bootstrap glue.
- Define clear ownership for resource creation, update, disposal, resize, frame
  timing, device loss, and unsupported WebGPU environments.
- Add browser automation when feasible; otherwise provide deterministic manual
  evidence without overstating CI coverage.

Out of scope: production web app packaging, WebGL2 fallback, general renderer
optimization, full materials, asset loading, and deployment.

## Gate

- The Hello Triga capstone renders indexed rotating geometry in a browser with
  no three.js import or runtime object.
- Pipeline and resource decisions come from compiler reflection or explicit
  Triga domain data, never WGSL parsing or field-name conventions.
- A structural or pixel result contract distinguishes successful rendering
  from merely creating a WebGPU device.
- Missing WebGPU, device loss, stale artifacts, and unsupported reflection fail
  with actionable diagnostics.
- Existing compute browser proof remains functional or has a documented clean
  replacement.

## Stop Conditions

- Host JavaScript recreates the scene graph or material model.
- Checked-in hand-written WGSL replaces Faber-emitted shader proof.
- Browser success is claimed without executing a render pass.
- Product packaging, bundling, or deployment expands the stage.
