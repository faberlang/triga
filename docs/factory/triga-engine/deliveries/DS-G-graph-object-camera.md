# DS-G — Graph Object/Camera Split

**Campaign**: triga-engine (Wave 2 parallel delivery spec)
**Seam**: G — graph `object`/`camera` split (checkpoint report §2: moderate — two live corpus consumers; "any time in S1; not with B")
**Risk verdict (frozen at S0)**: moderate — two live corpus consumers
**Status**: draft (Wave 2 lowered in parallel with DS-E, DS-A, DS-B, DS-D, DS-S2)
**Dependency edge**: **DS-G depends on DS-B** (light genera out of `graph.fab` first); must **not** land concurrently with DS-B (report §2 timing constraint: "any time in S1; not with B").

## Goal

After DS-B removes the light genera, `src/graph.fab` holds exactly: `Object3D`, `Scene`,
`PerspectiveCamera`, `OrthographicCamera`, `PerspectiveCameraProjectionFacts`,
`ViewProjectionFacts` (~95 lines, T-B seam-B table). Split that residue into:

| Leaf | File | Owns |
| --- | --- | --- |
| `triga:graph/object` | `src/graph/object.fab` | `Object3D`, `Scene` |
| `triga:graph/camera` | `src/graph/camera.fab` | `PerspectiveCamera`, `OrthographicCamera`, `PerspectiveCameraProjectionFacts`, `ViewProjectionFacts` |
| `triga:graph` | `src/graph.fab` | Map-only facade — **zero genera** |

`graph/light` is **dropped** (report §1.4.1) — this delivery must not create it.
All live consumers migrate in the same change: both corpus demos' `camera.fab`,
`exempla/triga-types-untested.fab`, `exempla/triga-math-edge-cases.fab`, plus the
internal consumer `src/material.fab`. A leftover genus in `src/graph.fab` would make
it a compat barrel (facade rule, report §1.4.7) — the split must empty it.

## Invariant

1. **Facade emptying is mandatory.** `src/graph.fab` ends with zero genera; no type
   re-export anywhere (`module-map.md`: "There is no type re-export. Consumers import
   the leaf that owns the genus."). The facade mirrors the `src/triga.fab` pattern:
   header comment + leaf `importa` lines only.
2. **Pure relocation.** No genus, field, method, or free-function rename; no new
   features; every genus body moves **verbatim**. The `camera_*` free functions in
   `math.fab` (`camera_pitch_coercita`, `camera_directio_ex_yaw_pitch`, …) stay where
   they are — they are math, not graph.
3. **Dependency acyclicity.** `camera → object → math`; `object` imports `triga:math`
   only; `camera` imports `triga:math` + `triga:graph/object` (same-level import for
   the `Object3D base` field — the exact precedent named in report §1.4.1). No
   `graph → lighting` edge after DS-B.
4. **Nesting rule satisfied.** The `graph` package has exactly 2 leaves (`object` +
   `camera`) — legal per `docs/module-map.md` ("at least two, preferably three or
   more" — 3 is prefer, not must; T-A-inventory concurs).
5. **No gate regression.** DS-G is a pure relocation and must not worsen the
   acknowledged `check-source`/`check-compile` reds (see Gates).

## Scope

### Files created

- `src/graph/object.fab` — `Object3D` + `Scene` bodies copied verbatim from
  `src/graph.fab` (genus range after DS-B: lines 8–24). Header comment per house
  style; `importa ex "triga:math" privata math`.
- `src/graph/camera.fab` — `PerspectiveCamera`, `PerspectiveCameraProjectionFacts`,
  `ViewProjectionFacts`, `OrthographicCamera` copied verbatim (lines 26–98 after
  DS-B). Header comment; `importa ex "triga:math" privata math` + `importa ex
  "triga:graph/object" privata object`.

### Files edited (this repo, same commit)

- `src/graph.fab` — emptied to map-only facade: header comment listing the two
  leaves + `importa ex "triga:graph/object" privata object` and `importa ex
  "triga:graph/camera" privata camera`; **all genus bodies removed**.
- `corpus/webgl-geometries/src/camera.fab` — import (line 2) + qualified names
  (line 84).
- `corpus/webgl-geometry-terrain/src/camera.fab` — import (line 2) + qualified names
  (line 84).
- `exempla/triga-types-untested.fab` — import (line 16) + qualified names
  (`graph.Object3D` lines 31/41, `graph.Scene` line 37, `graph.OrthographicCamera`
  line 41).
- `exempla/triga-math-edge-cases.fab` — import (line 12) + qualified names
  (`graph.Object3D` line 45, `graph.PerspectiveCamera` line 46).
- `src/material.fab` — import (line 7) + `graph.Object3D` reference (line 75, in
  `genus Mesh`). **Fifth, internal migration site** — see Fixtures.
- `scripta/check-compile` — module loop (`for mod in math graph material …`) gains
  `graph/object` and `graph/camera`; otherwise the new leaves escape the gate
  (currently only `src/graph.fab` is parsed by name).
- `docs/module-map.md` — living-map `triga:graph` row (the target map is already
  frozen: `graph | object, camera`).
- `src/triga.fab` — facade header comment, line 7 ("`triga:graph` Object3D, Scene,
  cameras, lights" → leaf list).
- `README.md` — "Current Types" table row (line 31) + import example (line 45).
- `AGENTS.md` — module-layout table row "`triga:graph` | Object3D, cameras, lights".

### Regenerated, gitignored — no manual edit

- `target/faber/src/main.rs` (`mod graph { … }` → `mod graph_object` /
  `mod graph_camera` or equivalent emitter naming — regeneration surface, T-B).
- Corpus demos: `faber.lock` (regenerated by `tests/run.sh`, gitignored per
  `corpus/<slug>/.gitignore:5`), `dist/`, `public/`, `src/shaders/`.

### Out of scope (do not touch)

- `src/graph/light.fab` — **must not exist** (dropped at S0, report §1.4.1).
- `src/lighting/` — DS-B territory.
- `scripta/check-exempla-inventory` — scans `exempla/` dynamically; no change.
- `docs/factory/triga-engine/checkpoint/*` — frozen S0 evidence, read-only.
- `corpus/_host/` — DS-S2 extraction territory.
- The faber generated-code lowering regression (compile-gate red) — faber emitter
  lane via the 80 generated-Rust acceptance; not this delivery.

## Implementation Stage Graph

Ordered authoring stages; **all land in one commit** (see Commit boundaries). Stages
1–6 are authoring order inside the single change, not separate commits.

0. **Preconditions (external).**
   - **DS-B landed**: `src/graph.fab` contains no `Light`, `AmbientLight`,
     `DirectionalLight`, or `PointLight` genus. Verify by reading `src/graph.fab`
     before starting. If DS-B has not landed, **do not start DS-G** (splitting the
     lights would force creating the dropped `graph/light` or a compat barrel).
   - **DEFER-121 verified**: nested-package resolution (`triga:<pkg>/<leaf>` paths)
     confirmed working in radix check + faber check/build. DS-D (scene split)
     verifies the tooling first and DS-G inherits the result (report §8, "DS-D
     first, then all splits").
   - **Not concurrent with DS-B** (report §2: G "any time in S1; not with B").
1. **Create `src/graph/object.fab`** — `Object3D`, `Scene` moved verbatim; import
   `triga:math`.
2. **Create `src/graph/camera.fab`** — `PerspectiveCamera`,
   `PerspectiveCameraProjectionFacts`, `ViewProjectionFacts`, `OrthographicCamera`
   moved verbatim; imports `triga:math` + `triga:graph/object`.
3. **Empty `src/graph.fab` to a map-only facade** — delete all genus bodies; keep
   header + leaf imports. This is the facade-emptying step: after it,
   `triga:graph` provides no genera.
4. **Migrate all consumers** (import-line + qualified-name churn only):
   `corpus/webgl-geometries/src/camera.fab`, `corpus/webgl-geometry-terrain/src/
   camera.fab`, `exempla/triga-types-untested.fab`, `exempla/triga-math-edge-cases.fab`,
   `src/material.fab`.
5. **Update gates + docs**: `scripta/check-compile` module loop; `docs/module-map.md`;
   `src/triga.fab` comment; `README.md`; `AGENTS.md`.
6. **Validate** (see Validation commands): source gate, compile gate (acknowledged
   red), both corpus demo builds.

Stage-graph edges: 1 → 2 (camera imports object), 2 → 3 → 4 (consumers migrate only
once leaves exist and the facade is emptied — the corpus build breaks otherwise),
4 → 5 → 6. Edge from 0: DS-B and DEFER-121 are hard preconditions.

## Fixtures

The four live consumers from T-B's adjacent caution, verified in the tree at
draft time (2026-08-01), plus the internal `src/material.fab` import:

### 1. `corpus/webgl-geometries/src/camera.fab`
- Uses (line 84): `graph.PerspectiveCamera { base = graph.Object3D { … } … }`
  constructor literal + `perspective.visus_projectio(...)`. All other graph usage
  is demo-local (`OrbitCamera`, `CameraInput`); `math.camera_*` calls stay.
- Migration:
  ```fab
  importa ex "triga:graph/object" privata object
  importa ex "triga:graph/camera" privata camera
  # line 84: camera.PerspectiveCamera { base = object.Object3D { … } … }
  ```

### 2. `corpus/webgl-geometry-terrain/src/camera.fab`
- Same shape as #1 (line 84; fov 45, near 0.5, far 600). Identical migration.

### 3. `exempla/triga-types-untested.fab`
- Uses: `graph.Object3D` (lines 31, 41), `graph.Scene` (line 37),
  `graph.OrthographicCamera` (line 41). Non-allowlisted →
  radix check + `faber run --compile` in `check-exempla-inventory`.
- Migration: add the two leaf imports with aliases `object` / `camera`, qualify
  accordingly. It also constructs `material.Mesh`/`material.MeshGeometry`
  (DS-A fixture) — DS-G touches only the graph lines; if DS-A lands first those
  symbols have already moved and DS-G's edit is unaffected.
- Note the `Object3D`/`Scene`/`OrthographicCamera`/`PerspectiveCamera` struct
  literals include `math.Euler`/`math.Quaternion` fields; those stay `math.*`.

### 4. `exempla/triga-math-edge-cases.fab`
- Uses: `graph.Object3D` (line 45), `graph.PerspectiveCamera` (line 46).
  Non-allowlisted → radix check + `faber run --compile`. Same import/qualify
  migration.

### 5. `src/material.fab` (internal, fifth site — not in T-B's graph consumer list but real)
- Imports `triga:graph` (line 7) for `graph.Object3D` in `genus Mesh` (line 75).
  Migration: `importa ex "triga:graph/object" privata object` + `object.Object3D`.
  **Coordination with DS-A**: if DS-A (Mesh → `renderable/mesh`) lands first, the
  `graph/object` import moves with `Mesh` into `renderable/mesh` and DS-G's
  material.fab edit becomes a no-op; if DS-G lands first, DS-A inherits an already
  migrated material.fab. Either ordering leaves no `triga:graph` import behind.

### Corpus `tests/run.sh` impact
- **No script change.** `run.sh` regenerates `faber.lock`
  (`interface_root = "$WORKSPACE/triga/src"`), runs `faber check` on each demo
  `src/*.fab` (including `camera.fab` — the first surfacing point for the split),
  then `faber build --package .` (TS browser target). The emitted module set changes
  (`triga-graph.js` → `triga-graph-object.js`/`triga-graph-camera.js`, and the
  `camera.js` import line) but is regenerated and gitignored; `run.sh`'s contract
  greps (`host-init.js` contents, page selector) never name the graph module. The
  `_host` JS imports are module-relative (`./webgpu-runtime.js`, …) and never name
  `triga-graph` — no host-side touch.

## Gates

- **`check-source` green** — the naming lint walks all of `src/` recursively
  (`find "$SRC" -name '*.fab'`), so the two new leaves are covered automatically;
  they add no public `functio` with a genus-prefix (all moved methods are receivers).
  The gate is RED today on `geometry_vertex_layout_matches` (src/geometry.fab:1332,
  DS-E-owned, acknowledged) — DS-G does not touch `geometry.fab` and reads the gate
  as *green except the acknowledged item*.
- **`check-compile` green** — acknowledged RED: 4 E0308 errors in regenerated
  `target/faber/src/main.rs` (faber generated-code lowering regression; fixtures
  verified correct in source; restoration is a named precondition of every S1
  delivery spec and belongs to the faber emitter lane — **outside DS-G's area**).
  DS-G must not worsen it; it is a pure relocation. The `scripta/check-compile`
  module loop must gain `graph/object` + `graph/camera` or the new leaves escape
  the gate.
- **Corpus build green (declared corpus-gate, not run by this spec)** — per demo
  `faber check` + `faber build` via `tests/run.sh`. Read-only drafting: the spec
  declares the gate; Wave 3 implementation runs it.

## Validation Commands

```bash
./scripta/check-source
./scripta/check-compile

# targeted leaf parse (nested-path resolution, DEFER-121):
FABER_LIBRARY_HOME=<faberlang-root> radix check src/graph/object.fab
FABER_LIBRARY_HOME=<faberlang-root> radix check src/graph/camera.fab

# corpus gates (per demo; faber check + faber build):
cd corpus/webgl-geometries && ./tests/run.sh
cd corpus/webgl-geometry-terrain && ./tests/run.sh
```

## Out Of Scope

- **Lighting = DS-B.** `Light`, `AmbientLight`, `DirectionalLight`, `PointLight`,
  the `lighting/light` package, and the (dropped) `graph/light` leaf. DS-G splits
  only the post-DS-B residue.
- **No new graph features.** No new genera, fields, methods, facts, or free
  functions on `Object3D`/`Scene`/cameras; no renames (`visus_projectio`,
  `projectio_facta`, `perspectiva` naming, etc. preserved verbatim).
- Geometry split (DS-E), material → renderable + `MeshGeometry` retirement (DS-A),
  scene store/query (DS-D), `triga:triga` facade growth, engine extraction + vertical
  slice (DS-S2), and the faber compile-gate regression — all other lanes.
- Growing genera on the `triga:triga` facade is forbidden by AGENTS.md regardless.

## Commit Boundaries

- **One cohesive commit in `triga`** (this repo): library split (stages 1–3) +
  all consumer migrations (stage 4) + gate/doc updates (stage 5). The split is
  not shippable without the consumer migration — the corpus demos resolve `triga:*`
  from `triga/src` via the generated `faber.lock`, so the build breaks the moment
  `triga:graph` stops providing the genera while `camera.fab` still imports it.
  The facade emptying is part of the same change (facade rule, report §1.4.7).
- **No commit to radix / faber / hosts / corpus `_host`.** If the DEFER-121 check
  reveals a provider/emitter gap for nested paths, that is a separate coordinated
  change owned by the compiler lane, not part of DS-G's commit.
- **DS-B lands first, never concurrently.** DS-G's commit assumes the DS-B residue;
  sequencing is parent-owned per the seam schedule.
- Wave 2 drafters do not commit; the parent owns authorship and validation of the
  DS-G commit.
