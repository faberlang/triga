# S0 Architecture Checkpoint Report — Triga Engine Campaign

**Status**: accepted (2026-08-01) — decision-grade integration of six parallel research tracks
**Inputs**: [GOAL.md](../GOAL.md), [CAMPAIGN.md](../CAMPAIGN.md), six track findings
(`T-A-inventory.md`, `T-B-seam-consumers.md`, `T-C-80-90-reconciliation.md`,
`T-D-reflection-boundary.md`, `T-E-runtime-home.md`, `T-F-capstone-first-artifact.md`),
live spot-verification (naming-lint RED confirmed, zero `Light` consumers confirmed,
`check-compile` gate run in parallel)
**Decision authority**: this report freezes the ownership map, clean-break list, seam
schedule, reflection boundary, engine-runtime home, first engine artifact, and the
80/90 routing contract. Later stages consume it; they do not re-litigate it.

## 0. Executive summary

- The GOAL's inventory is structurally sound (no nesting-rule violation; every
  proposed package has ≥3 leaves) but **36 of 61 leaves would own nothing today**.
  The map freezes only the leaves with live content; everything else is recorded as
  **planned**, not created.
- Four seams repair cleanly, with risk verdicts: **B lighting is free, A
  material→renderable is low-risk, D scene store/query is risky-by-gate-pinning,
  E geometry is risky-by-in-flight-Stage-4**. A fifth, the graph `object`/`camera`
  split, is moderate (two live corpus consumers).
- The seam schedule is the binding contract with the active Three.js 80 campaign:
  seams A, B, D land in the Stage 5→6 gap; seam C (scene) lands before 80 Stage 7;
  seam E (geometry) is the coordination-critical item (ideal precondition is 80
  Stage 4, which is in flight — land now with coordination or in the Stage 5→6 gap).
- The reflection boundary is frozen: **Triga declares backend-neutral render intent,
  Radix lowers/validates/reflects, the host executes and invents nothing**. Eleven
  named gaps exist today; the two biggest are draw facts (host draw manifest) and
  the entire pass-DAG/hazard layer.
- The engine runtime **must not stay in `corpus/_host`**: it is a one-commit,
  two-way-divergent fork of `hosts/webgpu-browser`. Decision: **extract into
  `hosts/webgpu-browser` `product/engine/` now, as the first S2 delivery**.
- The first engine artifact is **S2-First Engine Render**: Demo A = 80 Stage 5's
  Hello Triga workload, Demo B = corpus `webgl-geometry-terrain`, driven through one
  shared engine facade with numeric/pixel/structural/shared-instance oracles.
- World persistence is **hybrid**: glTF/GLB asset payloads + a versioned
  `triga.world.v1` manifest; the schema contract freezes now, load/save lands at S5.
- One gate amendment: **both source gates are RED today, both pre-existing**
  (tree was clean except docs at session start; neither caused by this campaign).
  1. `check-source` RED on a naming-lint failure (`geometry_vertex_layout_matches`,
     src/geometry.fab:1332) — scheduled for fix inside the geometry split (DS-E).
  2. `check-compile` RED with **4 E0308 errors in regenerated
     `target/faber/src/main.rs`**: `store.insere(&mesh_node.clone())` and
     `store.cape(&mesh_handle.clone())` passed to by-value params (generated from
     correct fixture calls `insere(mesh_node)` / `cape(mesh_handle)`), and
     `Some(onus.byte_count())` wrapping a `∪ nihil` binding (src/scene.fab:806,
     generated as `let bytes: Option<i64> = Some(onus.byte_count())`). Fixtures are
     verified correct in source; the generator injects `&…clone()` args and
     `Some(…)` wraps — a **faber generated-code lowering regression**, likely
     since 80's Stage 2 generated-Rust acceptance (2026-07-13). Root-cause owner:
     the faber Rust emitter, coordinated through the 80 generated-Rust acceptance
     lane; the S1 gate reads "check-source and check-compile green" with both items
     acknowledged and scheduled (DS-E owns the lint; the compile-gate restoration is
     a named precondition of every S1 delivery spec).

## 1. Frozen module ownership map

Corrected inventory: **61 non-facade leaves + 13 family facades + `triga` = 75 import
paths** (the GOAL's "~50 leaves" undercounts). Three states:

### 1.1 Freeze as-is (existing leaves, heavy live consumption, no split)

| Leaf | Reason |
| --- | --- |
| `math.fab` (~850 ln) | Bounds/Ray/face-code tables interdepend (`RayBox3Hit`); no split |
| `resource.fab` (~547 ln) | Logical handle/lifecycle; no split |
| `face.fab` (~39 ln) | Small helper; no split |
| `triga.fab` (facade) | Map-only; no genera ever (god-module stop condition) |

### 1.2 Split now (S1 / Horizon 1) — all leaves have live content

| Family | Leaves | Notes |
| --- | --- | --- |
| `scene` | `node`, `store`, `query` | Lowest-risk split; zero corpus consumers; pure relocation with unchanged interface names; gate on nested-package tooling check (DEFER-121) |
| `geometry` | `data`, `attribute`, `layout`, `bounds`, `batch` | Fixes the naming lint; preserves frozen ABI names verbatim; **MeshGeometry retires into `BufferGeometry` (see 1.4.3)** |
| `material` | `base`, `basic`, `lit`, `standard` | `Mesh` moves to `renderable/mesh`; `MaterialPipelineFacts.side_code` preserved; `texture`/`sampler` deferred to H3 |
| `renderable` | `mesh` | `Mesh` = graph + geometry + material composition; `skin`/`morph`/`instance` deferred to H5/H6 |
| `lighting` | `light` | Families move from `graph.fab`; zero consumers; `model`/`environment`/`shadow` deferred to H3/H5/H4 |
| `primitives` | `basic` | `procedural`/`terrain`/`voxel` deferred (corpus `terrain.fab` generator is the H5 seed) |
| `graph` | `object`, `camera` | Two live corpus consumers migrate to leaf imports in the same change; `graph/light` is **dropped** (1.4.1) |

### 1.3 Planned — do NOT create empty leaves

| Family | Fills at |
| --- | --- |
| `engine/{renderer,frame,session,capability}` | H2 (the S2 slice is the first owner) |
| `shader/*` (5 leaves) | H3 (program at H7) |
| `render/*` (7 leaves) | H4 |
| `asset/*`, `animation/*`, `world/{region,terrain,stream,instance}`, `renderable/{skin,morph}`, `primitives/{procedural,terrain,voxel}`, `lighting/environment` | H5 |
| `world/query`, `renderable/instance`, `engine/capability` | H6 |
| `material/{texture,sampler}` | H3 (only a placeholder `TextureDescriptor` exists today) |

Creating empty directories to satisfy the nesting rule would invert its intent
(module-map guidance: "next seam only if a second importer wants"). Each planned
family is recorded here as the future home; a delivery creates a leaf only when it
has content.

### 1.4 Inventory corrections resolved at this checkpoint

1. **`graph/light` dropped.** Today's light genera are already attachments
   (`Light { Object3D base; Color color; f32 intensity }`); there is no separate
   attachment to split off. Light *family* semantics move to `lighting/light`
   (importing `graph/object` — same-level, no cycle). `graph` keeps `object` +
   `camera` (2 leaves, legal).
2. **Bounds dualism resolved.** `Box3`/`Sphere` stay in `math` (RayBox3Hit and
   face-code tables depend on them). `geometry/bounds` owns only the geometry-side
   `BoundingBox`/`BoundingSphere`; its doc comment will state the distinction.
3. **`MeshGeometry` retired.** `material.fab`'s flat-SoA `MeshGeometry` and
   `geometry.fab`'s list-of-attributes `BufferGeometry` are two parallel geometry
   types. Clean break: `Mesh.geometry` becomes `BufferGeometry` (in `geometry/data`);
   `MeshGeometry` is removed. Exactly one live fixture constructs it
   (`exempla/triga-types-untested.fab`), which migrates.
4. **Leaf count corrected** to 61/75 at freeze so the ownership map is accurate.
5. **`cista.toml`** is a future distribution file, not current — the map notes it
   without treating it as live.
6. **Draw-batch facts get an explicit home.** Geometry-side payload/byte-count facts
   (`GeometryDrawCommand`, `GeometryGroup`, `Indexed/LineGeometryDrawBatchFacts`)
   land in `geometry/batch`; submission-group/instancing facts land in `render/batch`
   at H4. No orphan between the two packages.
7. **Facade rule enforced at split time:** each split must empty its facade file of
   genera (a split that leaves one genus behind turns the facade into a compat
   barrel). No type re-export anywhere.

## 2. Clean-break list with risk verdicts

| # | Seam | Move | Live consumers | Risk | Timing constraint |
| --- | --- | --- | --- | --- | --- |
| B | graph lights → lighting | light families to `lighting/light`; graph keeps attachments | **zero** Faber constructors (verified by grep) | **free** | before 80 Stage 6 (light families) |
| A | material → renderable | `Mesh` → `renderable/mesh`; `MeshGeometry` retirement (with E) | 1 exemplum (gate-breaking fixture) | **low** | before 80 Stage 6 |
| D | scene store/query | `scene.fab` → `scene/{node,store,query}` | 2 exempla, heaviest gate pinning (Stage 2 acceptance + direct Radix check in `check-compile`) | **risky by pinning** | before 80 Stage 7 |
| G | graph object/camera | `graph.fab` → `graph/{object,camera}` | 2 corpus demos + 2 exempla | **moderate** | any time in S1; not with B |
| E | geometry data/layout | `geometry.fab` → `geometry/{data,attribute,layout,bounds,batch}` | 2 internal modules, 5 exempla, 1 corpus demo, Stage 4 reflection pinning | **risky mid-flight** | coordinate with 80 Stage 4; else Stage 5→6 gap |

Seam urgency (cheapest first, verified): **B → A → D → C(scene) → E(geometry)**.
The G split is tracked separately (T-B: do not conflate B with the graph family
split).

## 3. Seam schedule — binding contract with the Three.js 80 campaign

| Seam | Must precede 80 stage | Must NOT land during 80 stages | Window |
| --- | --- | --- | --- |
| A material → renderable | 6 | 6; 4–5 (uncoordinated) | Stage 5→6 gap |
| B MeshGeometry → geometry/data | 6 (secondary: 8, 9) | 6; 4–5 (uncoordinated) | Stage 5→6 gap (bundle with A) |
| C scene store/query | 7 (secondary: 8) | 7; 4–5 (uncoordinated) | Stage 5→7 corridor, before Stage 6 |
| D graph lights → lighting | 6 and 7 | 6; 4–5 (uncoordinated) | Stage 5→6 gap (bundle with A) |
| E geometry data/layout | 4 (secondary: 8, 11) | 4–5 (uncoordinated); 8; 11 | before Stage 4 with coordination, else Stage 5→6 gap |

Rules that hold regardless of window:

- **No seam lands during 80 Stages 4–5 without coordination.** Stage 4 is in flight
  (2026-08-01) with its Triga-side vertex/layout contract complete; its reflection
  agreement pins the `geometry_vertex_layout_*` accessor names. A **pure relocation
  preserving accessor names and owners is fixture-churn-only** and is the safe form
  for the geometry split; any rename (e.g. the lint fix) is coordinated with Stage 4.
- Seams A, B, D all gate 80 **Stage 6**; the Stage 5→6 gap is their common landing
  lane. S1 plans A+B+D as one coordinated wave.
- Seam E is the one most at risk of landing late; it is the coordination-critical item.

## 4. Reflection boundary (frozen)

### 4.1 The split

- **Triga owns** (backend-neutral Faber facts, declared via the same
  `adfirma`/API-call pattern the compiler already recognizes): render items and draw
  ranges; render passes; targets/attachments (incl. depth format, MSAA, multi-target
  sets); pass DAG + hazards (validated in Triga before submission); batching/
  submission groups; required vs optional capability set; full pipeline-state intent
  (cull, blend, stencil, topology).
- **Radix/MIR owns**: stage legality; stage IO/varying/resource reflection; pipeline
  reflection (topology, color targets, depth/stencil, vertex count); draw reflection
  **once Triga declares draw facts**; compile-time target capability
  (`target-capability-matrix.md`); WGSL emission; fail-closed diagnostics.
- **Host owns**: device creation, residency, pipeline caching, runtime capability
  admission — consuming reflection + declared facts, inventing nothing.

### 4.2 The eleven gaps (host would guess today = the goal's named violation)

G1 draw facts (index format/count, first index, base vertex, instance count) — host
draw manifest today → Triga `render/item` declares, Radix reflects. **G2** depth
format (`depth24plus` host constant) → `render/target`. **G3** cull mode (two host
sites) → `render/pipeline`. **G4** blend state/alpha → pipeline-state facts. **G5**
MSAA/sample count → `render/target`. **G6** multi-color-target → target-set facts
(structurally possible in the emitter; no Triga source path). **G7** stencil source
facts (structs fully modeled; nothing feeds them) → pipeline-state facts. **G8** pass
membership + DAG + hazards + submission groups (nothing anywhere) → `render/{pass,
graph,batch}`. **G9** runtime device capability facts → Triga declares required/
optional set; host admits against it. **G10** explicit varying/fragment-output/
resource-binding source facts (currently derived or hardcoded defaults in the driver)
→ Triga API calls. **G11** shader-resource payload semantics (WGSL emitter hardcodes
a locked MVP transform layout) → `shader/resource`.

Biggest: **G1 + G8** — draw facts are the smallest live violation (the host already
carries a draw manifest); the pass-DAG/hazard layer is the largest absent family.

### 4.3 Frozen-ABI rules for new Triga fact genera

1. Enumerated/backend-mapped values stay **`_code: u32`** with a fail-closed decoder
   in `radix-mir` (e.g. `index_format_code`, `cull_mode_code`, `blend_factor_code`,
   `blend_op_code`, `stencil_op_code` — the `MirStencilOp` decode target exists).
2. Quantities stay raw numerics (`offset_bytes`, `stride_bytes`, `vertex_count`,
   `element_count`, sample counts, draw-range numbers). Booleans stay booleans.
3. The existing **silent-default decoders** (`step_mode_code`, `depth_compare_code`,
   `kind_code`, `role_code`, `access_code`) are acknowledged debt contradicting
   fail-closed posture; tightened when the seam is next touched. New decoders are
   fail-closed from the start.
4. New graphics-reflection fields are **leaf-owned MINOR schema bumps**
   (reflection-reciprocity §4); spine-frozen fields (`schema_version`, `target`,
   `kernels`, `webgpu_adapter`) need Mind approval.

### 4.4 Artifact honesty flags

- The three corpus `reflection.json` fixtures are **stale relative to the live
  emitter**: `"kind": "UniformBuffer"`/`"role": "Uniform"` are not emittable by any
  radix enum (StorageBuffer-only; Input/Output roles), and the fixtures lack
  `schema_version`/`target`. They must be regenerated through the radix path before
  host admission is built on them (coordinated with 80 Stage 4–5).
- `buildDescriptorFromReflection` (greybox-host.js) hand-rolls admission from the
  old format and would be **retired** once artifacts are regenerated — the shared
  `loadFaberGraphicsPipeline` becomes the only admission path.

## 5. Engine-runtime home (decision)

**Decision (b): extract `corpus/_host` into `hosts/webgpu-browser` `public/src/
{product,contract,engine,backend,presentation}`, landed as the first S2 delivery.**

- `corpus/_host` is a one-commit (2026-07-31, `806aa21`) fork of
  `hosts/webgpu-browser` runtime code, already diverged **two ways**: `faber-kernel.js`
  is byte-identical in both repos; `webgpu-runtime.js` differs by 450 lines
  (hosts-only reduction helpers; corpus-only MSAA 4×, uniform usage, greybox scene
  layer). Neither copy is a strict superset. `hosts/webgpu-browser` is authoritative
  (origin 2026-07-20, continuously evolved).
- The corpus demos are the S2 gate's two consumers; extraction is the S2
  precondition, not an S2.5. Growing `_host` in place contradicts triga `AGENTS.md`,
  the GOAL corrections, and scope routing; deferring guarantees a second migration.
- **Migration mapping** (from T-E): `faber-kernel.js` → `contract/artifact-admission.js`
  (keep the hosts copy); `webgpu-runtime.js` → `backend/webgpu-*` + `engine/
  resource-manager.js` (**merge first**: hosts base, re-apply corpus MSAA/uniform
  deltas); `greybox-host.js` → `engine/{engine,scene-extractor,resource-manager}`,
  with `buildDescriptorFromReflection` retired; `host-init.js` → `product/bootstrap`
  + `engine/frame-scheduler` + `presentation/{canvas,debug-overlay}`;
  `kernel.wgsl`/`reflection.json` → `generated/triga-lit.*`, **regenerated through
  radix** to the current format.
- **Corpus build flow**: `tests/run.sh` `HOST_DIR` switches from `$APP_DIR/../_host`
  to `$WORKSPACE/hosts/webgpu-browser` (same sibling-package precedent as
  `faber-web`); page imports move from `../public/host-init.js` to the shared
  bootstrap/facade; contract greps re-point at the new surface.
- **Sequencing**: land the hosts side first (merge + rewire), then rewire `run.sh`;
  gate on hosts `*-check.mjs` harnesses + both corpus demos; both trees currently
  clean. Triga `.fab` gates unaffected (no `.fab` changes in this delivery).
- The fine-grained 9-file `engine/*` lane split lands progressively as S2/S3
  stabilize contracts (the GOAL itself defers the exact split).

## 6. First engine artifact + capstone ownership

### 6.1 First engine artifact: S2-First Engine Render

A shared-renderer vertical slice with **no new invented workload**:

- **Demo A** = 80 Stage 5's Hello Triga workload (hierarchical world from the Stage 2
  scene store: rotating indexed mesh, one opaque engine-owned standard material, one
  directional light, perspective camera).
- **Demo B** = corpus `webgl-geometry-terrain` (48² heightfield, ~4.6k triangles,
  value noise, per-vertex colors) — genuinely unrelated construction, which is what
  the "two unrelated demos" gate demands.
- **"Standard material" at S2** = a single engine-owned opaque material derived from
  the existing `_host` lit shader (flat color + one directional light + depth) — not
  the PBR family (that is S3 / 80 Stage 6).
- **Oracles**: numeric (world-transform sequence, extractor-equals-traversal,
  draw-count), pixel (deterministic reference images), structural (demo bundles
  contain no WGSL and no render loop/pipeline creation — grep-able), shared-instance
  (both demos share one shader-module/pipeline-cache identity).
- **Deterministic failures**: unsupported capability → typed rejection before draw;
  stale/missing artifact → admission rejects; device loss → suspended→recovering
  state machine; resize → deterministic aspect-correct frame.
- **Deliberate deferrals**: textures/samplers, multi-light, transparency, shadows/
  post, instancing/compute, glTF, animation, world regions/streaming, picking,
  render-plan execution (S2 runs the shared imperative pass path).
- One delivery spec with a factory phase chain (A facade+state machine → B
  extractor+resource-manager → C wire Demo A → D wire Demo B → E oracle suite).

### 6.2 Capstone ownership (frozen overlap table)

| Engine item | Owner |
| --- | --- |
| 1 world package, 7 region streaming | **engine-unique** |
| 5 animation, 9 multipass | **80** (unconditional) |
| 3 shared-engine render, 4 standard path, 6 picking half, 8 mechanisms half, 10 oracle half | **80** (render proofs) |
| 2 prefabs half, 6 placement half, 8 scale/LOD half, 10 diagnostics half | **engine** |
| 3 "through the shared engine", 10 oracle vocabulary | **shared by construction** (engine S2 gate; inherited manifest vocabulary) |

Operational rules:

- 80's `proof/capstones/*.json` is **read-only for the engine campaign**; only 80
  flips states there. The engine records in a new engine-owned ledger
  (`proof/engine/capstones/world-capstone.json`), each item `covered-by-80:<id>` or
  `engine-evidence:<paths>`. Citation-by-ID is the double-credit gate; no additive
  scoring across ledgers.
- The missing `hello-triga.json` manifest and the campaign-name↔manifest-id mismatch
  are **80's Stage 12 audit decisions**; the engine records the gap, does not fix it.

### 6.3 World-persistence format

**Hybrid (c)**: glTF/GLB for asset payloads by URI + a versioned `triga.world.v1`
JSON manifest for world structure (regions, prefab instances, placement, terrain
references, streaming policy, schema version + migration). Grounded in the goal's
"stable semantic data and asset references"; reuses 80 Stage 9 ingestion; binary (d)
stays a later lossless encoder of the same schema. Persistence is **not load-bearing
at S2**: S2 freezes the schema contract stub + a no-GPU/browser-handle lint;
load/save lands at S5 (capstone point 1). Manifest node identity must be stable
string names/UUIDs, not `{index,generation}` handles (those stay runtime-only).

## 7. Routing contract with 80/90

### 7.1 Engine-consumes edges

| Engine stage | 80 preconditions | 90 overlap |
| --- | --- | --- |
| S0 | 80 Stage 0 ledger/manifests (reconciliation) | 90 Stage 0 brief (recorded, not activated) |
| S1 | 80 Stages 1–3 landed (material to split); seams precede 80 Stages 6/7 | none |
| S2 | 80 **Stage 5** (direct WebGPU first scene) | none |
| S3 | 80 **Stage 6** (materials/textures/lighting); Stage 3 attributes | 90 G02 (advanced PBR) adjacent |
| S4 | 80 **Stage 10** (shadows/multipass) | 90 G04 (render graph) adjacent |
| S5 | 80 **Stages 8–9** (animation, glTF) | 90 G03 (compressed assets) adjacent |
| S6 | 80 **Stage 11** (instancing/compute); Stage 7 culling/picking facts | 90 G06 (high-scale) adjacent |
| S7 | 80 **Stage 12 audit** (gates 90 activation); Stage 4 typed stage facts; Stage 6 materials | **90 G01 (programmable materials) + G05 (backend portability) twin surfaces** |

### 7.2 Twin mapping (anti-fork ledger)

Every 90 surface has an engine twin: G01/G05 ↔ S7, G02 ↔ S3, G03 ↔ S5, G04 ↔ S4,
G06 ↔ S6. The anti-fork rule (public API never forks per backend; host never
re-implements) is what prevents collision; this twin mapping is recorded here so S7
and 90's activation sequence into the same work instead of duplicating it. S7 must
not start before 90 activation (gated on 80 Stage 12).

### 7.3 Coordination rules

- **No engine seam during 80 Stages 4–5 without coordination**; seams land as
  preconditions of 80 Stages 6/7 per the schedule in §3.
- Engine is **read-only** over 80's `proof/capstones/*.json`.
- Cross-repo edits serialize or use non-overlapping worktrees; no Git cleanup of
  another session's work (foreign-work rule).
- 80 Stage 9's glTF loader constructs every seam target — seams A–D must land before
  it, or the loader bypasses public types (its own stop condition) or rewrites twice.

## 8. Known debt and open items

| Item | Status | Owner |
| --- | --- | --- |
| DS-E geometry split — tooling-forced deviations (D1–D4), all name-preserving | landed; D1 `PrimitiveTopology` in `geometry/data` (not layout) — cross-module enum variants not constructible (G2); D2 `geometry_vertex_layout_matches` in `geometry/data` (not layout) — cycle avoidance; D3 `_vertex_layout_format_code`/`_vertex_layout_step_mode_code` made public — `@ privata` free fns not file-exported; D4 hello-voxel exempla import `attribute`/`batch` additionally — struct-literal field namespaces. Two additive public helpers in `layout` (`vertex_format_from_component_width`, `vertex_step_mode_vertex_step`). Frozen ABI names verbatim; radix check green | recorded; C3 rename still gated on 80 Stage 4 |
| DS-D scene split | **BLOCKED** on G2 (enum variants) + G3 (import cycles); agent restored tree, evidence preserved in /tmp/dsd-leaves/ + probes; unblocks when the language gains cross-module variant access or the leaf map is adjusted | language decision |
| `check-source` RED on `geometry_vertex_layout_matches` (now src/geometry/data.fab:1027) | acknowledged; fixed at the C3 rename (gated on 80 Stage 4's reflection agreement closing) | DS-E C3 |
| `check-compile` RED — 4 E0308s in regenerated `target/faber/src/main.rs` (`&…clone()` args to by-value params at main.rs:25/28; `Some(…)` wraps of `∪ nihil`/Option expressions at main.rs:32/4273) | acknowledged; fixtures verified correct in source (`insere(mesh_node)`, `cape(mesh_handle)`, scene.fab:806) → **faber generated-code lowering regression**, not fixture bugs; restore as a named precondition of every S1 delivery spec; root-cause fix in the faber Rust emitter coordinated with the 80 generated-Rust acceptance lane | faber emitter (via 80 lane); DS specs gate on it |
| Corpus `reflection.json` fixtures stale (`UniformBuffer`/`Uniform` un-emittable; no `schema_version`/`target`) | regenerate through radix; coordinates with 80 Stage 4–5 graphics-MIR work | DS-S2 / radix |
| Silent-default decoders (`step_mode`, `depth_compare`, `kind`, `role`, `access`) | flagged; tighten when the ABI seam is next touched | radix |
| Nested-package tooling (DEFER-121) — **RESOLVED, three gaps (2026-08-01, probe evidence in /tmp/dsd-probe-*)**: G1 faber TS emitter never emits nested library modules (`faber/src/package/product.rs` ~1467/~1822 — two non-recursive `read_dir`; fix small/localized, fix agent in flight); G2 enum variants are module-scoped — no cross-module construction/matching of `discretio` variants (`finge`→SEM001, `casu`→SEM001, named variant import→`name_not_variant`, qualified→`SEM002`; blocks scene split outright, forced `PrimitiveTopology` into `geometry/data` in DS-E); G3 faber rejects library import cycles (`PKG001`) — scene node↔store↔query is genuinely cyclic | G1: faber packaging fix (in flight); G2+G3: **language-decision items** (new syntax/visibility semantics — require a language decision per the goal's stop conditions) | DS-D parked on G2+G3 |
| World-scale target for S6 (culling/LOD/streaming meaningfulness) | open; freeze at S5 with measurements | S5/S6 |
| Second backend choice | open; deferred to S7/90 activation | S7 |
| `hello-triga.json` manifest + campaign-name↔manifest-id reconciliation | 80 Stage 12 decision; recorded, not fixed | 80 |

## 9. Validation status

- **`check-source`**: RED (pre-existing naming lint, acknowledged — §0). Fix
  scheduled inside DS-E.
- **`check-compile`**: RED with 4 E0308 errors in regenerated `target/faber/
  src/main.rs` (generated-code lowering regression; fixtures verified correct —
  §8). Restoration is a named precondition of every S1 delivery spec; root-cause
  fix belongs to the faber Rust emitter via the 80 generated-Rust acceptance lane.
  Seams are pure relocations and must not worsen this gate.
- **Corpus browser builds**: **GREEN for both demos (2026-08-01)** after the G1
  faber TS-emitter fix (recursive library module emit + binding-alias normalization)
  and two run.sh integration fixes (workspace faber binary preference; shader copy
  names — `kernel.wgsl`/`reflection.json` for the `[product.shaders]` contract,
  `triga-lit.*` for runtime fetch). Runtime render remains gated on P1.3 artifact
  regeneration (stale-format reflection rejects at admission until the radix
  regeneration coordinated with 80 Stage 4–5).
- **S1 seam state**: DS-B, DS-E (C1+C2), DS-G landed; DS-D parked on G2/G3 (language
  decision); DS-A unblocked by union probe (construction works, matching doesn't —
  dedicated-accessor pattern); DS-S2 Phase 1 landed, Phase 2 gated on 80 Stage 5.
- **Track files**: `T-A`..`T-F` in this directory are the durable evidence for every
  decision above; load-bearing claims were spot-verified by the campaign owner
  (naming-lint RED, zero `Light` constructors, `geometry.fab:1332`, fixture
  correctness for the compile-gate red, cross-module enum-variant probes).
- **S0 gate**: satisfied with the two acknowledged amendments in §0. S1 is in
  progress with four lanes landed; the checkpoint report's §8 tracks the remaining
  gated items.
