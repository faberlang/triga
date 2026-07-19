# Goal 05: Voxel World And Chunk Meshing

**Status**: planned
**Campaign**: [`../CAMPAIGN.md`](../CAMPAIGN.md)
**Target repos**: `triga`, `examples`
**Depends on**: Goal 04
**Lowers to**: `delivery` -> `factory`
**Batching posture**: discovery-first, then batch face and boundary cases

## Purpose

Create the bounded world model and derived chunk geometry needed for the Hello
Voxel application.

## Invariant

Blocks are authoritative world data. Chunk meshes are derived render resources,
and no block becomes an individual scene node or draw call.

## Scope

- Define block identity, empty/solid state, bounded coordinates, and chunk
  coordinates in Faber source.
- Create a deterministic world fixture that crosses at least one chunk boundary.
- Generate visible faces only, including correct neighbor checks at world and
  chunk boundaries.
- Emit indexed position and material/color data compatible with the admitted
  Triga vertex layout.
- Produce stable chunk mesh ownership and bounds.
- Render the bounded world through the direct pipeline.
- Add CPU-level fixtures for face counts, indices, winding, bounds, and boundary
  behavior.

## Non-Goals

- Infinite terrain, noise generation, streaming, persistence, or workers.
- Greedy meshing unless evidence shows the simple admitted mesh is insufficient.
- One object, buffer, or draw per block.
- Texture atlases, transparency, water, or advanced lighting.

## Gate

- The deterministic world renders as chunk meshes.
- Hidden internal faces are absent.
- Chunk-boundary faces are included or omitted from authoritative neighbor data.
- Generated indices, winding, bounds, and draw counts validate.
- Draw and resource counts scale by chunk, not by block.

## Validation

Use deterministic source/CPU meshing fixtures, Triga source and compile checks,
generated artifact checks, and a browser rendering proof for the bounded world.

## Stop Conditions

- Render meshes become the authoritative voxel store.
- Scene traversal visits every block as an object.
- Optimization work begins before simple chunk meshing is correct and measured.
- Host code generates or repairs voxel geometry.
