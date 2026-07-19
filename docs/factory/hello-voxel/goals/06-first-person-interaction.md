# Goal 06: First-Person Interaction

**Status**: planned
**Campaign**: [`../CAMPAIGN.md`](../CAMPAIGN.md)
**Delivery**: [`../deliveries/06-first-person-interaction-delivery.md`](../deliveries/06-first-person-interaction-delivery.md)
**Target repos**: `triga`, `faber`, `examples`
**Depends on**: Goals 03 and 05
**Lowers to**: `delivery` -> `factory`
**Batching posture**: split-on-boundary between movement/collision and edits

## Purpose

Turn the rendered voxel world into an interactive application with authoritative
movement, selection, removal, and placement behavior.

## Invariant

Input changes Faber application state, and all collision and selection queries
read the authoritative voxel model rather than rendered pixels or host objects.

## Locked Interaction Contract

- The camera uses yaw around +Y and pitch clamped to +/- 89 degrees. Mouse
  deltas apply only while pointer lock is active.
- Movement uses physical W/A/S/D codes, frame time in seconds, a fixed speed,
  and horizontal forward/right vectors. Focus loss clears movement immediately.
- The player collision shape is an axis-aligned box 0.6 blocks wide and 1.8
  blocks high. Movement resolves X, then Y, then Z against opaque blocks.
- The first proof has gravity and grounded walking but no jump. Spawn is a fixed
  empty location in the deterministic Goal 05 world.
- Selection uses a voxel DDA ray from the camera with maximum distance 6
  blocks. It returns the hit coordinate and the preceding empty coordinate.
- Primary pointer removes the hit block. Secondary pointer places block id 1 at
  the preceding coordinate unless it intersects the player box.

## Ground Truth And Implementation Path

- Put application camera and controller state in
  `examples/hello-voxel/src/application.fab`.
- Put voxel DDA and collision queries beside the voxel model unless a proven
  renderer-generic ray/AABB helper belongs in `triga/src/triga.fab`.
- Reuse the Goal 03 typed input state and Goal 05 authoritative world API.
- Keep selection rendering as a small application-owned geometry/material
  choice using the admitted pipeline. Do not introduce GPU picking.
- Add deterministic, non-browser fixtures for yaw/pitch, time-normalized
  movement, axis resolution, DDA hits, edit coordinates, and player overlap.

## Scope

- Implement yaw/pitch first-person camera control with bounded pitch.
- Implement keyboard movement using frame time.
- Implement a bounded player collision shape against solid blocks.
- Cast a center-screen ray through the camera into voxel coordinates.
- Return the selected block and adjacent placement face deterministically.
- Remove and place blocks through explicit world mutation operations.
- Expose a minimal selection indicator and interaction state.
- Handle focus and pointer-lock loss without stuck movement.

## Non-Goals

- Full character physics, jumping, slopes, crouching, or moving platforms.
- Inventory, crafting, entities, combat, or game progression.
- Physics engines or host-side collision.
- Picking through GPU readback.

## Gate

- Keyboard and pointer input move and orient the camera.
- Collision prevents entry into solid blocks in deterministic fixtures.
- Ray selection identifies the expected block and face.
- Removal and placement mutate the world model.
- Focus and pointer-lock loss clear transient input state.

## Validation

Use deterministic movement, collision, ray traversal, and edit fixtures plus
browser automation for input delivery and visible selection when supported.

## Stop Conditions

- Collision or picking depends on three.js, browser scene objects, or rendered
  pixel interpretation.
- Host callbacks mutate the world directly.
- Variable frame rate changes movement distance without time normalization.
- Interaction semantics expand into inventory or gameplay systems.
