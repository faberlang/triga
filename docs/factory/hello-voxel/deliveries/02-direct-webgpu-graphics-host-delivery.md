# HV-02 Delivery: Reflection-Driven WebGPU Graphics Host

**Parent goal**: [`../goals/02-direct-webgpu-graphics-host.md`](../goals/02-direct-webgpu-graphics-host.md)
**Factory admission**: READY after HV-01
**Primary repo**: `radix`

## Interpreted Unit

Extend the existing browser WebGPU product from compute-only dispatch to one
reflection-driven indexed render path without adding a second host or renderer.

## Normalized Spec

- Admit the HV-01 graphics artifact without weakening compute admission.
- Create WebGPU layouts, shaders, pipeline, vertex/index/transform buffers,
  depth target, render pass, and indexed draw from reflection and payloads.
- Handle physical resize, canvas format mismatch, device loss, stale artifacts,
  and malformed descriptors.
- Expose structured graphics proof state.
- Do not add scene, camera, voxel, or material logic to JavaScript.

## Repo-Aware Baseline

- Product entry: `hosts/webgpu-browser/public/src/app.js`.
- Compute descriptor parser: `public/src/faber-kernel.js`.
- Device/buffer/dispatch effects: `public/src/webgpu-runtime.js`.
- Pure boundary tests: `public/src/product-boundary-check.mjs`.
- Product/artifact manifest: `public/faber-webgpu-product.json` and
  `public/generated/`.
- Generator/check/serve path: `scripta/webgpu-browser-proof`.
- Current page imports `three/webgpu` for presentation; it is not part of the
  compute contract and must not enter the graphics adapter.

## Stage Graph

### HV-02A - Graphics Descriptor Admission

**Output**: a pure parser/validator for the HV-01 graphics document and payload
manifest with typed error paths.
**Write scope**: browser source modules and Node boundary tests.
**Gate**: every required field is consumed; unknown/missing values reject;
compute descriptor tests remain green.

### HV-02B - WebGPU Graphics Effects

**Depends on**: HV-02A
**Output**: layout, resource, pipeline, depth, resize, render-pass, submission,
and device-loss behavior driven by the admitted descriptor.
**Write scope**: `webgpu-runtime.js` or one focused graphics sibling plus tests.
**Gate**: one indexed render pass submits with no third-party renderer.

### HV-02C - Product Harness And Evidence

**Depends on**: HV-02B
**Output**: generated graphics artifacts, product manifest entries, static
checks, browser proof state, and serve instructions.
**Write scope**: host manifest/page/app, generated fixtures, proof script, docs.
**Gate**: static checks distinguish themselves from actual GPU execution; a
browser run records a submitted graphics frame.

## Implementation Work

| Unit | Done when | Non-goals |
| --- | --- | --- |
| HV-02A | Reflection and payloads admit or reject deterministically | No WebGPU effects |
| HV-02B | Indexed render submits from admitted descriptors | No scene/game logic |
| HV-02C | Product generation and proof are reproducible | No final three.js cleanup |

Pure parser tests can proceed separately from effect implementation after the
schema is fixed. Runtime and harness integration are serialized.

## Checkpoints And Gates

- **Checkpoint**: direct indexed graphics submission is available to HV-04.
- **Batching / Split Decision**: split parser, WebGPU effects, and product proof
  at validation/effect boundaries; batch descriptor cases.
- **Release decision**: defer until a Faber-authored visible application exists.
- A canvas clear without indexed drawing does not pass.

## Validation

- `node hosts/webgpu-browser/public/src/product-boundary-check.mjs`.
- New graphics descriptor and runtime Node tests.
- `./scripta/webgpu-browser-proof check` from Radix.
- `./scripta/webgpu-browser-proof serve`, followed by a WebGPU-capable browser
  assertion on `window.faberWebGpuGraphicsProof`.
- Bounded source scan for third-party renderer imports in the graphics modules.

## Companion Skill Plan

- `red-green`: descriptor and unsupported-environment cases.
- `correctness`: buffer sizes, depth replacement, submission, and device loss.
- `cleanliness`: separate pure admission from browser effects.
- `polish`: modified JavaScript, scripts, manifests, and primary docs.

## Open Questions

None blocking. Actual browser automation availability affects evidence strength,
not the host architecture; record unavailable execution honestly.
