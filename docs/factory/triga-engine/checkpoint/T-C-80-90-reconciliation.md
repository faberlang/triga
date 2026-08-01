# Checkpoint T-C: Triga 80 / 90 / Engine Reconciliation

**Track**: engine-consumes dependency map and draft SEAM SCHEDULE
**Date**: 2026-08-01
**Scope**: `docs/factory/triga-threejs-80/**`, `docs/factory/triga-threejs-90/**`,
`docs/factory/triga-engine/{GOAL,CAMPAIGN}.md`, `docs/factory/README.md`
**Status**: draft evidence for the engine S0 seam schedule and routing contract.
Not an implementation decision. The final schedule is an S0 deliverable.

## Sources read (all inside the allowed root)

- `docs/factory/triga-threejs-80/CAMPAIGN.md` — stage statuses, gates, dependency
  rules, parallelism windows, stop conditions, scorecard.
- `docs/factory/triga-threejs-80/goals/00..12` — all thirteen goal files.
- `docs/factory/triga-threejs-80/stage1-poker-face-2026-07-11.md`,
  `stage1-poker-face-recheck-2026-07-11.md`,
  `stage2-generated-rust-acceptance-2026-07-13.md`,
  `stage4-readiness-map-2026-07-14.md` — what actually landed vs planned.
- `docs/factory/triga-threejs-80/00-capability-baseline-delivery.md`,
  `01-math-transform-delivery.md`, `02-scene-object-delivery.md`,
  `PROOF-HARNESS.md` — delivery/evidence-taxonomy detail.
- `docs/factory/triga-threejs-90/CAMPAIGN.md` + `goals/01..06` — the six parked
  surfaces and the activation gate.
- `docs/factory/triga-engine/GOAL.md` — ownership corrections table, Horizons
  1–7, module families.
- `docs/factory/triga-engine/CAMPAIGN.md` — engine S0–S7, the S1 overlap rule
  (the seam-timing posture this document evidences), current state.
- `docs/factory/README.md` — campaign status table.

Per scope rules I did **not** read `src/`, `exempla/`, `corpus/`. Claims about
live file contents (e.g., `material.fab` owning `Material`/`Mesh`/
`MeshGeometry`, `geometry.fab` ~1320 lines) are cited from the engine
CAMPAIGN.md Current State and the GOAL.md corrections table, not from source.

## Key precedent claims used (from the engine campaign itself)

The engine CAMPAIGN.md S1 overlap rule already names most seam→stage edges:

> each seam lands as a precondition of the 80 stage that would otherwise grow
> the monolith — material → renderable before 80 Stage 6, graph light fields →
> lighting before 80 Stages 6–7, scene store/query before 80 Stage 7, geometry
> data/attribute/layout/bounds split as the render pipeline needs layout facts.
> No seam lands during 80 Stages 4–5 without coordination.

This document supplies the goal-file evidence for those edges and pins the
previously-vague geometry split to a concrete precondition window.

---

## 1. The 80-stages table

Status legend: **C** complete, **G** gate green/accepted, **IP** in progress,
**P** planned. "Engine seam(s) it would conflict with" = the seams listed in
engine GOAL.md's current-to-target ownership corrections table.

| 80 Stage | Status (2026-08-01) | Triga modules/types it grows or touches | Engine seam it would conflict with if the seam lands late | Engine stage that consumes it |
| --- | --- | --- | --- | --- |
| **0** Capability baseline | **C** | `proof/capabilities.json`, `proof/capstones/*.json`, `scripta/check-capabilities`, `PROOF-HARNESS.md`; no `src/*.fab` | none | **S0** — ledger/scorecard inheritance (engine campaign open question: own ledger vs inherit) |
| **1** Math and transform foundation | **C** (foundation; re-poker-face CLEARED 2026-07-11; prior NOT CLEARED 2026-07-11 superseded) | `src/triga.fab` math families (Vector3/Matrix4/quat/Euler/Color/Box/Sphere/Plane/Ray), `exempla/triga-transforms.fab`; Radix vector/matrix intrinsics, WGSL register matrix subset, metal/llvm fail-closed | none (math is a seam foundation, not a seam target) | Foundation for all S1–S7 (implicit, not a named edge) |
| **2** Scene graph and object model | **G** — generated-Rust identity acceptance green; direct Radix scene-store check in `scripta/check-compile` | `src/scene.fab` (SceneStore, SceneNode group/mesh/camera/light variants, stable handles, reparent, traversal, world transforms, `scene_find_name`), `exempla/triga-scene-store.fab`; Radix arena/stable-reference facts | **scene store/query split** — the store landed pre-split; a late split becomes a move of landed code and collides with Stage 7 query growth | **S1** (split builds on the landed store), **S2** (hierarchical world), **S5** (world layer) |
| **3** Geometry, attributes, primitives | **G** — accepted on main `969b7cb` (Units 1–9) | `src/geometry.fab` (~1320 lines per engine CAMPAIGN: attribute/layout contract, `attribute_vertex_layout`, `geometry_vertex_layouts`, `geometry_vertex_layout_*` scalar accessors, bounds, normals, UVs, 7 primitives), `exempla/triga-stage4-source-facts.fab` | **geometry data/layout split** (monolith grew pre-split); **MeshGeometry → geometry/data** (the geometry family is now split across `src/geometry.fab` and `material.fab: MeshGeometry`) | **S1** (geometry split builds on it), **S2**, **S3**, **S5** (glTF) |
| **4** Graphics MIR and shader stages | **IP** — Radix vertex/fragment WGSL entry contracts, varyings, pipeline reflection, depth/stencil, multi-target output closed; **gate not met** (2026-07-18 check: source-level MIR lowering from `@vertex`/`@fragment` missing; reflection is test-constructed) | Radix MIR (`MirKernelShaderStage` fragment, `MirGraphicsPipelineReflection`, `MirDepthStencilState`, `validate_varying_compatibility`); Triga side done: vertex/layout contract v1 pinned in `src/geometry.fab` + `exempla/triga-stage4-source-facts.fab`; material source facts noted in `src/triga.fab` as Stage 6 shader inputs | **geometry data/layout split** — the Radix reflection agreement is being pinned against pre-split `geometry.fab` layout accessors | **S2** (direct host consumes reflection), **S3** (shader variants), **S4** (render-graph facts) |
| **5** Direct WebGPU host and first scene | **P** | `radix/hosts/webgpu-browser` (or successor) lifecycle; Triga scene/camera/indexed geometry/Mesh/basic-material types; `faber` artifact path; Hello Triga capstone (examples) | all four source seams — the capstone constructs/consumes Mesh, material, geometry, scene handles, camera, light node | **S2** (explicit named edge) |
| **6** Materials, textures, lighting | **P** | `src/material.fab` monolith (Material/Mesh/MeshGeometry per engine CAMPAIGN), texture/sampler/color-space contracts, graph.fab light fields → ambient/directional/point/spot/hemisphere families, Radix MIR resource reflection, browser host | **material → renderable**; **MeshGeometry → geometry/data**; **graph lights → lighting** — the three seams that gate Stage 6 | **S3** (explicit named edge) |
| **7** Cameras, culling, picking | **P** | `src/scene.fab` query growth (visibility, layers, frustum culling, render traversal); recommended new `src/picking.fab` (fieldboard note 2026-07-25); graph.fab camera; math Ray/Box3/Matrix4; browser host | **scene store/query split** (query surface grows on the 1100-line scene.fab); **graph lights → lighting**; **geometry data/layout** (bounds, ray tests) | **S6** (culling/picking/spatial queries), **S2** (camera) |
| **8** Animation and deformation | **P** | new animation leaf (clips, tracks, mixer, bones, skeleton, skin indices/weights), morph target attributes (geometry hooks), render-loop/dirty-transform/culling integration (scene) | **MeshGeometry → geometry/data** (morph/skin hooks), **geometry data/layout**, **scene store/query** (update ordering), renderable (skinned mesh) | **S5** (explicit named edge) |
| **9** glTF/GLB asset ingestion | **P** | new asset leaf (glTF/GLB parse → Mesh, MeshGeometry, materials, textures, cameras, punctual lights, skins, animations); `faber` byte/JSON support; host routes supply bytes only | **all four source seams** — the loader constructs every seam target; a private bypass violates its own stop condition | **S5** (explicit named edge) |
| **10** Shadows, render targets, post-processing | **P** | render-target/depth domain concepts (Triga render surface), Radix multipass reflection, browser host multipass | mild: scene store/query (render traversal), material seams (shadow depth behavior); mostly Radix/host | **S4** (explicit named edge) |
| **11** Instancing, particles, compute | **P** | instance data (renderable), points/particle geometry (geometry data), compute-to-render shared resources (Radix reflection + host) | **geometry data/layout** (instance/attribute growth), **scene store/query** (render traversal), renderable (instanced mesh) | **S6** (explicit named edge) |
| **12** Capstones and 80-point audit | **P** | all participating repos; poker-face; score/floor/capstone recompute; remaining-20% record | none directly — but audits "source-to-host ownership" and would record host workarounds caused by late seams as ratchets | **S7** (via 90 activation gate), **S0** (ledger reconciliation) |

---

## 2. Draft SEAM SCHEDULE

Seam definitions are the GOAL.md current-to-target ownership corrections. The
schedule states, per seam: the 80 stage it must precede, the 80 stage it must
NOT land during, and the suggested sequencing window, with the goal-file
evidence for each.

### Seam A — material → renderable (`material.fab: Mesh` → `renderable/mesh`)

- **Must precede**: 80 **Stage 6** (materials/textures/lighting).
- **Must NOT land during**: 80 Stage 6 (material families in flight), and 80
  Stages 4–5 without coordination (engine campaign rule).
- **Suggested window**: the **Stage 5→6 gap** — after 80 Stage 5's Hello Triga
  uses the existing Mesh type as-is, before 80 Stage 6 lowers. This matches the
  engine campaign's first-useful milestone ("first seam repaired (material →
  renderable)").
- **Evidence**:
  - Goal 06 scope: "Define a coherent material family covering basic/unlit,
    normal or classic lit, and metallic-roughness standard PBR; include only
    additional material variants that share the established implementation
    path."
  - Goal 06 gate: "Material/resource sharing and cache identity work across
    multiple meshes" — Mesh-as-composition is exactly the renderable seam.
  - Goal 06 invariant: "Materials and lights are backend-agnostic scene/domain
    values whose shader and resource requirements are derived by typed
    compiler/library contracts rather than host conditionals over class names."
  - Engine GOAL correction: "Mesh composes graph, geometry, and material."

### Seam B — MeshGeometry → geometry/data (`material.fab: MeshGeometry` → `geometry/data`)

- **Must precede**: 80 **Stage 6** (materials consume geometry data; the
  material side is where MeshGeometry currently sits), with **secondary
  deadlines** at 80 Stage 8 (morph/skin attribute hooks) and 80 Stage 9 (glTF
  geometry construction).
- **Must NOT land during**: 80 Stage 6, and 80 Stages 4–5 without coordination.
- **Suggested window**: same **Stage 5→6 gap** as Seam A. Both seams leave
  `material.fab`; the engine campaign's S1 grouping ("separate geometry data,
  materials, and renderables") supports delivering A+B as one `material.fab`
  repair, split-on-boundary but batched inside.
- **Evidence**:
  - Goal 08 scope: "Add morph target attributes and influence evaluation…
    bones, skeleton hierarchy, bind matrices, skin indices/weights" — geometry
    data hooks that must land on the right leaf.
  - Goal 09 scope: "meshes/primitives… construct only public Triga types."
  - Goal 09 stop condition: "Browser code parses glTF directly into GPU or
    host-private scene objects."
  - Engine GOAL correction: "Geometry data is not appearance state."

### Seam C — scene store/query split (`scene.fab` → `scene/store`, `scene/query`)

- **Must precede**: 80 **Stage 7** (cameras/culling/picking — the query-growth
  stage).
- **Must NOT land during**: 80 Stage 7 (query surface in flight), and 80 Stages
  4–5 without coordination.
- **Suggested window**: the **Stage 5→7 corridor** — after 80 Stage 2's store
  settled (already green, no reopen), after 80 Stage 5, and before 80 Stage 7
  lowers. 80's parallelism window allows Stage 7 to overlap Stage 6, so the
  seam should land before Stage 6 starts rather than in the 6/7 overlap.
- **Evidence**:
  - Goal 07 fieldboard note (attached 2026-07-25): "**New file:**
    `triga/src/picking.fab`. **Not in `scene.fab`** (already 1100 lines,
    'storage/traversal' scope)" — the 80 campaign already anticipates the
    split.
  - Goal 07 scope: "Integrate visibility flags, layers, frustum culling, and
    optional LOD behavior into render traversal without changing scene
    identity."
  - Goal 08 scope (secondary): animation "integrate… with dirty transforms,
    bounds, culling, resource updates, and render frames."
  - Engine GOAL correction: "Identity mutation and read-only traversal need
    separate seams."

### Seam D — graph lights → lighting (`graph.fab: light fields` → `lighting/light`)

- **Must precede**: 80 **Stage 6** (light families are Goal 06 scope) and 80
  **Stage 7** (lights participate in culling/picking scenes). The engine
  campaign rule says "before 80 Stages 6–7".
- **Must NOT land during**: 80 Stage 6 (light families in flight), and 80
  Stages 4–5 without coordination.
- **Suggested window**: same **Stage 5→6 gap** as Seams A+B — the light family
  growth is part of Goal 06, so D gates Stage 6 exactly like A and B.
- **Evidence**:
  - Goal 06 scope: "Cover ambient, directional, point, spot, and
    hemisphere-style light families where they share the selected light
    representation; defer shadow behavior to Goal 10."
  - Goal 09 scope (secondary deadline): glTF "selected punctual lights."
  - Engine GOAL correction: "Node placement and lighting semantics are
    different concerns."

### Seam E — geometry data/layout split (`geometry.fab` → `geometry/data`, `attribute`, `layout`, `bounds`, `batch`)

- **Must precede**: 80 **Stage 4** — the first render-pipeline consumer. The
  engine campaign rule phrases this as "geometry data/attribute/layout/bounds
  split **as the render pipeline needs layout facts**"; the render pipeline
  needs layout facts at 80 Stage 4 (MIR reflection agreement) and 80 Stage 5
  (direct host). Secondary deadlines: 80 Stage 8 (morph/skin attribute hooks)
  and 80 Stage 11 (instance attributes).
- **Must NOT land during**: 80 Stages 4–5 without coordination, and 80 Stage 8
  / Stage 11 (attribute growth on the mixed monolith).
- **Suggested window**: this is the **timing-critical seam**. Ideal sequence is
  the split as a precondition of Stage 4, before the Radix reflection fixture
  hardens against pre-split `geometry.fab`. But 80 Stage 4 is **in progress**
  as of 2026-08-01 and its Triga-side vertex/layout contract v1 is complete, so
  the practical windows are (a) land now with coordination before any remaining
  Stage 4 fixture work pins against the pre-split file, or (b) the **Stage 5→6
  gap** once the reflection agreement is closed. The split relocates already-
  landed accessor names (`attribute_vertex_layout`, `geometry_vertex_layouts`,
  `geometry_vertex_layout_*`); Radix matches facts, not file paths, so a
  coordinated landing is low-risk.
- **Evidence**:
  - Stage 4 readiness map ownership table: "Triga vertex/layout contract v1 |
    `triga` | Ready input" — the facts Stage 4's reflection must match.
  - Goal 04 progress: `attribute_vertex_layout` exposes "declared location,
    typed scalar/vector format, zero byte offset, derived byte stride, and
    per-vertex step mode as the CPU comparison seam"; `exempla/
    triga-stage4-source-facts.fab` pins the source-owned rows.
  - Goal 03 status: geometry landed pre-split in `src/geometry.fab` (the
    monolith the split repairs).
  - Engine GOAL correction: "CPU data, vertex layout, and host facts have
    distinct consumers."

### Schedule summary

| Seam | Must precede 80 stage | Must NOT land during 80 stages | Window |
| --- | --- | --- | --- |
| A material → renderable | 6 | 6; 4–5 (uncoordinated) | Stage 5→6 gap |
| B MeshGeometry → geometry/data | 6 (secondary: 8, 9) | 6; 4–5 (uncoordinated) | Stage 5→6 gap (bundle with A) |
| C scene store/query | 7 (secondary: 8) | 7; 4–5 (uncoordinated) | Stage 5→7 corridor, before Stage 6 |
| D graph lights → lighting | 6 and 7 | 6; 4–5 (uncoordinated) | Stage 5→6 gap (bundle with A) |
| E geometry data/layout | 4 (secondary: 8, 11) | 4–5 (uncoordinated); 8; 11 | before Stage 4 with coordination, else Stage 5→6 gap |

Note the concentration: Seams A, B, D all gate 80 **Stage 6**, and the Stage
5→6 gap is their common landing lane — which is why the engine campaign names
"material → renderable" as the first milestone seam and why the S1 repair batch
should plan A+B+D as one coordinated wave before 80 Stage 6 lowers. Seam E is
the only one whose strict precondition stage (4) is already in flight; it is
the seam most at risk of landing late.

---

## 3. The engine-consumes table

Engine stage → 80 preconditions → 90 overlap. Edges marked "explicit" are named
in the engine CAMPAIGN.md; the rest are derived from the S1 overlap rule, the
GOAL.md module families, and the 80 goal contents.

| Engine stage | 80 preconditions (evidence) | 90 overlap |
| --- | --- | --- |
| **S0** Architecture checkpoint | none — runs alongside 80 Stages 4–5 (research/report only); consumes 80 ledger and capstone manifests from 80 Stage 0 as reconciliation input | 90 Stage 0 activation brief (recorded, not activated) |
| **S1** Domain seam repair | 80 Stages 1–3 landed (math, scene store, geometry = the material to split); seams must precede 80 Stages 6/7 per the schedule above; no seam during 80 Stages 4–5 | none |
| **S2** Shared renderer vertical slice | 80 **Stage 5** (direct WebGPU first scene) — explicit | none |
| **S3** Materials and shader variants | 80 **Stage 6** (materials/textures/lighting) — explicit; 80 Stage 3 geometry attributes for material data | 90 Goal 02 (advanced PBR) adjacent — overlap risk (see §4) |
| **S4** Render graph and quality | 80 **Stage 10** (shadows/render targets/post-processing) — explicit | 90 Goal 04 (render graph/image quality) adjacent |
| **S5** Assets, animation, world data | 80 **Stages 8–9** (animation/deformation; glTF/GLB) — explicit | 90 Goal 03 (compressed/streamed assets) adjacent |
| **S6** World-building scale | 80 **Stage 11** (instancing/particles/compute) — explicit; 80 Stage 7 culling/picking/spatial facts | 90 Goal 06 (high-scale rendering) adjacent — overlap risk (see §4) |
| **S7** Programmability and backend expansion | 80 **Stage 12 audit** (gates 90 activation posture) — explicit; 80 Stage 4 typed shader-stage facts and 80 Stage 6 material contracts as the programmable-material substrate | **90 Goal 01 (programmable materials)** and **90 Goal 05 (backend portability)** — S7's twin surfaces; 90 owns the capability ledger, S7 is the engine-side half |

Cross-cutting: the engine campaign's dependency rules say the engine consumes
80/90 outputs and never re-implements a seam 80 owns. S1's seam repairs are the
only engine work that lands *inside* the 80 stage graph (as preconditions of 80
Stages 6/7), which is exactly why the S0 seam schedule is the binding contract
between the campaigns.

---

## 4. Conflicts and risks

### 4.1 80 goals whose scope would be broken or duplicated by an engine stage

1. **80 Stage 6 grows all three material/graph seam targets at once.**
   `material.fab` owns `Material`, `Mesh`, `MeshGeometry`; `graph.fab` owns the
   light fields. Goal 06 is the largest single monolith-growth stage (material
   families + texture/sampler contracts + five light families). If seams A/B/D
   land after Stage 6, the engine S1 repair becomes a clean-break move of the
   *expanded* monolith, and 80's own invariant ("no host conditionals over
   class names") is harder to hold because the host will have integrated
   against pre-split names. This is the highest-priority timing dependency.

2. **80 Stage 7 query growth vs the scene store/query seam.** The 80 campaign
   already anticipates the split — the fieldboard note explicitly refuses to
   put picking in `scene.fab` ("already 1100 lines, 'storage/traversal'
   scope") and recommends `src/picking.fab`. A late seam C would recreate the
   exact monolith the campaign avoids. Separate risk: engine S6's gate includes
   "spatial queries, picking, placement, camera navigation," which overlaps 80
   Goal 07's "one CPU raycasting path"; if the seam is late, S6 and Goal 07 can
   build two picking surfaces.

3. **80 Stage 9 glTF constructs every seam target.** The loader builds Mesh,
   MeshGeometry, materials, textures, cameras, punctual lights, skins, and
   animations. If any of seams A/B/C/D land after Stage 9, the post-split
   leaves become a second representation and the loader either bypasses public
   types (violating Goal 09's own stop condition) or must be rewritten twice.

4. **80 Stage 8 morph/skin hooks.** Morph target attributes and skin
   indices/weights are geometry-data growth (seams B/E territory) bound through
   skinned/morph renderables (seam A). Landing after Stage 8 puts deformation
   hooks on the wrong leaves; Goal 08's stop condition ("GPU skinning invents a
   separate skeleton or transform convention") is the failure mode.

5. **80 Stage 12 audit vs late seams.** Goal 12 audits "source-to-host
   ownership for shadow scene graphs, shader/layout guesses, host
   reimplementations." Late seams force temporary host-side workarounds that
   the audit will score as ratchets or stop-condition hits, not as engine
   progress.

### 4.2 90 surfaces that duplicate engine S7 (and the broader pattern)

- **90 Goal 01 (programmable materials, 3.0 pts) duplicates engine S7.**
  S7's gate is "bounded typed programmable materials across supported stages";
  Goal 01's surface is "a bounded Faber-native material composition model."
  Engine CAMPAIGN resolves this by ledger ownership: 90 stays the parked
  capability-ledger owner, S7 is the engine-side half ("must not fork the
  public model per backend"). The concrete risk is sequencing: S7 must not
  start before 90 activation (gated on 80 Stage 12), or the programmability
  surface is built twice.
- **90 Goal 05 (backend portability, 1.0 pt) duplicates engine S7.** S7's gate
  is "one second backend selected and proven only after the public contracts
  are stable"; Goal 05 is "one unchanged Triga scene through WebGPU and a
  selected second backend." Same ownership rule; same sequencing risk.
- **Broader pattern (adjacent, not S7):** each 90 surface has an engine twin —
  90 Goal 06 (high-scale rendering) ↔ engine S6 (world-building scale) on
  batching/LOD/visibility/residency; 90 Goal 04 (render graph) ↔ engine S4;
  90 Goal 02 (advanced PBR) ↔ engine S3; 90 Goal 03 (compressed assets) ↔
  engine S5. The anti-fork rule (public API never forks per backend; the host
  never re-implements) is what keeps these from colliding, but the engine
  campaign should record the twin mapping explicitly in S0.

### 4.3 Timing tension found

- **Seam E's precondition window overlaps the in-progress 80 Stage 4.** The
  strict rule ("as the render pipeline needs layout facts") points at Stage 4,
  which is mid-flight (2026-08-01) with its Triga-side contract complete and
  its reflection subset closed. A seam landing now requires coordination with
  the active Stage 4 session (the campaign's "no seam during 4–5 without
  coordination" rule); the safe fallback is the Stage 5→6 gap. This seam is the
  one most likely to slip, and the schedule above should treat it as the
  coordination-critical item.

## Uncertainty notes

- "material.fab ~180 lines owns Material, Mesh, MeshGeometry" is the engine
  CAMPAIGN's Current State claim; I did not verify it in `src/` (out of scope
  for this track). The 80 goal files never name `material.fab` directly.
- 80 Stage 4's status has two date-stamps: the goal file header says "in
  progress" with a 2026-07-18 gate check "not complete"; the CAMPAIGN header
  (2026-07-14) selects Stage 4 as next. Both agree Stage 4 is the active stage;
  the gate is not yet met.
- The engine CAMPAIGN's S1 overlap rule names seams A, C, D explicitly and
  leaves E deliberately vague ("as the render pipeline needs layout facts").
  The assignment of E's precondition to 80 Stage 4 is my inference from the
  Stage 4 readiness map and Goal 04 progress, flagged as an inference.
- 90 goals 01–06 are surface briefs with no delivery detail; the "duplicate S7"
  judgment is based on surface text, not implementation plans.
