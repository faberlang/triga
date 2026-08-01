# Delivery Spec DS-B: Lighting Package (Seam B)

**Campaign**: triga-engine, S1 — Domain seam repair (Horizon 1); Wave 2 parallel delivery spec
**Status**: drafted (2026-08-01) — research/document only; no code, no commits
**Output**: `docs/factory/triga-engine/deliveries/DS-B-lighting.md` (this file)
**Frozen inputs**: [S0 checkpoint report](../checkpoint/report.md) §§1.2, 1.3, 1.4.1, 1.4.7, 2, 3, 8, 9; [T-B seam consumers](../checkpoint/T-B-seam-consumers.md) (Seam B table); [module map](../../module-map.md) (nesting rule + target map); [API shape policy](../../api-shape-policy.md) §5; format template: [01-math-transform-delivery](../../triga-threejs-80/01-math-transform-delivery.md)

## Goal

Move the light genera out of `src/graph.fab` into a new `lighting` package, per the frozen clean-break list ([report §2, seam B](../checkpoint/report.md)):

- New leaf `src/lighting/light.fab` (import path `triga:lighting/light`) owns `Light`, `AmbientLight`, `DirectionalLight`, `PointLight` — moved **verbatim**, no renames, no shape changes (pure relocation; genus names, field names, and defaults preserved).
- New map-only facade `src/lighting.fab` (import path `triga:lighting`) documents the package; **no genera** (facade rule, [report §1.4.7](../checkpoint/report.md)).
- `src/graph.fab` keeps `Object3D`, `Scene`, `PerspectiveCamera`, `OrthographicCamera`, `PerspectiveCameraProjectionFacts`, `ViewProjectionFacts` (~99 of 119 lines).
- Per [report §1.4.1](../checkpoint/report.md): `graph/light` is **dropped** from the inventory — the `Light` genus *is* the attachment (`Light { Object3D base; Color color; f32 intensity }`); there is no separate attachment to split off. Light *family* semantics move to `lighting/light`, importing `triga:graph` for the `Object3D` base — a same-level import, no cycle (retargeted to `triga:graph/object` when DS-G lands, see the DS-G edge below).
- Migrate the only live references: `src/triga.fab` facade comment, `docs/module-map.md`, and the regenerated `target/faber/src/main.rs` (regeneration surface, gitignored).

**Timing** ([report §3](../checkpoint/report.md)): must precede 80 **Stage 6** (light families, `goals/06-material-texture-lighting.md:32`); must not land during 80 Stages 4–5 uncoordinated; landing window = the Stage 5→6 gap, bundled with seams A (material→renderable) and D (scene store/query). Verified at S0: **zero** live Faber constructors — the cheapest seam in the list.

> Note on seam lettering: report §2 uses B for lights and D for scene store/query; report §3's schedule table uses D for "graph lights → lighting" and C for scene. The campaign's spec letters (DS-B lights, DS-D scene) follow §2. This spec cites §3 timing rows by content.

## Invariant

- Triga remains one backend-neutral, versioned Faber source package; public modules are explicit semantic lanes. `lighting` is a **peer** of `graph`, not a child — dependency order `lighting/light → graph → math`, acyclic ([GOAL dependency direction](../../../GOAL.md), [report §1.4.1](../checkpoint/report.md) "same-level, no cycle").
- **Pure relocation**: genus names, field names, defaults (`intensity = 1.0`, `distance = 0.0`, `decay = 2.0`), and semantics move verbatim. No vocabulary changes (API shape policy holds; no `_code`/ABI fields are involved — nothing touches the frozen ABI seam).
- **Facade rule** ([report §1.4.7](../checkpoint/report.md)): `src/lighting.fab` holds no genera; no type re-export anywhere; consumers import the leaf that owns the genus.
- **Nesting rule**: no empty leaves created to satisfy the minimum ([report §1.3](../checkpoint/report.md)); only content-bearing leaves land. See [Nesting-rule treatment](#nesting-rule-treatment).
- This delivery does **not** worsen the acknowledged `check-compile` RED (faber generated-code lowering regression) and does **not** fix it (root-cause owner: the faber Rust emitter via the 80 generated-Rust acceptance lane; restoration is a named precondition of every S1 delivery spec, [report §8/§9](../checkpoint/report.md)).
- No `@ externa` / `@ subsidia`; optional genus fields use `sponte` (not introduced — the light genera keep their plain defaults).

## Repo-Aware Baseline

Live facts verified 2026-08-01 (read-only; no builds run):

- `src/graph.fab` is 119 lines; the light block is lines **90–109** (`genus Light` through the closing `}` of `PointLight`). Lines 111–119 are a **stale end-of-file GEOMETRY comment block** (a material.fab mirror note) — DS-A's cosmetic item, not DS-B's.
- Zero Faber consumers of the light genera (re-grepped across `exempla/` and `corpus/*/src/`: no matches). `src/scene.fab`'s `SceneLight` is a scene-side node-kind marker and does not reference `graph.Light`.
- `scripta/check-compile` parses modules via a fixed loop (`math graph material face geometry primitives scene resource triga`) plus direct exempla checks; `scripta/check-source` auto-discovers every `src/**/*.fab` via `find`.
- `target/faber/src/main.rs` is generated and gitignored; its `mod graph { AmbientLight, DirectionalLight, PointLight }` is regenerated from the compile set.
- Both source gates are RED today, both pre-existing and acknowledged (report §0): the `geometry_vertex_layout_matches` naming lint (src/geometry.fab:1332, fixed inside DS-E) and the 4 E0308s in regenerated `main.rs` (faber emitter). Neither is in DS-B's fixture area.
- DEFER-121 (nested-package resolution, [report §8](../checkpoint/report.md)): `triga:scene/store`-style resolution is a **precondition gate for every S1 split**; module-map documents it, tooling unconfirmed; DS-D verifies first, then all splits.

## Nesting-rule treatment

The module-map nesting rule ([module-map.md](../../module-map.md)): nested dirs (`src/<pkg>/<leaf>.fab` → `triga:<pkg>/<leaf>`) only when the directory has **at least two** modules (prefer 3+); a single nested file flattens to a top-level leaf (e.g. `triga:resource`, not `triga:scene/resource`).

**Current-content reality**: only `light` has content today; `model` (H3), `environment` (H5), `shadow` (H4) are planned, not filled. A strict flatten reading would move `light` to `src/lighting.fab` — but that path is already claimed by the package facade, and the checkpoint freezes `lighting/light` + facade as the split ([report §1.2](../checkpoint/report.md): "`lighting` | `light` | Families move from `graph.fab`; zero consumers; `model`/`environment`/`shadow` deferred to H3/H5/H4"; module-map target map: "`lighting` | `light` | light families move from `graph.fab`; `graph/light` dropped").

How the 2-leaf minimum is met / why this is the accepted structure:

1. `lighting` is frozen as a **4-leaf family** (light + model + environment + shadow). The flatten guidance targets *permanently* single-leaf families (e.g. `triga:resource`); lighting's remaining leaves are scheduled, not abandoned.
2. Creating `model`/`environment`/`shadow` now just to satisfy the count would invert the nesting rule's intent ([report §1.3](../checkpoint/report.md): "Creating empty directories to satisfy the nesting rule would invert its intent (module-map guidance: 'next seam only if a second importer wants')").
3. Flattening is structurally impossible: `triga:lighting` is the facade path; a flattened single leaf would collide with it or force a family rename — both contradict the frozen map.
4. The facade + filled leaf matches the module-map "Facade composes submodules" pattern (Norma `caelum` example) and the report's facade rule (§1.4.7).

**Decision recorded here**: the accepted structure is `src/lighting.fab` (map-only facade, no genera) + `src/lighting/light.fab` (the only content-bearing leaf at DS-B). The 2-leaf minimum is satisfied by the frozen 4-leaf family plan; the package directory currently holds one filled leaf + facade, and **H3/H5/H4 must fill `model`/`environment`/`shadow`** to complete the family. This exception is recorded in this spec and must be recorded in `docs/module-map.md` when the split lands.

## Scope

### Files in (exact)

| Path | Change | Contents |
| --- | --- | --- |
| `src/lighting/light.fab` | **NEW** | Header comment; `importa ex "triga:math" privata math`; `importa ex "triga:graph" privata graph`; the four genera moved verbatim from src/graph.fab:90–109: `genus Light { Object3D base; math.Color color; f32 intensity = 1.0 }`, `genus AmbientLight { Light base }`, `genus DirectionalLight { Light base; math.Vector3 target_position }`, `genus PointLight { Light base; f32 distance = 0.0; f32 decay = 2.0 }` |
| `src/lighting.fab` | **NEW** | Map-only facade: header comment documenting the package and its planned leaves (`light` now; `model` H3, `environment` H5, `shadow` H4); `importa ex "triga:lighting/light" privata lighting` (mirrors the triga.fab facade pattern); **no genera** |
| `src/graph.fab` | EDIT | Remove the four light genera (lines 90–109); update header comment line 1 ("Scene-graph shape contracts (Object3D, cameras, lights)." → "…(Object3D, cameras)."). Do **not** touch the stale GEOMETRY comment block (lines 111–119) — DS-A's cosmetic item (T-B Seam A table); non-overlap |
| `src/triga.fab` | EDIT | Facade comment migration: line 7 "`triga:graph` Object3D, Scene, cameras, lights" → "Object3D, Scene, cameras"; add a `triga:lighting` comment line; add `importa ex "triga:lighting" privata lighting` (consistent with the facade's existing leaf imports) |
| `docs/module-map.md` | EDIT | `triga:graph` row drops "lights"; add `triga:lighting` (facade) and `triga:lighting/light` (Light family) rows; size table (`graph.fab` ~119 → ~99; add `lighting.fab` and `lighting/light.fab`); dependency direction (`lighting ──► math, graph`; facade row gains `lighting`); import examples; one-line nesting-rule exception note for `lighting` |
| `scripta/check-compile` | EDIT | Add `lighting` to the module parse loop (parses `src/lighting.fab`); add a direct `"$RADIX_BIN" check "$ROOT/src/lighting/light.fab"` line (mirrors the geometry-attributes pattern) |

### Files out (must remain untouched)

- `src/math.fab`, `src/geometry.fab`, `src/scene.fab`, `src/material.fab`, `src/primitives.fab`, `src/face.fab`, `src/resource.fab` — untouched. (No imports change in any existing module; the move is consumer-free.)
- All `exempla/*.fab` and `corpus/*/src/*.fab` — untouched (zero light-genus references).
- `scripta/check-source` — untouched (auto-discovers the new files; no lint risk).
- `docs/factory/triga-engine/GOAL.md` — vision artifact; its `graph/light` inventory rows are superseded by report §1.4.1; not migrated in this delivery.
- `target/faber/src/main.rs` — gitignored regeneration surface; regenerated as a gate byproduct, never hand-edited or committed.
- The stale GEOMETRY comment block at `src/graph.fab:111–119` — DS-A's cosmetic item.

## Implementation Stage Graph (ordered)

1. **Precondition — DEFER-121 nested-package resolution** ([report §8](../checkpoint/report.md)): confirm `triga:lighting/light`-style resolution before creating the facade import. DS-D verifies first ("DS-D first, then all splits"); DS-B re-confirms with a throwaway probe consumer (implementation-time scratch, not committed). If unresolved, stop — the split does not land.
2. **Stage 1 — Create `src/lighting/light.fab`** with the four genera verbatim.
3. **Stage 2 — Edit `src/graph.fab`**: remove the four light genera; fix the header comment. **This graph.fab edit must land BEFORE any split of graph** — see the DS-G edge below.
4. **Stage 3 — Create `src/lighting.fab` facade** (map-only).
5. **Stage 4 — Migrate references**: `src/triga.fab` comment + import, `docs/module-map.md`, `scripta/check-compile`.
6. **Stage 5 — Regenerate** `target/faber/src/main.rs` via the gate's `faber run --compile` path; confirm `mod graph` loses `AmbientLight`/`DirectionalLight`/`PointLight` and no new E0308 candidates appear.
7. **Gate — `check-source` + `check-compile`** per the Gates section.

Stages 1–2 form one atomic move (the new leaf and its only current removal); stages 3–4 wire the surface; each maps to one commit (Commit boundaries).

### The DS-G edge

DS-G (graph → `graph/{object,camera}`, drafted in parallel) **depends on DS-B**:

- DS-B's graph.fab edit (Stage 2) is a hard prerequisite of DS-G's split; DS-G lands after DS-B, serialized ([report §2](../checkpoint/report.md) seam G: "any time in S1; not with B"). Do not bundle and do not pre-empt the graph-family split ([T-B adjacent caution](../checkpoint/T-B-seam-consumers.md): "Do not conflate the light-fields seam with the full graph-family split").
- Handoff item for DS-G: retarget `lighting/light`'s import from `triga:graph` to `triga:graph/object` per report §1.4.1 (same-level import, no cycle). DS-G owns that retarget within its own change; DS-B records it here and must leave `triga:graph` resolvable.
- While DS-B is in flight, DS-G's draft must not assume the light genera still live in graph.fab.

## Fixtures

**Expected: none gate-breaking.** Confirmed against the [T-B Seam B consumer table](../checkpoint/T-B-seam-consumers.md) and live re-grep (2026-08-01):

| Consumer | Status |
| --- | --- |
| `exempla/*.fab` | **zero hits** for `Light`/`AmbientLight`/`DirectionalLight`/`PointLight` (re-verified); `triga-types-untested.fab` covers Object3D/Scene/cameras only |
| `corpus/*/src/*.fab` | **zero hits** (only prose: "lighting follows the land" in `webgl-geometry-terrain/src/terrain.fab`) |
| `src/scene.fab` `SceneLight` | no impact — node-kind marker, no `graph.Light` reference |
| `proof/capstones/*.json` | no impact — no seam symbols |
| `scripta/*` | `check-compile` parses `graph.fab` by name (leaf stays); module loop gains a `lighting` entry — script change, not a fixture |
| 80 goals 06/09/10 prose | planned-stage references ("Cover ambient, directional, point, spot, and hemisphere-style light families…", glTF punctual lights, shadow-map rendering) — timing-only, no fixture churn |
| `target/faber/src/main.rs` | regeneration surface; zero constructions ⇒ no new error candidates |

## Gates

- **`./scripta/check-source`** — green for DS-B's fixture area: the new files carry no `functio` (no naming-lint surface), no line-start `//` comments, no `@ externa`/`@ subsidia`, no retired optional-field syntax; `check-source` auto-discovers `src/lighting.fab` and `src/lighting/light.fab`. The pre-existing RED (`geometry_vertex_layout_matches`, src/geometry.fab:1332) is **outside DS-B's fixture area** — geometry.fab is untouched; DS-B neither fixes nor worsens it (the fix is DS-E's).
- **`./scripta/check-compile`** — green for DS-B's area: the module loop parses the shrunk `graph.fab` and the new `lighting` entries; every exempla check is unchanged. The acknowledged RED (4 E0308s in regenerated `target/faber/src/main.rs` — a faber generated-code lowering regression, fixtures verified correct in source) is **outside DS-B's fixture area**: DS-B adds no light constructions and no generated-Rust consumers, so it introduces no new E0308 candidates and must not worsen the gate (no scene.fab or exempla edits). Restoration is the faber emitter's job via the 80 generated-Rust acceptance lane ([report §8/§9](../checkpoint/report.md)); every S1 delivery spec names it as a precondition, none fixes it.

## Validation Commands

```bash
./scripta/check-source
./scripta/check-compile
```

Targeted leaf parses (per the check-compile pattern, `FABER_LIBRARY_HOME` set to the faberlang root):

```bash
radix check src/lighting.fab
radix check src/lighting/light.fab
radix check src/graph.fab
```

Regeneration sanity (the generated file is gitignored — never committed):

```bash
faber run --compile exempla/triga-scene-store.fab
# → confirm regenerated target/faber/src/main.rs lost the three light types from mod graph
# → confirm no new E0308 candidates
```

DEFER-121 probe (implementation-time scratch consumer importing `triga:lighting/light`; not committed).

## Out Of Scope

- `lighting/model` (H3), `lighting/environment` (H5), `lighting/shadow` (H4) — recorded planned leaves ([report §1.2](../checkpoint/report.md), module-map target map); **NOT created** (report §1.3: no empty leaves).
- Graph `object`/`camera` split — **DS-G** (drafted in parallel; depends on DS-B; must not be bundled with or pre-empted by this delivery).
- `lighting/light` import retarget to `triga:graph/object` — DS-G's handoff item (§1.4.1).
- Material↔lighting coupling (light-resource requirements consumed by materials) — S3 / 80 Stage 6.
- `SceneLight` node-kind alignment with the lighting package — future additive.
- Compile-gate restoration (faber Rust emitter) — named precondition, owned via the 80 generated-Rust acceptance lane.
- GOAL.md inventory edits — vision artifact, superseded by the checkpoint.

## Commit Boundaries

Two cohesive commits in `triga` (no other repository touched; no Git cleanup of foreign work; intentional autocommit only):

- **C1 — the move (atomic)**: add `src/lighting/light.fab`; remove the four light genera from `src/graph.fab` (lines 90–109); update the graph.fab header comment. Intermediate states need not be individually gate-green.
- **C2 — the surface wiring**: add `src/lighting.fab` facade; update `src/triga.fab` comment + import; update `docs/module-map.md`; add `lighting` to `scripta/check-compile`.

`target/faber/src/main.rs` regenerates as a gate byproduct and is not committed (gitignored). C1 must land before DS-G's graph split (the DS-G edge). DS-B is implemented in the 80 Stage 5→6 gap, serialized with DS-A and DS-D (non-overlapping scopes: material/exempla, graph/lighting, scene respectively).

## Open Items

- Exact `radix check` / `faber check` behavior on the nested leaf path — resolved by the DEFER-121 probe (Stage 0).
- Whether `src/triga.fab` adds the `triga:lighting` import (recommended) vs comment-only — both are green; the import mirrors the facade's existing leaf-import pattern.
- Report §2 vs §3 seam lettering mismatch (B/D/C) — recorded, not a gate item.
