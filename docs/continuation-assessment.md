# Triga continuation assessment (CTO)

**Date**: 2026-09-20
**Seat**: head-cto
**Handle**: `41b22132`
**Verified against**: triga `d624fdd3e47b02d4e56a775654456b8fc065a851` (2026-09-17, `main`, clean)
**Posture**: advisory, not a landed-work verdict

Provenance tags: **known** (read at HEAD), **inferred** (from live types/imports, not executed), **unverified** (would need cargo/`faber`/browser, which this pass was forbidden to run).

This is a continuation pass on a dormant graphics library, not a scorecard for the three.js-80 campaign. Factory docs are cited only where they were checked against live source. Where they disagree, the repo wins and the doc is a finding.

---

## 1. State

### What exists

Triga at HEAD is a 26-module Faber source package (`src/**/*.fab`, 4,540 lines) plus co-located proba (26 files, 2,833 lines), exempla (35 `.fab`, 2,291 lines), and corpus (11 `.fab`, 1,287 lines). The reconnaissance count of 72 `.fab` / ~8k lines is the whole tree, not the library. `cista.toml` versions the package at `0.2.0`.

The live public surface is a Norma-style leaf map. Facades (`triga:triga`, `triga:geometry`, `triga:graph`, `triga:material`, `triga:lighting`, `triga:primitives`, `triga:renderable`) own no genera.

| Leaf | Lines (scorecard / live order) | What it actually is |
| --- | --- | --- |
| `triga:math` | 1,051 | Real. `Vector2/3/4`, `Matrix3/4`, `Quaternion`, `Euler`, `Color`, `Box3`, `Sphere`, `Plane`, `Ray`, `TransformPayload`, face-code tables. Receiver methods are English (`add`, `dot`, `cross`, `normalized`, …). Constructors: `vector3`, `matrix4_identity`, `matrix4_translation`, `matrix4_perspective`, `matrix4_look_at`, `transform_payload`. |
| `triga:geometry/data` | 833 | Real. `BufferGeometry`, `ColoredQuadMesh`, indexed/line constructors, vertex-layout facts, `@ shader_contract "vertex_layout"` adapter `geometry_vertex_layout_matches`. |
| `triga:scene` | 704 | Real monolith. `SceneStore`, `SceneHandle`, `SceneNode` + `union SceneNodeKind`, traversal, `visibilia`. Split to `scene/{node,store,query}` is parked. |
| `triga:resource` | 490 | Real. `ResourceHandle` generation/lifecycle receiver methods + batch free functions. |
| `triga:primitives/basic` | 328 | Real deterministic generators: plane, circle, sphere, cylinder, cone, torus, box, box-wire. |
| `triga:shader_contract` | 156 | Adapter, not a renderer. Five `@ shader_contract` role functions that `return true`; Goal-01 pipeline default codes. Radix ingests the annotations; Triga never emits WGSL. |
| `triga:geometry/{attribute,layout,batch,bounds}` | 136 / 168 / 171 / 34 | Real SoA attributes, layout codes, draw-batch facts, geometry-side bounds. |
| `triga:graph/camera` | 91 | Partial. `PerspectiveCamera` has projection / view-projection methods. `OrthographicCamera` is data only. |
| `triga:material/base` + `basic` | 95 + 64 | Partial. `Material` and `MeshBasicMaterial` have validation and pipeline-fact methods. `TextureDescriptor` is an H3 seed. |
| `triga:face` | 68 | Real voxel-face quad builder used by hello-voxel. |
| `triga:graph/object` | 31 | Shape only. `Object3D`, `Scene` — no methods. |
| `triga:lighting/light` | 44 | Shape only. `Light`, `AmbientLight`, `DirectionalLight`, `PointLight` — no methods. |
| `triga:renderable/mesh` | 33 | Shape only. `Mesh` composes graph + geometry + a material union. No methods. Same-module union `match` works; cross-module union `casu` does not (documented compiler gap G2b). |
| `triga:material/{lit,standard}` | 22 + 24 | Shape only. `MeshPhongMaterial`, `MeshStandardMaterial` — fields, no methods. |

S1 seam repair **did land** in source: geometry, material, lighting, graph, primitives, and renderable are split. That part of `triga-engine` GOAL.md is current. The scene split did not.

### What is stubbed

- **No `triga:engine`, `triga:render`, `triga:shader` (intent), `triga:asset`, `triga:animation`, `triga:world`.** Those names exist only in the S0 target map (`docs/module-map.md` Target map, frozen 2026-08-01; the scorecard itself flags that 61-leaf / 75-path count as a stale claim).
- **Materials beyond unlit facts.** Phong and PBR are records. Nothing evaluates lighting.
- **OrthographicCamera** has no projection.
- **shader_contract role functions** always return `true`. They are compiler-ingest adapters, not runtime checks.
- **TextureDescriptor** is a placeholder (owning comment: relocates at H3).
- **Corpus `_host`** is a pointer README. The greybox JS is gone from this repo.

### Honest quality and coverage

**Known (scorecard, not re-run):** `proof/coverage-scorecard.json` revision 3 records Stage 0.5 complete: 26/26 modules at `executed-proba`, 118 cases, all passed, run 2026-08-24 against `radix/target/release/faber`. Every live leaf has a sibling `.proba`. That is a real unit-test floor for the typed contract.

**Known (stale receipt):** the same scorecard sets `"inventory_mismatch": true`. Inventory pin is `cec9e551…`; observed source at scorecard write was already `451e7307…`. HEAD is `d624fdd3…`. September commits after the scorecard include English-first identifiers (`93d03e7`), idiom sweep, locale fragment, math polish, and coverage narration. Live proba status at HEAD is **unverified** (no `faber test`).

**Known (source vs docs):**

- `docs/api-shape-policy.md` still describes Latin stems (`addita`, `productum`, `transversum`, `matrix4_conspectus`). Live `src/math.fab` is English (`add`, `dot`, `cross`, `matrix4_look_at`). The policy is stale relative to `93d03e7`.
- `exempla/triga-transforms.fab` still calls `math.matrix4_translatio`, `.multiplicata`, `.applica_punctum`, `.inversa_affinis()`. That is the English-src / Latin-exempla split named in `generic-math-types/delivery-stage1.md` P-1. **Inferred:** `./scripta/check-compile` and `check-transforms` are red on main for this reason. Not re-run.
- `proof/capabilities.json` (three.js-80 ledger) still lists every proof as `"state": "unsupported"`. It is an honest unused scorecard, not a green 80%.
- `triga-threejs-80/CAMPAIGN.md` Status still says Stage 1 cleared / Stage 4 next (2026-07-14). It has no machine-managed `goal.md`. Treat as planning material.

**Known (committed parse break):** `corpus/webgl-geometries/src/scene.fab` and `corpus/webgl-geometry-terrain/src/scene.fab` at HEAD contain:

```text
@ public
class_corpus_placeholder) → CorpusGeometryManifest {
```

Git shows this was introduced in `f0cd717` (`fix(exempla,corpus): drop retired private imports…`), replacing `fn corpus_scene_geometry()`. `corpus/webgl-geometries/src/main.fab` still calls `scene.corpus_scene_geometry()`. Those two demos cannot parse. The three animation corpus packages were not hit by that rewrite.

### Where the library stops being usable

Usable today, as a **CPU-side typed contract**, for an author who imports leaves and English names:

- construct vectors/matrices/payloads;
- build `BufferGeometry` and the eight primitive meshes;
- store heterogeneous nodes in `SceneStore`;
- mint `ResourceHandle` generations;
- declare shader-contract facts for Radix to ingest.

It stops being usable at the **GPU execution boundary**, and it already stops being usable for its **existing application consumers**:

1. There is no Triga renderer. Draw happens in `hosts/webgpu-browser` JS, or not at all.
2. The live corpus draw path is gated: host admission rejects the checked-in `triga-lit` reflection (see §3).
3. `examples/hello-voxel` imports facades (`triga:geometry`, `triga:primitives`) that hold no genera, and still calls Latin constructors (`math.matrix4_perspectiva`, `math.matrix4_conspectus`, `math.matrix4_identitas`) plus `geometry.BufferGeometry` / `primitives.box_wire_geometry` through those facades. After S1 + English conversion, those imports do not resolve. **Inferred broken; not typechecked this pass.**
4. `examples/triga-drift-city` is the same class of break, and was declared deliberately broken by `api-shape-vocabulary` (`GOAL.md`: “`examples/triga-drift-city` is deliberately broken by this work”). It still uses `triga:graph` for `graph.PerspectiveCamera` and free functions `geometry.geometry_vertex_payload_byte_count`.
5. `examples/triga-budapest` uses `triga:math` plus the same DOM-blob publish pattern as the corpus.

The library is an MVP **data contract**, not an MVP **engine**. Co-located proba coverage is the strongest honest quality claim. End-to-end render, consumer compile, and the 80-point ledger are not.

---

## 2. The gap

### Distance to three.js-80 / -90

`triga-threejs-80` wanted “at least 80 percent of the capabilities used by ordinary three.js scenes,” workload-proven, no three.js runtime. The live ledger (`proof/capabilities.json`) still scores every domain `unsupported`. Capstones (`hierarchical-scene`, `pbr-textured-lighting`, `animated-gltf`, `picking-culling`, `multipass-instancing`) remain fixture names.

Against that aspiration, what landed is roughly the **math + geometry + scene-identity + unlit-material-facts** floor — the left-hand side of a three.js scene graph — without:

- a working direct-draw path (80 Stage 5);
- materials that light (Stage 6);
- textures, animation, glTF, shadows, instancing, picking, culling as engine features.

`triga-threejs-90` is explicitly parked on an 80 Stage-12 audit that never happened. Programmability, PBR environment, compressed assets, render graph, second backend, high-scale residency are not started.

**The distance is not “a few stages.”** It is “typed scene values exist; the renderer, assets, and 80-point proofs do not.”

### Is that still the right target?

No. Three independent later decisions already retired the three.js-shaped destination as a product contract:

1. **`api-shape-vocabulary`** (Status: core break landed `8312fc7`; follow-up still open) overturns three.js-mirror naming on purpose: “the bet was made before Triga had real consumers, and it costs Faber's language identity plus an implied parity guarantee Triga does not honor.”
2. **`triga-engine` GOAL** says the production outcome “is not source compatibility with Unreal or Three.js.” Three.js is an oracle, not a runtime and not an API promise.
3. **`generic-math-types`** selects `vector<f32, N>` / `matrix<f32, [R, C]>` and retires `Vector3`/`Matrix4` identifiers — the opposite of three.js field alignment. `api-shape-policy.md` §1b still says keep `Vector2/3/4`. That is an unresolved fork in the docs; live source still has numbered genera; Stage 1 of generic-math is only planned.

What changed in the rest of the workspace while Triga sat:

- **tela** owns the browser DOM/Canvas2D seam (`tela:dom`, `tela:web`, `tela:canvas2d`). It does not import Triga. Corpus demos import tela for controllers, not for 3D.
- **Radix** owns generic shader-contract ingestion, WGSL emit, and (separately) Metal for Gradus/inference. Triga's archived `docs/archived/wgsl-shader-contract-boundary/` records the Triga adapter as done; the compiler campaign lives in radix. Metal is not a Triga backend.
- **hosts/webgpu-browser** became the engine-runtime home (S2 Phase 1 extraction landed; see §3).
- **Gradus** took the GPU-attention of the workspace. It does not import Triga (**known:** no `triga:` imports under `gradus/`).

The right 2026 target is a **backend-neutral scene/geometry/material contract** that one shared host renderer executes, with three.js as a visual/oracle reference for corpus demos — not an 80% API-parity campaign and not a 61-leaf world-building engine.

---

## 3. The render seam (load-bearing)

**Triga does not render through Triga.** There is no `triga:render` / `triga:engine` module at HEAD. The public types stop at backend-neutral values and shader-contract facts.

### Edges as they exist today

```text
Faber app (triga leaves: math / geometry / primitives / scene / face)
        │
        │  tela:dom / tela:web   ← controller, input, attr_set
        │  (NOT a 3D renderer; tela/src/tela.fab is stdlib-only, no triga import)
        ▼
DOM facts: data-scene-geometry, data-transform-payload, .triga-canvas, .triga-facts
        │
        ▼
hosts/webgpu-browser/public/src/
  product/bootstrap.js          session entry (initEngine)
  engine/engine.js              greybox facade + state machine
  engine/scene-extractor.js     parses the DOM blob (pos3+normal3+color3, stride 36)
  engine/resource-manager.js    GPU upload
  engine/frame-scheduler.js     rAF / resize
  contract/artifact-admission.js  loadFaberGraphicsPipeline
  backend/webgpu-runtime.js     WebGPU device / draw
        │
        ▼
WebGPU in the browser
```

**tela** is the DOM/input seam. Canvas2D (`tela:canvas2d`) is a 2D draw surface. Neither is the 3D renderer.

**Radix device backends (Metal / WGSL)** are not a Triga runtime:

- **WGSL text emit** (`faber emit -t wgsl-text`) is the compiler path for `@ shader_contract` programs. Conformance lives in `triga/exempla/conformance/shader-contract/` and `hosts/webgpu-browser/fixtures/graphics.fab` (that fixture **does** import `triga:geometry/data` and `triga:primitives/basic`). Council lock in `shader_contract.fab`: “Triga never emits WGSL. It maps its API to the generic surface; radix emits.”
- **Metal** (`radix/GPU.md`, Gradus parity) is the inference/compute device path. `radix/GPU.md` does not mention Triga. Triga does not target Metal.

**Frozen ABI lockstep with radix:** `format_code`, `step_mode_code`, `offset_bytes`, `stride_bytes`, `source_name`, and `*_code` fields on fact genera (`docs/api-shape-policy.md` §3; codes tabulated in `src/shader_contract.fab`) are consumed by `radix/crates/radix-mir/src/shader_contract.rs`. Renaming them is a radix change. The real-API adapter `geometry_vertex_layout_matches` still omits `stage_io_role_code`; the dedicated `triga:shader_contract` adapters include it (U6). Library-declared annotations on the real API are not the ingest site — that split is documented, not a surprise.

### S2: what the goal says vs what HEAD has

`triga-engine/GOAL.md` Status: “S0 architecture checkpoint and S1 seam-repair evidence are landed; **S2 shared-renderer vertical slice remains planned**.”

Live:

- **S2 Phase 1 extraction landed.** `triga/corpus/_host/README.md` is a pointer to `hosts/webgpu-browser/public/src/{product,contract,engine,backend,presentation}`. Corpus `tests/run.sh` copies from `$WORKSPACE/hosts/webgpu-browser`. The host tree contains `engine.js`, `scene-extractor.js`, `resource-manager.js`, `frame-scheduler.js`, admission, capability admission, canvas, bootstrap.
- **S2 Phase 2 (actual shared draw) did not.** `engine.js` comments: `hosts/public/generated/triga-lit.*` are still the **old pre-radix reflection format** until regeneration, gated on 80 Stage 4–5 graphics-MIR. `loadFaberGraphicsPipeline` requires `schema_version` / `target` / `launch.webgpu_adapter`. The placeholder is **rejected**, “documented gated state, not a defect.” Confirmed at HEAD: `triga-lit-reflection.json` has `"kernels"` / `"kind": "StorageBuffer"` and **no** `schema_version`. Sibling `hosts/.../generated/reflection.json` (compute) does have `schema_version: 1`.
- `engine-shared-instance-check.mjs` is labeled **SCAFFOLD ONLY** and “does NOT assert the two-demo S2 gate.”
- Scene extraction still parses a **pipe-separated DOM blob**, not `triga:scene` `SceneStore`. Faber controllers flatten geometry to text; the host does not walk Triga nodes.
- Hand-authored `triga-lit.wgsl` comments a transform buffer of **64 f32** (16+16+32 pad). Triga `transform_payload` and `GOAL_TRANSFORM_ELEMENT_COUNT` are **32 f32**. That mismatch is live; regeneration would have to pick one contract.

**Verdict on the seam:** the next honest renderer step is **not a new Triga module**. It is (a) radix-regenerate `triga-lit` into the current reflection schema, (b) admit it in `hosts/webgpu-browser`, (c) keep two demos on that one facade, (d) stop publishing geometry as a DOM string once `SceneStore` can be the extractor input. Until (a)–(c), “S2 vertical slice” is a host+compiler job with a Triga-shaped workload, not a Triga-source job.

---

## 4. Work areas (ordered)

Three areas, not six. Later items in §6 are parked on purpose.

### A. Reconnect the live consumers and repair the corpus parse break — **S**, first

**What:** Restore `fn corpus_scene_geometry` (or an English public equivalent) in the two broken corpus `scene.fab` files. Migrate `examples/hello-voxel`, `examples/triga-drift-city`, and `examples/triga-budapest` off facade imports and Latin free-function names onto current leaves (`triga:geometry/data`, `triga:geometry/batch`, `triga:primitives/basic`, `triga:graph/camera`, `triga:math` English constructors). Migrate `triga/exempla/*.fab` the same way so `check-compile` / `check-transforms` have an honest oracle. Update `scripta/check-source` exemptions from Latin constructor names to the English ones that actually exist.

**Why now:** Without this, Triga has no working application proof and its own corpus cannot parse. The api-shape-vocabulary goal left consumer follow-up “outside this hygiene repair”; that debt is the actual continuation, not a new family of leaves. Hello-voxel is the only application that exercises `triga:face` + `triga:resource` lifecycle together.

**Size:** S if scoped to import/name repair; M if hello-voxel's geometry facts (`VisibleFaceMeshFacts`, `box_wire_geometry`) need leaf-by-leaf audit.

**Parallel:** yes, with a tela caveat (see §5). No radix source change required.

### B. Close the S2 draw path at the host/artifact seam — **M**, second, not Triga-src-first

**What:** Regenerate `triga-lit.wgsl` + `triga-lit-reflection.json` through current radix (`schema_version: 1`, `target: "wgsl-text"`, `launch.webgpu_adapter`). Point admission at those artifacts. Make the two corpus demos (after A) actually draw through `initEngine` with one pipeline-cache identity. Replace the shared-instance **scaffold** with a real oracle. Keep scene extraction on the DOM blob for this slice; do not invent `triga:engine` modules.

**Why now rather than later:** this is the only missing step that turns the typed contract into a visible scene. It is also the step the engine campaign already named. Doing library expansion (PBR, glTF, world) before a single admitted draw repeats the 80-campaign failure mode: declarations without a host path.

**Size:** M. Cross-repo: `hosts/webgpu-browser` (primary), radix emit (artifact producer), triga corpus (workload). DS-S2 already specified this; it is unfinished, not undesigned.

**Parallel:** **no** with Radix/hosts GPU work (see §5).

### C. Fill typed-contract holes that consumers actually hit — **S–M**, third, only from A

**What:** Implement methods and facts that A’s consumers need and that are currently shape-only or missing: `OrthographicCamera` projection if a consumer asks; `Mesh` accessors that do not require union `casu`; any `VisibleFaceMeshFacts` / payload-byte-count helpers hello-voxel still expects on the wrong module. Do **not** create `material/texture`, `lighting/shadow`, `render/pass`, or `world/region` leaves.

**Why now rather than later:** second-caller rule. Hello-voxel and the corpus are the callers. Empty engine leaves violate the S0 freeze (“do NOT create empty leaves”) and the pragmatic-purity bar (speculative machinery with no named harm).

**Size:** S per hole, cap M for the set.

**Parallel:** yes, Triga-src only.

Everything else — generic-math Stage 1, scene split, three.js-80 remaining stages, 61-leaf inventory — is §6.

---

## 5. Parallelizability

**Verdict:** Triga **can** move in parallel with Gradus / Radix-compiler / inference work **if and only if** it stays inside area A and C. Area B, generic-math, shader-contract shape changes, and G2/G3 language work **compete** for the same surfaces and the same attention. Treating “resume Triga” as “resume the engine campaign” is a distraction.

### What is independent (parallel-safe)

| Surface | Why it does not fight Gradus/Radix-forward |
| --- | --- |
| `triga/src/**/*.fab` math, geometry, primitives, scene, resource, face | Sibling Faber library. Radix resolves it via `FABER_LIBRARY_HOME`. Gradus has no `triga:` imports. |
| `triga/exempla`, `triga/corpus/*.fab` name/import repair | Same package. Needs a **stable** `faber` binary to check, not a moving compiler feature. |
| `examples/hello-voxel`, `triga-drift-city`, `triga-budapest` consumer migration | Examples repo. Uses Triga types + tela DOM. Not Metal, not Gradus. |

### What shares a moving surface (not parallel)

| Dependency | Status at this pass | Why it contends |
| --- | --- | --- |
| `hosts/webgpu-browser` | Live engine + compute proofs (matmul, kernel chain, placement, chunk lifecycle). Area B edits `public/src/engine/**` and `public/src/backend/webgpu-runtime.js`. | This host is the GPU proof product for **radix graphics and compute**, hello-voxel host proofs, and Triga corpus. Gradus library benches are CPU/FMIR (`gradus/scripta/bench`) and Metal parity is `radix/scripta/parity` — those do **not** share this JS tree — but **radix GPU harnesses do**. A Triga engine refactor in `webgpu-runtime.js` races those proofs. |
| Radix `shader_contract` / WGSL graphics emit | Adapter in Triga is landed; regeneration of `triga-lit` is **not**. | Area B is a radix emit. Graphics MIR was the 80 Stage 4–5 gate. That lane is the same compiler family Gradus/WGSL work sits in. |
| Radix generics (`vector<f32, N>`, `matrix<f32, [R, C]>`) | `generic-math-types` Stage 1 delivery (2026-09-16) records S1-R1…R4 in **radix**, and a live `SEM010` regression on the Stage-0 fixture at radix `574526dfb`. | Looks like Triga work. It is compiler work. It also clean-breaks every Triga consumer A is trying to reconnect. |
| G2 / G3 (cross-module enum variants; `PKG001` import cycles) | Still parked in `triga-engine/checkpoint/language-lane-handoff.md`. Live `scene.fab` remains a monolith using **same-module** `match` on `union SceneNodeKind`. | Scene split is a radix/faber language change. |
| Frozen `*_code` ABI | Live lockstep with `radix-mir` shader_contract. | Any rename or new code is a paired radix commit. |
| tela DOM API | Corpus and examples import `tela:dom` / `tela:web`. tela kernel explicitly has **no** triga dependency. | A-area consumer work compiles against tela. If tela DOM is in flight, serialize those packages. It is not a 3D-render coupling. |

### What would make Triga a distraction

- Opening **generic-math Stage 1** while Gradus/Radix is moving: it demands radix units, currently fails a frozen proof, and invalidates the consumer reconnection in A.
- Building **`triga:engine` / `triga:render` / `triga:world` leaves** before an admitted draw: speculative inventory, S0 freeze already forbids empty leaves.
- Using **Metal** as Triga’s backend “because GPU”: wrong device, wrong repo, fights inference work for no architectural gain.
- Resuming **three.js-80/90** as a score: the ledger is still all-unsupported; chasing points recreates the compiler-pressure campaign that was abandoned for Gradus.
- Editing **`hosts/webgpu-browser/public/src/backend/webgpu-runtime.js`** as a Triga-only task: that file is the shared WebGPU backend for compute and graphics proofs.

**Norma:** Triga does not import Norma. `api-shape-policy` §1b rejected `norma:vector`. No Norma feature gate.

**Stable enough to use without editing:** English leaf APIs in `triga:math` / `geometry/*` / `primitives/basic` / `scene` / `resource` / `face`; tela DOM as a publish bus; radix shader-contract **codes** (do not rename). **Not stable:** WGSL graphics artifact schema as consumed by admission; radix generics; hollow-facade re-exports (they do not exist).

---

## 6. Premature or blocked

| Attractive item | Why not now |
| --- | --- |
| **Generic-math types Stage 1** (`Vector<N>` / native `vector<f32, N>`) | Compiler-blocked (`SEM010` on the Stage-0 fixture per delivery-stage1.md P-2, 2026-09-16). Clean-breaks A. Competes with radix. Policy fork vs `api-shape-policy` §1b. **Demote** until radix generics are green on that fixture **and** consumers in A have been migrated once. |
| **DS-D scene split** (`scene/{node,store,query}`) | Hard-gated on G2 (cross-module enum/union variants) and G3 (`PKG001` cycles). The monolith works. Splitting it does not add a consumer capability. |
| **Creating `engine/*`, `render/*`, `shader/*`, `world/*`, `asset/*`, `animation/*`** | S0: “do NOT create empty leaves.” No second caller. Area B does not need them. |
| **PBR / textures / shadows / glTF / skinning / instancing** | No admitted unlit draw. `triga-hardening` already excluded these from the professional-baseline campaign. |
| **Three.js-90** | Parked on an 80 Stage-12 audit that has no evidence. |
| **Metal / second-backend portability** | 90-surface. WebGPU browser host is the only graphics runtime. Metal is Gradus. |
| **Replacing DOM-blob extraction with SceneStore walking** | Right architecture, wrong slice. Blocked on a working admitted draw **and** on a host that understands Triga values, not a semicolon-separated string. Do after B. |
| **`check-source` going green by weakening the lint** | The lint is red in part because exemptions are still Latin. Fix the exemptions and constructors together (A). Do not delete the rule. |
| **Filling Phong/Standard with methods “for completeness”** | No consumer. Shape-only records are honest. Methods without a shader variant are theatre. |

---

## 7. The honesty question

**Resuming Triga is worth the effort if the resume is A → (B when hosts/radix graphics is idle) → C from actual callers.** It is not worth the effort as a restart of three.js-80, as generic-math, or as the 61-leaf world-building engine.

The 4.5k-line library is **not** a dead-end prototype to throw away. `math`, `geometry/*`, `primitives/basic`, `scene`, `resource`, `face`, and `shader_contract` are real typed contracts with co-located tests and at least four external callers (hello-voxel, drift-city, budapest, hosts `fixtures/graphics.fab`). That is more than a sketch.

What **is** a dead end is the **aspiration layer**:

- the 80/90 capability ledgers (still all-unsupported);
- the engine GOAL inventory of families that own nothing;
- Latin policy docs over English source;
- a shared renderer whose artifacts cannot pass admission;
- a corpus whose two showcase demos do not parse.

**Do not re-derive the API from a blank page.** Re-derive the *backlog* from the consumers:

1. Make those consumers compile against HEAD (A).
2. Make one shared host draw of their geometry (B).
3. Add only the types those programs lack (C).

**Cost of a full rewrite** (throw away `src/`, keep the idea): you would rewrite ~2.5k lines of actual math/geometry/primitives and then rediscover scene/resource/shader_contract. That is an L–XL with no new information. **Cost of the consumer-driven prune:** S–M in A, M in B later, and deletion of unused vision docs when someone is already in the factory tree. Prefer prune.

**Negative, plainly:** do not staff a Triga engine campaign in parallel with Gradus. Do staff a small, parallelizable consumer-reconnect on the existing contract. If the operator only has attention for one GPU surface, that surface is still Gradus/Metal; Triga should wait for B, not pretend B is a Triga-only lane.

---

## Stale-doc findings (repo wins)

| Doc | Claim | Live |
| --- | --- | --- |
| `triga-engine/GOAL.md` Status | S2 “remains planned” | Phase 1 extraction is in hosts; Phase 2 draw is gated on rejected artifacts |
| `triga-engine/CAMPAIGN.md` | “S1 seam repair lowered as six parallel delivery specs”; DS-S2 still draft | S1 splits are in `src/`; DS-S2 Phase 1 files exist in hosts |
| `api-shape-policy.md` | Latin stems, `matrix4_conspectus` | English methods/constructors in `src/math.fab` |
| `api-shape-policy.md` §1b | Keep `Vector2/3/4` | `generic-math-types` selected native `vector<f32, N>` (not applied in src) |
| `module-map.md` Size / Target map | ~850-line math, 61 leaves | Scorecard flags both as stale; 26 modules live |
| `triga-threejs-80/CAMPAIGN.md` | Stage 4 next (2026-07-14) | No subsequent stage land; capabilities.json all unsupported |
| `hello-voxel/CAMPAIGN.md` | Goals 00–03 complete; Goal 04 next | Campaign lives in triga docs; application lives in `examples/hello-voxel` and is **inferred** broken against current Triga APIs |
| `AGENTS.md` module table | `triga:graph` owns lights | Lights are `triga:lighting/light` |
| `proof/capabilities.json` | Campaign baseline | Still a useful **unsupported** ledger; not a progress meter |
| `coverage-scorecard.json` | 26/26 executed-proba | Dated 2026-08-24; `inventory_mismatch: true`; HEAD later |

---

## Not verified

- No `faber check` / `faber test` / `./scripta/check*` / cargo (forbidden). Exempla and hello-voxel breakage is from symbol/import reading.
- G2/G3 still present in **current** radix parser/semantics — inferred from parked handoff + live monolith; not re-probed.
- Whether tela DOM is currently in-flight in another session.
- Whether `hosts/webgpu-browser` engine JS runs at all beyond admission-reject (would need WebGPU browser).
- Live proba at HEAD after September polish.
- Whether `geometry_vertex_layout_matches` without `stage_io_role_code` is still the intended library-surface split under current radix ingest (documented as such; not re-run).
- `examples/triga-budapest` beyond its `triga:math` + DOM-blob pattern.
- Any consumer outside `triga/`, `examples/hello-voxel`, `examples/triga-drift-city`, `examples/triga-budapest`, and `hosts/webgpu-browser/fixtures/graphics.fab`. None others were found by `import from "triga:` / `importa ex "triga:` on `.fab` under `tela/`, `norma/`, `gradus/`.
