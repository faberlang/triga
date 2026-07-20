# Test Decomposition Analysis — triga

**Date:** 2026-07-19
**Source files:** `src/triga.fab`, `src/geometry.fab`, `src/scene.fab`
**Exempla:** `exempla/triga-basics.fab`, `exempla/triga-transforms.fab`, `exempla/triga-geometry-attributes.fab`, `exempla/triga-scene-store.fab`, `exempla/triga-stage4-source-facts.fab`, `exempla/hello-voxel-first-draw-facts.fab`

## Summary

| Lens | Findings | Critical | High | Medium | Low |
|---|---|---|---|---|---|
| Coverage gaps | 35 | 9 | 12 | 8 | 6 |
| Missing negatives | 18 | 2 | 7 | 6 | 3 |
| Redundancy | 12 | 0 | 3 | 5 | 4 |
| Setup complexity | 8 | 0 | 1 | 3 | 4 |

## Top 10 recommendations (ranked by impact)

1. **[Critical] `src/triga.fab`: Untested types (Vector2, Vector4, Matrix3, Mesh, Scene, etc.)** — Nine public genus types have zero exempla coverage. These are declared as public API shapes but no exemplum constructs or validates them. At minimum, instantiation-and-field-access tests are needed.

2. **[Critical] `src/triga.fab`: Untested math functions** — `vector3_projecta` with zero axis, `quaternion_normalizata` with all-zero input, `camera_view_projection`, `camera_view_projection_facts` have no test coverage. A quaternion normalization returning (0,0,0,1) for zero input is especially important — it's a degenerate-input guardrail that should be verified.

3. **[Critical] `src/geometry.fab`: Untested `PointList` topology path** — The `PrimitiveTopology.PointList` discriminant exists and is used by `attribute_valid`, `geometry_vertex_normals`, `geometry_planar_uvs`, `geometry_triangle_count`, `geometry_line_count`, and `_primitive_range_valid`, but no exemplum ever constructs a PointList geometry to exercise those code paths.

4. **[Critical] `src/triga.fab`: Untested material variants (MeshStandardMaterial, MeshPhongMaterial)** — Two of the three material shapes declared in the module have zero exempla coverage. Only `MeshBasicMaterial` has a constructor (`mesh_basic_material`) and tests. `MeshStandardMaterial` (PBR) and `MeshPhongMaterial` lack constructors entirely — they are pure genus shapes — but no exemplum even instantiates one to validate field defaults.

5. **[Critical] `src/triga.fab`: `camera_view_projection` and `camera_view_projection_facts` untested** — These functions compose projection and view matrices but have no exempla coverage. A wrong near/far or up-vector normalization bug would be caught only downstream.

6. **[High] `src/scene.fab`: No tests for 0-length scene store** — Functions like `scene_traverse`, `scene_visible_mesh_count`, and `scene_find_name` are not tested with an empty `SceneStore`. Empty-store traversal should return nil or empty, not crash.

7. **[High] `src/triga.fab`: No NaN/Infinity tests anywhere** — Zero exempla test floating-point edge cases: NaN inputs, Infinity inputs, denormals. A NaN in a Vector3.x passed to `vector3_dot`, `vector3_cross`, or `matrix4_applica_punctum` propagates silently. For a graphics library, NaN vertices crash GPU pipelines.

8. **[High] Four copy-paste traversal variants in `src/scene.fab`** — The source itself acknowledges (lines 754–757): "_WHEN FABER GAINS CLOSURES/VISITORS: collapse these into a single scene_traverse(…) and delete the copies._" Four near-identical `_scene_traverse_*_preorder` functions share a skeleton of node fetch → field copy → seen-set guard → visitor action → child iteration. Any bugfix in one must be replicated in all four. This is a maintenance risk.

9. **[Medium] Repeated Option-unpack boilerplate in exempla** — The pattern `fixum T ∪ nihil result ← f(…); adfirma result non est nihil, …; fixum T value ← T { field1 = result!.field1, … }` appears 50+ times. Faber's lack of `unwrap`/destructuring makes this unavoidable, but a `fingo`-like helper could reduce token cost and clutter.

10. **[Medium] Visibility tests repeat identical assertion sets** — `triga-scene-store.fab` tests three visibility variants (all visible, one hidden, root hidden) with 10 nearly identical assertions each. These could be expressed as a table-driven test if Faber supports iteration over test data.

## Per-module details

### `src/triga.fab` → exempla coverage: `exempla/triga-basics.fab`, `exempla/triga-transforms.fab`

**Coverage gaps (Critical):**
- `Vector2` — genus declared (line 39), **no exemplum** constructs or accesses it
- `Vector4` — genus declared (line 48), **no exemplum** constructs or accesses it
- `Matrix3` — genus declared (line 57), **no exemplum** constructs or accesses it
- `Scene` — genus declared (line 176), **no exemplum** constructs or accesses it
- `OrthographicCamera` — genus declared (line 207), **no exemplum** constructs or accesses it
- `Light`, `AmbientLight`, `DirectionalLight`, `PointLight` — genera declared (lines 219–236), **no exemplum** constructs or accesses them
- `Mesh` — genus declared (line 310), **no exemplum** constructs or accesses it
- `TextureDescriptor` — genus declared (line 609), **no exemplum** constructs or accesses it

**Coverage gaps (High):**
- `MeshStandardMaterial` — genus declared (line 285), no constructor function, **no exemplum** instantiates it
- `MeshPhongMaterial` — genus declared (line 297), no constructor function, **no exemplum** instantiates it
- `camera_view_projection` (line 1448) — **no exemplum** calls it
- `camera_view_projection_facts` (line 1462) — **no exemplum** calls it
- `matrix4_conspectus` with up-vector parallel to forward — **no test** for this degenerate case

**Coverage gaps (Medium):**
- `vector3_projecta` with zero-length axis — **no test** (returns zero vector at line 690–691)
- `quaternion_normalizata` with all-zero quaternion — **no test** (returns (0,0,0,1) at line 710)
- `box3_translata` with invalid bounds — **no test** (passes through unchanged, line 1048)
- `Object3D` — only constructed as a camera base sub-struct, **no standalone test**
- `ViewProjectionFacts` — genus declared (line 197), **no exemplum** constructs or accesses it

**Coverage gaps (Low):**
- `euler_ad_quaternionem` with non-XYZ order — tested (rejects), but **no test for "XZY", "YZX" etc.** — only "ZYX" tested
- `camera_pitch_coercita` — tested at 100°, but **no test at exactly 89.0** (boundary), **no test at -100°** (negative extreme)

**Missing negatives:**
- `material_valid` with `side > 2` — NOT tested (function rejects, but no exemplum exercises side=3)
- `material_valid` with `opacity < 0` or `opacity > 1` — NOT tested
- `material_valid` with `alpha_test < 0` or `alpha_test > 1` — NOT tested
- `color_valid` with g or b out of range — only r=1.1 tested; g and b untested
- `ray_intersecat_box3` with `max_distance < 0` — NOT tested
- `camera_motus_planus_ex_yaw` with negative speed — NOT tested
- NaN/Infinity propagation in vector3/matrix4 operations — **zero tests exist anywhere**
- `_radix_f32` with NaN input — NOT tested (returns 0 for ≤ 0; NaN propagates)

**Redundancy (Medium):**
- Face-code tests repeat the same pattern for x, y, z positive and negative faces (~80 lines could be table-driven)
- `face_code_axis_code`, `face_code_opposite`, `face_code_x_offset`, `face_code_y_offset`, `face_code_z_offset` tested with near-identical assertion shapes for each axis

**Setup complexity (Low):**
- Individual function tests are mostly 5–15 lines of setup each
- Face-code quad geometry tests require 15–30 lines, but each tests winding correctness and is worth the cost

### `src/geometry.fab` → exempla coverage: `exempla/triga-geometry-attributes.fab`, `exempla/triga-stage4-source-facts.fab`, `exempla/hello-voxel-first-draw-facts.fab`

**Coverage gaps (Critical):**
- `PrimitiveTopology.PointList` — discriminant exists (line 17) and is handled by `geometry_vertex_normals`, `geometry_planar_uvs`, `geometry_triangle_count`, `geometry_line_count`, `geometry_valid`, `_primitive_range_valid`, `_geometry_topology_valid` — but **no exemplum** constructs a PointList geometry. Those code paths are unreachable in all exempla.

**Coverage gaps (High):**
- `AttributeUsage.DynamicAttribute`, `AttributeUsage.StreamAttribute` — discriminants exist (lines 21–22), but only `StaticAttribute` is used in exempla. The `attribute_valid` function (line 500) checks `attribute.normalized` but does not inspect `usage` — so Dynamic/Stream have no behavioral difference to test. However, all three discriminants should be exhaustively verified at least once.
- `attribute_scalar_bytes` (line 228) — **no direct test**; returns 4 for both Float32 and Uint32 variants, but no exemplum calls it independently
- `geometry_vertex_layout_format_code` (line 368) — **no direct test**; tested indirectly via `geometry_vertex_layout_matches`
- `attribute_vertex_layout` (line 472) — **no direct test**; only `geometry_vertex_layouts` (which calls it) is tested

**Coverage gaps (Medium):**
- `geometry_group_draw_commands` with multiple groups — tested with single group only; the split-groups geometry (lines 343–357) tests bounding boxes but not multi-group draw command lists
- `IndexedGeometryDrawBatchFacts` with multi-group input — same gap as above
- `VertexAttributeLayout` standalone construction by user code — not tested (always derived via `geometry_vertex_layouts`)
- `_geometry_position_values` — private helper, tested implicitly via bounding box/normals, but **no test** for geometry with multiple attributes where position is not the first attribute

**Coverage gaps (Low):**
- `geometry_vertex_layout_offset_bytes` — always returns 0 in current implementation (no interleaved buffers), tested indirectly but never explicitly verified that non-zero offset could work
- Attribute with component_width = 4 (Float32x4) — never constructed; all tests use width=2 or 3

**Missing negatives:**
- `geometry_valid` with `normalized = true` on an attribute — NOT tested (line 502 explicitly rejects)
- `geometry_valid` with empty attribute list (0 attributes) — NOT tested
- `geometry_valid` with one attribute having `element_count = 0` — tested indirectly (malformed attribute length)
- `colored_quad_mesh_append` with mismatched position/color lengths — tested
- `geometry_bounding_box` with empty position data — NOT tested
- `geometry_vertex_normals` with indexed geometry whose indices reference out-of-range vertices — NOT tested (geometry_valid would catch, but what if someone skips validation?)
- `geometry_planar_uvs` with zero-width or zero-height bounds — tested (degenerate triangle rejects)
- `geometry_group_bounding_box` with indexed geometry and group referencing out-of-range indices — NOT tested explicitly

**Redundancy (High):**
- The geometry unpack/repack pattern appears 6 times:
  ```faber
  fixum geometry.BufferGeometry geometry ← geometry.BufferGeometry {
      topology = result!.topology,
      vertex_count = result!.vertex_count,
      attributes = result!.attributes,
      indexed = result!.indexed,
      indices = result!.indices,
      draw_range = result!.draw_range,
      groups = result!.groups
  }
  ```
  This is used for plane, box, box_wire, and colored quad meshes. Faber's value-semantic records force copy-out/copy-in when extracting from `∪ nihil`, but a helper function could reduce line count by ~40 lines across the exempla.

**Setup complexity (Medium):**
- `hello-voxel-first-draw-facts.fab`: 40 lines of position/color/index data arrays before any assertion. This is inherent to a 36-index cube mesh, but the data could live in a shared fixture.

### `src/scene.fab` → exempla coverage: `exempla/triga-scene-store.fab`

**Coverage gaps (High):**
- **Empty SceneStore**: `scene_store()` creates an empty store, but no traversal, visibility, or count function is tested with it. `scene_traverse(empty_store, root)` would fail (nil root), but `scene_visible_mesh_count(empty_store, any_handle)` could be tested — what happens?
- **Deep hierarchies**: All tests use 2-level hierarchy (root → children). No test exercises 3+ levels. The `_scene_traverse_*_preorder` recursion, `_scene_would_cycle`, and `_scene_mark_world_dirty` all use recursive descent.
- **Remaining-counter in traversal**: `remaining ← store.slots.longitudo()` is used as a cycle guard. No test verifies it triggers correctly on pathological input.

**Coverage gaps (Medium):**
- `scene_attach` to self — cycle detection should catch, but no explicit test for child=parent
- `scene_set_local_matrix` with invalid matrix (wrong element count) — NOT tested explicitly
- `scene_effective_visible` with orphan node (parent chain broken) — NOT tested
- `_scene_without_child` removing a non-existent child — NOT tested (used only internally after validation)

**Missing negatives:**
- `scene_insert` into a store with gaps (some slots dead) — NOT explicitly tested; the current setup fills sequentially
- `scene_get` with index beyond slots length — tested (stale handle)
- `scene_contains` with index beyond length — tested
- Duplicate scene_handle in traversal list — tested (cycle rejection)
- `scene_attach` when child already has same parent — tested (duplicate attach)
- `scene_detach` with no parent — NOT tested (function returns nil at line 1541, but no exemplum exercises)
- `scene_update_world` on a non-root node — tested (rejects)
- `scene_remove` with non-empty children — tested (rejects)
- Concurrent resource lifecycle transitions with the same logical index — tested (rejects)
- `_scene_would_cycle` on deep chains — NOT tested (only 1-level cycle: root→mesh vs mesh→root)

**Redundancy (High):**
- The visibility test block repeats ~30 assertions across three nearly identical sections:
  1. Default (all visible): lines 386–486 in exemplum
  2. Shared-mesh hidden: lines 498–576
  3. Root hidden: lines 576–648
  Each section tests the same 15+ functions with the only difference being expected counts (2, 1, or 0). This is ~150 lines that could be a table-driven test.
- `SceneStore { slots = x!.slots }` repack pattern appears 8 times in one exemplum — every time an operation returns a new store, it must be repacked for the next operation. A helper or chaining pattern would help.
- Resource handle preparation repeats: `ResourceHandle { index = …, generation = … }` appears 15+ times.

**Setup complexity (High):**
- The `triga-scene-store.fab` exemplum requires 140 lines of setup before the first traversal assertion:
  - 4 ResourceHandles (lines 14–16)
  - 4 ResourceLifecycleTransitions with lifecycle batch validation (lines 109–278, ~170 lines)
  - Full 5-node scene hierarchy with 4 attach calls (lines 279–319, ~40 lines)
  - The transform section (lines 649–681) adds 30 more lines of setup
- This is the highest setup-to-assertion ratio in the exempla suite. It reflects `scene.fab`'s tight coupling: every operation touches the graph, so every test needs the graph.

**Setup complexity source signal:**
The four copy-paste traversal variants in `src/scene.fab` (acknowledged at lines 754–757) are the root cause of high setup cost. Each variant is ~50 lines of nearly identical skeleton code. The source's own comment says: "_WHEN FABER GAINS CLOSURES/VISITORS: collapse these into a single scene_traverse(store, root, filter, accumulator) and delete the copies._" This refactor would meaningfully reduce the blast radius of traversal bugs and cut exempla setup cost.

### `exempla/triga-stage4-source-facts.fab`
- **Purpose**: Contract-lock for vertex layouts passed to Radix MIR
- **Coverage**: Only tests `geometry.geometry_vertex_layouts` for plane geometry and duplicate-location rejection (2 positive, 1 negative assertion)
- **Gaps**: Does not test `geometry_vertex_layout_format_code`, `geometry_vertex_layout_offset_bytes`, `geometry_vertex_layout_stride_bytes`, or `geometry_vertex_layout_step_mode_code` explicitly
- **Redundancy**: Overlaps with `triga-geometry-attributes.fab` on plane geometry vertex layout validation

### `exempla/hello-voxel-first-draw-facts.fab`
- **Purpose**: Contract-lock for the Hello Voxel colored indexed cube geometry
- **Coverage**: Tests geometry construction, validation, topology, index format, vertex/index counts, payload byte counts, draw commands, vertex layouts (2 attributes), edge cases (invalid indices, empty instance counts)
- **Gaps**: Does not test bounding box/sphere on the cube (present in geometry module but skipped here), does not test vertex normals or UVs

## Cross-cutting observations

### 1. NaN/Infinity protection (Critical)
Zero exempla test floating-point extreme values. Functions like `_radix_f32`, `_sinus_f32`, `vector3_dot`, `vector3_cross`, `vector3_normalizata`, `matrix4_applica_punctum`, and all Box3/Ray intersection functions silently propagate NaN inputs. Graphics pipelines produce undefined rendering with NaN vertices. At minimum, `vector3_normalizata` with NaN input should be tested to verify it returns a zero vector rather than NaN.

### 2. Module boundary enforcement (Medium)
`src/triga.fab` and `src/geometry.fab` have a documented boundary comment (lines 7–18 in both files), but no exemplum tests that types do not leak across modules. E.g., does any exemplum verify that `triga.fab`'s `face_code_colored_quad_mesh_append` correctly delegates to `geometry.colored_quad_mesh_append` without exposing `geometry.BufferGeometry` internals to triga-level callers?

### 3. Deterministic primitive output (Low)
All primitive generators (`plane_geometry`, `sphere_geometry`, etc.) assert vertex counts and index counts, but none test that the **exact** position values, normal directions, or UV coordinates match expected values for a known input. The tests are "count-based" rather than "value-based." A refactor that accidentally flips UV coordinates or swaps normal directions would pass all current tests.

### 4. Performance stress tests (Low)
No exemplum tests large inputs: 10,000-vertex geometries, 1,000-node scene hierarchies, 100-resource lifecycle transitions. The `_scene_mark_world_dirty` and `_scene_update_world_node` functions use recursive descent; deep chains could stack-overflow at runtime (Faber's compilation target may or may not have recursion limits).

## Appendix: Public API coverage matrix

| Source module | Public functions/types | Tested | Untested |
|---|---|---|---|
| `triga.fab` | 34 genera | 16 | 18 |
| `triga.fab` | 46 functions (approx.) | 38 | 8 |
| `geometry.fab` | 8 discriminants | 6 | 2 (DynamicAttribute, StreamAttribute) |
| `geometry.fab` | 13 genera | 13 | 0 |
| `geometry.fab` | 38 functions (approx.) | 32 | 6 |
| `scene.fab` | 19 genera | 19 | 0 |
| `scene.fab` | 28 functions (approx.) | 25 | 3 |

**Overall exempla assertion counts:**

| Exemplum | Positive assertions | Negative assertions | Total |
|---|---|---|---|
| `triga-basics.fab` | 17 | 5 | 22 |
| `triga-transforms.fab` | 72 | 26 | 98 |
| `triga-geometry-attributes.fab` | 82 | 41 | 123 |
| `triga-scene-store.fab` | 62 | 28 | 90 |
| `triga-stage4-source-facts.fab` | 2 | 1 | 3 |
| `hello-voxel-first-draw-facts.fab` | 15 | 2 | 17 |
| **Total** | **250** | **103** | **353** |
