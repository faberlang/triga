# Goal 07: Cameras, Culling, And Picking

**Status**: planned
**Campaign**: [`../CAMPAIGN.md`](../CAMPAIGN.md)
**Target repos**: `triga`, `radix` for reusable math/intrinsics, browser host, `examples`
**Depends on**: Goals 02, 03, and 05; may overlap Goal 06
**Lowers to**: `delivery` → `factory`
**Batching posture**: batch-by-default after camera/frustum proof

## Purpose

Make scenes navigable and queryable through camera, bounds, visibility, and
selection behavior that stresses transforms, matrices, spatial algorithms,
render traversal, and deterministic host interaction.

## Invariant

Camera projection, visibility, spatial queries, and picking derive from shared
scene/math facts; the renderer may accelerate them but cannot redefine their
meaning.

## Scope

- Complete perspective and orthographic camera projection/update behavior,
  viewports, layers, look-at orientation, and resize/aspect handling.
- Implement geometry/object bounds, frusta, plane tests, object/triangle ray
  intersections, and deterministic nearest-hit ordering.
- Integrate visibility flags, layers, frustum culling, and optional LOD behavior
  into render traversal without changing scene identity.
- Provide one CPU raycasting path and select a GPU picking path only when it
  contributes to score or exposes a graphics-pipeline requirement.
- Define the minimal browser input-to-ray/pixel contract without building a
  controls framework.

Out of scope: orbit/fly/control addon parity, physics collision, editor gizmos,
and a general spatial database.

## Gate

- Perspective and orthographic fixtures produce agreed projection/frustum
  results and render the expected visible sets.
- A dynamic hierarchical scene culls off-frustum objects and returns
  deterministic ray/pick results.
- Bounds invalidation follows transform and deformation changes.
- Degenerate projections, stale bounds, invalid viewport values, and
  unsupported picking resources fail according to explicit policy.

## Stop Conditions

- The browser host owns a separate camera or culling model.
- Picking depends on object array position or unstable colors without an
  explicit identity map.
- Culling changes observable scene state instead of render selection.
- Camera convenience work expands into a general input/control library.

## Reference: fieldboard picking patterns (attached 2026-07-25)

When this goal lowers, the planner should consider `~/work/ianzepp/fieldboard/canvas/`
as a reference spec for **three transferable patterns**, sourced from a finished
Rust 2D-canvas implementation. None of the literal code ports — fieldboard is 2D
and uses Canvas2D — but the algorithm shapes informed a three-head fleet review
(head-cto `b5409c51`, head-cxo `89612905`, head-ceo `512f887f`) summarized below.

### Transferable patterns (adapt, do not port literally)

| Pattern | fieldboard source | 3D-native adaptation |
|---|---|---|
| Handle-priority picking | `canvas/src/hit.rs` tests resize/rotate handles before bodies; iterates top-most-first | Out of scope for Goal 07 (editor gizmos explicitly excluded). Revisit if a future editor goal names gizmo handles. |
| Local-space transform-then-test | `canvas/src/hit.rs` unrotates the query point into each object's local space before testing | Use triga's landed `matrix4_inversa_affinis` (`triga/src/triga.fab:1361`) + `matrix4_applica_punctum` (`:1349`). Don't port fieldboard's scalar `rotate_point`. |
| Broad-phase culling | `canvas/src/doc.rs:350-525` uniform 256-unit 2D grid | **Defer.** First version is O(n) walk over `scene_visible_mesh_traverse`. A 3D BVH/grid is premature until scene size forces it (out of scope: "general spatial database"). |

### Recommended landing (head-cto + head-cxo agreement)

- **New file:** `triga/src/picking.fab`. Not in `scene.fab` (already 1100 lines, "storage/traversal" scope) or `triga.fab` ("spatial math + shape contracts" scope).
- **Imports** `Ray`, `Box3`, `Matrix4`, `SceneHandle` from existing types the way `scene.fab` already does.
- **Net-new primitives** (bounded, ~40 lines total per head-cto):
  - `ray_triangle_hit` via Möller–Trumbore (the one genuinely new geometry test)
  - `unproject_screen_to_world` (screen→world ray — fieldboard had to build its own unproject; triga already has the matrix inverses)
  - composite `pick_object` over `scene_visible_mesh_traverse` + `ray_box3_hit` broad-phase + `ray_triangle_hit` narrow-phase
- **Return type:** `PickResult { SceneHandle, distance, point, normal }`. Do not port fieldboard's `HitPart` enum (2D-specific: resize/rotate/edge).

### 2D traps to refuse (head-cxo)

| Trap | Refuse |
|---|---|
| Scalar `rotate_point` | Use `matrix4_inversa_affinis` |
| `WorldBounds` AABB type | Use `Box3` |
| Flat `sorted_objects` list | Use hierarchy `scene_visible_mesh_traverse` |
| 256-unit 2D grid | Defer (O(n) walk first) |
| `HitPart` / `ResizeAnchor` enums | `PickResult` struct; design gizmo handles fresh if a future goal names them |

### Sequencing note (head-ceo)

Fieldboard does not accelerate this goal enough to pull it forward in the spine.
The real gaps (unproject, Möller–Trumbore, deterministic nearest-hit ordering)
are 3D problems fieldboard's 2D code does not solve. Lower when a real consumer
appears (editor, block-selection feature) — not as a speculative port.
