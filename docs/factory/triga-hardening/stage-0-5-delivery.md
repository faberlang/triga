# Triga Hardening — Stage 0.5 Delivery Spec
## Full co-located proba coverage and executed-proba scorecard

**Status**: delivery — READY for delivery audit
**Date**: 2026-08-16
**Campaign**: [`CAMPAIGN.md`](./CAMPAIGN.md), Stage 0.5 operator amendment
**Depends on**: Stage 0 (`tgh-s0-1` through `tgh-s0-4`)
**Repository**: `/Users/ianzepp/work/faberlang/triga`
**Scope**: Triga co-located `.proba` sources, Stage-0 scorecard refresh, and
named Radix route units. No Triga product-source edits. Radix units are
owning-repository specifications, not Triga implementation work.

## 1. Interpreted theme

Stage 0.5 changes the Triga evidence contract from one stale probe to one
co-located English-surface proba beside every live source module. Each public
implementation must receive a positive, boundary, degenerate, or negative
assertion appropriate to its contract. Map-only facades receive an explicit
executed discovery smoke rather than invented API claims.

The stage has three boundaries:

1. Triage the current test path before coverage is allowed to close.
2. Add module-family batches of co-located probas under `triga/src/`.
3. Add a machine gate and scorecard row that distinguish discovered,
   analyzed, and actually executed proba evidence.

This is a test-and-evidence stage. It does not repair Triga implementations,
change the supported profile, change `proof/capabilities.json`, or silently
work around a compiler or Faber package defect.

## 2. Live baseline and triage verdict

### 2.1 Coverage gap

The live tree has 26 `.fab` modules and one `.proba`:

```bash
cd /Users/ianzepp/work/faberlang/triga
find src -type f -name '*.fab' | sort | wc -l       # 26
find src -type f -name '*.proba' | sort            # src/math.proba only
```

`src/math.proba` has three cases. The Stage-0 scorecard therefore correctly
records one co-located test source and 25 structural-only module rows. The
module set is the live 26-module set from `proof/inventory/triga-inventory.json`,
not the future 61-leaf / 75-import-path horizon in the archival module map.

### 2.2 Existing `math.proba` failure

The existing probe is written in the retired Latin source surface:

- `importa ex "./math" privata math`
- `probandum`, `proba`, and `adfirma`
- `fixum` declarations

The current Triga package declares `[reader] locale = "en"`. The current English
reader pack maps the canonical testing constructs to `describe`, `test`,
`assert`, `const`, `import`, and `from`. The current parser also rejects the
old import privacy modifier with `PARSE050.import_privata_removed`.

The module was not renamed. These live facts remain true:

- `src/math.fab` exists.
- `Vector3` is public.
- `vector3`, `Vector3.addita`, and `Vector3.normata` exist in that module.
- `radix check --locale en src/math.fab` exits 0 with warnings only.

The original direct-probe symptoms were a stale proba surface plus a semantic
cascade, not evidence that the math module disappeared:

```text
faber test /Users/ianzepp/work/faberlang/triga/src/math.proba
  -> SEM001.unknown_identifier / SEM008.undefined_name

radix check --locale en src/math.proba
  -> SEM001.unknown_identifier / SEM008.undefined_name
```

This is historical Stage-0 triage evidence. The first coverage unit rewrote
`src/math.proba` to the current English surface, and the later visibility series
made the imported public math surface available. Current failures belong to the
expanded coverage cases and their remaining MIR/provider seams. The stage must
not add a compatibility alias or change the math module to match the stale
probe.

### 2.3 `faber test .` package-path gap

The package invocation was reproduced from the Triga root before the Radix
path repair:

```text
cd /Users/ianzepp/work/faberlang/triga
/Users/ianzepp/work/faberlang/radix/target/debug/faber test .
  -> cannot read '.' (os error 2)
  -> package analysis failed
```

The pre-repair implementation passed the raw CLI `PathBuf` from
`radix/crates/faber/src/commands/test.rs` to
`radix_package::analyze::analyze_package_for_tests`. The package analyzer's
contract required absolute inputs. `radix-package::normalize_path` was lexical;
normalizing `.` removed the `CurDir` component and left an empty relative path,
so discovery checked the wrong path and emitted the observed I/O error.

This historical Radix/Faber package-path defect was separate from the stale
probe source. A second invocation confirmed the shape distinction:

```text
faber test src
  -> cannot read 'src/main.fab' (os error 2)
```

A source directory without a manifest was treated as a legacy package whose
entry was `main.fab`; it was not the Triga package form. An absolute package
path reached package analysis and reproduced the probe's semantic errors
instead of `cannot read '.'`, separating the two historical failures.

Radix `9919d480c` now absolutizes the package-test input before analysis. The
old path failure is retained as route history, not as an active Stage-0.5
prerequisite.

### 2.4 Converted English probe and the landed Radix route

A temporary package containing the unchanged `src/math.fab` and a converted
English `math.proba` originally exposed these MIR error shapes:

```text
unsupported MIR lowering: method call before runtime/provider MIR lowering
unsupported MIR lowering: projection base that does not resolve to a local value
```

Those errors are historical route evidence. They identified public `Vector3`
method calls and field projections that had to remain real assertions; they did
not justify weakening the Triga coverage to count-only tests.

The package-link portion landed in Radix as `e56d45f70`. Radix
`018cc8b25` then selected and implemented link-then-run: `faber test` collects
test-bearing roots, links the package scope once, and runs every discovered case
against the shared validated MIR. Radix `736b14766` preserves the scalar
collection-length result at the nullable expression boundary. The recorded
official converted three-case math fixture is green: `3 passed, 0 failed`.
That receipt is distinct from the later expanded `src/math.proba` coverage
file, whose cases remain subject to the residuals below.

Later Triga visibility repairs (`94c8da7`, `cdf8c0e`, `9d9246c`, `91b3389`,
`ef48638`, `b8def7c`) address public math, graph, geometry/face,
material/lighting, renderable, shader, and facade exports. The remaining
Stage-0.5 residuals are coverage-specific: broader probes still expose MIR
method-call, projection-base, and unresolved-path shapes, while resource and
shader-contract probes expose provider/runtime gaps. These residuals keep the
affected Triga module rows open; they do not reopen the Radix package-link
route.

### 2.5 Triage conclusion

The current package-link receipt (`148226b`,
`proof/coverage-scorecard.json`, coverage revision 2) records **9/26** module
selections at `executed-proba`. The remaining 17 rows are all
`runner-failure`; there are 0 `analysis-error` rows. `src/graph/camera.fab`
reaches the runner and fails all five cases, including unsupported provider
route `package:triga:graph/camera::camera::children`; it is not an analysis
error. `src/primitives/basic.fab` is also a `runner-failure`, and
`src/geometry/data.fab` is a `runner-failure` with three failed cases. The
remaining named unsupported provider routes are
`package:triga:graph/camera::camera::children` and
`package:BufferAttribute::return::dele`. The receipt has no `PARSE050` row;
`PARSE050.import_privata_removed` is historical evidence from the retired
import-modifier and single-file/roundtrip routes, not the current Triga
package-link verdict.

The Stage-0 Q4 conclusion remains in force: the executed-proba tier is open,
but not because of an unresolved Radix link architecture. The classification
is mixed and must stay explicit:

| Symptom | Owner | Classification | Stage-0.5 consequence |
| --- | --- | --- | --- |
| stale-Latin `src/math.proba` history | Triga test source | superseded by the English coverage wave and later visibility repairs | judge the current probe result, not the historical syntax failure |
| `faber test .` path history | Radix/Faber package route | fixed by `9919d480c` | retain the path regression as historical evidence |
| converted probe method/field shapes | Radix package-link route | fixed by `018cc8b25`, with scalar-result repair in `736b14766`; official three-case receipt is green | keep method/field assertions and track actual Triga coverage results |
| later Triga coverage failures | Triga visibility and MIR/provider seams | visibility repairs landed, but broader probes retain named MIR/provider residuals | keep affected rows below `executed-proba` until their cases pass |

Coverage units may author their `.proba` files while their own visibility and
MIR/provider residuals are in flight. No coverage unit may claim executed-proba
completion until its actual cases pass through the package gate. The aggregate
Stage-0.5 tier stays open until the gate reports 26/26 passing modules.

## 3. Proba framework contract

### 3.1 Current compiler and package paths

The live Radix/Faber source establishes these boundaries:

- `radix/crates/radix/src/proba/mod.rs`
  - `inventory_cases` inventories `proba` cases from HIR.
  - `ProbaCase.suite_path` records nested `probandum` paths.
  - `ProbaModifierView` supports `omitte`, `futurum`, `solum`, `tag`,
    `temporis`, `metior`, `repete`, `fragilis`, and `solum_in`.
  - `run_proba_source` handles a direct single-file run.
  - `run_proba_on_analyzed` remains the direct analyzed-unit API; package tests
    use the linked validated-MIR API below.
  - `run_proba_on_validated_with_function_ids` executes package cases against
    linker-assigned function identities in one validated MIR image.
- `radix/crates/radix-package/src/analyze.rs`
  - `analyze_package` excludes `.proba` sources.
  - `analyze_package_for_tests` includes `.proba` sources and accepts a
    `TestSourceFilter`.
- `radix/crates/faber/src/commands/test.rs`
  - a single `.fab` or `.proba` path uses the direct single-file runner;
  - a package path uses `analyze_package_for_tests`, collects every analyzed
    test-bearing root, links the package scope once, and runs the cases against
    the shared validated MIR;
  - package testing is MIR execution, not Cargo or a generated Rust test crate.
- `radix/crates/faber/src/package/proba_integration_test.rs`
  - verifies `include_proba = true` discovers sibling `.proba` files;
  - verifies a proba may import a product `.fab` helper but may not import
    another `.proba`;
  - verifies the Norma-style package shape with an English `describe` /
    `test` / `assert` probe.

### 3.2 Grammar and locale surface

The canonical grammar in `faber/docs/EBNF.md` defines the testing forms as:

- `probandum` containing nested `probandum` or `proba` blocks;
- `proba` cases with modifiers;
- `praepara` / `praeparabit` and `postpara` / `postparabit` setup and teardown
  blocks;
- `adfirma` assertions.

`radix/stdlib/locale/en/pack.toml` supplies the current English spellings:

| Canonical form | English package surface |
| --- | --- |
| `probandum` | `describe` |
| `proba` | `test` |
| `adfirma` | `assert` |
| `praepara` / `praeparabit` | `setup` / `async_setup` |
| `postpara` / `postparabit` | `teardown` / `async_teardown` |
| `fixum` | `const` |
| `importa` + `ex` | `import` + `from` |

The old `privata` import modifier is not part of the current import contract;
Radix reports `PARSE050.import_privata_removed` when it is used there.

Nested suites and setup syntax are compiler-supported. The regression fixture
`radix/crates/radix/src/driver/regression_test.rs::compile_lowers_probandum_nested_cases_without_lowering_errors`
contains a `describe`-equivalent nested suite and `setup all` form. Stage 0.5
may use setup/teardown where a family has shared state, but it must not claim
fixture runtime behavior merely from parsing. A fixture assertion must execute
through the same gate as every other case.

### 3.3 Norma examples used as en-surface references

The freshest examples are:

- `norma/exempla/caelum/terminus.proba`: local package import, `describe`,
  `test`, `const`, typed construction, and field assertions;
- `norma/exempla/caelum/auscultator.proba`: several describe/test blocks and
  compilation-focused checks;
- `norma/exempla/caelum/connexus.proba`: multiple describe/test blocks with
  explicit compilation checks;
- `norma/src/mathesis.proba`: co-located package proba with a local `.fab`
  import, helper function, nested test cases, and English assertions.

The Caelum examples are valid grammar references, not evidence that network
operations execute. Compilation-only examples stay labeled as structural or
runner evidence according to the actual command result.

## 4. Normalized Stage-0.5 outcome

One delivery-sized outcome:

> Every live `src/**/*.fab` module has a sibling `src/**/*.proba` written in the
> current `en` surface, with public behavior and relevant edge cases exercised;
> the package runner executes every case through the MIR proba path; and the
> Stage-0 scorecard records the executed-proba tier per module without hiding
> Radix prerequisites or failed cases.

Non-goals:

- no edits to `src/**/*.fab` implementation code;
- no Radix implementation in the Triga checkout;
- no Stage 1 source/package gate repair beyond the named Radix routes;
- no support upgrade in `proof/capabilities.json`;
- no browser, target-equivalence, stress, or clean-install claim;
- no compatibility alias for the retired Latin probe surface;
- no assertion weakening, case deletion, or test-only workaround for a red
  runner.

## 5. Owning-repository prerequisite units

These units are named here because the boundary rule requires an owning-repo
route before Triga's executed-proba gate can close. They are not Triga write
scopes and must be dispatched in `radix/`.

### `rdx-s05-1` — normalize package-test path inputs (**landed**)

- **repo**: `radix`
- **status**: landed in `9919d480c`.
- **outcome**: `faber test .`, a relative package path, and an absolute package
  path resolve the same manifest-backed package before
  `analyze_package_for_tests`; single-file `.fab` / `.proba` behavior remains
  distinct.
- **write_scope**: `radix/crates/faber/src/commands/test.rs`,
  `radix/crates/radix-package/src/discovery.rs` or the owning path-normalization
  seam, and focused package/test regression files under the corresponding
  crates.
- **done_when**: from the Triga root, `faber test .` no longer emits
  `cannot read '.'`; `faber test triga` from the workspace parent and an
  absolute Triga package path enter the same package discovery path; the
  regression proves manifest reader-locale selection and does not alter the
  `.proba` source contract. **Met by `9919d480c`.**
- **depends_on**: none
- **non_goals**: rewriting Triga probas, MIR lowering, or accepting a directory
  with no manifest as a package without `main.fab`.
- **risk**: medium — path normalization is a package boundary and can change
  legacy direct-file behavior.
- **integrable**: yes

### Historical route — `rdx-s05-2` (superseded; see `rdx-s05-3` below)

> **Superseded 2026-08-17** — closed `block_ship` (task `76f5a125`): the
> original write scope was wrong because imported method bodies were absent
> from an isolated proba MIR image and became available only at package-link
> time. No fix confined to `crates/radix/src/mir/lower/*` could execute an
> imported method. Re-scoped successor: **`rdx-s05-3`** (Vivi `b7934c6a`) —
> link-path lowering in `crates/radix-package/src/mir/link.rs`
> (`link_library_method_targets`). Evidence memo: `5aa20bf8`.
>
> **Resolution 2026-08-17** — `e56d45f70` landed the link-path portion;
> `018cc8b25` selected and implemented link-then-run for package probas; and
> `736b14766` repaired the scalar collection-length result. The recorded
> official converted three-case math fixture is `3 passed, 0 failed`. The route is closed;
> the remaining Stage-0.5 residuals are in Triga visibility/MIR/provider seams.

### `rdx-s05-3` — link-path completion and proba execution architecture (**landed**)

- **repo**: `radix`
- **status**: landed through `e56d45f70`, `018cc8b25`, and `736b14766`.
- **outcome**: preserve the existing Triga assertions and make the English math
  probe executable through the package-test route. Package testing links the
  test-bearing scope once, then runs its cases against shared validated MIR.
- **done_when**: the selected route is implemented by Radix and the recorded
  unchanged converted three-case math probe reaches `3 passed, 0 failed`; no
  Triga assertion is removed. **Met by the listed commits.**
- **depends_on**: none (landed route)
- **non_goals**: broad runner feature expansion, Rust/Cargo execution, or
  changing Triga public method semantics.

## 6. Triga Hand unit graph

All Triga units below write only the listed paths. The nine coverage families
are disjoint after triage and may be implemented in parallel on their separate
`.proba` paths. The gate is serial after all coverage units because it owns the
aggregate scorecard and inventory verdict.

### `tgh-s05-0` — record triage and external routes

- **outcome**: durable Stage-0.5 triage receipt records the historical 26/1
  coverage gap, the stale-Latin and package-path diagnoses, the landed Radix
  link-then-run route (`018cc8b25` / `736b14766`), and the later Triga
  visibility/MIR/provider residuals.
- **write_scope**: `triga/docs/factory/triga-hardening/stage-0-5-triage.md`
- **done_when**: the receipt contains the historical commands and current route
  update in §2 of this spec; it states that the Radix prerequisites are landed
  and that the aggregate executed-proba tier remains open only for actual
  Triga coverage results; it contains no Radix implementation.
- **depends_on**: none
- **sanity**: compare the receipt's module/proba counts with
  `proof/inventory/triga-inventory.json` and `find src`.
- **non_goals**: changing source, tests, scorecard, or Radix.
- **risk**: low — evidence-only record.
- **integrable**: yes

### `tgh-s05-c01` — math / vector / matrix coverage

- **outcome**: replace the stale `src/math.proba` with an English-surface
  co-located proba covering the math module's public vector, matrix, transform,
  quaternion, color, volume, plane, ray, and constructor contracts.
- **write_scope**: `triga/src/math.proba`
- **done_when**: the proba imports `./math` with `import from`, uses
  `describe` / `test` / `assert` / `const`, names every current public math
  symbol in the inventory at least once, and covers exact vector arithmetic,
  zero normalization, matrix validity/shape edges, transform payload facts,
  quaternion/color boundaries, and representative volume/ray degenerates;
  the package gate reports every case passed.
- **depends_on**: `tgh-s05-0`
- **sanity**: `radix check --locale en src/math.fab` plus the filtered package
  proba command from the gate.
- **read_scope**: `src/math.fab`, `proof/inventory/triga-inventory.json`,
  `norma/exempla/caelum/terminus.proba`,
  `radix/stdlib/locale/en/pack.toml`.
- **non_goals**: changing math implementation or preserving the old Latin
  syntax as an alias.
- **risk**: high — first probe establishes the executable shape for all later
  families.
- **integrable**: yes

### `tgh-s05-c02` — geometry and face coverage

- **outcome**: add co-located probas for the geometry family and FaceQuad.
- **write_scope**:
  `triga/src/geometry.proba`,
  `triga/src/geometry/attribute.proba`,
  `triga/src/geometry/batch.proba`,
  `triga/src/geometry/bounds.proba`,
  `triga/src/geometry/data.proba`,
  `triga/src/geometry/layout.proba`,
  `triga/src/face.proba`
- **done_when**: all seven listed modules have English probas. Public
  attributes, layouts, bounds, draw ranges/groups, geometry constructors,
  topology/index facts, and FaceQuad builders are named from the live
  inventory. Cases include empty/malformed buffers, wrong attribute lengths,
  invalid ranges/indices, degenerate bounds, invalid face codes, and exact
  position/normal/UV/winding/index values where generators publish them. All
  cases pass through the package runner.
- **depends_on**: `tgh-s05-0`
- **sanity**: filtered package proba run for the seven relative source paths.
- **read_scope**: listed `.fab` modules, `docs/module-map.md`,
  `proof/inventory/triga-inventory.json`, and existing geometry exempla.
- **non_goals**: geometry implementation repair, browser draw proof, or ABI
  changes.
- **risk**: high — broadest data-family surface and exact-value oracle.
- **integrable**: yes

### `tgh-s05-c03` — graph / object / camera coverage

- **outcome**: add co-located probas for graph facades, Object3D/Scene, and
  camera/projection facts.
- **write_scope**:
  `triga/src/graph.proba`,
  `triga/src/graph/object.proba`,
  `triga/src/graph/camera.proba`
- **done_when**: all three modules have English probas. Object identity,
  parent/child defaults, scene construction, perspective and orthographic
  camera facts, projection/view-projection outputs, and invalid projection
  inputs are exercised. `graph.proba` is an explicit facade-discovery smoke,
  not a claim that the facade re-exports leaf types. All cases pass.
- **depends_on**: `tgh-s05-0`
- **sanity**: filtered package proba run for graph paths.
- **read_scope**: listed `.fab` modules, `src/math.fab`,
  `proof/inventory/triga-inventory.json`, and camera exempla.
- **non_goals**: scene-store mutation coverage, host camera behavior, or graph
  module relocation.
- **risk**: medium — camera facts depend on math behavior but write paths are
  disjoint.
- **integrable**: yes

### `tgh-s05-c04` — scene and resource lifecycle coverage

- **outcome**: add co-located probas for SceneStore and ResourceHandle
  semantics.
- **write_scope**: `triga/src/scene.proba`, `triga/src/resource.proba`
- **done_when**: empty/deep/orphaned stores, insertion/deletion, negative and
  stale handles, generation replacement, self-attach/cycle rejection,
  reparent/detach, visibility/traversal, and resource identity/replacement/
  removal facts are covered with mutation sequences. Genuine absence remains
  distinct from invalid-handle rejection in the assertions. Both modules' all
  cases pass.
- **depends_on**: `tgh-s05-0`
- **sanity**: filtered package proba run for `scene` and `resource`.
- **read_scope**: listed `.fab` modules, Stage-0 Q4/open-question records,
  `docs/factory/triga-engine/deliveries/DS-D-scene-store-query.md`, and the
  inventory.
- **non_goals**: the parked scene split, typed-error implementation, host
  allocation/disposal, or device-loss behavior.
- **risk**: high — mutation sequences expose existing invariant gaps.
- **integrable**: yes

### `tgh-s05-c05` — material family coverage

- **outcome**: add co-located probas for the material facade and all four live
  material leaves.
- **write_scope**:
  `triga/src/material.proba`,
  `triga/src/material/base.proba`,
  `triga/src/material/basic.proba`,
  `triga/src/material/lit.proba`,
  `triga/src/material/standard.proba`
- **done_when**: base construction and validation, basic/lit/standard carrier
  facts, side/depth/opacity/alpha policies, and pipeline-fact projections are
  exercised. Out-of-range opacity/alpha and unsupported variants are tested as
  explicit rejection/unsupported behavior, not silently accepted as rendered
  capability. The facade proba is a discovery smoke. All cases pass.
- **depends_on**: `tgh-s05-0`
- **sanity**: filtered package proba run for material paths.
- **read_scope**: listed `.fab` modules, `docs/api-shape-policy.md`,
  `proof/inventory/triga-inventory.json`, and Profile v0.
- **non_goals**: adding material constructors, PBR support, or host pipeline
  consumption.
- **risk**: medium — carrier-only rows must not be promoted by test prose.
- **integrable**: yes

### `tgh-s05-c06` — lighting family coverage

- **outcome**: add co-located probas for the lighting facade and light leaves.
- **write_scope**: `triga/src/lighting.proba`, `triga/src/lighting/light.proba`
- **done_when**: AmbientLight, DirectionalLight, and PointLight carrier facts,
  color/intensity/direction boundaries, and the facade discovery shape are
  covered. Tests state carrier evidence separately from host lighting
  execution. All cases pass.
- **depends_on**: `tgh-s05-0`
- **sanity**: filtered package proba run for lighting paths.
- **read_scope**: listed `.fab` modules, Profile v0, and the inventory.
- **non_goals**: browser lighting, shadows, environment lights, or new light
  families.
- **risk**: medium — unsupported host variants must remain explicit.
- **integrable**: yes

### `tgh-s05-c07` — primitive generator coverage

- **outcome**: add co-located probas for the primitive facade and basic
  generators.
- **write_scope**: `triga/src/primitives.proba`,
  `triga/src/primitives/basic.proba`
- **done_when**: facade discovery executes; every live basic generator has
  exact vertex positions, normals, UVs, winding, index/topology, and count
  assertions where its API publishes them. Degenerate dimensions, invalid
  ranges, and unsupported generator inputs are covered. All cases pass.
- **depends_on**: `tgh-s05-0`
- **sanity**: filtered package proba run for primitive paths.
- **read_scope**: listed `.fab` modules, geometry facts, primitive exempla, and
  the inventory.
- **non_goals**: procedural/terrain/voxel modules, generator implementation,
  or browser rendering.
- **risk**: high — exact-output assertions are sensitive to accidental value
  drift and must not be reduced to length checks.
- **integrable**: yes

### `tgh-s05-c08` — renderable mesh coverage

- **outcome**: add co-located probas for renderable facade and Mesh composition.
- **write_scope**: `triga/src/renderable.proba`,
  `triga/src/renderable/mesh.proba`
- **done_when**: facade discovery executes; Mesh composition covers valid
  graph/geometry/material assembly, public fact access, missing/invalid
  component rejection, and composition edge cases. The proba does not claim a
  host draw. All cases pass.
- **depends_on**: `tgh-s05-0`, `tgh-s05-c02`, `tgh-s05-c03`,
  `tgh-s05-c05`
- **sanity**: filtered package proba run for renderable paths.
- **read_scope**: listed `.fab` modules, geometry/graph/material family specs,
  and the inventory.
- **non_goals**: host draw, shader compilation, or new renderable families.
- **risk**: medium — composition depends on several carrier contracts.
- **integrable**: yes

### `tgh-s05-c09` — shader contract and top-level facade coverage

- **outcome**: add co-located probas for shader-contract adapters and the
  top-level `triga` facade.
- **write_scope**: `triga/src/shader_contract.proba`,
  `triga/src/triga.proba`
- **done_when**: shader contract matchers cover matching and each published
  mismatch/rejection dimension, including code and resource-binding facts.
  `triga.proba` executes a facade-discovery smoke and does not invent type
  re-exports. All cases pass.
- **depends_on**: `tgh-s05-0`
- **sanity**: filtered package proba run for the two paths.
- **read_scope**: listed `.fab` modules, frozen ABI fields in the inventory,
  Profile v0, and shader-contract exempla.
- **non_goals**: changing ABI names/codes, resolving the Stage-7 transform
  disagreement, or host WGSL admission.
- **risk**: high — ABI assertions must remain read-only and exact.
- **integrable**: yes

### `tgh-s05-gate` — executed-proba coverage gate and scorecard refresh

- **outcome**: add a machine gate that discovers all 26 module/proba pairs,
  executes them through the package runner, and records the Stage-0.5 result
  without conflating structural or exempla evidence with executed proba.
- **write_scope**: `triga/scripta/check-proba-coverage`,
  `triga/proof/coverage-scorecard.json`,
  `triga/proof/coverage/README.md` if the gate needs a contract note.
- **depends_on**: `tgh-s05-c01` through `tgh-s05-c09`
- **done_when**:
  1. the gate discovers exactly the 26 live `.fab` modules from `src/`;
  2. it requires exactly one sibling `.proba` per module, including explicit
     facade-discovery probas;
  3. it invokes the package runner with an absolute package path and records
     the relative proba filter, command, exit status, case counts, and
     failures per module;
  4. it exits non-zero for a missing probe, analysis error, runner failure,
     unresolved Radix prerequisite, or count-only result;
  5. the scorecard adds a Stage-0.5 refresh row with `module_count = 26`,
     `proba_source_count = 26`, `executed_module_count`, and the executed tier;
  6. each module row records its proba path, case count, and actual execution
     tier; `evidence_tier` becomes `executed-proba` only after that module's
     cases pass;
  7. a full run reports 26/26 modules at the executed-proba tier before the
     Stage-0.5 row can be marked complete.
- **sanity**: `./scripta/check-proba-coverage` and `git diff --check`.
- **read_scope**: `src/**/*.fab`, `src/**/*.proba`,
  `proof/inventory/triga-inventory.json`, existing scorecard schema, and the
  Faber test CLI contract.
- **non_goals**: source lint, compile-stage replacement, target/browser gates,
  or editing the capability ledger to claim support.
- **risk**: high — this is the evidence authority and must fail honestly.
- **integrable**: yes, but only after all coverage units and Radix routes.

## 7. Integration and validation ownership

No Triga merge gate is needed for the nine disjoint coverage batches; their
`.proba` paths are disjoint. `tgh-s05-c08` consumes the test contracts from
geometry, graph, and material and therefore lands after those units. The gate
is the sole aggregate writer for the scorecard refresh.

The Radix routes are landed owning-repo history, not hidden changes in a Triga
commit. A red Triga proba keeps its module row below `executed-proba`; the gate
must report the failing case and stop. Current residual classes are the later
Triga visibility/export seams, MIR method/projection/path lowering, and
provider-backed runtime cases.

Lane-owned validation, named once:

```bash
cd /Users/ianzepp/work/faberlang/triga
./scripta/check-proba-coverage
./scripta/check-source
./scripta/check-capabilities
./scripta/check-exempla-inventory
./scripta/check-transforms
git diff --check
```

`check-source`, `check-capabilities`, `check-exempla-inventory`, and
`check-transforms` are regression guards. They do not substitute for the
Stage-0.5 executed-proba gate. Broad Stage 1–4 ladder commands remain owned by
their validation lanes and are not child Hand done-when conditions.

## 8. Open questions for Mind

- The two compiler/toolchain routes are landed under the owning-repo boundary:
  `rdx-s05-1` at `9919d480c`, and `rdx-s05-3` through `e56d45f70`,
  `018cc8b25`, and `736b14766`. The recorded official converted three-case math fixture is
  green (`3 passed, 0 failed`); no head-cto architecture fork remains.
- Later Triga visibility repairs (`94c8da7`, `cdf8c0e`, `9d9246c`, `91b3389`,
  `ef48638`, `b8def7c`) are separate from the Radix route. Coverage remains
  open for the affected MIR method/projection/path and provider/runtime
  residuals until the actual module probes pass.
- Setup/teardown syntax is supported by the current grammar. Default policy is
  to use fixtures only where a family needs shared state and to require their
  effects to pass through the same runner gate.
- Facade probas are settled as discovery smokes. They provide module-level
  executed evidence without pretending that map-only facades re-export leaf
  types.
- The executed-proba tier stays **open** until the gate reports 26/26 passing
  modules. Structural compilation, Norma examples, and a dated receipt cannot
  close it.

## 9. Delivery readiness

This artifact is **READY for delivery audit**. It names the live gap, separates
Triga stale-test work from Radix defects, grounds the grammar and package
analyzer paths in source, defines nine disjoint module-family coverage units
covering all 26 modules, and defines an aggregate gate that tracks actual
executed-proba evidence per module.
