# Goal 09: glTF And GLB Asset Ingestion

**Status**: planned
**Campaign**: [`../CAMPAIGN.md`](../CAMPAIGN.md)
**Target repos**: `triga`, `faber`, `faber-runtime` if byte/runtime support is required, browser host, `examples`
**Depends on**: Goals 03, 06, and 08
**Lowers to**: `delivery` → `factory`
**Batching posture**: discovery-first for format/boundary proof; batch-by-default for the selected core subset

## Purpose

Load the recommended real-time asset format into the public Triga model so the
campaign tests Faber JSON/binary processing, typed validation, resource
resolution, scene construction, materials, textures, skins, morphs, animation,
cameras, and lights against real data.

## Invariant

Asset acquisition, decoding, parsing, validation, and Triga construction have
explicit boundaries; no loader may create a private host scene or bypass public
types to make a fixture render.

## Scope

- Select and document a core glTF 2.0 JSON/GLB subset sufficient for the asset
  capstone: buffers, buffer views, accessors, meshes/primitives, nodes/scenes,
  metallic-roughness materials, images/textures/samplers, skins, animations,
  cameras, and selected punctual lights.
- Parse container/JSON/binary structures in Faber where current byte and JSON
  capabilities make that honest; route missing reusable support to its owner.
- Separate URL/file/embedded-data acquisition from format parsing and image
  decoding. Host routes may supply bytes or decoded pixels without owning the
  asset model.
- Validate indexes, offsets, lengths, component types, strides, normalized
  values, hierarchy, references, and resource limits before constructing a
  scene or allocating GPU memory.
- Use small checked-in fixtures plus at least one representative public asset;
  pin provenance and expected behavior.
- Record unsupported extensions explicitly; do not silently discard semantics
  that affect the scorecard proof.

Out of scope: exhaustive three.js loaders, authoring/export, Draco/Meshopt/KTX2
unless separately selected, network caching, and production CDN policy.

## Gate

- The asset capstone loads a glTF/GLB scene with hierarchy, mesh attributes,
  metallic-roughness material, texture, and available animation/deformation
  without using `GLTFLoader` or three.js runtime code.
- Malformed and resource-exhaustion fixtures fail before unsafe allocation or
  out-of-bounds access.
- Parser output constructs only public Triga types and the direct renderer
  consumes those values.
- The selected extension/subset matrix and deferred semantics are machine
  visible in the capability ledger.

## Stop Conditions

- Browser code parses glTF directly into GPU or host-private scene objects.
- Unknown required extensions or unsupported component forms are ignored.
- Asset breadth expands into a format zoo before the core capstone passes.
- Unbounded lengths/counts from input control allocations.
