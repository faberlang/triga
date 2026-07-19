# HV-05 Delivery: Voxel World And Chunk Meshing

**Parent goal**: [`../goals/05-voxel-world-chunk-meshing.md`](../goals/05-voxel-world-chunk-meshing.md)
**Factory admission**: READY after HV-04
**Primary repo**: `examples`
**Supporting repo**: `triga`

## Interpreted Unit

Replace the single cube payload with a deterministic bounded voxel model and
derived per-chunk visible-face meshes while preserving the direct render path.

## Normalized Spec

- Implement the locked `32 x 16 x 32` world and four `16 x 16 x 16` chunks.
- Store air/solid ids with the locked flat local index.
- Implement bounds-safe world/chunk/local coordinate conversion.
- Generate only externally visible faces with position/color attributes and
  `u32` indices.
- Render one resource pair and draw per non-empty chunk.
- Add deterministic CPU and browser evidence; do not optimize speculatively.

## Repo-Aware Baseline

- Application package and direct renderer from HV-04.
- New domain modules:
  `examples/hello-voxel/src/voxel.fab` and `src/meshing.fab`.
- Reusable geometry constructors, bounds, and validation in
  `triga/src/geometry.fab`, including the validated position/color indexed
  triangle constructor, triangle-count helper, and single/all group
  draw-command helpers for chunk mesh payloads. Triga also exposes group-local
  bounding boxes and bounding spheres so chunk draw groups can carry
  source-owned coarse volumes without host-side vertex inference. Validated
  topology, index-format, vertex, index, group, grouped-element, and
  named-attribute scalar and byte counts, indexed draw batch facts, plus
  visible-face vertex/index/triangle and payload byte accounting, let chunk
  tests prove resource size, upload sizes, expected index totals, face-derived
  triangle counts, and draw scaling without host-side geometry scans.
  The `ColoredQuadMesh` append helper lets the application mesher derive
  face-local position/color/index buffers from caller-owned coordinates and RGB
  values while Triga owns the repeated color and index-base pattern. Its
  finalization, fact, draw-batch, and bounds helpers let chunk mesh tests prove
  emitted payload shape, draw scale, upload byte counts, and coarse volumes from
  the same accumulated buffers. `face_code_colored_quad_mesh_append` bridges
  face-code quads and colors into the same accumulated mesh so the application
  mesher owns neighbor visibility and voxel coordinates, but not repeated face
  winding, color, or index-base tables.
- Reusable `Box3` min-max/min-size/center-size construction, validation, size,
  center, containment, union, and translation helpers in `triga/src/triga.fab`
  for chunk mesh bounds. Generic face-code validation, offset projection, and
  direction colors in `triga/src/triga.fab` let chunk meshing encode six
  visible face directions without host-side color policy. `face_code_facts`
  packages code, axis, opposite face, offsets, normal, and color when the
  mesher needs one face metadata record. `face_code_unit_quad` also provides
  the outward-wound corner order for each visible face so the application
  mesher does not own a duplicate winding table.
- Reusable scene visibility state, effective visible traversal, visible
  mesh-handle traversal, visible mesh resource projection, visible resource-pair
  counts, visible resource facts, geometry/material handle projection, and
  visible mesh transform payload counts/bytes, visible mesh draw packets, and
  visible draw batch facts in `triga/src/scene.fab`, plus mesh world-matrix
  lookup for chunk draw transforms, without host renderer policy.
- No current voxel or chunk implementation exists in the examples repository.

## Stage Graph

### HV-05A - Authoritative World Model

**Output**: block/chunk/world types, coordinate conversion, bounds-safe get/set,
and deterministic fixture constructor.
**Write scope**: `examples/hello-voxel/src/voxel.fab` and focused tests.
**Gate**: all 32,768 cells address deterministically; out-of-bounds operations
fail explicitly; boundary fixture facts pass.

### HV-05B - Visible-Face Chunk Mesher

**Depends on**: HV-05A
**Output**: position/color/index payloads and chunk bounds from authoritative
neighbor reads.
**Write scope**: `meshing.fab`, focused tests, and only proven generic Triga
helpers.
**Gate**: face/index counts, winding, colors, and X/Z boundary behavior pass.

### HV-05C - Four-Chunk Render Integration

**Depends on**: HV-05B
**Output**: non-empty chunk resources/draws through the HV-04 renderer and
visible deterministic world proof.
**Write scope**: Hello Voxel application and proof script.
**Gate**: resource/draw count follows non-empty, effectively visible chunks;
hidden faces are absent; the world is visibly rendered.

## Implementation Work

| Unit | Done when | Non-goals |
| --- | --- | --- |
| HV-05A | World access and fixture facts are deterministic | No meshes as storage |
| HV-05B | Chunk meshes match neighbor and winding rules | No greedy meshing |
| HV-05C | Four chunks render through one canonical path | No streaming/textures |

World model precedes meshing. Independent face-direction cases are batched after
one direction establishes the test and emission pattern.

## Checkpoints And Gates

- **Checkpoint**: bounded voxel scene visible; HV-06 can add interaction.
- **Batching / Split Decision**: split world model, derived meshing, and GPU
  integration at data ownership and validation boundaries.
- **Release decision**: defer; application is not yet editable.
- One draw or scene node per block is a hard failure.

## Validation

- Check/run focused Faber tests for indexing, bounds, get/set, fixture facts,
  face counts, indices, winding, colors, and chunk boundaries.
- Run Triga source/compile checks if Triga changes.
- Build the Hello Voxel browser package and verify four logical chunks, bounded
  draw count, expected index totals, and visible pixel evidence.
- Re-run the HV-04 cube proof or its retained lower-level render regression.

## Companion Skill Plan

- `red-green`: model and meshing invariants before integration.
- `correctness`: coordinate overflow, boundary neighbors, winding, and indices.
- `optimization`: read-only measurement after correctness; no optimization gate.
- `polish`: modified Faber sources and proof scripts.

## Open Questions

None blocking. If Faber collection limits prevent the locked flat storage, stop
and route the missing language/runtime capability rather than changing world
semantics inside the application.
