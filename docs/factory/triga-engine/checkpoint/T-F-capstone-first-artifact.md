# Track F — Capstone reconciliation, first engine artifact, world-persistence format

**Checkpoint**: triga-engine S0 (Horizon 0) — architecture checkpoint
**Track**: T-F (capstone overlap + first engine artifact + persistence format)
**Author date**: 2026-08-01
**Inputs**: [engine GOAL.md](../GOAL.md) (Horizon 0/2, Engine capability vision, Capstone vision, Invariants, Stop conditions), [engine CAMPAIGN.md](../CAMPAIGN.md) (S0–S7), [triga-threejs-80 CAMPAIGN.md](../../triga-threejs-80/CAMPAIGN.md) (5 mandatory capstones, Stages 2/5/12 gates), `proof/capabilities.json`, `proof/capstones/*.json`, `proof/prerequisites/hello-voxel-browser-runtime.json`, `exempla/threejs-host-demo/triga-scene.json`, shallow survey of `examples/` (README + listing).

**Verdict in one sentence**: the 10-point engine world capstone and the 80 campaign's 5 mandatory capstones overlap on the *rendering-weight* of the engine capstone (points 3, 4, 5, 8, 9, and half of 6), 80 owns those proofs, and the engine owns points 1, 7, the world half of 2, and the production-diagnostics half of 10; the first engine artifact is an S2 shared-renderer vertical slice that reuses 80's Hello Triga workload plus the existing `webgl-geometry-terrain` corpus demo as its two consumers, and the canonical world format for the first capstone should be the hybrid (glTF/GLB assets + a versioned Triga world manifest).

---

## 1. Capstone overlap map

### The two capstone sets

**Engine goal — Capstone vision (10 points)** (`GOAL.md` "Capstone vision"):

| # | Engine capstone item | Short tag |
|---|---|---|
| 1 | Build a persistent world package from Faber source | world package |
| 2 | Load or generate terrain and multiple reusable object instances | terrain + prefabs |
| 3 | Render hierarchical geometry through the shared engine, no three.js runtime | shared-engine render |
| 4 | Standard materials, textures, lights, depth, camera controls | standard path |
| 5 | At least one animated or deformed asset | animation/deformation |
| 6 | Picking **or spatial placement** | picking / placement |
| 7 | Stream or replace a bounded world region without invalid resource use | region streaming |
| 8 | Culling, batching, instancing, **or LOD** at a meaningful scale | scale proof |
| 9 | At least one shadow or offscreen/postprocessing path | multipass |
| 10 | Structured success / unsupported / device-failure / stale-artifact outcomes | production outcomes |

**Three.js 80 campaign — 5 mandatory capstones** (`CAMPAIGN.md` "Mandatory Capstones"): C1 Hello Triga (indexed rotating geometry + camera + direct WebGPU, no three.js), C2 Hierarchical lit scene (heterogeneous nested objects, shared resources, multiple cameras/lights, transform propagation, culling, picking), C3 Asset scene (glTF/GLB + metallic-roughness + textures + hierarchy + one animation/deformation), C4 Multipass scene (dynamic shadows + offscreen target + one deterministic post pass), C5 GPU-scale scene (instanced/particle workload updated by Faber-emitted compute, no host round-trip).

**Observed ledger nuance.** The 80 campaign's proof manifests are keyed by *capability family*, not by the 5 campaign names. `proof/capabilities.json` lists `["hierarchical-scene","pbr-textured-lighting","animated-gltf","picking-culling","multipass-instancing"]`, and the five manifests cover: C2 → `hierarchical-scene` + `picking-culling`, C3 → `pbr-textured-lighting` + `animated-gltf`, C4+C5 → `multipass-instancing`. There is **no `hello-triga.json` manifest** — C1 has no ledger entry yet; it is effectively the Stage 5 gate itself (the direct-draw proof under the `renderer` domain). Whoever reconciles the capstone ledger must decide whether C1 gets a manifest of its own (80 owns creating it) or is carried as the Stage 5 gate.

### Overlap table

| Engine item | 80 coverage | Verdict | Owning ledger |
|---|---|---|---|
| 1 world package | none | **engine-unique** (persistence is an open question in both campaigns; nothing in 80 serializes a world) | engine |
| 2 terrain + prefabs | partial: procedural terrain mesh generation exists in corpus `webgl-geometry-terrain` (not a 80 capstone); 80 has no prefab/world-instance concept | **mixed**: "load or generate terrain" reuses corpus geometry; "multiple reusable object instances" (prefabs) is engine-unique (`world/instance`) | engine (prefab/instance part); corpus proof is evidence, not a 80 capstone |
| 3 shared-engine render | C1 (direct WebGPU no-three.js) + C2 (hierarchical scene) | **overlap, with an engine-only seam**: 80 proves the raw render; the *shared engine* consumption of those proofs by two unrelated demos is the engine S2 gate and is not 80's | 80 for the render proofs; engine for the shared-runtime consumption |
| 4 standard path | C2 (lights/cameras/depth via Stage 6–7), C3 (standard material + textures via Stage 6), C1 (camera) | **overlap**: materials/textures/lights/depth/camera are 80 Stages 5–7 domains; engine adds only the "same shared material instances across demos" seam | 80 |
| 5 animation/deformation | C3 | **full overlap** | 80 |
| 6 picking / placement | C2 includes picking (Stage 7); 80 has no placement concept | **mixed**: picking is 80's; spatial placement is engine-unique (`world/query` placement rules) | 80 (picking); engine (placement) |
| 7 region streaming | none | **engine-unique** (`world/stream`, `world/region`) | engine |
| 8 scale proof | C5 (instancing/particles) + C2 (culling) | **overlap on mechanisms, engine-only on scale and LOD**: instancing/culling are 80's; LOD and the frozen scale target are engine S6 | 80 (mechanisms); engine (scale target, LOD) |
| 9 multipass | C4 | **full overlap** | 80 |
| 10 production outcomes | partial: 80 has fail-closed and negative coverage per domain and deterministic oracles in manifests | **mixed**: the deterministic-oracle vocabulary is shared; the *structured diagnostics* taxonomy (owning layer/artifact/resource/pass/target capability, explicit device-lost state machine) is engine S7 production contract | engine (diagnostics); shared oracle vocabulary with 80 |

### Ownership verdict

- **80 owns, unconditionally**: engine points 5 and 9 (fully), plus the raw-render halves of 3, 4, 6, 8.
- **Engine owns, unconditionally**: points 1 and 7 (nothing in 80 touches them), plus the prefab half of 2, placement half of 6, LOD/scale half of 8, diagnostics half of 10.
- **Shared by construction**: point 3's "through the shared engine" is the engine S2 gate and cannot be earned by 80 alone; point 10's oracle vocabulary is inherited from 80's manifest schema.
- Net: 80's 5 mandatory capstones cover roughly half the engine capstone's weight; the engine capstone is *not* a re-scoring of 80 — it adds a persistent-world, streaming, placement, scale, and production-contract layer on top of 80's render proofs.

---

## 2. FIRST ENGINE ARTIFACT — definition

### Name and alignment

**S2-First Engine Render** — the shared-renderer vertical slice, lowered from the S2 gate ("two unrelated demos render through one shared engine path with no private renderer, pipeline, or shader copy: hierarchical world, camera, opaque mesh, standard material, depth, resize, and deterministic failure states").

Horizon 2 alignment (GOAL.md Horizon 2): "replace copied corpus host assets with a shared engine runtime path; render a hierarchical world with camera, opaque mesh, standard material, depth, resize, and deterministic failure states; prove two unrelated demos consume the same engine without shader or pipeline duplication." The artifact is exactly this sentence.

**Interpretation note (state uncertainty)**: "standard material" in Horizon 2 cannot mean the full metallic-roughness PBR family — that is 80 Stage 6 / engine S3. For S2 it must mean a **single engine-owned opaque standard material** derived from the existing corpus `_host` lit-mesh shader (flat color + one directional light + depth). This keeps the "shared shader, no per-demo copy" requirement true without gating the slice on 80 Stage 6.

### The Faber scene it builds

Two workloads, both pre-existing, no new invented scene:

1. **Demo A — Hello Triga workload** (80 Stage 5's Faber-authored indexed scene): root group → rotating indexed geometry (shared from the Stage 3 primitive family), one opaque standard material, one perspective camera, one directional light. This is 80's C1/Stage-5 artifact being *reused*, per the mandate not to invent a new workload. Hierarchical placement comes from the Stage 2 scene store (world transforms already proven at the Stage 2 gate).
2. **Demo B — corpus `webgl-geometry-terrain`**: a procedurally generated 48² heightfield (~4.6k triangles) with value-noise displacement and per-vertex colors. Genuinely unrelated to Demo A in construction (different generator, different attribute profile, different mesh count), which is precisely what the "two unrelated demos" gate demands. It already shares `corpus/_host`, so it is the cheapest second consumer.

One additional Faber fixture may be added: `exempla/`-style engine contract example, but the *workloads* are the two demos.

### Host seams it exercises

The shared engine facade at the host boundary, per the GOAL host-side target structure (S0 must confirm the engine-runtime-home decision; recommendation: extract `corpus/_host` into `hosts/webgpu-browser` `product/engine/`, keeping `_host` as behavioral seed only — this closes the goal's correction "corpus `_host` shader/runtime files → shared host engine package"):

- `engine/engine.js` — renderer/session facade; owns the explicit state machine (startup → ready → suspended → device-lost → recovering → failed).
- `engine/frame-scheduler.js` — update/frame/present ordering; owns resize (canvas size → viewport/aspect → next frame deterministic).
- `engine/scene-extractor.js` — Triga scene store → render items; consumes Stage 2 world transforms and Stage 4 graphics reflection (explicit render facts; no host guessing).
- `engine/resource-manager.js` — minimal residency: geometry buffer upload, material uniform, generation checks.
- `backend/webgpu-*.js` — device/resources/pipelines/render (existing `_host`/Stage-5 WebGPU code moved under this seam).
- `presentation/canvas.js` — canvas/resize/presentation state.
- `contract/artifact-admission.js` + `capability-admission.js` — the fail-closed seams for stale/missing artifacts and unsupported capabilities.

### Deterministic success oracles

Reuse the 80 manifest oracle vocabulary (`proof/capstones/*.json` kinds: `numeric_and_pixel`, `pixel`, `numeric`) so engine evidence stays compatible with 80's harness:

- **Numeric**: per-frame world-transform oracle for Demo A (rotation angle sequence over N frames vs expected values); scene-extractor output equals scene-store traversal for a frozen fixture; draw-call/count assertions.
- **Pixel**: deterministic reference image for each demo at a fixed canvas size (single-region readback or full capture).
- **Structural**: both demo `public/` bundles contain **no** WGSL and **no** render loop / pipeline creation — only imports of the engine package (grep-able gate, mirrors the campaign invariant "no private renderer/pipeline/shader copy").
- **Shared-instance**: Demo A and Demo B use the *same* shader-module/pipeline-cache identity for the shared standard material — asserts no per-demo duplication.

### Deterministic failure oracles

- Unsupported capability (e.g., request MSAA or a non-admitted color format) → typed rejection **before** draw/dispatch, with structured diagnostics naming layer/artifact/pass/capability.
- Missing/stale artifact → `artifact-admission` rejects, render status reports failed, no draw.
- Device loss → explicit suspended → recovering (recreate resources, resume) or clean failed state; render status attribute transitions observed (precedent: `examples/triga-drift-city` publishes `data-render-status` / `data-device-status`).
- Resize → canvas resized to a fixed known size produces a deterministic aspect-correct frame (oracle re-runs).

### Deliberate deferrals (NOT in the slice)

Textures/samplers; lighting beyond one directional; transparency/alpha; shadows/offscreen/post (80 Stage 10 / S4); instancing/particles/compute (80 Stage 11 / S6); glTF ingestion and animation (80 Stages 8–9 / S5); world regions, terrain persistence, streaming, prefabs (S5–S6); spatial queries, picking, placement (80 Stage 7 / S6); render-graph execution — S2 runs the shared imperative pass path; render-plan execution is S4; second backend; programmable materials; any editor/physics/audio seams.

### Why one factory phase sequence

One delivery spec with a short factory phase chain: (A) engine facade skeleton + state machine; (B) scene-extractor + minimal resource-manager consuming Stage 4 reflection; (C) wire Demo A through the facade; (D) wire Demo B through the same facade; (E) oracle suite + negative/failure cases + no-private-copy gate. Every phase consumes existing artifacts (Stage 2 store, Stage 3 primitives, Stage 4 reflection, Stage 5 Hello Triga, corpus demos) — no new workload or asset pipeline is created, which is what keeps it "small enough for one factory phase sequence."

---

## 3. World-persistence format options

Grounding requirement (GOAL.md): "World persistence must be explicit. A world should be serializable as stable semantic data and asset references rather than as browser handles or incidental GPU state" and "World packages must be portable semantic artifacts. They may reference assets, materials, and regions by stable identifiers, but they must not depend on the current browser, GPU vendor, adapter limits, or incidental cache layout." Invariant: "World persistence does not serialize browser or GPU handles." Both campaigns list the canonical format as an open question.

Precedent: `exempla/threejs-host-demo/triga-scene.json` (`schema: triga.threejs-host-demo.v1`) already sketches the natural Triga-shaped data model: named/semantic material descriptors (color/roughness/metalness), structure-of-arrays geometry attributes, node handles `{index, generation}` + names + `parent`/`children` + column-major `localMatrix`, and a camera record. It is scene data, not yet a world, but it is the format family the manifest option would formalize. Note: for *persistence*, `{index,generation}` handles are runtime-store identity and can be reused across sessions; a persistent manifest should key nodes by stable string names/UUIDs and keep index/generation as runtime-only. That distinction is the anti-leak rule in practice.

### Option comparison

**(a) glTF/GLB scene JSON as the canonical world format.**
Strengths: 80 Stages 8–9 already build glTF ingestion; glTF natively carries meshes, hierarchy, materials, textures, skins, morphs, animations, cameras, lights; widely toolable.
Weaknesses as a *world* format: no native concept of persistent world regions/chunks, residency/eviction, prefab instances, or placement rules; terrain is normally baked to a mesh rather than expressed as heightfield/layers; no engine/session state (spawn, camera bookmarks); single-scene orientation makes region streaming an undeclared extension; forcing Triga world semantics into a glTF dialect either loses Triga material/query semantics or creates a private dialect that erases glTF's portability benefit. Covers asset payloads well, world structure poorly.

**(b) Custom Triga world manifest (stable semantic data + asset references).**
Strengths: directly matches the goal's wording — the manifest *is* the stable semantic data, referencing assets/materials/regions by stable identifiers; full control of regions/placement/terrain/prefabs/streaming policy; versioned migration policy is native; easy to author, diff, test (JSON); `triga-scene.json` precedent.
Weaknesses: would reinvent what glTF already solves for heavy payloads (buffers, images, animations) if it tried to carry asset bytes; risks divergence from 80's glTF ingestion work if the manifest is not careful to reference glTF URIs for assets.

**(c) Hybrid — glTF/GLB for assets, Triga world manifest for world structure.**
glTF/GLB carries asset payloads (geometry, textures, materials, animations, per-asset hierarchy) by URI; a versioned Triga world manifest (`triga.world.v1` JSON) carries world structure: regions, prefab instances, placement, terrain layer references/heightfields, streaming policy, engine/session state, schema version + migration. Exactly matches "stable semantic data **and** asset references."
Strengths: reuses 80's Stage 9 ingestion as the asset pipe; world layer stays backend-neutral and portable; regions/placement/streaming live where they belong; migration is a manifest-schema concern; small geometry may be inlined in the manifest (as `triga-scene.json` does) while large assets are glTF-referenced.
Weaknesses: two formats to maintain; the manifest↔glTF boundary (what is "asset" vs "world structure") must be pinned in the S0 checkpoint or the boundary drifts.

**(d) Binary.**
Right answer for size/streaming performance at engine S6 scale, but premature for the first capstone: needs codecs, migration tooling, and is harder to author/diff/debug; negative cases (missing/unsupported assets, version mismatch) are easiest to author and test as JSON. The manifest schema should be designed so a later binary encoding is a *lossless serialization of the same semantic model* — option (d) is a later encoder, not a competing model.

### Recommendation

**Adopt (c) hybrid as the canonical world-package format: glTF/GLB for assets, a versioned Triga world manifest for world structure/regions/placement/terrain references.**

Reasons:
1. The goal's invariant language ("stable semantic data and asset references") is effectively a spec for the hybrid — the manifest is the data, glTF URIs are the references.
2. It reuses 80's Stage 9 glTF work instead of duplicating an asset pipeline inside the manifest, and it gives 80's asset capstone a consumer.
3. Regions, prefabs, placement, and streaming are world-layer concepts glTF does not define; putting them in the manifest keeps them in `triga:world/*` ownership and keeps the world package portable.
4. The `triga-scene.json` precedent formalizes naturally into the manifest's first schema.
5. Binary stays a later lossless encoder of the same schema, so the choice does not block S6 scale work.

**Timing caveat**: persistence is *not* load-bearing for the S2 slice — the S2 world is a static in-memory hierarchical scene. The S2 slice should therefore (a) freeze the manifest *schema contract* (a `triga.world.v1` schema stub plus the "no GPU/browser handles" lint), and (b) implement load/save in engine S5 where the world layer lands. The first *persistence proof* belongs to engine capstone point 1 at S5, not to S2.

---

## 4. What "capstone ownership" means operationally

### Ledger rule

- **80's ledger is `proof/capstones/*.json`** (state `unsupported` → `passed`, with `evidence` entries). Only the 80 campaign flips states there (stage gates → Stage 12 audit). The engine campaign is **read-only** over those files.
- **The engine ledger is new and engine-owned**: a `proof/engine/capstones/world-capstone.json` (or equivalent) recording the 10 engine capstone items, where each item is either `covered-by-80:<manifest-id>` (points 3/4/5/9 and the render halves of 6/8) or `engine-evidence:<paths>` (points 1, 7, and the engine halves of 2/6/8/10). 80's `proof/prerequisites/hello-voxel-browser-runtime.json` is the precedent for a non-scoring, cross-campaign prerequisite ledger entry — the engine may add prerequisite entries there only with 80's coordination.

### Double-credit gate

- The overlap table in this document is **frozen at S0 acceptance** and is the single source of truth for who records what.
- A capstone point is recorded **once**: in the ledger of the campaign that first demonstrates it. The other ledger cites it by ID and adds no score. The overlap table + citation-by-ID convention is the gate.
- Engine items that map to 80 capstones C1–C5 are not re-proven; engine S2/S5/S6 evidence *consumes* the 80 manifest evidence (same workload, same oracle family) and adds only the shared-engine/world seams the 80 capstones cannot cover.
- No additive scoring across ledgers: engine capstone items do not add points to 80's scorecard, and 80's scorecard does not award the engine world capstone.
- The `hello-triga` manifest gap and the campaign-name ↔ manifest-id mismatch (C2/C3/C4/C5 spread across five family-keyed manifests) are for the **80 Stage 12 audit** to reconcile; the engine checkpoint records the gap but does not fix it.

### Operational consequences

- Engine S2's acceptance evidence is recorded in the engine ledger, but its underlying render proof references 80 C1 evidence (`hierarchical-scene`/Stage 5 artifacts).
- The engine S0 report must not modify `proof/capstones/*.json`; any state flip there is 80's.
- Engine capstone item 10 (production outcomes) shares the manifest oracle vocabulary (numeric/pixel/numeric_and_pixel) with 80 so both ledgers can run the same harness — the vocabulary is shared, the diagnostics taxonomy is engine-owned.

---

## Open items / handoffs to other tracks

- Engine-runtime home decision (extract `corpus/_host` vs grow in place) is owned by the S0 deliverable but constrains the S2 slice's seam list; this track recommends extraction into `hosts/webgpu-browser` `product/engine/`.
- Whether Hello Triga (C1) needs its own `proof/capstones/hello-triga.json` is an 80-campaign decision; it should not be created by the engine.
- The `triga.world.v1` schema stub and the no-GPU-handle lint belong to the S0 checkpoint freeze (or S1), so S5 can implement against a frozen contract.
- "Standard material" scope at S2 (single engine-owned opaque material from `_host`'s lit shader, not the PBR family) should be confirmed by the S2 delivery spec against 80 Stage 6 timing.
- World-building corpora: `examples/` holds no world-persistence corpus today — the closest precedents are `triga-drift-city` (bounded circuit + scene-facts publishing) and `triga-budapest` (static large-mesh scene), both greybox direct-WebGPU packages with `public/`-owned transport; neither serializes a world. The first world-capstone corpus must be authored under engine S5 per the campaign's scope routing.
