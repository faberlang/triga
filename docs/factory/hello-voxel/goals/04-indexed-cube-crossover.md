# Goal 04: Indexed Cube Crossover

**Status**: planned
**Campaign**: [`../CAMPAIGN.md`](../CAMPAIGN.md)
**Target repos**: `triga`, `radix`, `faber`, `examples`
**Depends on**: Goals 01-03
**Lowers to**: `delivery` -> `factory`
**Batching posture**: one coherent vertical slice

## Purpose

Prove the complete Faber-to-WebGPU architecture before adding the voxel domain.

## Invariant

The visible cube is determined by Faber source, Triga data, and Radix artifacts;
the browser host supplies platform lifecycle only.

## Scope

- Author an indexed cube workload as a Faber package.
- Use Triga geometry and transform contracts for vertex/index data and model,
  view, and projection values.
- Use a minimal unlit material and Faber-authored vertex/fragment entrypoints.
- Render through the Goal 02 direct WebGPU host.
- Rotate or otherwise update the cube from the Goal 03 frame loop.
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
- Perspective and depth behavior are exercised.
- No third-party renderer or handwritten WGSL participates.
- Browser proof distinguishes device creation, pipeline creation, submission,
  and visible output.

## Validation

Run all producer checks from Goals 01-03 plus an actual browser proof. Capture
artifact identity and pixel/canvas evidence from the same build.

## Stop Conditions

- Host JavaScript constructs the cube, camera, matrices, shader, or material.
- A non-indexed or static clear-color proof is reported as crossover success.
- The vertical slice is split into isolated green tests with no executed
  end-to-end path.
