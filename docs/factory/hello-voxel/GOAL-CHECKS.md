# Hello Voxel Goal Checks

**Evaluator mode**: self-contained cold pass
**Handoff bar**: mid-tier implementation model through `delivery`, then factory
**Reviewed**: all goal artifacts under [`goals/`](goals/)
**Overall verdict**: READY for delivery lowering

## Method

Each goal was checked for a concrete end state, live repository grounding,
canonical ownership, data and control flow, compatibility posture, bounded
scope, acceptance signals, validation, implementation touchpoints, open
questions, and stop conditions. Dependency-blocked goals can be READY as
artifacts even when factory cannot execute them yet.

The first pass found shared blocking gaps: the first graphics data contract,
browser artifact shape, voxel dimensions, chunk dimensions, storage indexing,
interaction semantics, and resource retirement rule were not locked. The goal
documents now contain those decisions and concrete source paths.

## Goal 00 - Baseline And Contract Lock

**Verdict**: READY
**Consumer**: delivery

The discovery outcome, authoritative live paths, stale-claim warning, red-proof
requirement, and ownership matrix are explicit. The goal does not require the
implementer to choose a graphics architecture. Its open findings are intended
outputs of the baseline rather than hidden product decisions.

## Goal 01 - Source Graphics Pipeline

**Verdict**: READY
**Consumer**: delivery, then factory after Goal 00

The vertex layout, index type, transform binding, stage inputs/outputs, color
and depth formats, topology, draw facts, compiler ownership, and exact Radix
touchpoints are locked. The goal explicitly starts from current source truth:
fragment is not admitted in `MirKernelShaderStage`, and the current source
vertex path is a driver scaffold.

## Goal 02 - Reflection-Driven WebGPU Graphics Host

**Verdict**: READY
**Consumer**: delivery, then factory after Goal 01

The existing browser host is canonical. Descriptor admission, WebGPU effects,
artifact inputs, canvas/depth formats, resize behavior, proof state, compute
regression requirement, and no-WGSL-parsing boundary are specific. WebGL and
third-party renderer fallbacks are excluded.

## Goal 03 - Faber Browser Application Runtime

**Verdict**: READY
**Consumer**: delivery, then factory after Goal 00

The existing `browser-app` and `WebController` path is canonical. Event names,
key semantics, pointer-lock rules, animation-frame ownership, cleanup behavior,
package location, generated boundary, and Faber code touchpoints are explicit.
The live owner is locked to sibling `faber-web`: source contracts in `src/` and
browser effects in `runtime/dom.ts`.

## Goal 04 - Indexed Cube Crossover

**Verdict**: READY
**Consumer**: delivery, then factory after Goals 01-03

The application location, cube payload, shader/resource contract, matrix
ownership, frame update, camera behavior, depth requirement, and visible-output
evidence are fixed. Host-side construction and isolated proxy proofs are barred.

## Goal 05 - Voxel World And Chunk Meshing

**Verdict**: READY
**Consumer**: delivery, then factory after Goal 04

World and chunk dimensions, coordinate convention, block ids, flat indexing,
deterministic fixture features, face generation, vertex/index emission, draw
granularity, source ownership, and boundary cases are locked. Optimization and
streaming cannot enter the first implementation.

## Goal 06 - First-Person Interaction

**Verdict**: READY
**Consumer**: delivery, then factory after Goals 03 and 05

Yaw/pitch, input state, time normalization, player bounds, collision order,
gravity posture, spawn, DDA range, removal/placement semantics, overlap rule,
source ownership, and deterministic tests are concrete. Full gameplay and GPU
picking remain excluded.

## Goal 07 - Incremental Chunk Resource Lifecycle

**Verdict**: READY
**Consumer**: delivery, then factory after Goals 05 and 06

Dirty-chunk rules, frame batching, stable logical identity, empty/non-empty
transitions, queue completion, destruction timing, and proof counters are
explicit. The split between Faber invalidation and browser-owned GPU disposal
is canonical.

## Goal 08 - Clean Break And Application Proof

**Verdict**: READY
**Consumer**: delivery, then factory after Goals 00-07

The canonical package, proof state, scripted flow, pixel/structural evidence,
exact runtime removal surfaces, capability-ledger honesty, bounded dependency
scan, independent review, release deferral, and no-fallback posture are locked.

## Factory Handoff

All nine goals pass the goal-check definition bar. Factory vision can admit all
nine boundaries, but production may select only dependency-unblocked units.
Goal 00 is the current unit. See [`FACTORY-READINESS.md`](FACTORY-READINESS.md)
and [`deliveries/`](deliveries/).
