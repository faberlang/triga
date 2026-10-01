# Triga API Shape And Vocabulary Policy

**Status:** accepted law — updated 2026-09-30 for `faber-native-surface`
**Date:** 2026-09-30
**Supersedes:** 2026-07-27 text that kept `Vector3` / Latin `en` stems / three.js product nouns

## Authority

This document is the accepted policy for Triga's public API shape and
vocabulary. Identity law lives in
[`docs/factory/faber-native-surface/GOAL.md`](factory/faber-native-surface/GOAL.md).
Morphologia (`radix/docs/stdlib/morphologia.md`) still governs *receiver
posture* on Triga-owned genera. It does not put dimension in identifiers and
does not make three.js product names the public surface.

The `en` package surface is English. The `la` pack in `locale/la/pack.toml` is
the Latin *reader* projection of those English canonicals, not a second public
API.

## 1. Shape: Receiver Methods On Triga Genera

### Rule

All public operations that act on a Triga-owned genus instance are **receiver
methods** on that genus. The type prefix is dropped from the method name.

Language-owned carriers (`vector<f32, N>`, `matrix<f32, [R, C]>`) cannot grow
Triga receivers. Use compiler glyphs and intrinsics (`·`, `×`, `.dot`,
`.cross`, `.added`, `.subtract`, `.multiply`, `.normalize`, `.apply`). Triga
free functions cover graphics-domain work the compiler does not own
(perspective, look-at, affine inverse, ray–box, face codes, transform payload).

### Exceptions (stay as free functions)

- **Constructors** — no receiver exists yet: `matrix_identity()`,
  `box_from_min_max(...)`, `quaternion(...)`.
- **Pure scalar helpers** — no genus receiver: `sqrt_f32`, `sin_f32`,
  `cos_f32`, `radians_from_degrees`.
- **Primitive generators** — build a new genus, no receiver: `plane(...)`,
  `box(...)` on `triga:primitives/basic`.
- **Lane and matrix cell reads** on language carriers: `x` / `y` / `z`,
  `matrix_element`.

### Decision: Native Math Types (§ 1b)

Triga does **not** own `Vector2`, `Vector3`, `Vector4`, `Matrix3`, or
`Matrix4`. Callers use `vector<f32, N>` and `matrix<f32, [R, C]>` directly.
`Box<N>` is the remaining Triga math nominal in that family, over two
`vector<f32, N>` corners. `Quaternion`, `Euler`, `Color`, `Sphere`, `Plane`,
`Ray`, and `TransformPayload` stay Triga genera and are retyped off the
retired carriers. No `norma:vector` adoption. No numbered compatibility alias.

Construction: `[x, y, z] ↦ vector<f32, 3>`. Matrix builders are
`matrix_identity`, `matrix_translation`, `matrix_scale`, `matrix_compose`,
`matrix_perspective`, `matrix_look_at`.

### Decision: Scene Store Is Imperativus (§ 1c)

Scene mutations are Imperativus on a `var` receiver. `SceneStore.insert()`
returns `SceneHandle` only.

## 2. Vocabulary

### Carrier nouns

Industry-standard domain nouns stay. three.js *product* names do not.

**Keep:** `Quaternion`, `Euler`, `Color`, `Sphere`, `Plane`, `Ray`, `Mesh`,
`Material`, `Light`, `AmbientLight`, `DirectionalLight`, `PointLight`,
`PerspectiveCamera`, `OrthographicCamera`, `Scene`, `f32`, `u32`, `UV`,
`WGSL`, `WebGPU`, `vertex`, `fragment`, `shader`, `pipeline`, `yaw`, `pitch`.

**Language types (not Triga genera):** `vector<f32, N>`, `matrix<f32, [R, C]>`.

**Triga reshape:** `Box<N>` (was `Box3`).

**Settled renames** (`faber-native-surface` OQ-1, 2026-09-30):

| Retired | Destination |
| --- | --- |
| `Object3D` | `Object` |
| `BufferGeometry` | `Geometry` |
| `BufferAttribute` | `Attribute` |
| `MeshBasicMaterial` | `UnlitMaterial` |
| `MeshPhongMaterial` | `PhongMaterial` |
| `MeshStandardMaterial` | `StandardMaterial` |
| `plane_geometry` … `box_wire_geometry` | `plane`, `circle`, `sphere`, `cylinder`, `cone`, `torus`, `box`, `box_wire` |

Import paths (`triga:material/basic`, `triga:geometry/data`, …) stay in this
goal. No compatibility alias for a retired name.

`en` operation stems are English (`add`, `dot`, `cross`, `normalized`,
`contains`, `insert`). Do not Latinize the `en` surface. Latin spellings belong
in the `la` pack only.

## 3. Frozen ABI Seam

Fact-genus field names and numeric codes consumed by
`radix/crates/radix-mir/src/abi.rs` / shader_contract are **exempt** from
vocabulary changes until a lockstep radix change is planned:

`format_code`, `step_mode_code`, `offset_bytes`, `stride_bytes`, `source_name`,
`primitive_topology_code`, `color_target_format_code`, `side_code`, and any
field ending in `_code` on a fact genus.

`TransformPayload` remains 32 `f32` / 128 bytes, model then view-projection,
column-major.

The `VertexFormat` variant spellings (`Float32x4`, `Uint32`, …) are
**temporary, not canonical** (operator ruling 2026-08-21). When the
bounded-buffers value-parameterized family ships, convert this union to
proper generics. The integer format codes are frozen ABI and outlive the
spelling change.

## 4. Layer Patterns

### Projection Families → Query Genus

When N functions project different facts from the same traversal, collapse into
one query genus with accessors.

### Nullable Re-Validation → Construction Invariant

When accessors return `∪ none` only to re-check an invariant already held at
construction, hold the invariant at construction and make accessors total.
Genuine absence (e.g., non-overlap) stays nullable. `matrix<f32, [4, 4]>`
makes the 16-lane condition a type invariant; do not reintroduce
`Matrix4.valid()`.

## 5. Naming Lint

`triga/scripta/check-source` enforces:
- No line-start `//` comments.
- No retired `@ externa`/`@ subsidia` annotations.
- No retired optional genus field syntax.
- No public `fn` whose name is a live genus prefix plus `_`.
  The script derives the genus set from every `class Name` declaration in
  `src/**/*.fab`.

  Exemptions stay free functions, anchored to `(`:
  - constructors: `box_from_*`, `matrix_identity` / `matrix_translation` /
    `matrix_scale` / `matrix_compose` / `matrix_perspective` /
    `matrix_look_at`, `scene_store(`, `scene_node(`, `scene_group(`,
    `scene_mesh(`, `scene_camera(`, `scene_light(`, `scene_handle_equals(`
  - primitive generators: `plane(`, `circle(`, `sphere(`, `cylinder(`,
    `cone(`, `torus(`, `box(`, `box_wire(`, `colored_quad_mesh_append`
  - camera scalar helpers: `camera_*`
  - compiler-contract adapter: `geometry_vertex_layout_matches` and the
    `shader_contract.fab` role adapters
  - face-code table helpers `face_code_*`
  - `transform_payload`
  - `visible_face_*`
  - Geometry constructors `indexed_triangle_geometry` / `line_geometry` /
    `colored_indexed_geometry` / `triangle_geometry`
  - declaring-leaf enum constructors `vertex_format_from_component_width` /
    `vertex_step_mode_vertex_step`
