# Track A — Proposed module inventory vs live repo rules

**Checkpoint**: triga-engine S0 (Horizon 0) — architecture checkpoint
**Track**: T-A (inventory validation against repo rules)
**Author date**: 2026-08-01
**Inputs**: [engine GOAL.md](../GOAL.md) ("Proposed Triga file inventory", "Structural model", "Responsibilities by module family", "Proposed implementation horizon"), [AGENTS.md](../../../AGENTS.md) (module layout rules), [api-shape-policy.md](../../api-shape-policy.md) (receiver shape, naming lint, frozen ABI seam), [module-map.md](../../module-map.md) (9-leaf current map), `scripta/check-source`, `src/*.fab` (line counts + genus inventories), live corpus consumers under `corpus/*/src/*.fab`.

**Verdict in one sentence**: the inventory is structurally sound (no nesting-rule violation; every proposed package has ≥3 leaves) but **36 of 61 leaves would own nothing today** (59%), the graph/light + lighting/light double-leaf and the math-bounds vs geometry/bounds dualism must be resolved before freezing, the repo is currently **red on the naming lint** (`geometry_vertex_layout_matches`, src/geometry.fab:1332), and the "~50 leaves" claim is actually 61 leaves / 75 import paths.

---

## 0. What the repo actually has today

| File | Lines | Owns |
| --- | --- | --- |
| `src/math.fab` | 850 | Vector2/3/4, Matrix3/4, Quaternion, Euler, Color, Box3, Sphere, Plane, Ray, TransformPayload, face-code tables (`face_code_*`), camera-yaw/pitch helpers, free constructors |
| `src/geometry.fab` | 1343 | BufferGeometry (list-of-attributes), BufferAttribute, VertexAttributeLayout, DrawRange, GeometryDrawCommand, GeometryGroup, Indexed/Line draw-batch facts, BoundingBox, BoundingSphere, VisibleFaceMeshFacts, ColoredQuadMesh, generators (`indexed_triangle_geometry`, …) |
| `src/scene.fab` | 930 | SceneHandle, SceneNode(+kind), SceneStore (Imperativus), SceneTraversal, VisibiliaRetium, constructors `scene_store()/scene_node()/…` |
| `src/resource.fab` | 547 | ResourceHandle, ResourceTransition, ResourceLifecycleTransition, batch facts, traversal |
| `src/primitives.fab` | 473 | `plane_geometry`, `circle_geometry`, `sphere_geometry`, `cylinder_geometry`, `cone_geometry`, `torus_geometry`, `box_geometry`, `box_wire_geometry` |
| `src/material.fab` | 183 | Material, MaterialPipelineFacts, MeshStandardMaterial, MeshBasicMaterial, MeshPhongMaterial, Mesh, MeshGeometry, TextureDescriptor (placeholder), helpers |
| `src/graph.fab` | 119 | Object3D, Scene, PerspectiveCamera, OrthographicCamera, Light, AmbientLight, DirectionalLight, PointLight + projection facts |
| `src/face.fab` | 39 | FaceQuad + `face_code_unit_quad`, `face_code_colored_quad_mesh_append` |
| `src/triga.fab` | 20 | Facade / map only (imports math, graph, material, face; no genera) |
| `src/math.proba` | 27 | Vector3 test suite |

Live corpus consumers (the acceptance workloads — only `math`, `graph`, `geometry`, `primitives` are consumed):
- `corpus/webgl-geometries/src/camera.fab:84`, `corpus/webgl-geometry-terrain/src/camera.fab:84` → `graph.PerspectiveCamera`, `graph.Object3D`
- `corpus/webgl-geometries/src/shapes.fab:21,28,69` → `geometry.BufferAttribute`, `geometry.BufferGeometry`; `:9-10` imports `geometry` + `primitives`
- both `main.fab` + `terrain.fab` → `triga:math`

**No corpus consumer imports `triga:material`, `triga:scene`, `triga:resource`, or `triga:face`** (the corpus demos each define their own local `scene.fab` module, unrelated to `triga:scene`). So splits of material/scene/resource/face have zero corpus breakage; splits of graph and geometry have live corpus breakage.

---

## 1. Per-family table

Inventory is 61 non-facade leaves + 13 family facades + `triga` = **75 import paths** (GOAL.md calls it "~50 leaves").

| Family | Proposed leaves | Current source | Live content today? | Nesting-rule verdict | Split recommendation |
| --- | --- | --- | --- | --- | --- |
| math | 1 (`math.fab`) | `src/math.fab` ~850 | **yes** | n/a (existing leaf) | keep flat; freeze |
| resource | 1 (`resource.fab`) | `src/resource.fab` ~547 | **yes** | n/a (existing leaf) | keep flat; freeze |
| face | 1 (`face.fab`) | `src/face.fab` ~39 | **yes** | n/a (existing leaf) | keep flat; freeze |
| graph | 3 (`object`, `camera`, `light`) + facade | `src/graph.fab` ~119 | **yes** for object+camera; `light` leaves are being moved to lighting | OK (3 leaves) | split `object`+`camera` now; **drop/defer `graph/light`** (see §3b) |
| scene | 3 (`node`, `store`, `query`) + facade | `src/scene.fab` ~930 | **yes** (all three) | OK (3 leaves) | split now (H1) — lowest-risk split, no corpus consumer |
| geometry | 5 (`data`, `attribute`, `layout`, `bounds`, `batch`) + facade | `src/geometry.fab` ~1343 | **yes** (all five) | OK (5 leaves) | split now (H1), but fix the lint failure and preserve frozen ABI names (§3a, §3d) |
| primitives | 4 (`basic`, `procedural`, `terrain`, `voxel`) + facade | `src/primitives.fab` ~473 | **yes for basic only**; others empty until H2/H5 | OK (4 leaves) | split `basic` now; defer `procedural`/`terrain`/`voxel` until content exists |
| material | 6 (`base`, `basic`, `lit`, `standard`, `texture`, `sampler`) + facade | `src/material.fab` ~183 | **yes** for base/basic/lit/standard; `texture` = 10-line placeholder; `sampler` empty | OK (6 leaves) | split `base`/`basic`/`lit`/`standard` now; defer `texture`+`sampler` to H3 |
| lighting | 4 (`light`, `model`, `environment`, `shadow`) + facade | light families live in `src/graph.fab` | **partial** — `light` moves in from graph; model/environment/shadow empty | OK (4 leaves) | move `light` now (no corpus consumer); defer `model`(H3), `environment`(H5), `shadow`(H4) |
| renderable | 4 (`mesh`, `skin`, `morph`, `instance`) + facade | `Mesh` lives in `src/material.fab` | **yes for mesh** (moves in); skin/morph/instance empty | OK (4 leaves) | split `mesh` now (the ownership-correction centerpiece); defer `skin`/`morph`(H5), `instance`(H6) |
| shader | 5 (`stage`, `value`, `program`, `resource`, `variant`) + facade | none anywhere in `src/` | **no** — empty until H3 (`program` until H7) | OK (5 leaves) | **defer entire package** to H3 |
| render | 7 (`item`, `pipeline`, `target`, `pass`, `graph`, `batch`, `capability`) + facade | none (draw-batch facts live in `src/geometry.fab`) | **no** — empty until H4 | OK (7 leaves) | **defer entire package** to H4 |
| engine | 4 (`renderer`, `frame`, `session`, `capability`) + facade | none | **no** — empty until H2 | OK (4 leaves) | **defer entire package** to H2 |
| asset | 4 (`source`, `gltf`, `image`, `cache`) + facade | none | **no** — empty until H5 | OK (4 leaves) | **defer entire package** to H5 |
| animation | 4 (`clip`, `sampler`, `mixer`, `deformation`) + facade | none | **no** — empty until H5 | OK (4 leaves) | **defer entire package** to H5 |
| world | 5 (`region`, `terrain`, `stream`, `instance`, `query`) + facade | none | **no** — empty until H5 (query until H6) | OK (5 leaves) | **defer entire package** to H5 |
| triga | facade only | `src/triga.fab` ~20 | facade | n/a | freeze as map-only (no genera ever) |

---

## 2. Empty-facade risk: leaves that would own nothing today

**36 of 61 leaves (59%) have zero content at freeze time.** Grouped by horizon:

| Horizon that fills it | Leaves | Why deferred is right |
| --- | --- | --- |
| H2 | `engine/{renderer,frame,session}` (+ `capability`) | the shared-engine vertical slice is the first thing that can own an engine contract; until then there is no session/renderer concept in Triga |
| H3 | `shader/{stage,value,resource,variant}`, `material/{texture,sampler}`, `lighting/model` | typed shader intent, texture/sampler reflection, and lighting-family requirements all appear with the material-variant work. `material/texture` has only the `TextureDescriptor` placeholder today (src/material.fab:167-176, self-described "minimal placeholder") |
| H4 | `render/{item,pipeline,target,pass,graph,batch,capability}`, `lighting/shadow` | explicit passes/targets/hazards and shadow policy appear with the render-graph work |
| H5 | `asset/*`, `animation/*`, `world/{region,terrain,stream,instance}`, `renderable/{skin,morph}`, `primitives/{procedural,terrain,voxel}`, `lighting/environment` | assets/animation/world/deformation are all H5 families. Seed candidates: `corpus/webgl-geometry-terrain/src/terrain.fab` (226 lines of heightfield/value-noise/normal/color-ramp generation) is exactly the code that should flow back into a triga terrain leaf |
| H6 | `renderable/instance`, `world/query`, `engine/capability` | instancing/query scale proofs |
| H7 | `shader/program` | bounded programmable materials |

**The two worst empty-facade packages are `shader` (6 modules: 5 leaves + facade, nothing) and `render` (8 modules, nothing).** Creating them at Horizon 0 to satisfy the nesting rule inverts the rule's intent — the module map's own guidance (module-map.md:96-98) is "next seam only if a second importer wants" the content. Neither package should be created as empty directories; the inventory should record them as **planned**, not **created**.

**Not-yet-empty but misleading:**
- `material/texture.fab` — one placeholder genus (`TextureDescriptor`, ~11 lines) that explicitly says it will be expanded "when texture pipeline (samplers, mipmaps, render targets) is designed". Either move it into `material/texture.fab` now as the seed, or keep it in `material.fab` until H3. Do not create the leaf "because the package needs six".

---

## 3. Exact rule check

### 3a. Naming lint — the repo is currently RED (pre-existing)

`./scripta/check-source` exits 1:

```
1332:functio geometry_vertex_layout_matches(
check-source: genus-prefixed function should be a receiver method … in src/geometry.fab
```

`geometry_vertex_layout_matches(` matches the lint's reject pattern (`^functio … geometry_[a-z]`) and is **not** in the constructor exemption list (scripta/check-source:39-44). This predates the inventory, but the geometry split is the natural place to fix it (make it a receiver method on `VertexAttributeLayout`, or move it onto the fact tuple). The lint runs over `find "$SRC" \( -name '*.fab' -o -name '*.proba' \)` (scripta/check-source:47), so **nested leaves are linted too** — new split leaves are not exempt. No proposed leaf name itself trips the lint; the exemption list is constructor-anchored (e.g. `scene_store(`, `camera_pitch_coercita(`).

### 3b. Nesting rule — no violations in the proposal

Every proposed package has ≥3 leaves (graph 3, scene 3, geometry 5, primitives 4, material 6, lighting 4, renderable 4, shader 5, render 7, engine 4, asset 4, animation 4, world 5). The "single nested file flattens to a top-level leaf" rule (module-map.md:24-26, AGENTS.md) never triggers. **The risk is not under-nesting but over-nesting into empty leaves** — see §2.

### 3c. Facade rule — structurally compliant; sharpest migration edge

- `triga:triga` stays map-only (it is today, src/triga.fab:15 "intentionally holds no genera"). GOAL's "must not become a god module / compatibility barrel" is satisfied by construction **only if the split literally empties each facade file**. A split that leaves one genus behind in `graph.fab` turns it into a compat barrel — that is the failure mode to watch.
- No type re-export exists (module-map.md:18, GOAL.md:128-129). **Live consequence**: the corpus demos import `triga:graph` for `PerspectiveCamera`/`Object3D` and `triga:geometry` for `BufferGeometry`/`BufferAttribute`. After the split, `triga:graph` and `triga:geometry` stop providing those genera, and `corpus/webgl-geometries/src/camera.fab:84`, `corpus/webgl-geometry-terrain/src/camera.fab:84`, `corpus/webgl-geometries/src/shapes.fab:21,28,69` must migrate to leaf imports (`triga:graph/camera`, `triga:geometry/data`) **in the same change**. Since demos are the acceptance workloads (AGENTS.md corpus rule), this is a migration obligation, not optional.

### 3d. Frozen ABI seam — names that must survive the split verbatim

api-shape-policy.md §3 freezes `format_code`, `step_mode_code`, `offset_bytes`, `stride_bytes`, `source_name`, `primitive_topology_code`, `color_target_format_code`, and any `_code` field on a fact genus. Current occurrences in the split zone:

| Today | Must land in | Names that must survive |
| --- | --- | --- |
| `VertexAttributeLayout` (src/geometry.fab:128-136) | `geometry/layout.fab` | `source_name`, `offset_bytes`, `stride_bytes` |
| `vertex_layout_matches` signature (src/geometry.fab:911-916) | `geometry/layout.fab` | `format_code`, `offset_bytes`, `stride_bytes`, `step_mode_code` |
| private code helpers `_vertex_format_code`, `_vertex_layout_format_code`, `_vertex_step_mode_code`, `_vertex_layout_step_mode_code`, `_primitive_topology_code` (src/geometry.fab:1244-1284) | `geometry/layout.fab` | unchanged |
| `BufferGeometry.index_format_code()` (src/geometry.fab:393) | `geometry/data.fab` | unchanged |
| `MaterialPipelineFacts.side_code` (src/material.fab:41) | `material/base.fab` | unchanged |
| `color_target_format_code` | **not present in src today** | when `render/target.fab` is created at H4, the field must use this exact name |

The splits are safe as long as they are pure moves. Do not "clean up" any of these names during the split.

### 3e. Internal inventory inconsistencies (must be resolved before the map freezes)

1. **Bounds dualism.** GOAL.md:334 says math owns "vectors, matrices, quaternions, colors, **bounds**, rays" and module-map.md:30 lists math owning `Box3`, `Sphere`; but GOAL.md:222 assigns `geometry/bounds.fab` "bounds, spheres, boxes, and spatial extents". Two bound families already coexist: `Box3`/`Sphere` (src/math.fab:284,404) and `BoundingBox`/`BoundingSphere` (src/geometry.fab:174-188). Do **not** move `Box3`/`Sphere` out of math — `RayBox3Hit` (src/math.fab:492) and the face-code tables depend on them, and face.fab:4-5 explicitly keeps face-code tables in math "so RayBox3Hit can call them without a math↔face import cycle". `geometry/bounds` should own the geometry-side `BoundingBox`/`BoundingSphere` and its comment should say so, or the two families must be named as intentionally distinct.
2. **graph/light + lighting/light double-leaf.** GOAL.md:207 (`graph/light.fab` "light attachment/node values") and GOAL.md:242 (`lighting/light.fab` "directional, point, spot, hemisphere") are two leaves for one concept. Today's light genera are already attachments (`Light { Object3D base, Color color, f32 intensity }`, src/graph.fab:90-113); there is no separate attachment genus to split off. **Recommendation: drop `graph/light.fab`.** Light families move to `lighting/light.fab` (importing `graph/object` for the base — same-level import, no cycle); the graph package then has `object` + `camera` (2 leaves, legal; 3 is "prefer", not "must"). Reintroduce a graph-side light node only if a real second importer appears.
3. **MeshGeometry + BufferGeometry both land in `geometry/data`.** GOAL.md:215 sends "MeshGeometry and CPU-side vertex data" there, and the ownership-correction table (GOAL.md:318) moves `material.fab: MeshGeometry` → `geometry/data`. But `MeshGeometry` (src/material.fab:9-19, flat SoA layout) and `BufferGeometry` (src/geometry.fab:279, list-of-attributes) are two different geometry value types; the module map (module-map.md:33) and graph.fab:114-118 treat them as deliberately distinct ("renamed to avoid collision"). `geometry/data` would own two parallel geometry types. Resolve: merge, rename, or document the distinction before freezing.
4. **Leaf count.** GOAL.md:191 says "~50 leaves"; the inventory is 61 non-facade leaves / 75 import paths. Correct the number at freeze so the ownership map is accurate.
5. **`cista.toml` listed** (GOAL.md:196) but does not exist and distribution is explicitly a later checkpoint (GOAL.md:519-523). Fine as future, but it is not a current file.
6. **`render/batch` vs existing geometry draw-batch facts.** Current `GeometryDrawCommand`, `GeometryGroup`, `IndexedGeometryDrawBatchFacts`, `LineGeometryDrawBatchFacts` (src/geometry.fab:142-172) have an undecided home once `render/batch` ("batching, instancing, and submission groups", GOAL.md:268) exists. Geometry-side payload/byte-count facts most naturally stay in `geometry/batch` ("groups and draw-range data", GOAL.md:224); decide explicitly at H4.

---

## 4. One-line verdict per family

- **math** — freeze as proposed (existing leaf, heavy live consumption, no split).
- **resource** — freeze as proposed (existing leaf, no split).
- **face** — freeze as proposed (existing leaf, no split).
- **graph** — adjust: split `object`+`camera` now; drop `graph/light` (light families → `lighting/light`); migrate the two corpus `camera.fab` demos to `triga:graph/camera` in the same change.
- **scene** — freeze as proposed (split now at H1: node/store/query all have content, zero corpus consumers).
- **geometry** — adjust: split now at H1 (data/attribute/layout/bounds/batch all have content), but fix the `geometry_vertex_layout_matches` lint failure and preserve frozen ABI names (§3a, §3d); resolve the bounds dualism and MeshGeometry/BufferGeometry dualism first (§3e).
- **primitives** — adjust: split `basic` now; defer `procedural`/`terrain`/`voxel` until content exists (corpus terrain generator is the natural seed).
- **material** — adjust: split `base`/`basic`/`lit`/`standard` now (Mesh → `renderable/mesh`, MeshGeometry → `geometry/data`); defer `texture`/`sampler` to H3; preserve `side_code`.
- **lighting** — adjust: move the light families into `lighting/light` now (no corpus consumer); defer `model`(H3), `shadow`(H4), `environment`(H5).
- **renderable** — adjust: split `mesh` now; defer `skin`/`morph`(H5), `instance`(H6).
- **shader** — defer the entire package to H3 (record as planned; create no empty leaves).
- **render** — defer the entire package to H4; assign the existing geometry draw-batch facts an explicit home at that point.
- **engine** — defer to H2; when created, `renderer`/`session`/`frame` first, and guard the god-module stop condition.
- **asset** — defer to H5.
- **animation** — defer to H5.
- **world** — defer to H5 (`region`/`terrain`/`stream`/`instance`), `query` at H6.
- **triga** — freeze: facade stays map-only, no genera ever.

**Bottom line for the freeze**: freeze only math/resource/face/scene and the H1 split list (graph object+camera, geometry 5-way, primitives basic, material base/basic/lit/standard, renderable mesh, lighting light). Everything else is a *planned* leaf set, not a created one — creating empty directories now would manufacture 36 empty facades and invert the nesting rule's intent.
