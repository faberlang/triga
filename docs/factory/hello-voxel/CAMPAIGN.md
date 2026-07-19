# Campaign: Hello Voxel

**Status**: in factory
**Selected next stage**: Goal 00 - Baseline And Contract Lock
**Primary owner**: `triga`
**Target repos**: `triga`, `radix`, `faber`, `faber-web`, `examples`
**Process**: `campaign` -> `delivery` -> `factory`

## Summary

Hello Voxel coordinates the first complete interactive 3D browser application
authored in Faber and rendered through direct WebGPU. The application presents
a bounded voxel world, supports first-person movement and block edits, and uses
no third-party rendering runtime or application-specific JavaScript rendering
shim.

The campaign is a focused application proof. It does not attempt to reproduce
three.js, Minecraft, a general game engine, or a production CAD renderer.

## Problem

Triga owns useful math, geometry, scene identity, and vertex-layout source
contracts. Radix owns direct WebGPU compute execution and partial graphics MIR,
WGSL, and reflection contracts. The visible browser fixtures still delegate
rendering to three.js. No current proof connects Faber-authored vertex and
fragment intent, Triga data, compiler reflection, browser lifecycle, indexed
draws, input, and dynamic resource updates into one application.

Deleting the three.js imports without closing those ownership gaps would move
renderer policy into ad hoc JavaScript. Hello Voxel instead establishes one
compiler-owned and library-owned path from Faber source to WebGPU execution.

## Desired End State

A user can open a browser application that:

- was authored as a Faber package;
- renders a bounded, chunked voxel world through direct WebGPU;
- supports first-person camera movement and pointer-based block selection;
- removes and places blocks without reloading the page;
- rebuilds and replaces only affected chunk resources after an edit;
- contains no runtime import or object from three.js or another rendering
  framework; and
- reports deterministic success and actionable failure evidence.

The browser remains a platform dependency. Faber and Radix own the generated
adapter to canvas, input, frame scheduling, and WebGPU APIs. Application code
does not own handwritten JavaScript rendering behavior.

## Development Posture

- **Clean break**: remove three.js from the admitted visible rendering path.
- **Contract first**: the host consumes emitted reflection and explicit Triga
  data. It does not parse WGSL or infer layouts from source field names.
- **Faber authored**: game state, world logic, shaders, camera behavior, and
  interaction live in Faber source.
- **Thin host**: browser code owns platform lifecycle only. It does not recreate
  a scene graph, material system, voxel model, or draw policy.
- **Bounded proof**: use a small deterministic world before terrain streaming,
  persistence, advanced lighting, or multiplayer.
- **No compatibility shim**: do not preserve the three.js fixture as a second
  accepted runtime route after the direct path passes.

## Implementation Workflow

Each campaign goal lowers to a repo-aware `delivery` specification. Execution
then runs through `factory`. A goal can split only at a named ownership,
architecture, validation, or external-effect boundary. End-of-goal evidence
must be recorded before the next dependent goal advances.

Compiler and host changes must follow the governing `radix/AGENTS.md`. Triga
source changes must keep `./scripta/check-source` and
`./scripta/check-compile` green. Browser execution claims require an actual
WebGPU render or a clearly labeled non-GPU admission result.

Goal-check verdicts are recorded in [`GOAL-CHECKS.md`](GOAL-CHECKS.md).
Factory vision, production order, and generated delivery specs are indexed in
[`FACTORY-READINESS.md`](FACTORY-READINESS.md).

## Scope Routing

### In Campaign

- source-level vertex and fragment shader entrypoints;
- graphics MIR, WGSL emission, and render-pipeline reflection;
- a reflection-driven direct WebGPU graphics host;
- generated browser entry, frame, resize, input, and failure lifecycle;
- Triga camera, geometry, resource, visibility, and picking contracts needed by
  the application;
- bounded voxel storage, visible-face meshing, and chunk resource replacement;
- first-person movement, collision, selection, removal, and placement;
- removal of three.js from admitted runtime paths; and
- structural, browser, interaction, pixel, and resource-lifecycle evidence.

### Follow-Up Targets

#### Minecraft Scale

Add streamed multi-chunk terrain, persistence, lighting propagation, entities,
background generation, and multiplayer synchronization.

#### Flappy Bird Profile

Prove that the same browser platform supports sprites, alpha blending, 2D
collision, audio, touch input, and a small application package.

#### Doom-Compatible Engine

Add WAD parsing, BSP and sector traversal, sprite rendering, palette behavior,
audio, and deterministic game simulation with freely redistributable fixtures.

#### CAD Renderer

Add high-precision geometry, topology, tessellation, snapping, selection,
sectioning, and large-model resource management.

#### Networked FPS

Add skeletal animation, physics, advanced visibility, networking, prediction,
audio, and production-grade performance controls.

### Explicitly Out Of Scope

- infinite terrain and background world streaming;
- saved worlds and network synchronization;
- advanced voxel lighting, water, weather, and particles;
- general PBR, shadow, post-processing, or asset-loader breadth;
- mobile controls and production deployment;
- API-symbol parity with three.js; and
- original Minecraft, Doom, or Counter-Strike code or proprietary assets.

## Batching And Split Policy

The first instance of each compiler, WebGPU, and browser contract is
`discovery-first`. After the contract passes, homogeneous descriptor fields,
resource variants, or chunk cases are `batch-by-default`. Split only when work
crosses repo ownership, requires a language decision, changes a public artifact
schema, needs browser execution that is unavailable, or reveals a distinct
security or external-effect boundary.

Do not split the indexed-cube crossover into disconnected shader, host, and
scene proofs that never execute together. Do not combine later Minecraft-scale
features into the bounded Hello Voxel acceptance path.

## Ground Truth Researched

The campaign is grounded in:

- `triga/src/triga.fab`, `geometry.fab`, and `scene.fab`;
- `triga/exempla/threejs-host-demo/`, which currently delegates the visible
  render path to three.js;
- `radix/hosts/webgpu-browser/`, which directly executes emitted compute WGSL
  but uses three.js only for presentation;
- `faber-web/src/` and `faber-web/runtime/dom.ts`, which own the imported
  `web:web` and `web:dom` source/runtime contracts;
- Radix graphics MIR ABI and WGSL entry-contract code under
  `radix/crates/radix/src/mir/`;
- `triga/docs/factory/triga-threejs-80/goals/04-graphics-mir-shader-stages.md`;
  and
- `triga/docs/factory/triga-threejs-80/goals/05-direct-webgpu-first-scene.md`.

Current executable truth overrides status prose in those documents. At campaign
creation, Radix exposes vertex and fragment reflection and WGSL contract seams,
but canonical source device roles remain compute-oriented and the browser
reflection consumer admits compute kernels only.

## Current State

| Track | State | Next action |
| --- | --- | --- |
| Triga math and transforms | Camera, ray, AABB, collision extent, and first-person planar movement facts are locked | Preserve and consume |
| Triga scene identity | Stable scene-store source, resource transitions, and lifecycle-state fixtures exist | Reuse stable handles and lifecycle states for application objects and chunk resources |
| Triga geometry layouts | First-draw position/color layout, topology, index format, vertex-step mode, draw, and count facts are locked | Preserve and consume |
| Triga material policy | Opaque material, side, depth-test, and depth-write facts are locked | Preserve and consume |
| Graphics shader lowering | Partial MIR/WGSL contract seams | Lower Goal 01 after baseline lock |
| Browser WebGPU host | Direct compute path exists; visible graphics use three.js | Extend through Goal 02 |
| Browser application runtime | `faber-web` contracts and Faber `browser-app` packaging exist; frame/input lifecycle is missing | Extend through Goal 03 |
| Voxel domain | Not implemented | Begin only after indexed-cube crossover |
| Direct graphics proof | Not implemented | Goal 04 |
| Runtime clean break | Not achieved | Goal 08 |

## Campaign Path

### Goal 00 - Baseline And Contract Lock

**Status**: active
**Source**: [`goals/00-baseline-contract-lock.md`](goals/00-baseline-contract-lock.md)
**Contract map**: [`goal-00-contract-map.md`](goal-00-contract-map.md)
**Gate**: one checked boundary map names every Faber, Triga, Radix, host, and
browser fact required by the first indexed draw.
**Lowers to**: `delivery` -> `factory`
**Batching**: discovery-first
**Progress**: Triga-side executable-truth inventory is complete. Geometry now
locks first-draw layout, topology, index format, vertex-step mode, draw, and
count facts. Material policy now locks side, depth-test, and depth-write facts.
Interaction math now locks yaw/pitch rays and normalized planar movement deltas.
Ray/AABB hit facts now lock face codes and integer face offsets for edit
placement derivation.
Scene/resource facts now lock created, replaced, unchanged, and removed
single-resource lifecycle states for empty and non-empty chunk remeshes.
Radix red fixtures remain pending because Radix has active foreign
implementation work.

### Goal 01 - Source Graphics Pipeline

**Status**: planned
**Source**: [`goals/01-source-graphics-pipeline.md`](goals/01-source-graphics-pipeline.md)
**Depends on**: Goal 00
**Gate**: one Faber source fixture emits admitted vertex and fragment WGSL plus
complete reflection for the first render pipeline.
**Lowers to**: `delivery` -> `factory`
**Batching**: discovery-first

### Goal 02 - Reflection-Driven WebGPU Graphics Host

**Status**: planned
**Source**: [`goals/02-direct-webgpu-graphics-host.md`](goals/02-direct-webgpu-graphics-host.md)
**Depends on**: Goal 01
**Gate**: the browser host creates and executes an indexed render pass using
generated artifacts without three.js or WGSL parsing.
**Lowers to**: `delivery` -> `factory`
**Batching**: discovery-first, then batch descriptor families

### Goal 03 - Faber Browser Application Runtime

**Status**: planned
**Source**: [`goals/03-browser-application-runtime.md`](goals/03-browser-application-runtime.md)
**Depends on**: Goal 00; can overlap Goal 01
**Gate**: a Faber package owns frame updates, resize, keyboard, pointer, pointer
lock, and platform-failure handling through generated browser bindings.
**Lowers to**: `delivery` -> `factory`
**Batching**: split-on-boundary

### Goal 04 - Indexed Cube Crossover

**Status**: planned
**Source**: [`goals/04-indexed-cube-crossover.md`](goals/04-indexed-cube-crossover.md)
**Depends on**: Goals 01-03
**Gate**: a Faber-authored rotating indexed cube renders with a perspective
camera and depth testing through direct WebGPU.
**Lowers to**: `delivery` -> `factory`
**Batching**: one coherent vertical slice
**Release checkpoint**: record an internal direct-render milestone; do not
publish unless separately authorized.

### Goal 05 - Voxel World And Chunk Meshing

**Status**: planned
**Source**: [`goals/05-voxel-world-chunk-meshing.md`](goals/05-voxel-world-chunk-meshing.md)
**Depends on**: Goal 04
**Gate**: a deterministic bounded world becomes visible-face indexed chunk
meshes and renders without one scene object per block.
**Lowers to**: `delivery` -> `factory`
**Batching**: discovery-first, then batch face and boundary cases

### Goal 06 - First-Person Interaction

**Status**: planned
**Source**: [`goals/06-first-person-interaction.md`](goals/06-first-person-interaction.md)
**Depends on**: Goals 03 and 05
**Gate**: movement, collision, ray selection, removal, and placement work against
the authoritative voxel model.
**Lowers to**: `delivery` -> `factory`
**Batching**: split-on-boundary between movement/collision and edit semantics

### Goal 07 - Incremental Chunk Resource Lifecycle

**Status**: planned
**Source**: [`goals/07-incremental-chunk-resources.md`](goals/07-incremental-chunk-resources.md)
**Depends on**: Goals 05 and 06
**Gate**: an edit rebuilds and replaces only affected chunk resources, including
neighbor chunks when the edit crosses a chunk boundary.
**Lowers to**: `delivery` -> `factory`
**Batching**: discovery-first, then batch resource transition cases

### Goal 08 - Clean Break And Application Proof

**Status**: planned
**Source**: [`goals/08-clean-break-application-proof.md`](goals/08-clean-break-application-proof.md)
**Depends on**: Goals 00-07
**Gate**: Hello Voxel passes structural, browser, pixel, interaction, and
resource-lifecycle evidence with no third-party rendering runtime.
**Lowers to**: `delivery` -> `factory`
**Batching**: batch-by-default after the proof harness is admitted
**Release checkpoint**: decide whether to tag or publish only after the clean
break audit; no release is implied.

## Dependency Rules

- Extend the existing MIR GPU shader and ABI model. Do not create a
  Triga-specific shader compiler or reflection schema.
- If the host must guess a binding, layout, target, topology, depth, draw, or
  resource fact, stop and route the missing fact to Radix.
- If application code needs handwritten JavaScript to express game, scene,
  shader, or render behavior, stop and route the missing platform surface to
  Faber/Radix.
- Keep voxel storage independent of render meshes. Blocks are world facts;
  chunk meshes are derived resources.
- Do not represent each block as a scene node or GPU draw.
- A new language annotation or keyword requires a separate language-design
  decision and coordinated grammar, diagnostics, reader, and exemplar work.
- Browser unavailability can defer GPU execution evidence. It cannot convert
  static checks into a graphics-pass claim.
- The existing Triga Three.js 80 campaign remains a breadth reference. Goals 01
  and 02 are the active routing authority for overlapping graphics Stage 4/5
  work. Do not implement parallel shader or host paths.
- After Goal 08 passes, remove the obsolete three.js runtime fixtures instead
  of retaining compatibility aliases or fallback routes.

## First Useful Milestones

1. The source-to-WebGPU contract is locked with red proof fixtures.
2. Faber emits one complete vertex/fragment pipeline artifact.
3. A direct WebGPU indexed render pass executes without three.js.
4. A Faber-authored indexed cube is visible and interactive.
5. A bounded voxel world renders as chunk meshes.
6. The user can move, select, remove, and place blocks.
7. Edits update only affected GPU resources.
8. The clean-break audit admits Hello Voxel.

## Campaign Acceptance Criteria

This campaign artifact is ready for downstream work when:

- every active goal has a source document, dependency, gate, lowering path, and
  batching posture;
- Goal 00 is selected as the next stage;
- cross-repo ownership and Three.js 80 overlap rules are explicit;
- the bounded voxel application and all follow-up targets are separated;
- clean-break, generated-host, and evidence rules prevent proxy success; and
- release checkpoints do not imply publication authorization.

The implementation campaign is complete only when Goal 08 passes. Creating
delivery documents or rendering a static cube does not complete the campaign.

## Validation

Campaign maintenance:

```bash
find docs/factory/hello-voxel -type f | sort
rg -n 'Status|Depends on|Gate|Lowers to|Batching' \
  docs/factory/hello-voxel
```

Implementation validation is goal-specific. The final proof must include:

- Triga source and compile checks;
- Radix shader, reflection, and host tests;
- Faber package/browser artifact checks;
- actual browser WebGPU execution;
- deterministic canvas or pixel evidence;
- scripted input and edit evidence; and
- a scan proving no admitted runtime imports a third-party renderer.

## Open Questions

- Which existing Faber browser binding surface can be reused unchanged after
  Goal 00 inventory?
- Which graphics reflection fields remain compiler-owned gaps when the first
  indexed pipeline fixture is lowered? The current Goal 00 contract map names
  fragment reflection, render-pipeline reflection, and indexed-draw reflection
  as Radix-owned gaps.
- What deterministic bounded world dimensions and chunk dimensions best keep
  proof execution fast while exercising a chunk boundary?
- Which browser automation surface can provide repeatable WebGPU pixel and
  pointer-lock evidence in the current environment?

These questions belong to Goal 00 discovery unless they change the campaign
boundary.

## Stop Conditions

- Three.js or another renderer remains in the admitted runtime path.
- Handwritten WGSL replaces Faber-authored shader proof.
- Host JavaScript reconstructs scene, material, voxel, or draw policy.
- Reflection or Triga data is bypassed by field-name or shader-text inference.
- A static page, device acquisition, or pipeline creation is reported as a
  successful render without an executed render pass.
- The target expands to infinite terrain, multiplayer, general engine breadth,
  or a successor application before Goal 08.
- Existing foreign work in a shared repo is overwritten, reverted, or bundled
  into a Hello Voxel commit.
