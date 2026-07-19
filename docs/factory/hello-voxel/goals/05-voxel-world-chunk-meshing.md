# Goal 05: Voxel World And Chunk Meshing

**Status**: planned
**Campaign**: [`../CAMPAIGN.md`](../CAMPAIGN.md)
**Delivery**: [`../deliveries/05-voxel-world-chunk-meshing-delivery.md`](../deliveries/05-voxel-world-chunk-meshing-delivery.md)
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

## Locked World And Mesh Contract

- The world is `32 x 16 x 32` blocks and contains four `16 x 16 x 16` chunks in
  an X/Z grid. Coordinates are integer `(x, y, z)` with Y up.
- Block id 0 is air and block id 1 is opaque solid. The first proof has no
  additional block properties.
- Each chunk owns a flat block-id list indexed by
  `x + 16 * (z + 16 * y)`. World access resolves chunk and local coordinates
  before reading or writing the list.
- The deterministic fixture contains ground, one wall, one pillar, one cavity,
  and solid blocks that cross both an X and a Z chunk boundary.
- Meshing emits only faces adjacent to air or outside the bounded world. Each
  face emits four vertices and six `u32` indices with consistent outward
  winding. Vertex colors encode the six face directions without textures.
- One draw and one vertex/index resource pair exist per non-empty chunk.

## Ground Truth And Implementation Path

- Keep voxel domain code in `examples/hello-voxel/src/voxel.fab` and meshing in
  `examples/hello-voxel/src/meshing.fab`; it is not generic Triga core.
- Reuse Triga `BufferAttribute`, `BufferGeometry`, bounds, and validation from
  `triga/src/geometry.fab`.
- Add focused Faber tests or exempla beside the Hello Voxel package for index
  mapping, neighbor lookup, face counts, winding, bounds, and chunk boundaries.
- Add Triga source only when a helper is renderer-generic and has a Triga-owned
  exemplar. Do not move voxel storage into `triga/src/scene.fab`.

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
