# HV-06 Delivery: First-Person Interaction

**Parent goal**: [`../goals/06-first-person-interaction.md`](../goals/06-first-person-interaction.md)
**Factory admission**: READY after HV-03 and HV-05
**Primary repo**: `examples`
**Supporting repos**: `triga`, `faber`

## Interpreted Unit

Add deterministic first-person camera, collision, voxel selection, removal, and
placement to the bounded world using Faber state and the authoritative model.

## Normalized Spec

- Apply the locked yaw/pitch, key state, speed, gravity, and focus rules.
- Resolve the `0.6 x 1.8` player AABB along X, Y, then Z.
- Implement a maximum-distance-6 voxel DDA returning hit and preceding cells.
- Remove on primary input and place solid id 1 on secondary input when legal.
- Render a minimal selection indicator through existing graphics contracts.
- Keep host callbacks, GPU picking, inventory, and general physics out.

## Repo-Aware Baseline

- Typed browser events and frame lifecycle from HV-03.
- Authoritative world model from `examples/hello-voxel/src/voxel.fab`.
- Render integration from the existing Hello Voxel application package.
- Triga vectors, rays, matrices, bounds, AABB overlap, translation, and
  ray-to-`Box3` entry checks in `triga/src/triga.fab`. Triga also provides a
  yaw/pitch camera ray helper with the locked pitch clamp, yaw-derived
  horizontal forward/right vectors, and normalized planar movement deltas with
  speed and frame time for first-person movement. The
  `camera_yaw_pitch_facts` record packages input yaw, input pitch, clamped
  pitch, view direction, planar basis, and ray for one camera state. It also
  provides min-max/min-size and center-size `Box3` construction helpers for
  player and selection extents,
  `Box3` overlap extents, axis-specific overlap accessors, and
  `box3_superpositio_facta` for a packaged overlap vector plus X/Y/Z extents
  in axis-ordered collision fixtures. It also provides `Box3` containment and
  union for aggregate bounds, `Box3` inflation for selection and collision
  tolerances, and a `RayBox3Hit` result with distance, point, outward face
  normal, stable face-code projection, and integer face-offset projection for
  selection indicators and
  edit-adjacent-cell derivation. Generic face-code axis, normal, opposite-face,
  and offset helpers expose the same adjacent-cell, selection-normal, and
  paired-face direction facts without requiring a ray-hit value. Voxel DDA
  remains application-owned. Triga geometry also provides
  `box_wire_geometry` for a minimal selection outline, `geometry_line_count`
  for deterministic line-list count evidence, and
  `line_geometry_draw_batch_facts` for selection-outline draw scale and upload
  byte evidence without host-side shape or line geometry scans.
- New application state belongs in
  `examples/hello-voxel/src/application.fab`.

## Stage Graph

### HV-06A - Camera, Input State, And Collision

**Output**: time-normalized yaw/pitch/movement, gravity, axis-ordered collision,
spawn, grounded state, and focus cleanup.
**Write scope**: Hello Voxel application/controller modules and tests.
**Gate**: deterministic frame-time and collision fixtures pass; no solid overlap
occurs after resolution.

### HV-06B - Voxel DDA And Edit Semantics

**Depends on**: HV-06A and HV-05 world API
**Output**: hit/preceding result, remove/place operations, range limit, and player
overlap rejection.
**Write scope**: voxel query/application modules and tests.
**Gate**: axis, diagonal, empty, boundary, range, removal, placement, and overlap
fixtures pass.

### HV-06C - Browser Interaction Proof

**Depends on**: HV-06B
**Output**: pointer-lock/input integration, visible selection, and scripted edit
state in the browser proof.
**Write scope**: application package and proof script; Faber adapter only for
missing generic event behavior.
**Gate**: scripted input changes Faber state and authoritative blocks; focus loss
clears movement.

## Implementation Work

| Unit | Done when | Non-goals |
| --- | --- | --- |
| HV-06A | Camera and player motion are deterministic and collision-safe | No jump/full physics |
| HV-06B | DDA and edit rules match locked semantics | No GPU picking/inventory |
| HV-06C | Browser input produces visible, structural interaction evidence | No host world mutation |

Movement/collision and DDA/edit work can proceed in parallel only after shared
application/world interfaces are frozen. Browser integration follows both.

## Checkpoints And Gates

- **Checkpoint**: bounded world is editable; HV-07 can optimize update scope.
- **Batching / Split Decision**: split motion/collision, selection/edit, and
  browser proof at algorithm and validation boundaries.
- **Release decision**: defer; resource update behavior is not yet admitted.
- Pointer-lock denial must be an explicit supported failure or degraded
  inspection state, never a silent hang.

## Validation

- Focused Faber tests for pitch clamp, frame normalization, collision axes,
  gravity/ground, DDA hits, range, edit coordinates, and player overlap.
- Build/check the Hello Voxel package.
- Browser automation for focus, pointer lock, relative movement, key press/release,
  selection, removal, and placement where browser permissions allow.
- Structural state assertions remain required when pointer lock automation is
  unavailable.

## Companion Skill Plan

- `red-green`: collision and DDA algorithms.
- `correctness`: tunneling bounds, zero direction components, boundary cells,
  focus cleanup, and frame-time spikes.
- `polish`: application, voxel query, test, and proof sources.

## Open Questions

None blocking. The first implementation may clamp unusually large frame deltas
to a documented maximum, but it must record that value in tests and proof state.
