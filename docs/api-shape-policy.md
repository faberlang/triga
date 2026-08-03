# Triga API Shape And Vocabulary Policy

**Status:** accepted law — supersedes `api-vocabulary-proposal.md` (which retains
proposal status for revision history)
**Date:** 2026-07-27

## Authority

This document is the accepted policy for Triga's public API shape and
vocabulary. It is grounded in `radix/docs/stdlib/morphologia.md` (Faber public
API inflection rules) and the evidence gathered during the API rework clean
break (goal: `docs/factory/api-shape-vocabulary/GOAL.md`).

## 1. Shape: Receiver Methods On Genera

### Rule

All public operations that act on a genus instance are **receiver methods** on
that genus. The receiver is implicit `ego`. The type prefix is dropped from the
method name.

```fab
genus Vector3 {
    f32 x, f32 y, f32 z

    functio addita(de Vector3 alter) → Vector3 { … }
}
```

### Exceptions (stay as free functions)

- **Constructors** — no receiver exists yet: `vector3(x, y, z)`,
  `box3_ex_minimo_et_maximo(...)`, `matrix4_conspectus(...)`.
- **Pure scalar helpers** — no genus receiver: `_radix_f32`,
  `_sinus_f32`, `_cosinus_f32`, `radians_ex_gradibus`.
- **Primitive generators** — build a new genus, no receiver:
  `indexed_triangle_geometry(...)` on `triga:geometry`; shape builders such as
  `sphere_geometry(...)` / `plane_geometry(...)` on `triga:primitives`.

### Imperativus vs Perfectum

| Mode | Receiver | Returns | Use |
|---|---|---|---|
| **Perfectum** | `de ego` (default) | Copy or projection | Non-mutating operations |
| **Imperativus** | `varia ego` | `vacuum` or status flag | In-place mutation |

### Decision: Own Math Types (§ 1b)

Triga keeps `Vector2`, `Vector3`, `Vector4`, `Matrix3`, `Matrix4`, `Quaternion`
as Triga-owned genera. No `norma:vector` adoption. One self-contained idiom; no
dependency on Norma register-lane maturity.

### Decision: Scene Store Is Imperativus (§ 1c)

The copy-out `SceneStore` pattern was an artifact of free-function shape, not
deliberate persistence. Scene mutations are Imperativus on a `varia` receiver.
`SceneInsert` genus deleted; `SceneStore.insere()` returns `SceneHandle` only.

## 2. Vocabulary: Technical Latin

### Carrier Nouns Kept As English

Standard graphics/math terms stay as-is where the standard identity is the point:

`Vector2`, `Vector3`, `Vector4`, `Matrix3`, `Matrix4`, `Quaternion`, `Euler`,
`Box3`, `Sphere`, `Plane`, `Ray`, `f32`, `u32`, `UV`, `WGSL`, `WebGPU`,
`vertex`, `fragment`, `shader`, `pipeline`, `yaw`, `pitch`, `BufferGeometry`,
`BufferAttribute`.

### Operation Stems Latinized

| English | Latin stem | Applied to |
|---|---|---|
| `dot` | `productum` | Vector3, Vector4 dot product |
| `cross` | `transversum` | Vector3 cross product |
| `normalize` | `normata` | All normalize operations |
| `valid` | `valida` / `validum` | Predicate adjectives |
| `get` | `cape` | Retrieval |
| `find` | `inveni` | Search |
| `contains` | `continet` | Containment predicates |
| `insert` | `insere` | Insertion |
| `attach` | `adiunge` | Attachment |
| `detach` | `seiunge` | Detachment |
| `remove` | `detrahe` | Removal |
| `set` | `pone` | Setting state |
| `forward` | `prorsum` | Direction |
| `right` | `dextra` | Direction |
| `visible` | `visibile` / `visibilia` | Visibility |
| `world` | `mundus` | World space |
| `mesh` | `rete` | Mesh (internal names) |

### Morphologia Compliance

- One stem per operation; conjugated form carries posture.
- Imperativus for mutation (`varia` receiver); Perfectum for projections.
- Real Latin forms, not invented endings.
- No same-behavior aliases.
- No English aliases for Latin names absent a real external contract.

## 3. Frozen ABI Seam

Fact-genus field names and numeric codes consumed by
`radix/crates/radix-mir/src/abi.rs` are **exempt** from vocabulary changes until
a lockstep radix change is planned:

`format_code`, `step_mode_code`, `offset_bytes`, `stride_bytes`, `source_name`,
`primitive_topology_code`, `color_target_format_code`, and any field ending in
`_code` on a fact genus.

## 4. Layer Patterns

### Projection Families → Query Genus

When N functions project different facts from the same traversal, collapse into
one query genus with accessors. Example: 14 `scene_visible_*` functions →
`VisibiliaRetium` with `.numerus()`, `.geometriae()`, `.materiae()`, `.octeta()`,
`.ductus()`.

### Nullable Re-Validation → Construction Invariant

When accessors return `∪ nihil` only to re-check an invariant already held at
construction, hold the invariant at construction and make accessors total.
Genuine absence (e.g., non-overlap) stays nullable.

## 5. Naming Lint

`triga/scripta/check-source` enforces:
- No line-start `//` comments.
- No retired `@ externa`/`@ subsidia` annotations.
- No retired optional genus field syntax.
- **(New)** No public `functio` with a type-name prefix matching a defined genus
  (`vector3_*`, `box3_*`, `matrix4_*`, `camera_*`, `scene_*`, `geometry_*`,
  `transform_payload_*`) except constructors and pure scalar helpers explicitly
  documented in this policy. The compiler contract adapter
  `geometry_vertex_layout_matches` is also exempt: its standalone signature
  is the canonical `@ shader_contract "vertex_layout"` bridge and is not a
  receiver operation.
