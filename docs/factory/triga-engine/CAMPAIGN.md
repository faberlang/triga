# Campaign: Triga Engine And World-Building Architecture

**Status**: active (2026-08-01) — **S0 architecture checkpoint COMPLETE**; S1 seam repair lowered as six parallel delivery specs
**Mode**: run — campaign control plane
**Owner repo**: `/Users/ianzepp/work/faberlang/triga`
**Participating repos**: `triga`, `radix`, `hosts` (`webgpu-browser`), `faber`, `faber-runtime`, `examples`; `cista` only for an explicit distribution checkpoint
**Vision source**: [GOAL.md](GOAL.md) — Triga Engine And World-Building Architecture
**Checkpoint report**: [S0 report](checkpoint/report.md) — frozen ownership map, seam schedule, reflection boundary, runtime-home decision, first artifact
**Selected next stage**: S1 — Domain seam repair (Horizon 1); Wave 2 = six parallel delivery specs (DS-E geometry split, DS-A material→renderable, DS-B lighting, DS-D scene store/query, DS-G graph object/camera, DS-S2 engine extraction + vertical slice)
**Release posture**: foundation-first; no release before the first shared-renderer checkpoint; `cista` distribution only at an explicit release stage

## Summary

This campaign turns the Triga engine vision into a routed destination map for a
production-oriented 3D engine. Triga remains one versioned Faber source package,
organized as explicit importable modules representing the engine's semantic
lanes; the engine runtime is implemented at the host boundary, while Triga owns
the backend-neutral scene, resource, material, shader-intent, render-plan, and
world contracts the runtime executes. The campaign coordinates three kinds of
work: the architecture checkpoint and ownership map (S0–S1), the shared engine
runtime and render pipeline (S2–S4), and the world-building layer plus
production contract (S5–S7). It consumes the active [Triga Three.js 80
campaign](../triga-threejs-80/CAMPAIGN.md) as the capability delivery vehicle,
leaves [Triga Three.js 90](../triga-threejs-90/CAMPAIGN.md) parked as the
vehicle for the programmability/backend surface, and routes stages only through
`delivery` and `factory`. The campaign artifact routes stages; it does not
implement directly.

## Invariant

Triga remains one backend-neutral, versioned Faber source package whose public
modules are explicit semantic lanes; the shared engine runtime at the host
boundary consumes Radix reflection and explicit render facts, and no demo or
capstone carries a private renderer, pipeline, or shader copy. Three.js is a
reference and oracle only, never a permanent runtime layer.

## Problem

The [engine goal](GOAL.md) is deliberately a vision artifact, not an
implementation-ready specification. The gaps this campaign must close are
routing gaps, not code gaps:

- the goal names a target inventory of roughly fifty leaves across fifteen
  module families, but no live file ownership, fixtures, gates, or commit
  boundaries;
- the two existing capability campaigns assume the current flat module map
  (nine leaves) and do not own the engine runtime, the world layer, or the
  production contract;
- the seam repairs the goal demands (Mesh → renderable/mesh, MeshGeometry →
  geometry/data, scene store/query split, graph light fields → lighting) are
  time-sensitive: the active Three.js 80 campaign's upcoming material,
  lighting, and animation stages will grow the very monoliths the seams must
  split;
- nothing yet owns the shared engine runtime that replaces the corpus
  `_host` greybox renderer, nor the persistent world layer the capstone
  requires;
- the goal's own stop conditions (host guessing bindings, engine god module,
  demos carrying WGSL, credit for declarations) are architectural, and need a
  control plane that stops before they are violated.

A library-only roadmap would hide host and world blockers. A host-only roadmap
would bypass the compiler and scene contracts. This campaign keeps the
ownership map, the shared runtime, and the world workloads coupled while
preserving repository ownership.

## Desired End State

At campaign closeout:

1. One `triga` package organized as explicit semantic-lane modules with a
   frozen ownership map and acyclic dependency DAG, per the goal's inventory
   and current-to-target ownership corrections.
2. A shared engine runtime at the host boundary executes Triga/Radix facts;
   every standard demo and corpus workload uses the same engine package and
   host runtime with no private renderer, pipeline, or shader copy.
3. Triga public types remain backend-neutral; the host consumes compiler
   reflection and explicit render facts and never parses WGSL or recreates
   scene semantics.
4. A world-building layer owns persistent regions, terrain, reusable
   instances, bounded streaming, spatial queries, and placement, with world
   persistence expressed as stable semantic data and asset references.
5. The production contract holds: explicit engine states, bounded allocation
   and residency budgets, deterministic disposal, structured diagnostics,
   versioned manifests, reproducible cache identities, and instrumentation.
6. The world-building capstone (ten points in the goal) passes as an
   executable workload with negative evidence, not a declaration.
7. The Three.js 80 campaign's verified results are consumed without
   duplication; Three.js 90 remains the parked capability successor and the
   engine's S7 surface routes through it rather than forking it.

## Development Posture

- **Backend-neutral public model.** Triga public types carry no `GPUDevice`,
  `GPUBuffer`, `GPUTexture`, canvas handles, or backend objects. Backend
  specifics live in compiler reflection and host descriptors.
- **Clean breaks, justified by live consumers.** Existing internal callers are
  not automatic compatibility contracts. Every ownership correction is
  validated at the package boundary.
- **Shared engine, not per-demo renderers.** Demos are acceptance workloads
  that pressure the public surface; they do not become independent renderers.
- **Repair before expand.** The first architectural cleanup corrects ownership
  before features grow on top of monoliths; seam repairs interleave with the
  capability campaign's stage gates.
- **Fail closed.** Unsupported layouts, resource forms, passes, and target
  capabilities reject before draw or dispatch rather than degrading through
  guessed defaults.
- **Workload proven.** A capability claim requires an executable workload and
  negative evidence. Static source, generated WGSL, or reflection freshness
  alone cannot claim a working world renderer.
- **Three.js as oracle.** It may inform behavior and fixtures; it may not
  become a runtime implementation layer.
- **Portable world packages.** World packages reference assets, materials, and
  regions by stable identifiers and must not depend on the current browser,
  GPU vendor, adapter limits, or incidental cache layout.

## Implementation Workflow

For every campaign stage:

1. Use `delivery` to compile the whole stage into a durable delivery spec with
   live file ownership, fixtures, gates, and commit boundaries.
2. State one cross-repo invariant before implementation.
3. Use `factory` for implementation, targeted validation, review, and cohesive
   commits in each touched repository.
4. Update this campaign only for routing/status changes; keep detailed progress
   in the stage goal or its delivery spec.
5. For seam-repair stages, coordinate with the Three.js 80 stage gates through
   the S0 seam schedule; no seam lands during 80 Stages 4–5 without
   coordination.
6. Use `poker-face` before milestone promotion and final closeout.

Cross-repo changes use non-overlapping worktrees or serialized edits; no stage
may use Git cleanup to remove another session's work. Compiler work follows
Radix's compiler engineering rules; source-library work follows Triga's
`AGENTS.md` and the API shape policy.

## Scope Routing

| Surface | Canonical owner | Campaign responsibility |
| --- | --- | --- |
| Backend-neutral scene, material, shader-intent, render-plan, world contracts | `triga/src` | Ownership map, seam repairs, new families (lighting, renderable, shader, render, engine, asset, animation, world) |
| Instructional module examples | `triga/exempla` | Small source-level demonstrations |
| Browser-rendered engine workloads | `triga/corpus` | Shared-host demos pressuring the public surface; acceptance workloads |
| Language semantics, lowering, reflection, WGSL | `radix` | Typed shader/render facts, stage legality, target capability checks, artifact freshness |
| Engine runtime (frame, extraction, residency, caches, passes, streaming) | `hosts/webgpu-browser` | Shared engine facade and backend adapter; the corpus `_host` renderer is a seed, not the distribution |
| Provider routing kernel | `hosts/crates/host-kernel` | Remains provider-neutral; not the renderer |
| Generated Rust representations | `faber-runtime` | Application-lane generated code only; not the engine or a second scene model |
| Build/package orchestration | `faber` | Provider imports and multi-artifact build/run workflow |
| World-building capstones and regression corpus | `examples`, `triga/corpus` | Cross-repo scenes, assets, expected outputs, end-to-end workloads |
| Distribution and versioned installation | `cista` | Explicit release checkpoint only |

The campaign does not own physics, audio, WebXR, an editor, a web framework,
production deployment, or an exhaustive three.js/addon parity surface. Those
are adapters or separate products consuming the engine's stable seams.

## Batching And Split Policy

- **S0, S2, S4** are **discovery-first**: they establish the ownership map, the
  shared engine pattern, and the render-plan execution pattern respectively.
- **S1** is **split-on-boundary** at the named ownership seams (geometry split,
  material → renderable, scene store/query, graph → lighting). Each seam is one
  delivery spec, sequenced against the Three.js 80 stage gates by the S0 seam
  schedule.
- **S3 and S6** are **discovery-first** for their shared seams (shader-library
  specialization; scale proof), then **batch-by-default** for the homogeneous
  families (material families; culling/LOD/batching/instancing mechanisms).
- **S5** is **discovery-first per family** (glTF ingestion, animation, world
  regions/streaming), then batch within a family after its first integrated
  proof.
- **S7** is **discovery-first** and gated on stable public contracts.
- Do not pre-slice individual material parameters, generators, lights, tracks,
  passes, or world features into factory phases at campaign level.

## Ground Truth Researched

Local authority:

- [GOAL.md](GOAL.md) — the vision artifact this campaign routes; especially the
  file inventory, current-to-target ownership corrections, responsibilities by
  module family, host-side target structure, capability vision, capstone,
  invariants, stop conditions, validation direction, and later delivery
  questions.
- [module map](../../module-map.md) (2026-07-30) — current nine-leaf public
  surface; `geometry.fab` noted as large with a named next-seam condition.
- [API shape policy](../../api-shape-policy.md) (accepted 2026-07-27) —
  receiver methods on genera, Latin vocabulary, frozen ABI seam consumed by
  `radix-mir`, layer patterns, naming lint enforced by `check-source`.
- [AGENTS.md](../../../AGENTS.md) — module layout rules: one file per import
  path, nested packages only with ≥2 leaves (prefer 3+), no re-export, facade
  map-only, no `@ externa`/`@ subsidia`, `sponte` optional fields.
- [corpus README](../../../corpus/README.md) and `corpus/_host` — the shared
  greybox renderer, lit-mesh shader, and generated per-demo host assets that
  seed the shared engine runtime.
- [Triga Three.js 80](../triga-threejs-80/CAMPAIGN.md) (active, 2026-07-14
  status) — Stages 1–3 landed (math/transform, scene graph, geometry/
  attributes/primitives); Stage 4 in progress (graphics MIR and shader stages);
  Stages 5–12 planned (direct WebGPU first scene, materials/textures/lighting,
  cameras/culling/picking, animation, glTF, shadows/multipass,
  instancing/compute, capstone audit); five mandatory capstones.
- [Triga Three.js 90](../triga-threejs-90/CAMPAIGN.md) (parked successor) —
  activation gated on the 80 Stage 12 audit; six surfaces reserve ten
  provisional points (programmable materials, advanced PBR, compressed/streamed
  assets, render graph/image quality, backend portability, high-scale
  rendering).
- [factory README](../README.md) — open-campaign table and the note that the
  engine goal requires an architecture checkpoint before delivery.

## Current State

| Track | State | Next action |
| --- | --- | --- |
| S0 checkpoint | **Complete (2026-08-01)** — frozen ownership map, seam schedule, reflection boundary, runtime-home decision, first artifact; report at `checkpoint/report.md` | Lower S1 as six parallel delivery specs |
| Triga public API | Nine flat leaves; `geometry.fab` ~1343 lines (lint RED, acknowledged); `material.fab` ~183 lines owns `Material`, `Mesh`, `MeshGeometry` (all seam targets); no nested packages yet | S1 seam repairs (Wave 2: DS-E, DS-A, DS-B, DS-D, DS-G) |
| Module map | Living (2026-07-30); target map frozen at S0 and recorded in `docs/module-map.md` | Update per split as each seam lands |
| API shape policy | Accepted (2026-07-27); naming lint in `check-source` | Constrains every split and new leaf |
| triga-threejs-80 | Active; Stages 1–3 landed; Stage 4 in progress; Stages 5–12 planned | Continue as capability vehicle; engine consumes its outputs per seam schedule |
| triga-threejs-90 | Parked successor; activation gated on 80 Stage 12 | Stays parked; S7 routes through its surfaces (twin mapping frozen) |
| Corpus `_host` | Shared greybox renderer — **one-commit two-way fork of `hosts/webgpu-browser`** | DS-S2: extract into `hosts/webgpu-browser` `product/engine/` (decision (b)), first S2 delivery |
| Engine runtime | Does not exist as a product; `_host` is the only shared runtime | DS-S2 vertical slice |
| World layer | Absent (no world/asset/animation leaves) | S5–S6 |
| Capstones | Overlap table frozen at S0; engine-owned world-capstone ledger created | Record engine evidence per stage; 80's ledger stays read-only |

## Campaign Path

### S0 — Architecture checkpoint (Horizon 0)

**Status**: **complete (2026-08-01)** — report accepted: [`checkpoint/report.md`](checkpoint/report.md); six research tracks under `checkpoint/T-*.md`
**Source**: [GOAL.md](GOAL.md) Horizon 0; the goal's later-delivery questions
**Why now**: the goal declares the architecture checkpoint the only authorized
next step; every later stage and the overlap with 80 depend on the frozen
ownership map, the clean-break list, and the seam schedule.
**Deliverables**: frozen module map and dependency DAG (validated against the
nesting rule, API shape policy, and live consumers); clean-break list with
live-consumer justification; seam schedule against 80 Stages 6–9;
Triga/Radix/host reflection boundary; first engine artifact and capstone
definition; engine-runtime home decision (corpus `_host` seed vs. extraction
into `hosts/webgpu-browser`); routing contract with 80/90. Flag any target
leaves that would be empty facades and defer them to the horizon that fills
them.
**Gate**: checkpoint report accepted; module-map doc updated; `check-source`
and `check-compile` green; one bounded horizon selected for delivery lowering.
**Gate amendment (recorded at acceptance)**: both source gates are RED today,
both pre-existing (neither caused by this campaign): `check-source` on a naming-lint
item (`geometry_vertex_layout_matches`, src/geometry.fab:1332 — fixed inside DS-E),
and `check-compile` with 4 E0308 errors in regenerated `target/faber/src/main.rs`
(a faber generated-code lowering regression — fixtures verified correct in source;
restoration is a named precondition of every S1 delivery spec). Details:
[checkpoint report §0/§8/§9](checkpoint/report.md). The gate reads "green except
the two acknowledged items" until S1 lands.
**Lowers to**: `delivery` (research/report phase)
**Batching**: discovery-first

### S1 — Domain seam repair (Horizon 1)

**Status**: in progress (2026-08-01) — **DS-B lighting LANDED**, **DS-E geometry LANDED**
(C1+C2, deviations D1–D4 recorded), **DS-G graph LANDED** (object/camera leaves + all
consumer migrations + corpus demo `camera_controls` rename), **DS-S2 Phase 1 LANDED**
(hosts extraction + fork merge, 8/8 harnesses green), **G1 faber TS-emitter fix LANDED**
(recursive library module emit + binding-alias normalization; 632 faber tests pass).
**Corpus browser builds GREEN for both demos** (build-level; runtime render gates on
the P1.3 artifact regeneration, documented). **DS-A material→renderable UNBLOCKED** by
the union probe (cross-module union construction works; union `casu` fails even
same-module — consumers use the dedicated-accessor pattern; the `triga-types-untested`
fixture needs repair; a radix interface bug blocks `triga:material.Mesh` +
`triga:graph` co-import — probe during DS-A). **DS-D scene split PARKED** on G2
(cross-module enum variants) + G3 (faber import-cycle rejection) — language-decision
items. DS-S2 Phase 2 gated on 80 Stage 5; DS-E C3 rename gated on 80 Stage 4.
**Source**: [GOAL.md](GOAL.md) Horizon 1 and the current-to-target ownership
corrections table; [checkpoint report](checkpoint/report.md) §§1–3, §8
**Depends on**: S0 (seam schedule — frozen in the checkpoint report)
**Overlap rule**: each seam lands as a precondition of the 80 stage that would
otherwise grow the monolith — material → renderable before 80 Stage 6,
graph light fields → lighting before 80 Stages 6–7, scene store/query before
80 Stage 7, geometry data/attribute/layout/bounds split as the render pipeline
needs layout facts. No seam lands during 80 Stages 4–5 without coordination.
**Gate**: ownership corrections landed with live-consumer justification;
nested-package rule and API shape policy honored; generated-Rust gates honest;
`check-source` green (including the DS-E lint fix) and `check-compile` green.
**Lowers to**: `delivery` → `factory`
**Batching**: split-on-boundary at named seams (six specs); batch sub-parts within a seam

### S2 — Shared renderer vertical slice (Horizon 2)

**Status**: planned
**Source**: [GOAL.md](GOAL.md) Horizon 2 and the host-side target structure
**Depends on**: S0–S1; 80 Stage 5 (direct WebGPU first scene); the S0
engine-runtime-home decision
**Gate**: two unrelated demos render through one shared engine path with no
private renderer, pipeline, or shader copy: hierarchical world, camera, opaque
mesh, standard material, depth, resize, and deterministic failure states.
**Lowers to**: `delivery` → `factory`
**Batching**: discovery-first

### S3 — Materials and shader variants (Horizon 3)

**Status**: planned
**Source**: [GOAL.md](GOAL.md) Horizon 3 and the material/lighting/shader
responsibility sections
**Depends on**: S2; 80 Stage 6 (materials, textures, lighting)
**Overlap rule**: 80 Stage 6 establishes the material families on the repaired
seams; S3 adds the shared shader-library, specialization identity, pipeline
caching, and keeps raw WGSL out of the normal demo path.
**Gate**: unlit, lit, and metallic-roughness families; texture/sampler/resource
reflection; reproducible specialization and cache identities; no raw WGSL in
the normal public material path.
**Lowers to**: `delivery` → `factory`
**Batching**: discovery-first for the shader-library/specialization seam;
batch-by-default for material families

### S4 — Render graph and quality (Horizon 4)

**Status**: planned
**Source**: [GOAL.md](GOAL.md) Horizon 4 and the render responsibility section
**Depends on**: S3; 80 Stage 10 (shadows, render targets, postprocessing)
**Overlap rule**: consumes 80 Stage 10 multipass proof; moves the host from
imperative greybox rendering to render-plan execution per the S0
reflection-boundary decision.
**Gate**: explicit passes, targets, attachments, and hazards; shadows plus one
deterministic postprocessing chain; cycles, incompatible formats, stale sizes,
unsupported multisampling, and read/write hazards validated before submission.
**Lowers to**: `delivery` → `factory`
**Batching**: discovery-first

### S5 — Assets, animation, and world data (Horizon 5)

**Status**: planned
**Source**: [GOAL.md](GOAL.md) Horizon 5 and the asset/animation/world
responsibility sections
**Depends on**: S3–S4; 80 Stages 8–9 (animation, glTF/GLB ingestion)
**Overlap rule**: consumes 80's animation and glTF results; the persistent
world layer (regions, terrain, reusable instances, bounded streaming) is
engine-owned and new.
**Gate**: glTF/GLB semantic ingestion; animation and deformation; persistent
world regions, terrain, and reusable instances; bounded acquisition, residency,
and eviction; world save/load without GPU-handle leakage.
**Lowers to**: `delivery` → `factory`
**Batching**: discovery-first per family; batch-by-default within a family
after its first integrated proof

### S6 — World-building scale (Horizon 6)

**Status**: planned
**Source**: [GOAL.md](GOAL.md) Horizon 6 and the world-building capability
vision
**Depends on**: S5; 80 Stage 11 (instancing, particles, compute integration)
**Gate**: culling, LOD, batching, instancing, and region streaming at the scale
target frozen by S0, with frame-time, memory, upload, and residency
measurements; spatial queries, picking, placement, and camera navigation.
**Lowers to**: `delivery` → `factory`
**Batching**: discovery-first for the scale proof; batch mechanisms afterward

### S7 — Programmability and backend expansion (Horizon 7)

**Status**: planned — gated on stable public contracts; routes through the
parked 90 surfaces
**Source**: [GOAL.md](GOAL.md) Horizon 7; [Triga Three.js 90](../triga-threejs-90/CAMPAIGN.md)
**Depends on**: S5–S6; 90 activation posture
**Overlap rule**: 90 remains the parked capability-ledger owner for
programmability and backend portability; S7 is the engine-side half (world-
facing programmable materials, second-backend evidence) and must not fork the
public model per backend.
**Gate**: bounded typed programmable materials across supported stages; one
second backend selected and proven only after the public contracts are stable;
target differences explicit and fail closed.
**Lowers to**: `delivery` → `factory`
**Batching**: discovery-first

## Parallelism Windows

- S0 runs alongside 80 Stages 4–5: S0 is research/reporting, 80 is building the
  graphics MIR and direct WebGPU first scene; no file overlap.
- S1 interleaves with 80 Stages 6–9 through the seam schedule; each seam is a
  named boundary, not a parallel lane inside 80's files.
- S2 may begin once 80 Stage 5 lands and the S0 engine-runtime-home decision
  exists.
- S3 and S4 follow 80 Stages 6 and 10 respectively; they may overlap each other
  only when S4 consumes facts S3 does not own.
- S5 follows 80 Stages 8–9; the world layer may begin as soon as its public
  contracts are frozen, independent of 80's animation/glTF completion.
- S6 follows 80 Stage 11 for the instancing/compute seam and S5 for the scale
  workload.
- S7 coordinates with 90 activation; nothing proceeds before stable public
  contracts and the 80 Stage 12 audit that gates 90.

## Dependency Rules

- The engine campaign consumes 80/90 outputs; it never re-implements a seam 80
  owns, and no stage may use Git cleanup to remove another session's work.
  Cross-repo edits serialize or use non-overlapping worktrees.
- Seam repairs land as preconditions of the 80 stage that would grow the
  monolith, per the S0 seam schedule; no seam during 80 Stages 4–5 without
  coordination.
- Triga public types remain backend-neutral: no `GPUDevice`, `GPUBuffer`,
  `GPUTexture`, canvas handles, or backend descriptor models in public modules.
- The host consumes reflection and explicit render facts; if a stage needs the
  host to guess a missing binding, layout, resource, draw, or pipeline fact,
  stop and route the fact back to Radix.
- Render-graph facts split between Triga and Radix/MIR per the S0
  reflection-boundary decision; hosts may execute the graph but may not invent
  it.
- Raw WGSL is not the normal public material API; typed shader intent passes
  through Radix lowering, reflection, target checks, and engine caching.
- Nested module families need ≥2 leaves (prefer 3+), no type re-export, and
  map-only facades; a single-file family flattens to a top-level leaf.
- New language features (for example private-module visibility) require a
  separate language decision with coordinated grammar, diagnostics, reader,
  exempla, and implementation work; this campaign does not route them
  silently.
- Physics, audio, WebXR, and editor UI remain adapters consuming stable world
  and spatial seams; they are never mandatory core-renderer dependencies.
- World persistence is stable semantic data and asset references; browser or
  GPU handles never serialize into public Faber values.
- `cista` distribution and versioned engine-module packages happen only at an
  explicit release checkpoint with proven independent cadence, dependency
  ownership, or target isolation.
- A capability claim requires an executable workload and negative evidence at
  the goal's validation rungs; declarations, static WGSL, or a three.js visual
  substitute earn nothing.
- A feature that requires a backend-specific public Triga module, or a campaign
  score earned without the world capstone, stops the campaign for revision.

## First Useful Milestones

1. S0 checkpoint report accepted: frozen ownership map, dependency DAG,
   clean-break list, seam schedule, reflection boundary, first capstone.
2. First seam repaired (material → renderable) with `check-source`/
   `check-compile` and 80's affected gates green.
3. Two unrelated demos render through one shared engine path (S2 gate).
4. Standard material families with shared shader-library and pipeline caching
   (S3 gate).
5. Shadows plus one deterministic postprocessing chain from render-plan
   execution (S4 gate).
6. A glTF/GLB asset, an animated mesh, and a persistent world region (S5 gate).
7. A measured world-scale workload with culling/LOD/batching/instancing and
   streaming (S6 gate).
8. Bounded programmable materials and one second backend (S7 gate).
9. The ten-point world-building capstone passes with structured success,
   unsupported-capability, device-failure, and stale-artifact outcomes.

## Acceptance Criteria

This campaign artifact is ready when:

- S0 is selected as the next stage to lower;
- every stage has a status, source, dependency, gate, lowering path, and
  batching posture;
- the 80/90 overlap rules, the seam-timing posture, and the parallelism windows
  are explicit;
- the goal's invariants, stop conditions, and validation rungs are incorporated
  rather than paraphrased away;
- release checkpoints (including the `cista` distribution gate) are explicit;
- open routing decisions are listed and named as checkpoint inputs.

Campaign completion requires the goal's Desired End State: the frozen ownership
map, the shared engine runtime consumed by every standard demo, the world layer
and production contract, and the verified ten-point world capstone — not merely
completion of every planned stage document.

## Validation

Artifact validation:

```bash
find docs/factory/triga-engine -type f | sort
rg -n "Status|Depends on|Overlap rule|Gate|Lowers to|Batching|Stop Conditions" \
  docs/factory/triga-engine
git diff --check
```

Implementation validation is stage-owned and must climb the goal's honest
rungs: source checked → compiler lowered → reflection complete → host
instantiated → submitted → presented/read back → world result checked.
Required families include the Triga source/module-map checks, generated-Rust
acceptance where the application lane consumes types, Radix stage/reflection/
negative-target checks, host resource/pipeline/pass contract checks, browser
execution with explicit adapter/device evidence, deterministic structural or
pixel oracles, asset/world/streaming/disposal/device-loss failure cases, and
performance/memory measurements once world scale is claimed. The
`./scripta/check-source` and `./scripta/check-compile` gates stay green across
every stage; affected Three.js 80 stage gates stay green through the seam
schedule.

## Open Questions

- Which seams land before which 80 stages — final seam schedule from S0 live
  evidence and 80's actual fixture consumers.
- Engine-runtime home: extract `corpus/_host` into
  `hosts/webgpu-browser` `product/engine/`, or keep `_host` as the seed and
  grow it in place.
- First engine artifact and capstone: the exact first vertical slice and how
  the engine's ten-point world capstone reconciles with 80's five mandatory
  capstones.
- Render-graph fact split: which facts belong in Triga versus Radix/MIR
  reflection.
- Does Faber need a private-module visibility mechanism, or are public-leaf
  policies sufficient?
- Which world/asset persistence format is canonical for the first capstone.
- Which scale target makes culling, LOD, instancing, and streaming meaningful.
- Which second backend gives the most architectural information after WebGPU.
- Does the engine campaign maintain its own evidence ledger, or does it inherit
  the 80 campaign's capability ledger?

## Stop Conditions

Stop and revise the campaign if:

- `triga:engine` becomes a god module owning every domain type.
- Every new demo still carries a WGSL file or a private host renderer.
- Materials are selected by browser-side switches over Triga type names.
- Render-graph order exists only as imperative host code.
- The host guesses bindings, layouts, resources, or draw topology instead of
  consuming reflection and explicit facts.
- World streaming leaks GPU handles into public Faber values.
- A new feature requires a backend-specific public Triga module.
- A stage earns credit by declarations, static WGSL, or a three.js visual
  substitute rather than a real engine workload.
- Production readiness is claimed without the world-building capstone and
  documented performance/environment limits.
- A seam repair lands during 80 Stages 4–5, or overlaps another session's dirty
  work, without coordination.
- Scope expands into physics, audio, WebXR, editor tooling, deployment, or
  exhaustive addon parity without a new campaign decision.
