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
