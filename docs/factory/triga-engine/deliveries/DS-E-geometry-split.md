# DS-E — Geometry Package Split

**Campaign**: triga-engine (Wave 2, six parallel S1 delivery specs)
**Seam**: E — geometry data/layout (`geometry.fab` → `geometry/{data,attribute,layout,bounds,batch}`)
**Status**: draft delivery spec
**Frozen inputs**: `checkpoint/report.md` (§1.2, §1.4.2/3/6/7, §3 seam E, §8, §9), `checkpoint/T-A-inventory.md` (§3a, §3d, §3e), `checkpoint/T-B-seam-consumers.md` (Seam C consumer table), `docs/api-shape-policy.md` (§3 frozen ABI, §5 naming lint), `docs/module-map.md` (nesting rule), `docs/factory/triga-threejs-80/stage4-readiness-map-2026-07-14.md` and `goals/04-graphics-mir-shader-stages.md` (Stage 4 pins)

---

## Goal

Split `src/geometry.fab` (1343 lines) into a nested package `src/geometry/{data,attribute,layout,bounds,batch}.fab` plus a map-only `src/geometry.fab` facade, as a **pure relocation that preserves every frozen ABI name verbatim**, retire `MeshGeometry` into `BufferGeometry` on the `geometry/data` side (DS-A consumes), migrate every internal module, exemplum, and corpus consumer **in the same change**, and fix the pre-existing naming-lint RED (`geometry_vertex_layout_matches`, `src/geometry.fab:1332`) — sequenced so the one rename 80 Stage 4 pins is coordinated with Stage 4's reflection agreement per report §3.

## Invariant

The geometry split is a pure relocation that preserves every frozen ABI name and owner verbatim, keeps the module graph acyclic, lands the one naming-lint rename coordinated with 80 Stage 4 (or in the Stage 5→6 gap), and never worsens the acknowledged `check-compile` red.

---

## Scope

### In scope — exact files

**New leaves** (all under `src/geometry/`):

| Leaf | Owns (exact, current location → new owner) |
| --- | --- |
| `src/geometry/layout.fab` | `VertexAttributeLayout`, `VertexFormat`, `VertexStepMode`, `PrimitiveTopology`, private code helpers `_vertex_format_code`, `_vertex_layout_format_code`, `_vertex_step_mode_code`, `_vertex_layout_step_mode_code`, `_primitive_topology_code` (all names verbatim, T-A §3d). Zero imports; self-contained. `PrimitiveTopology` moves here so `_primitive_topology_code` stays co-located and `data → layout` stays one-way. |
| `src/geometry/bounds.fab` | `BoundingBox`, `BoundingSphere` (geometry-side bounds only; `Box3`/`Sphere` stay in `math` — report §1.4.2). Zero imports. Doc comment states the bounds dualism distinction. |
| `src/geometry/batch.fab` | `DrawRange`, `GeometryDrawCommand`, `GeometryGroup`, `IndexedGeometryDrawBatchFacts`, `LineGeometryDrawBatchFacts`, `VisibleFaceMeshFacts`, and scalar helpers `visible_face_vertex_count`, `visible_face_index_count`, `visible_face_triangle_count`, `visible_face_position_payload_byte_count`, `visible_face_color_payload_byte_count`, `visible_face_index_payload_byte_count`, `visible_face_payload_byte_count`, `visible_face_mesh_facts`. Zero imports. Home for geometry-side payload/byte-count facts per report §1.4.6; `render/batch` is H4 and out of scope. |
| `src/geometry/attribute.fab` | `BufferAttribute` (+ all its methods), `AttributeData`, `AttributeUsage`, free constructor `float32_attribute`. Imports `triga:geometry/layout`. Co-location per corpus README:73-75 — `float32_values()` must live next to the `AttributeData` enum (variants are not in scope cross-module). |
| `src/geometry/data.fab` | `BufferGeometry` (+ all its methods, including `index_format_code()` and `topology_code()`), `ColoredQuadMesh` (+ methods), `colored_quad_mesh_append`, free constructors `indexed_triangle_geometry`, `triangle_geometry`, `line_geometry`, `colored_indexed_geometry`, private scalar helpers `_geometry_radix_f32`, `_element_count_divisible`, `_primitive_range_valid`. Imports `triga:geometry/attribute`, `triga:geometry/layout`, `triga:geometry/bounds`, `triga:geometry/batch`. |

> **Leaf-content judgment call (flagged for confirmation at kickoff).** The brief's scope line reads "BufferGeometry/BufferAttribute/AttributeData → data". This spec assigns `BufferAttribute`/`AttributeData`/`AttributeUsage`/`float32_attribute` to `attribute` per GOAL.md:218 ("attribute.fab — BufferAttribute and typed attributes") and the T-B Seam C consumer map (primitives' `float32_attribute`/`BufferAttribute` churn lands on the attribute leaf; corpus README requires `float32_values()` co-located with the `AttributeData` enum). Under the literal reading, `attribute` would own only `AttributeUsage` + `float32_attribute` (a legal but ~15-line leaf); either way **every public name and owner is preserved** — the gate risk is nil. Confirm at DS-E kickoff.

> **Method-placement constraint.** Faber methods are genus-bound: the `vertex_layout_*` accessors, bounding-volume methods, draw-command methods, and batch-facts methods on `BufferGeometry` cannot move off the genus, so they stay in `data.fab`. "Layout accessors → layout" is satisfied at the type/helper level (`VertexAttributeLayout`, `VertexFormat`, `VertexStepMode`, code helpers, and the lint-fixed comparison surface). The private code helpers are called by `data.fab` methods (`topology_code()`, `vertex_layout_format_code()`, `vertex_layout_step_mode_code()`, `vertex_layout_matches()`); if `@ privata` is module-scoped (DEFER-121 tooling check), the helpers stay with their callers in `data.fab` with names verbatim — the ABI freeze is about names, not file location.

**Facade** — `src/geometry.fab` is emptied of all genera and becomes a map-only facade (no type re-export, report §1.4.7): header comment listing the five leaves, optional leaf imports for orientation only. `check-compile`'s module loop keeps parsing `geometry` (facade remains).

**Migrated in the same change** (the atomic consumer set):

| File | Change | Gate |
| --- | --- | --- |
| `src/primitives.fab` | imports → `triga:geometry/data` (BufferGeometry, `indexed_triangle_geometry`, `line_geometry`), `triga:geometry/attribute` (BufferAttribute, `float32_attribute`), `triga:geometry/batch` (DrawRange, GeometryGroup, LineGeometryDrawBatchFacts); qualified names updated | module loop |
| `src/face.fab` | imports → `triga:geometry/data` (ColoredQuadMesh, `colored_quad_mesh_append`) | module loop |
| `exempla/triga-geometry-attributes.fab` | import churn across data/attribute/batch; no name changes | radix check (allowlisted) |
| `exempla/triga-stage4-source-facts.fab` | Phase 1: import churn, `geometry_vertex_layout_matches` preserved verbatim; Phase 2 (gated): the one rename | radix check (allowlisted); **Stage 4 pin** |
| `exempla/hello-voxel-first-draw-facts.fab` | import churn across data/batch; no name changes | generated-Rust path (red zone) |
| `exempla/triga-hello-voxel-shaders.fab` | import churn → data | generated-Rust path (red zone) |
| `exempla/triga-hello-voxel-pipeline.fab` | import churn across data/batch | generated-Rust path (red zone) |
| `exempla/triga-types-untested.fab` | `material.MeshGeometry` construction migrates to a `data.BufferGeometry` value; coordinated with DS-A's `Mesh.geometry` flip | generated-Rust path (red zone); Seam A fixture |
| `corpus/webgl-geometries/src/shapes.fab` | imports → `triga:geometry/data` (BufferGeometry), `triga:geometry/attribute` (BufferAttribute), keep `triga:primitives` | corpus build (`tests/run.sh`) |
| `src/triga.fab` | facade comment line 10 (`triga:geometry BufferGeometry / vertex layout`) → leaf list | cosmetic |
| `docs/module-map.md` | `triga:geometry` row, size section, dependency direction, import examples, "next seam" prose | doc gate |
| `corpus/README.md` | gap-note path `triga/src/geometry.fab` → `src/geometry/attribute.fab` | doc (optional) |
| `scripta/check-source` + `docs/api-shape-policy.md` §5 | **only in the documented-exemption branch** of the lint fix (below) | gate |

### Out of scope — exact

- `src/material.fab` — `MeshGeometry` genus removal and `Mesh.geometry → BufferGeometry` field flip are **DS-A's** (Seam A). DS-E only defines the `geometry/data` side DS-A consumes; DS-E does not edit `material.fab`.
- `renderable/*`, `material/{base,basic,lit,standard}`, `lighting/light`, `graph/{object,camera}` — other seams (A/B/G), other delivery specs.
- `render/batch` and all H4 render work — geometry draw-batch facts stay in `geometry/batch` until H4 creates `render/batch` (report §1.4.6); no H4 work here.
- `scene.fab` split (Seam D), `math` `Box3`/`Sphere` moves, corpus `_host`/reflection.json regeneration, the faber generated-code E0308 regression (owned by the faber Rust emitter via the 80 generated-Rust acceptance lane), 80 `proof/capstones/*.json` (read-only for this campaign).
- No new `.proba` files, no new exempla, no 80-owned goal/readiness-map edits by DS-E (see coordination below).

---

## Implementation stage graph

```
 0. Precondition gate — DEFER-121 tooling check (report §8; DS-D verifies first, all splits gate on it):
    (a) nested-package resolution `triga:geometry/data` etc. resolves in radix check and faber
        provider/browser paths; (b) `@ privata` semantics across leaf modules (code helpers).
    If (b) fails: helpers stay with their callers in data.fab, names verbatim.
 1. Leaf creation + pure relocation + facade emptying (the atomic change)
    - create src/geometry/{layout,bounds,batch,attribute,data}.fab; move content per Scope map
    - empty src/geometry.fab of genera → map-only facade
    - every public name and owner preserved verbatim (frozen ABI §3: format_code, step_mode_code,
      offset_bytes, stride_bytes, source_name; index_format_code(); _vertex_format_code &
      friends; *_code fields)
 2. Internal consumers in the same change — src/primitives.fab, src/face.fab → leaf imports
 3. Exempla in the same change — triga-geometry-attributes, triga-stage4-source-facts (Phase 1
    form), hello-voxel-first-draw-facts, triga-hello-voxel-shaders, triga-hello-voxel-pipeline,
    triga-types-untested (MeshGeometry→BufferGeometry part, with DS-A)
 4. Corpus in the same change — corpus/webgl-geometries/src/shapes.fab → leaf imports
 5. Docs — src/triga.fab comments, docs/module-map.md, corpus/README.md note
 6. THE ONE RENAME (lint fix) — gated commit, sequenced AFTER 80 Stage 4's reflection
    agreement closes OR coordinated (report §3 seam E; see Lint-fix sequencing below)
 7. DS-A dependency edge — DS-E precedes DS-A in the S1 wave:
    DS-E provides geometry/data's BufferGeometry; DS-A consumes it for
    material.fab (MeshGeometry retired, Mesh.geometry → BufferGeometry) and migrates
    triga-types-untested's Mesh/MeshGeometry usage to its final renderable/mesh form.
    DS-E + DS-A land together in the S1 A+B+D wave (Stage 5→6 gap); the shared fixture
    (triga-types-untested) is edited once, in the coordinated pair.
```

### Lint-fix sequencing — stated choice

**Primary: coordinated rename, landing with the Stage 5→6 gap.** The free function `geometry_vertex_layout_matches` (src/geometry.fab:1332) is retired and `exempla/triga-stage4-source-facts.fab` migrates to the **receiver method** — the natural receiver already exists as `BufferGeometry.vertex_layout_matches(index, …)` (src/geometry.fab:908), which the free function merely wraps; alternatively a `VertexAttributeLayout.vertex_layout_matches(…)` receiver in `geometry/layout.fab` per T-A §3a. The rename is sequenced **after 80 Stage 4's reflection agreement closes** (the radix first reflection fixture matches the source facts), which per the 80 schedule precedes Stage 5 and therefore coincides with the Stage 5→6 gap — matching report §3's "before Stage 4 with coordination, else Stage 5→6 gap" (Stage 4 is in flight, so "before Stage 4" is no longer available; the coordinated mid-flight option is the accelerated path below). The 80 lane moves its own pins in the same change: `goals/04` §progress (the `geometry_vertex_layout_matches` sentence) and `stage4-readiness-map` (the `geometry_vertex_layout_*` pin list) — 80-owned files, updated by the 80 lane, not by DS-E.

**Accelerated path (coordinated now):** if the 80 lane confirms the reflection agreement is effectively closed, the rename rides with the split rather than the gap. The coordination precondition is the same in both paths.

**Fallback (documented exemption):** if the split must land green before the reflection agreement closes, `geometry_vertex_layout_matches` is preserved verbatim (Phase 1 is pure relocation), the name is added to the `check-source` exemption list (scripta/check-source:39-44) with an explicit §5 policy note (api-shape-policy §5 sanctions "pure scalar helpers explicitly documented in this policy" — here a documented seam-alias exemption), and the receiver-method cleanup then lands in the Stage 5→6 gap. This branch touches `scripta/check-source` + `docs/api-shape-policy.md` (listed in Scope, conditional).

The split itself is fixture-churn-only in every branch: names and owners of all `geometry_vertex_layout_*` accessors (report §3's safe form) are untouched by Phase 1.

---

## Fixtures

### Gate-breaking list (from T-B Seam C + Seam A tables) and how each migrates

| Fixture | Uses | Migration (all in the same change as the split) | Gate role |
| --- | --- | --- | --- |
| `src/primitives.fab` | `geometry.BufferGeometry`, `indexed_triangle_geometry`, `float32_attribute`, `DrawRange`, `GeometryGroup`, `line_geometry`, `BufferAttribute`, `LineGeometryDrawBatchFacts` | three leaf imports: `triga:geometry/data`, `triga:geometry/attribute`, `triga:geometry/batch`; qualified names `data.*` / `attribute.*` / `batch.*` | **gate** (check-compile module loop parses `primitives` by name) |
| `src/face.fab` | `geometry.ColoredQuadMesh`, `geometry.colored_quad_mesh_append` | one leaf import: `triga:geometry/data` | **gate** (module loop) |
| `exempla/triga-stage4-source-facts.fab` | `geometry_vertex_layout_matches`, `float32_attribute`, `BufferGeometry`, `BufferAttribute`, `triangle_geometry`, `DrawRange` | Phase 1: leaf imports, `layout.geometry_vertex_layout_matches(…)` verbatim. Phase 2 (gated): the one rename → receiver method, in coordination with the 80 pin updates | **gate-breaking for Stage 4** if names/owners change; fixture-only if pure relocation. Allowlisted (radix check only) |
| `exempla/hello-voxel-first-draw-facts.fab` | `colored_indexed_geometry`, `BufferGeometry`, `GeometryDrawCommand`, `cube.draw_command` | leaf imports: `data` + `batch`; no name/owner/signature change | **gate-breaking**; **red zone** (generated-Rust path) |
| `exempla/triga-hello-voxel-shaders.fab` | `colored_indexed_geometry`, `BufferGeometry` | leaf import: `data` | **gate-breaking**; **red zone** |
| `exempla/triga-hello-voxel-pipeline.fab` | `colored_indexed_geometry`, `BufferGeometry`, `GeometryDrawCommand`, `cube.draw_command` | leaf imports: `data` + `batch` | **gate-breaking**; **red zone** |
| `exempla/triga-types-untested.fab` | `material.MeshGeometry`, `material.Mesh` | the `MeshGeometry { positions = vacua, … }` construction becomes a `data.BufferGeometry` value (e.g. empty literal, `topology = finge TriangleList, vertex_count = 0, …`); coordinated with DS-A's `Mesh.geometry` field flip and genus removal; DS-A owns the final Mesh form | **gate-breaking** (Seam A fixture, T-B); **red zone** (generated-Rust path) |
| `corpus/webgl-geometries/src/shapes.fab` | `triga:geometry` + `triga:primitives`; `geometry.BufferGeometry`, `geometry.BufferAttribute`, `attr.float32_values()`, `geom.attributes`, `geom.vertex_count`, `geom.indices` | imports → `triga:geometry/data` (BufferGeometry) + `triga:geometry/attribute` (BufferAttribute) + `triga:primitives`; `float32_values()` moves with BufferAttribute to `attribute` | **gate-breaking for corpus build** (`tests/run.sh` `faber check` + `faber build` breaks otherwise) |

**Fixture-only (not gate-breaking):** `exempla/triga-geometry-attributes.fab` (radix-check allowlist; import churn across `data`/`attribute`/`batch` — `BufferGeometry`, `BufferAttribute`, `float32_attribute`, `indexed_triangle_geometry`, `triangle_geometry`, `DrawRange`, `GeometryGroup`, `GeometryDrawCommand`, `ColoredQuadMesh`, `colored_quad_mesh_append`). **Cosmetic:** `src/triga.fab` comment, `docs/module-map.md`, `corpus/README.md`. **Zero impact (verified):** `exempla/triga-basics.fab`, `triga-graphics-pipeline-facts.fab`, `triga-transforms.fab`, `triga-math-edge-cases.fab`, `triga-scene-store.fab`, `triga-scene-store-empty.fab`, `triga-vertex-fragment-stub.fab`, `triga-box3-genus-spike.fab`, both corpus `camera.fab`/`scene.fab`/`main.fab`/`terrain.fab` (they use `triga:math`/`triga:graph` only), `proof/capstones/*.json`, `target/faber/src/main.rs` (regeneration surface).

### Hello-voxel gate preservation

`check-hello-voxel-contract` (a separate campaign's gate) radix-checks `hello-voxel-first-draw-facts`, `triga-geometry-attributes`, `triga-basics`, `triga-transforms`, `triga-scene-store` and runs `check-compile` + `check-source`. DS-E preserves every name those fixtures use (`colored_indexed_geometry`, `BufferGeometry`, `GeometryDrawCommand`, `cube.draw_command`, `float32_attribute`, `BufferAttribute`), so the gate stays green modulo the two acknowledged reds.

---

## Gates

- **`check-source`**: GREEN at DS-E completion. The lint fix is the last commit (receiver method, or documented exemption in the fallback branch). Through Phase 1 the pre-existing lint RED on `geometry_vertex_layout_matches` remains acknowledged debt owned by DS-E (report §8). No other lint failures: nested leaves are linted (`find "$SRC"` covers `src/geometry/*`), and no new leaf name trips the genus-prefix reject pattern; the only current offender is `geometry_vertex_layout_matches`.
- **`check-compile`**: stays at the acknowledged RED — 4 E0308s in regenerated `target/faber/src/main.rs` (faber generated-code lowering regression; fixtures verified correct; root-cause fix owned by the faber Rust emitter via the 80 generated-Rust acceptance lane). **DS-E's fixtures in the red zone** (non-allowlisted, run `faber run --compile` via `check-exempla-inventory`): `hello-voxel-first-draw-facts`, `triga-hello-voxel-shaders`, `triga-hello-voxel-pipeline`, `triga-types-untested`. **Not in the red zone** (compile allowlist, radix check only): `triga-geometry-attributes`, `triga-stage4-source-facts`. DS-E discipline: those four red-zone fixtures get **import-line churn only** — no name, owner, signature, or call-shape changes — so DS-E cannot worsen the regression or mask it. Module loop unchanged (`geometry` facade still parses).
- **Corpus build** (`corpus/webgl-geometries/tests/run.sh`): green after `shapes.fab` migrates to leaf imports.
- **Nesting rule**: 5 leaves ≥ 3 ✓. **Facade rule**: `geometry.fab` emptied of genera, no type re-export (report §1.4.7).
- **Frozen ABI**: `format_code`, `step_mode_code`, `offset_bytes`, `stride_bytes`, `source_name`, `primitive_topology_code`, and the private helpers `_vertex_format_code` etc. — verbatim (api-shape-policy §3, T-A §3d).
- **Acyclic dependency graph**: `layout`, `bounds`, `batch` (zero imports) ← `attribute` → `layout`; `data` → `attribute`/`layout`/`bounds`/`batch`; `face` → `math`, `data`; `primitives` → `data`/`attribute`/`batch`. No cycles (GOAL.md:702).
- **Coordination gate**: the one rename lands only after the 80 lane confirms Stage 4's reflection agreement closed (or per the documented-exemption fallback).

## Validation commands

```bash
./scripta/check-source
./scripta/check-compile
./scripta/check-hello-voxel-contract     # separate campaign's gate — names preserved, must stay green
(cd corpus/webgl-geometries && ./tests/run.sh)   # corpus build gate (faber check + build, browser target)
```

The acknowledged `check-compile` red is a named precondition of every S1 delivery spec (report §8/§9): DS-E gates on it staying at exactly the 4 known E0308s, not on its restoration.

---

## Commit boundaries

All within one delivery wave; the code move is atomic (intermediate states are red), docs and the rename are separable green commits.

1. **C1 — the split + consumers (atomic)**: create the five leaves; empty `geometry.fab` to facade; migrate `primitives.fab`, `face.fab`, all six exempla (Phase 1 form), and `corpus/webgl-geometries/src/shapes.fab`; `index_format_code()` stays with `BufferGeometry` in `data`. Gate: `check-source` at its acknowledged one-lint RED, `check-compile` at its acknowledged 4-E0308 RED, corpus build green, `check-hello-voxel-contract` otherwise green.
2. **C2 — docs**: `src/triga.fab` facade comments, `docs/module-map.md`, `corpus/README.md` note.
3. **C3 — the one rename (gated)**: retire `geometry_vertex_layout_matches`, migrate `exempla/triga-stage4-source-facts.fab` to the receiver method, coordinate the 80 pin updates (`goals/04`, `stage4-readiness-map`). Lands after Stage 4's reflection agreement closes (Stage 5→6 gap) or via the accelerated coordination path. Fallback branch: exemption commit in `scripta/check-source` + `docs/api-shape-policy.md` §5 instead, with C3' cleanup in the gap.
4. **Wave join**: DS-A lands immediately after DS-E in the same S1 wave (Stage 5→6 gap), consuming `geometry/data` for `material.fab`; the triga-types-untested migration is completed once across the pair.

---

## Open questions (carried, not blocking)

- DEFER-121 nested-package tooling (resolution + `@ privata` cross-module semantics) — verified by DS-D first, gating every S1 split including this one.
- Leaf-content confirmation for `geometry/attribute.fab` (brief-literal vs GOAL.md/T-B reading — no gate impact either way).
- Whether the lint-fix receiver is the existing `BufferGeometry.vertex_layout_matches` or a new `VertexAttributeLayout.vertex_layout_matches` in `geometry/layout.fab` — the 80 lane's pin-update shape decides.
