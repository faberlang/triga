# DS-A — Material→Renderable Split (Seam A)

**Campaign**: triga-engine, Wave 2 (S1 domain seam repair, six parallel delivery specs)
**Spec**: DS-A (Seam A — material → renderable)
**Status**: draft
**Read first**: [checkpoint/report.md](../checkpoint/report.md) (§1.2, §1.4.3, §2, §3, §7.1, §8),
[checkpoint/T-B-seam-consumers.md](../checkpoint/T-B-seam-consumers.md) (Seam A consumer table),
[checkpoint/T-A-inventory.md](../checkpoint/T-A-inventory.md) (§2, §3a, §3c, §3d, §4),
[api-shape-policy.md](../../api-shape-policy.md) (§1, §3, §5), [module-map.md](../../module-map.md) (target map)
**Companion spec**: **DS-E** (geometry/data — declared consumed interface below).
DS-A and DS-E are drafted in parallel; DS-A consumes one interface and does not assume DS-E's internal leaf names beyond `data`.

## Goal

Land Seam A in the 80 Stage 5→6 gap (report §3): move `Mesh` out of
`src/material.fab` into a new `src/renderable/mesh.fab`; retire `MeshGeometry`
(§1.4.3 clean break — `Mesh.geometry` becomes `geometry.data.BufferGeometry`);
split the Material family into `src/material/{base,basic,lit,standard}.fab`
behind a map-only `src/material.fab` facade. This **removes the
`material → graph` reverse dependency** the campaign GOAL records as an
architectural defect: after the split, `renderable/mesh` imports
`graph` + `geometry/data` + the material leaves, and the material package
imports only `math`.

Timing contract (report §3): seam A must precede 80 **Stage 6** (materials/
textures/lighting — the stage that would grow the material monolith); must NOT
land during 80 Stages 4–5 without coordination (Stage 4 is in flight); lands in
the Stage 5→6 gap as part of the coordinated A+B+D wave. Preconditions per
§7.1: 80 Stages 1–3 landed.

## Invariant (frozen; not re-negotiated by this spec)

1. **`MaterialPipelineFacts.side_code` survives verbatim** (frozen ABI, api-shape-policy §3; T-A §3d) — it moves to `material/base.fab` unmodified, together with the rest of `MaterialPipelineFacts`.
2. **`MeshGeometry` retirement is consumed, not re-opened** (report §1.4.3). `MeshGeometry` is deleted, not moved; its flat SoA shape is preserved nowhere; `BufferGeometry` (list-of-attributes) is the single geometry type. The GOAL's literal "`material.fab: MeshGeometry` → `geometry/data`" row was resolved at S0 into retirement — this spec builds on that resolution.
3. **Pure relocation.** No public-name renames, no helper reshaping, no validation tightening, no new genus fields during the split. The `material_*`/`mesh_basic_material*` free functions stay free functions (constructors/pure helpers, api-shape-policy §1; none trip the §5 lint prefix list).
4. **Facade rule (§1.7).** `src/material.fab` and `src/renderable.fab` end the delivery empty of genera (map-only). No type re-export anywhere.
5. **No new reverse dependency.** Post-split dependency direction: `material/* → math`; `renderable/mesh → graph + geometry/data + material/{standard,basic,lit}`. No module in the material package imports `graph`; no cycles.
6. **No new gate violations.** DS-A adds no new `check-source` failures (acknowledged `geometry_vertex_layout_matches` red is DS-E's) and no new `check-compile` errors beyond the acknowledged 4 E0308s (report §8).
7. **No `@ externa`/`@ subsidia`** (repo rule); new files use `#` comments only (`check-source` rejects line-start `//`).

## Baseline (what exists today)

- `src/material.fab` (~183 ln): `Material`, `MaterialPipelineFacts` (with
  `side_code`), `MeshStandardMaterial`, `MeshBasicMaterial`, `MeshPhongMaterial`,
  `Mesh`, `MeshGeometry`, `TextureDescriptor` (10-line placeholder), and the
  free helpers `materia_ex_nomine`, `material_valida`, `material_double_sided`,
  `material_est_double_sided`, `material_side_code`, `material_depth_enabled`,
  `material_depth_test_enabled`, `material_depth_write_enabled`,
  `material_pipeline_facts`, `mesh_basic_material`,
  `mesh_basic_material_valida`, `mesh_basic_material_color_r/g/b`,
  `mesh_basic_material_alpha`, `mesh_basic_material_pipeline_facts`.
  Imports: `triga:math`, `triga:graph` (the reverse dependency being removed).
- Live consumers of `material.*` (T-B seam-A table): `exempla/triga-types-untested.fab`
  (only live constructor of `Mesh`/`MeshGeometry` — gate-breaking),
  `exempla/triga-basics.fab` (family-only, indirect),
  `exempla/triga-graphics-pipeline-facts.fab` (family-only, indirect, allowlisted).
  Zero corpus, zero proof-manifest, zero proba consumers (T-A §0).
- `src/triga.fab` line 8 comment names material as "Material family, Mesh, MeshGeometry" (cosmetic); `src/graph.fab` lines 113–119 carry a stale MeshGeometry/BufferGeometry comment (cosmetic); `docs/module-map.md` current-state table rows for `triga:material` (cosmetic).

## Scope

### Files created

| File | Content |
| --- | --- |
| `src/material/base.fab` | `Material`, `MaterialPipelineFacts` (`side_code` verbatim), `TextureDescriptor` (placeholder seed), `materia_ex_nomine`, `material_valida`, `material_double_sided`, `material_est_double_sided`, `material_side_code`, `material_depth_enabled`, `material_depth_test_enabled`, `material_depth_write_enabled`, `material_pipeline_facts`. No imports. |
| `src/material/basic.fab` | `MeshBasicMaterial`, `mesh_basic_material`, `mesh_basic_material_valida`, `mesh_basic_material_color_r`, `mesh_basic_material_color_g`, `mesh_basic_material_color_b`, `mesh_basic_material_alpha`, `mesh_basic_material_pipeline_facts`. Imports: `triga:math`, `triga:material/base`. |
| `src/material/lit.fab` | `MeshPhongMaterial`. Imports: `triga:math`, `triga:material/base`. |
| `src/material/standard.fab` | `MeshStandardMaterial`. Imports: `triga:math`, `triga:material/base`. |
| `src/renderable/mesh.fab` | `Mesh` genus (signature below). Imports: `triga:graph`, `triga:geometry/data`, `triga:material/standard`, `triga:material/basic`, `triga:material/lit`. |
| `src/renderable.fab` | Map-only facade. Imports: `triga:renderable/mesh`; documents `skin`/`morph` (H5), `instance` (H6) as planned. No genera. |

### Files rewritten (emptied of genera)

- `src/material.fab` → map-only facade importing the four leaves; documents `texture`/`sampler` as planned at H3. All 13 current genera and all free helpers leave this file.

### Files edited (fixtures + docs)

- `exempla/triga-types-untested.fab` — gate-breaking migration (§ Fixtures).
- `exempla/triga-basics.fab`, `exempla/triga-graphics-pipeline-facts.fab` — family re-org migrations (§ Fixtures).
- `src/triga.fab` — line 8 comment update ("`triga:material` Material family" — drop "Mesh, MeshGeometry"; add `triga:renderable` mesh row); optionally add `importa ex "triga:renderable" privata renderable` to the map. Coordinates with DS-B (graph comment line) — different lines, same file.
- `docs/module-map.md` — current-state updates only (§ Implementation stage graph, stage 4). Do not touch the frozen "Target map" section.
- `src/graph.fab` — stale MeshGeometry comment (lines 113–119). **Coordinated**: DS-B edits this file substantively in the same wave; if lines overlap, DS-A yields this cosmetic edit (or applies it in the doc-only commit after DS-B lands).

### Files NOT touched

- `src/geometry.fab` — DS-E owns its split; DS-A consumes the post-split `triga:geometry/data` interface only.
- `target/faber/src/main.rs` — generated and gitignored; regenerated by `faber run --compile`; never hand-edited.
- `scripta/*` — the `check-compile` module loop (`math graph material face geometry primitives scene resource triga`) is unchanged: parsing the `material.fab` facade transitively covers the nested leaves.
- Corpus demos, `proof/*`, `src-backup-test/`, all other exempla — zero consumers (verified at T-B/T-A).

### Leaf → content map (material + renderable)

```text
src/material/            src/material.fab (facade — map only)
  base.fab       Material, MaterialPipelineFacts [side_code verbatim],
                 TextureDescriptor (H3 seed), materia_ex_nomine,
                 material_valida, material_double_sided, material_est_double_sided,
                 material_side_code, material_depth_enabled,
                 material_depth_test_enabled, material_depth_write_enabled,
                 material_pipeline_facts                      (no imports)
  basic.fab      MeshBasicMaterial, mesh_basic_material,
                 mesh_basic_material_valida, mesh_basic_material_color_r/g/b,
                 mesh_basic_material_alpha,
                 mesh_basic_material_pipeline_facts           → math, material/base
  lit.fab        MeshPhongMaterial                            → math, material/base
  standard.fab   MeshStandardMaterial                         → math, material/base

src/renderable/          src/renderable.fab (facade — map only)
  mesh.fab       Mesh                                        → graph,
                 geometry/data, material/{standard,basic,lit}
```

**`TextureDescriptor` decision**: the placeholder moves to `material/base.fab`
as the H3 seed, with a comment noting it relocates to `material/texture.fab`
when the texture pipeline (samplers, mipmaps, render targets) is designed.
Do NOT create `material/texture.fab` now (report §1.3 "a delivery creates a
leaf only when it has content"; T-A §2 warns against creating the leaf to hit
a leaf count). `base.fab` is its temporary home because the facade must be
emptied (§1.7) and `base` is the only material leaf its shape fits.

**`renderable` single-leaf note**: the nesting rule prefers ≥3 leaves but
requires ≥2; `renderable/mesh` + facade is the frozen S0 shape (§1.2 —
"`renderable` | `mesh`", with `skin`/`morph`/`instance` planned at H5/H6).
Not re-litigated here.

### The `renderable/mesh` genus signature (verbatim)

```fab
importa ex "triga:graph" privata graph
importa ex "triga:geometry/data" privata geometry
importa ex "triga:material/standard" privata standard
importa ex "triga:material/basic" privata basic
importa ex "triga:material/lit" privata lit

genus Mesh {
    graph.Object3D base
    geometry.BufferGeometry geometry
    standard.MeshStandardMaterial ∪ basic.MeshBasicMaterial ∪ lit.MeshPhongMaterial material sponte
}
```

The union references the three leaf-owned genera directly — no `triga:material`
facade reference (no type re-export). No constructor helper is added: the only
consumer constructs `Mesh { … }` via record literal, as today. The `geometry`
alias above is `triga:geometry/data` (DS-E).

## Dependency Edge — DS-E (declared consumed interface)

DS-A consumes exactly one DS-E interface. **DS-E must expose, from
`triga:geometry/data`, with today's names and shapes:**

- `genus BufferGeometry` (fields `topology`, `vertex_count`, `attributes`,
  `indexed`, `indices`, `draw_range`, `groups`; methods unchanged incl. `valida()`)
- `genus DrawRange` (`start`, `count`)
- free constructor `triangle_geometry(vertex_count, attributes, draw_range, groups)`

DS-A's fixture uses only `BufferGeometry` + `DrawRange` + `triangle_geometry`
from `triga:geometry/data` (construction via free constructor, so no cross-module
`finge`/enum construction is needed in exempla). DS-A does not assume any other
DS-E leaf name. Should the fixture ever need more (e.g. `float32_attribute`,
`BufferAttribute`), those names are referenced by their current names in
whatever leaf DS-E places them.

**Landing order**: DS-E's `geometry/data` leaf must land before DS-A's fixture
migration compiles (the fixture imports `triga:geometry/data`). If DS-E slips
past the Stage 5→6 gap, DS-A holds — do NOT adopt an interim import of
`triga:geometry` as a stopgap (double churn on the gate-breaking fixture and a
seam landing mid-80-Stage-5).

## Implementation Stage Graph (ordered)

```
Stage 0 — Preconditions (verify early; parallel)
  0.1  DEFER-121 nested-package tooling check: DS-D verifies triga:scene/store
       resolution first, then all splits (§8); DS-A needs triga:material/base,
       triga:renderable/mesh, triga:geometry/data to resolve. DS-A is blocked
       on this.
  0.2  DS-E lands triga:geometry/data with the declared consumed interface.
  0.3  Window gate: 80 Stage 5 in flight — no landing during 4–5 uncoordinated;
       land in the Stage 5→6 gap.

Stage 1 — Material family split (pure relocation)
  1.1  create src/material/base.fab      (Material, MaterialPipelineFacts,
       TextureDescriptor seed, base helpers)                 [no imports]
  1.2  create src/material/basic.fab     (MeshBasicMaterial + helpers)
                                              [imports triga:math, triga:material/base]
  1.3  create src/material/lit.fab       (MeshPhongMaterial)
                                              [imports triga:math, triga:material/base]
  1.4  create src/material/standard.fab  (MeshStandardMaterial)
                                              [imports triga:math, triga:material/base]
  1.5  rewrite src/material.fab as map-only facade: remove every genus and
       free helper; import the four leaves; header comment lists base/basic/
       lit/standard and notes texture/sampler planned at H3.
       Ordering: base before basic (basic imports base); lit/standard parallel
       with basic.

Stage 2 — Renderable mesh creation
  2.1  create src/renderable/mesh.fab    (Mesh = graph + geometry/data +
       material/{standard,basic,lit}) — the material→graph reverse dependency
       is removed here (the material package imports graph nowhere).
  2.2  create src/renderable.fab         (map-only facade; imports mesh;
       documents skin/morph H5, instance H6 as planned).

Stage 3 — Fixture migration (lands with Stages 1–2; see Fixtures)
  3.1  exempla/triga-types-untested.fab  (gate-breaking: MeshGeometry →
       BufferGeometry; qualified-name changes)
  3.2  exempla/triga-basics.fab          (indirect: base/basic qualified names)
  3.3  exempla/triga-graphics-pipeline-facts.fab (indirect: base/basic names)

Stage 4 — Docs and comments
  4.1  src/triga.fab facade comment (line 8) + optional renderable import line
  4.2  src/graph.fab stale MeshGeometry comment (coordinated with DS-B)
  4.3  docs/module-map.md current-state: public-modules rows for material +
       renderable (+ material leaves), dependency-direction diagram
       (material/* → math; renderable/mesh → graph + geometry/data +
       material/*), import examples (nested-leaf form), size table material row.
       Target-map section stays as frozen.

Stage 5 — Gates (see Gates)
  5.1  ./scripta/check-source            — no new violations; still RED only on
       the acknowledged geometry lint (DS-E owns)
  5.2  ./scripta/check-compile           — exactly the acknowledged 4 E0308s
  5.3  targeted fixture checks           — radix ×3 + faber run --compile ×1
```

## Fixtures

### Gate-breaking: `exempla/triga-types-untested.fab`

The only live Faber source constructing `Mesh` and `MeshGeometry` (T-B seam-A
table, severity gate-breaking; non-allowlisted → `radix check` + `faber run
--compile`). Migration:

```fab
# before                                                        # after
importa ex "triga:material" privata material                    importa ex "triga:geometry/data" privata geometry
                                                                importa ex "triga:renderable/mesh" privata mesh
                                                                importa ex "triga:material/base" privata base
                                                                importa ex "triga:material/standard" privata standard
                                                                importa ex "triga:material/lit" privata lit
...
fixum material.MeshStandardMaterial pbr_material ←              fixum standard.MeshStandardMaterial pbr_material ←
  material.MeshStandardMaterial { base = material.material(       standard.MeshStandardMaterial { base = base.material(
  "pbr"), color = white, ... }                                    "pbr"), color = white, ... }
fixum material.MeshGeometry empty_geometry ←                    # MeshGeometry retired (S0 §1.4.3): Mesh binds BufferGeometry
  material.MeshGeometry { positions = vacua, indices =            fixum geometry.DrawRange empty_range ←
  vacua, draw_start = 0 }                                         geometry.DrawRange { start = 0, count = 0 }
fixum material.Mesh mesh ← material.Mesh { base = standalone,   fixum geometry.BufferGeometry empty_geometry ←
  geometry = empty_geometry }                                     geometry.triangle_geometry(0, vacua, empty_range, vacua)
fixum material.MeshPhongMaterial phong ←                        fixum mesh.Mesh mesh ← mesh.Mesh { base = standalone,
  material.MeshPhongMaterial { base = material.material(          geometry = empty_geometry }
  "phong"), ... }                                               fixum lit.MeshPhongMaterial phong ← lit.MeshPhongMaterial
                                                                { base = base.material("phong"), ... }
```

Notes: the geometry is intentionally empty (matches the original fixture's
intent; no validation is invoked on it here); `mesh.Mesh { … }` omits the
sponte `material` field exactly as today; front-matter comment updated to name
`renderable/mesh` + `geometry/data`.

### Indirect (family re-org only; no Mesh/MeshGeometry usage)

| Fixture | After DS-A | Gate path |
| --- | --- | --- |
| `exempla/triga-basics.fab` | `base.Material`, `base.MaterialPipelineFacts`, `base.material`, `base.material_pipeline_facts`, `base.material_double_sided`, `basic.mesh_basic_material`, `basic.MeshBasicMaterial` | radix check (`check-hello-voxel-contract` "material facts") + `faber run --compile` (non-allowlisted) |
| `exempla/triga-graphics-pipeline-facts.fab` | `basic.MeshBasicMaterial`, `basic.mesh_basic_material`, `basic.mesh_basic_material_pipeline_facts`, `base.MaterialPipelineFacts` | radix check only (allowlisted, annotation-only) |

Both add two imports (`triga:material/base` as `base`, `triga:material/basic`
as `basic`) and replace `material.` with `base.`/`basic.` on the names above —
mechanical, no semantic change.

## Gates

Both gates are **RED today** — both acknowledged pre-existing (report §0/§8);
DS-A must not worsen them.

**`check-source`**: still RED on the acknowledged naming lint
(`geometry_vertex_layout_matches`, src/geometry.fab:1332 — DS-E owns the fix).
DS-A adds zero new violations: new/edited files use `#` comments (no line-start
`//`), no `@ externa`/`@ subsidia`, no retired optional-field syntax, and no
public function matches the §5 prefix list (`vector[234]|box3|matrix[34]|
quaternion|euler|sphere|plane|ray|scene|geometry|transform_payload`) — the
relocated `material_*`/`mesh_basic_material*`/`materia_ex_nomine` free functions
are constructors/pure helpers and do not trip it. The lint runs over nested
leaves (`find src -name '*.fab'`), so the new files are linted — verified clean
by construction.

**`check-compile`**: still RED on the acknowledged **4 E0308s** (faber
generated-code lowering regression; fixtures verified correct; report §8).
DS-A's interaction with the red zone:

- The 4 errors live in regenerated `target/faber/src/main.rs`: by-value
  `&…clone()` args at main.rs:25/28 generated from `store.insere(mesh_node)` /
  `store.cape(mesh_handle)` in **`exempla/triga-scene-store.fab`** (untouched by
  DS-A), and `Some(…)` wraps at main.rs:32/4273 generated from
  **`src/scene.fab:806`** (`octeta`) — also untouched. DS-A edits neither the
  scene-store fixture nor `src/scene.fab`.
- DS-A's own fixture churn is pure import/qualified-name relocation plus the
  MeshGeometry→BufferGeometry construction swap. The new constructions are
  record literals and one free-constructor call on plain data genera (`Mesh`,
  `BufferGeometry`, `MeshStandardMaterial`, `MeshPhongMaterial`, union field) —
  **no by-value receiver-method calls and no `∪ nihil`/Option-bound expressions
  are introduced**, so no new E0308 class can originate from DS-A's fixtures.
- After landing, the compile-gate error list must be **exactly the same 4 E0308
  classes** (by-value arg injection; `Some(…)` wrap of Option bindings). Line
  numbers in regenerated main.rs will shift (module set changes); compare by
  error class, not line number.
- The restore of the 4 E0308s (faber Rust emitter fix via the 80
  generated-Rust acceptance lane) is the named precondition of the S1 gate per
  report §8; the gate reads green-with-acknowledged-reds until the emitter lane
  lands the fix. DS-A does not attempt to patch the emitter or the generated file.

**Preconditions**: DEFER-121 nested-package resolution (Stage 0.1) and DS-E's
`geometry/data` (Stage 0.2) must both be satisfied before Stage 3 fixture checks
can pass.

## Validation Commands

```bash
./scripta/check-source        # no NEW violations; acknowledged geometry lint RED (DS-E)
./scripta/check-compile       # exactly the acknowledged 4 E0308s; no new
```

Targeted fixture checks:

```bash
radix check exempla/triga-types-untested.fab
radix check exempla/triga-basics.fab
radix check exempla/triga-graphics-pipeline-facts.fab
faber run --compile exempla/triga-types-untested.fab   # non-allowlisted
```

Acceptance: the regenerated `target/faber/src/main.rs` shows `mod material`
split into `mod material_base`/`material_basic`/… (or equivalent), `mod
renderable` present, and no `MeshGeometry` anywhere; compile error list is the
same 4 E0308 classes. `./scripta/check-hello-voxel-contract` (material facts
radix check on triga-basics.fab) stays green.

## Commit Boundaries

DS-A lands as **one atomic unit** in the 80 Stage 5→6 gap, after DS-E's
`geometry/data`. No intermediate subset is gate-green on its own (the three
exempla reference pre-split names the moment the facade empties), so the split
and its fixture migrations share one landing, one review, one merge. Recommended
structure:

1. **Commit A1 — structural split**: `src/material/{base,basic,lit,standard}.fab`,
   `src/material.fab` facade rewrite, `src/renderable/mesh.fab`, `src/renderable.fab`.
2. **Commit A2 — fixtures + docs**: the three exempla migrations, `src/triga.fab`
   comment, `src/graph.fab` comment (if not yielded to DS-B), `docs/module-map.md`
   current-state updates.

A1+A2 land together (squash into one merge or merge as a pair with no
gate-required checkpoint between them). File-level coordination with parallel
specs: DS-B owns substantive `src/graph.fab` edits (DS-A yields the comment if
lines overlap); DS-E owns `src/geometry.fab`; the A+B+D wave serializes shared
doc edits (`docs/module-map.md` rows) at merge time.

## Out of Scope

- **`material/texture`, `material/sampler`** — H3. Only the `TextureDescriptor`
  placeholder moves (to `base.fab` as seed); no texture leaf is created.
- **`renderable/{skin,morph}`** (H5), **`renderable/instance`** (H6) — not created.
- **DS-E internals**: anything in `geometry/{attribute,layout,bounds,batch}` beyond
  the declared consumed interface (`BufferGeometry`, `DrawRange`,
  `triangle_geometry` in `geometry/data`).
- **Other seams**: lighting (DS-B), scene store/query (DS-D), graph object/camera
  (seam G), scene (seam C), primitives `basic` split. Notably DS-A does not touch
  `src/scene.fab` or `exempla/triga-scene-store.fab`.
- **Faber emitter regression fix** (compile-gate restore) — named precondition,
  owned by the faber/80 generated-Rust lane.
- **Geometry naming-lint fix** (`geometry_vertex_layout_matches`) — DS-E.
- **Any material helper rename, receiver-method conversion, or validation change** —
  pure relocation only (api-shape-policy §1/§3).
- **proba work** — no material proba exists today; exempla remain the coverage
  surface.

## Open Items And Risks

1. **DEFER-121 nested-package tooling** — hard precondition; DS-D verifies first.
   If `triga:material/base`-style resolution is blocked, DS-A is blocked (no
   flatten fallback — report the blocker).
2. **DS-E landing order** — DS-A holds if `geometry/data` misses the gap; no
   interim `triga:geometry` stopgap.
3. **Compile-gate red** — acknowledged; DS-A must demonstrate "same 4 E0308
   classes, no new" at landing.
4. **Coordinated cosmetic edits** (`src/graph.fab` comment, `docs/module-map.md`)
   — serialize with DS-B/DS-D/DS-E at merge; a stale comment is acceptable if
   coordination fails, but module-map rows should land in the wave.
