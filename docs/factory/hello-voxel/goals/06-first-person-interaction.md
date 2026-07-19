# Goal 06: First-Person Interaction

**Status**: planned
**Campaign**: [`../CAMPAIGN.md`](../CAMPAIGN.md)
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
