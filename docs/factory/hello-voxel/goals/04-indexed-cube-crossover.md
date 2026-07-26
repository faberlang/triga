# Goal 04: Indexed Cube Crossover

**Status**: planned
**Campaign**: [`../CAMPAIGN.md`](../CAMPAIGN.md)
**Delivery**: [`../deliveries/04-indexed-cube-crossover-delivery.md`](../deliveries/04-indexed-cube-crossover-delivery.md)
**Target repos**: `triga`, `radix`, `faber`, `hosts`, `examples`
**Depends on**: Goals 01-03
**Lowers to**: `delivery` -> `factory`
**Batching posture**: one coherent vertical slice

## Purpose

Prove the complete Faber-to-WebGPU architecture before adding the voxel domain.

## Invariant

The visible cube is determined by Faber source, Triga data, and Radix artifacts;
the browser host supplies platform lifecycle only. The host exposes a generic,
reflection-addressed update operation while Faber remains the sole owner of the
transform values written through it.

## Locked Crossover Shape

- The application package is `examples/hello-voxel/`.
- The cube uses 8 positions, per-vertex RGB colors, and 36 `u32` indices. The
  vertex layout and transform resource are exactly the Goal 01 contract.
- Faber updates the model matrix from frame time. Triga supplies column-major
  matrix operations and perspective/view composition. JavaScript does not
  calculate matrices.
- The camera begins outside the cube and looks at the origin. Resize updates the
  projection aspect. The proof draws one indexed instance with depth enabled.
- Success requires at least two submitted frames with different model matrices
  and non-background pixels inside a deterministic central sample region.

## Ground Truth And Implementation Path

- Reuse `triga/src/triga.fab` matrix functions and
  `triga/src/geometry.fab` attribute/layout constructors. Add only missing
  generic math or geometry operations to those modules.
- Add the Faber package, fixture data, and browser proof state under
  `examples/hello-voxel/`.
- Consume the generated shader/reflection path from Radix Goal 01, the graphics
  host from Goal 02, and browser lifecycle from Goal 03.
- Extend Triga exempla only for reusable library behavior. Application behavior
  remains in the example package.

## Scope

- Author an indexed cube workload as a Faber package.
- Use Triga geometry and transform contracts for vertex/index data and model,
  view, and projection values.
- Use a minimal unlit material and Faber-authored vertex/fragment entrypoints.
- Render through the Goal 02 direct WebGPU host.
- Add a public host operation that resolves a declared graphics storage resource
  from admitted reflection, validates the input role and byte bounds, and uses
  `GPUQueue.writeBuffer` to update it before submission.
- Rotate or otherwise update the cube from the Goal 03 frame loop. Each frame
  transports the Faber-owned transform through that generic operation; no
  cube-specific host API or JavaScript matrix calculation is admitted.
- Handle perspective projection, canvas resize, and depth testing.
- Record structural artifact, executed render-pass, and deterministic pixel or
  canvas evidence.

## Non-Goals

- Voxel storage, chunking, collision, or block editing.
- Lighting, textures, PBR, shadows, or post-processing.
- Orbit controls or a general scene editor.
- Keeping the three.js cube as an accepted fallback.

## Gate

- The indexed cube is visibly rendered through direct WebGPU.
- Rotation or another deterministic frame update changes rendered output.
- Two submitted frames prove different Faber-owned transform payloads were
  written through the public reflection-addressed host operation to the same
  admitted GPU resource before drawing.
- Unknown resources, non-input resources, and out-of-bounds writes reject before
  `GPUQueue.writeBuffer` or submission.
- Perspective and depth behavior are exercised.
- No third-party renderer or handwritten WGSL participates.
- Browser proof distinguishes device creation, pipeline creation, submission,
  and visible output.

## Validation

Run all producer checks from Goals 01-03 plus an actual browser proof. Capture
artifact identity and pixel/canvas evidence from the same build.

## Stop Conditions

- Host JavaScript constructs the cube, camera, matrices, shader, or material.
- The update path selects a buffer by DOM field convention, bypasses reflection,
  or exposes a cube-specific or application-specific host operation.
- A non-indexed or static clear-color proof is reported as crossover success.
- The vertical slice is split into isolated green tests with no executed
  end-to-end path.
