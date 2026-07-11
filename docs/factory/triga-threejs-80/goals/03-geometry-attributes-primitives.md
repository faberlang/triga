# Goal 03: Geometry, Attributes, And Primitives

**Status**: Units 1–9 implemented on packet — attribute/layout contract,
structural geometry validation, position-derived bounding boxes and spheres,
fail-closed generated vertex normals, normalized planar UVs, and validated plane
box, circle, sphere, cylinder, cone, and torus primitives; reflection remains
**Campaign**: [`../CAMPAIGN.md`](../CAMPAIGN.md)
**Target repos**: `triga`, `radix`, `faber-runtime` when generated storage needs it, `examples`
**Depends on**: Goals 00–01; may overlap Goal 02 after identity policy is locked
**Lowers to**: `delivery` → `factory`
**Batching posture**: discovery-first for attribute/layout contract; batch-by-default for primitive families

## Purpose

Turn `BufferGeometry` from a collection of optional lists into a validated,
extensible geometry/attribute system that can feed both CPU algorithms and GPU
vertex/storage resources.

## Invariant

Attribute shape, element type, component width, normalization, indexing, range,
grouping, and physical layout are explicit facts shared by Triga, MIR
reflection, and the host.

## Scope

- Define typed buffer attributes, indices, draw ranges, groups, usage/update
  policy, bounds, and custom attribute names without stringly host guesses.
- Support indexed and non-indexed triangle geometry plus line and point
  topologies needed by the campaign.
- Implement a coherent initial primitive family such as box, plane, sphere,
  circle, cylinder/cone, and torus after one generator establishes the pattern.
- Support normals/tangents, UVs, colors, transforms, bounding volumes, and the
  morph/skin attribute hooks required by later goals.
- Connect attribute/device-view layout facts to MIR GPU and reflection without
  turning Triga geometry records into backend descriptors.
- Add negative coverage for malformed lengths, index ranges, group overlap,
  unsupported component types, and target-incompatible layouts.

Out of scope: glTF parsing, material shading, mesh optimization suites, and
every three.js geometry addon.

## Gate

- Custom indexed and non-indexed fixtures and the initial primitive batch
  produce deterministic attributes, bounds, normals, and UVs.
- The same attribute contract feeds the first graphics shader/host proof.
- Malformed geometry is rejected before buffer upload or draw.
- CPU and GPU-visible layout calculations agree through reflection tests.

## Stop Conditions

- Item size or vertex count is inferred from field names.
- The host hardcodes position/normal/UV buffer layouts not present in compiler
  facts.
- A generator uses target-specific APIs or opaque external implementations.
- Primitive expansion proceeds before the first generator and layout contract
  have integrated proof.
