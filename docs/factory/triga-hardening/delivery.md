# Triga Hardening — Stage 0 Delivery Spec (live baseline + profile decision + scorecard)

**Status**: delivery — READY for delivery audit
**Date**: 2026-08-16
**Campaign**: [`CAMPAIGN.md`](./CAMPAIGN.md) Stage 0 (discovery-first)
**Goal doc**: `docs/factory/triga-hardening/` (campaign control plane)
**Scope**: delivery — Stage 0 only. No Stage 1+ units, no `src/` edits, no
hosts/radix/cista edits.
**Mode**: direct on `triga` main, path-limited commits.

## 1. Interpreted theme

Stage 0 freezes the *facts* every later hardening stage will route against:
one live, versioned inventory of the real `triga/src` surface; one bounded
supported-profile decision (Core Graphics Profile v0) that answers the
retention-vs-reduction open question with live evidence; and one coverage
scorecard that replaces stale module/test reports. Discovery only — Stage 0
must not correct source, upgrade support claims, or touch the capability
ledger.

## 2. Normalized spec

One delivery-sized outcome: **Stage-0 discovery artifacts, machine-checkable,
grounded exclusively in the live tree.**

Four artifacts (all committed on `triga` main):

1. Live versioned inventory — `proof/inventory/triga-inventory.json`
2. Core Graphics Profile v0 decision — `docs/factory/triga-hardening/profile-v0.md`
   + machine-readable rows `proof/profile-v0.json`
3. Coverage scorecard — `proof/coverage-scorecard.json` (replacing stale
   module/test reports)
4. Stage-0 open-question answers — `docs/factory/triga-hardening/open-questions.md`

Stage-0 gate (campaign §Stage 0) is met when the inventory names all 26 live
modules with public symbols, error/null contracts, tests, ABI fields,
consumers, and evidence tiers; Profile v0 rows are frozen with supported/
unsupported splits, size assumptions, and proof requirements; and the scorecard
contains no stale line number, pre-split symbol, or future module counted as
live.

## 3. Repo-aware baseline (live-grounded)

Verified against the live tree on 2026-08-16. **Docs are not authority here**:
`docs/module-map.md` (S0 size table, target map) and
`docs/factory/test-decomposition-report.md` (pre-split line numbers/symbols)
are stale; the 61/75 figures in `docs/module-map.md` + `docs/factory/triga-engine/`
describe the frozen target horizon, not the live package.

### 3.1 Live module inventory (26 modules, derived by `find src -name '*.fab'`)

| Module | lines | classes | unions | `fn` | imports |
| --- | --- | --- | --- | --- | --- |
| `src/math.fab` | 925 | 18 | 0 | 80 | 0 |
| `src/geometry/data.fab` | 868 | 2 | 1 | 47 | 4 |
| `src/scene.fab` | 687 | 13 | 1 | 30 | 2 |
| `src/resource.fab` | 448 | 5 | 0 | 35 | 0 |
| `src/primitives/basic.fab` | 375 | 0 | 0 | 9 | 3 |
| `src/geometry/batch.fab` | 150 | 6 | 0 | 8 | 0 |
| `src/geometry/attribute.fab` | 141 | 1 | 2 | 8 | 1 |
| `src/geometry/layout.fab` | 133 | 1 | 2 | 2 | 0 |
| `src/material/base.fab` | 112 | 3 | 0 | 9 | 0 |
| `src/graph/camera.fab` | 87 | 4 | 0 | 4 | 2 |
| `src/material/basic.fab` | 62 | 1 | 0 | 7 | 2 |
| `src/shader_contract.fab` | 157 | 0 | 0 | 5 | 0 |
| `src/face.fab` | 46 | 1 | 0 | 2 | 2 |
| `src/lighting/light.fab` | 40 | 4 | 0 | 0 | 2 |
| `src/triga.fab` | 39 | 0 | 0 | 0 | 8 |
| `src/geometry/bounds.fab` | 32 | 2 | 0 | 0 | 0 |
| `src/renderable/mesh.fab` | 32 | 1 | 0 | 0 | 5 |
| `src/graph/object.fab` | 29 | 2 | 0 | 0 | 1 |
| `src/material.fab` | 24 | 0 | 0 | 0 | 4 |
| `src/material/standard.fab` | 23 | 1 | 0 | 0 | 2 |
| `src/geometry.fab` | 22 | 0 | 0 | 0 | 5 |
| `src/material/lit.fab` | 21 | 1 | 0 | 0 | 2 |
| `src/primitives.fab` | 16 | 0 | 0 | 0 | 1 |
| `src/lighting.fab` | 15 | 0 | 0 | 0 | 1 |
| `src/graph.fab` | 13 | 0 | 0 | 0 | 2 |
| `src/renderable.fab` | 13 | 0 | 0 | 0 | 1 |
| **Total** | **4510** | **66** | **6** | **246** | **50** |

Faber count method (live syntax): `class`/`union` declarations at line start,
`fn name(` at line start (indentation allowed), counted for
non-underscore/public functions only — 282 `fn name(` lines minus 36
underscore-private (`fn _`) = 246 — and `import from` lines. Totals are
instantiated at inventory build time by
`proof/inventory/derive-inventory.sh`, never hand-typed.

### 3.2 Test / evidence surface (live)

- Only co-located proba: `src/math.proba` (27 lines, 3 cases: `addita`,
  `normata`, `normata` zero). Every other public leaf has none.
- Exempla inventory (live): 15 documented exempla listed in
  `exempla/README.md` + `conformance/` subdir; `check-exempla-inventory`
  enforces README ⇄ files agreement.
- No typed public error channel: zero occurrences of the `⇥ E` failable-return
  pattern and zero `iace` call sites in `src/`. Failures collapse to `bool` or
  `∪ null` (Option). `null` is used for genuine absence and recoverable
  failure indistinguishably today.
- `faber test [PATH]` (MIR proba runner) exists on the live sibling faber
  binary (`radix/target/debug/faber`) but is **not green in-repo**:
  `faber test .` → `cannot read '.'` (os error 2); `faber test src/math.proba`
  → SEM001/SEM008 undefined-identifier cascade. The executed-proba tier is
  therefore OPEN; the packaging/finder gap routes to the faber package-test
  surface (see open-question records).

### 3.3 ABI / contract seam (live)

- Frozen ABI fields live on shader-contract adapters (`src/shader_contract.fab`:
  `vertex_layout_matches`, `varying_matches`, `fragment_output_matches`,
  `pipeline_matches`, `resource_binding_matches`) and geometry fact methods
  (`index_format_code()`, `topology_code()` in `src/geometry/data.fab`). The
  committed `tgh-s0-1` inventory derives **172 ABI field occurrences** from
  `_code` (109), `offset_bytes` (20), `stride_bytes` (22), and `source_name`
  (21); the authoritative total is
  `proof/inventory/triga-inventory.json:totals.abi_field_occurrences`, not a
  hand-typed claim.
- Transform ABI drift (confirmed live): `src/math.fab`
  `TransformPayload` contract — 32 f32 / 128 bytes (documented canonical);
  `hosts/webgpu-browser/public/generated/graphics-reflection.json` transform
  binding — `element_count: 64`, `buffer_byte_len: 256`. Two independent
  authorities; resolution is Stage 7, recorded here as a baseline fact.
- `SceneStore.continet` (`src/scene.fab:103`) guards only the upper handle
  bound (`index ≥ slots.length()`), not negative indexes.
- Newton loops without finite guard: `_radix_f32` (`src/math.fab:705`, `≤ 0.0 →
  0.0` clamp, NaN propagates), `_geometry_radix_f32` (`src/geometry/data.fab:816`),
  `_primitives_radix_f32` (`src/primitives/basic.fab:356`). `Matrix4` carries
  `list<f32> elements`; `determinans_affinis()` indexes fixed positions without
  first enforcing length.

### 3.4 Scripta / faber surface (verified live, 2026-08-16)

- `./scripta/check-source` — lint gate (currently exit 0). Scans only the
  selected receiver-method vocabulary, not the full exported surface (gap
  recorded, fixed in Stage 1).
- `./scripta/check-compile` — `radix check --locale en <leaf>` per module
  (manual leaf list that omits `lighting.fab`, `renderable.fab`,
  `material/{base,basic,lit,standard}.fab`, `primitives/basic.fab`,
  `renderable/mesh.fab`), then `faber check` + `faber build` on
  `exempla/triga-scene-store.fab`, then `scripta/check-transforms` +
  `scripta/check-exempla-inventory`.
- `./scripta/check-exempla-inventory` — README⇄files agreement + `radix check`
  on every exempla + `faber run --target rust --compile` with the documented
  radix-emitter E0308/E0425 allowlist.
- `./scripta/check-transforms` — package-aware transform-chain gate.
- `./scripta/check-capabilities` — validates `proof/capabilities.json`:
  all 32 broad proofs `unsupported`, score 0/100, 0/11 floors, 5/5 capstones
  unmanifested/unsupported. Ledger is unchanged in Stage 0.
- `./scripta/check-wgsl-shader-contract-conformance` — pins radix
  `41b4c0411` (revision-pinned; Stage 1 replaces with contract assertion).
- Faber CLI subcommands (live, `radix/crates/faber/src/cli/mod.rs`):
  `check`, `build`, `run --target rust --compile`, `test`, `format`.
  In-scripta invocation surface: `cargo run --manifest-path
  "$FABER/Cargo.toml" -- check|build|run --target rust --compile <file>`.

### 3.5 Profile-row evidence (feeds the v0 decision)

| Default profile row | Live source fact | State today |
| --- | --- | --- |
| Perspective camera | `PerspectiveCamera` + `projectio()` / `visus_projectio()` + facts genera, `src/graph/camera.fab` | constructible, no proba |
| Indexed triangle geometry | `indexed_triangle_geometry`, `src/geometry/data.fab:722` | constructible, proba absent |
| Position/normal/UV attributes | `BufferAttribute` + `float32_attribute`, `geometry/data`; `vertex_normals()`/`planar_uvs()` receivers `src/geometry/data.fab:491,569` | constructible, proba absent |
| Model/view-projection transforms | `TransformPayload`, `matrix4_*`, `src/math.fab` | 32/128 vs hosts 64/256 drift |
| Depth/culling policy | `pipeline_matches(depth_compare_code, depth_write_enabled_code, …)` `src/shader_contract.fab:88` | adapter facts only |
| One lit material path | `MeshPhongMaterial` (`src/material/lit.fab`) — carrier only, no constructor/validation | shape only |
| Ambient/directional lighting | `AmbientLight`/`DirectionalLight` (`src/lighting/light.fab`) — carriers only | shape only |
| Resize/device-loss | no Triga surface; hosts execution (no-draw placeholder state) | hosts-owned, unproven |

Every default-profile row has a live source fact in the 26-module tree: the
row set does not force inventing modules. Execution gaps (carrier-only
composition, no draw, ABI drift) are owned by later stages (5/7) as proof
requirements, not by a profile reduction.

### 3.6 Package / release facts (live)

- `faber.toml`: package `triga` 0.2.0, locale `en`, targets rust+ts.
- `cista.toml`: source package `triga` 0.2.0.
- All 5 corpus packages (`corpus/*/faber.toml`) depend on `triga = "0.1.0"`.
- No git tags, no `LICENSE`, no `.github/workflows`, no changelog.

## 4. Hand unit graph

All units are docs/JSON/proof artifacts. Every unit lands alone on `triga`
main (path-limited commit). No unit needs a worktree or a merge gate.

| id | outcome | write_scope | depends_on | risk | integrable |
| --- | --- | --- | --- | --- | --- |
| `tgh-s0-1` | Live versioned inventory created + validator green | `triga/proof/inventory/` (new) | — | low | yes |
| `tgh-s0-2` | Core Graphics Profile v0 frozen (retention-vs-reduction answered, rows + proof requirements) | `triga/docs/factory/triga-hardening/profile-v0.md`, `triga/proof/profile-v0.json` | `tgh-s0-1` (read) | medium | yes |
| `tgh-s0-3` | Coverage scorecard live; stale reports annotated | `triga/proof/coverage-scorecard.json`, `triga/proof/coverage/` (new); archive banners on `triga/docs/module-map.md`, `triga/docs/factory/test-decomposition-report.md` | `tgh-s0-1` (read) | low | yes |
| `tgh-s0-4` | Open-question record: Stage-0 answers + stage routings | `triga/docs/factory/triga-hardening/open-questions.md` | `tgh-s0-1`, `tgh-s0-2` (read) | low | yes |

### Unit `tgh-s0-1` — Live versioned inventory

- **outcome**: one machine-readable, versioned inventory of the complete live
  `src/` surface, derived from the live tree (generation is the source of
  truth; hand-typed counts forbidden).
- **write_scope** (exact): `triga/proof/inventory/` only (new directory):
  - `derive-inventory.sh` — walks `src/**/*.fab` + `src/**/*.proba` via
    `find`, counts per module: lines, `class`/`union`, `fn name(` at line
    start (non-underscore/public only, per §3.1), `import from` lines,
    null-returning `fn`s (`∪ null` in signature),
    co-located proba refs, `_code`/ABI field occurrences; captures `git
    rev-parse HEAD`, `faber.toml`/`cista.toml` versions, and generation
    timestamp. Shell+awk only, no external tools.
  - `triga-inventory.json` — committed output. Schema
    `inventory_schema_version: 1`, `inventory_revision: 1`; top-level: 26
    modules, tuple counts, error/null contract summary, co-located tests,
    ABI field occurrences, consumer import map, per-module evidence tier
    (default `structural`; `executed-proba` where a co-located proba exists).
  - `check-inventory` — validator: re-derive and compare (module set must
    equal the live 26; per-module counts must match the live tree; JSON
    schema field names fixed). Exit non-zero on any mismatch or on any
    module not present in `find src` output (no stale/future modules).
  - `README.md` — regenerate + check instructions.
- **read_scope**: `triga/src/**`, `triga/faber.toml`, `triga/cista.toml`,
  `triga/exempla/` (for consumer refs).
- **done_when**: `./proof/inventory/check-inventory` exits 0; re-running
  `./proof/inventory/derive-inventory.sh` produces a byte-identical
  `triga-inventory.json` (git diff clean); JSON lists exactly the 26 live
  modules with the §3.1 counts and per-module contract/proba/ABI/consumer/
  evidence-tier fields; `git diff --check` clean; committed path-limited on
  `triga` main.
- **sanity** (Hand, one narrow check): `./proof/inventory/check-inventory`.
- **non_goals**: `scripta/` edits (Stage 1), `src/` edits, `proof/capabilities.json`
  edits, corpus/README/lint-policy changes.
- **risk**: low — derived data, validator only reads.

### Unit `tgh-s0-2` — Core Graphics Profile v0 decision

- **outcome**: the retention-vs-reduction open question answered with live
  evidence; Profile v0 frozen with supported/unsupported rows, profile-size
  assumptions, and per-row proof requirements; machine-readable rows file
  that later stages (7–8) can consume.
- **write_scope** (exact):
  - `triga/docs/factory/triga-hardening/profile-v0.md` (authoritative decision)
  - `triga/proof/profile-v0.json` (rows mirror; `profile_schema_version: 1`)
- **read_scope**: `triga/src/**` (§3.5 row evidence),
  `hosts/webgpu-browser/public/generated/graphics-reflection.json` and
  `hosts/webgpu-browser/public/src/contract/artifact-admission.js` +
  `.../engine/engine.js` (no-draw state, read-only),
  `faber/docs/EBNF.md` (fixed-size matrix capability).
- **done_when**: the decision, stated as **retain** (see content requirements),
  is on record with the §3.5 evidence table; supported rows = perspective
  camera, indexed triangle geometry (position/normal/UV), model/view-projection
  transforms, depth/culling policy, one lit material (`MeshPhongMaterial`, not
  PBR), ambient+directional lighting; unsupported rows name the broad horizon
  explicitly (PBR `MeshStandardMaterial`, `PointLight`, textures, animation/
  skinning, shadows, post-processing, instancing, terrain/voxel, asset
  ingestion); profile-size assumptions documented *as assumptions for a
  bounded draw proof* (single small scene, one camera, one directional light,
  ≤ one lit mesh, no textures) — explicitly not the Stage 8 stress budget;
  each supported row carries a proof requirement + owning stage (3/5/7) and
  evidence level (executed-proba → target-equivalence → browser-numeric/pixel);
  the doc states `proof/capabilities.json` rows remain `unsupported` until
  Stage 8; `profile-v0.json` mirrors the doc rows; every module/function cited
  exists in `triga-inventory.json`; `git diff --check` clean; committed
  path-limited.
- **sanity** (Hand): cross-check all cited symbols against
  `proof/inventory/triga-inventory.json` (script or grep; must name no
  pre-split symbol or non-existent module); `./proof/inventory/check-inventory`
  still exits 0.
- **non_goals**: editing `proof/capabilities.json` or any capstone manifest
  (ledger updates are Stage 8 only); host/radix edits; any change to
  `src/`; inventing rows without a live source fact.
- **risk**: medium — the decision is evidence-justified but is the audit
  centerpiece; audit is the delivery audit (Mind dispatch), not a Hand gate.

### Unit `tgh-s0-3` — Coverage scorecard

- **outcome**: a live coverage scorecard that replaces the stale module/test
  reports, with a machine check that guarantees no stale line number,
  pre-split symbol, or future module is counted as live.
- **write_scope** (exact):
  - `triga/proof/coverage-scorecard.json` — one row per live module (keyed by
    module path from inventory): lines, symbol counts, co-located proba refs,
    exempla coverage refs (from `exempla/README.md` + `check-exempla-inventory`
    truth), evidence tier (fixed enum below), stale-claim list (every stale
    doc claim superseded in this stage, with its stale source).
  - `triga/proof/coverage/derive-scorecard.sh` — derives the module row frame
    from `triga-inventory.json`.
  - `triga/proof/coverage/check-scorecard` — validator, exit non-zero when:
    any module key absent from the live inventory module set; any symbol
    reference absent from the inventory's symbol table; any test/exempla
    reference to a nonexistent file; any evidence tier outside
    `structural|executed-proba|target|browser-numeric-pixel|stress|clean-install`;
    any stale-claim text containing `61 non-facade|75 import|pre-split|future`
    counted in a live field.
  - Archive banners only (no content rewrite) on the stale sections of
    `triga/docs/module-map.md` (§Size, §Target map) and
    `triga/docs/factory/test-decomposition-report.md`:
    "live coverage data superseded by `proof/coverage-scorecard.json`
    (2026-08-16); this section is archival".
- **read_scope**: `triga/src/**`, `triga/exempla/**`, `triga/proof/inventory/**`.
- **done_when**: `./proof/coverage/check-scorecard` exits 0; scorecard has
  26 live rows; `rg -n "61 non-facade|75 import" docs/` matches only the
  documented frozen-correction and archival claims (campaign validation rule,
  §Validation); archive banners present; `git diff --check` clean; committed
  path-limited.
- **sanity** (Hand): `./proof/coverage/check-scorecard` +
  the campaign `rg` validation pair.
- **non_goals**: rewriting the module-map or decomposition-report content;
  editing `proof/capabilities.json`; src edits; new docs.
- **risk**: low — machine-verified enumeration; low risk of a validator
  drifting (nothing is weakened; checks only enumerate).

### Unit `tgh-s0-4` — Stage-0 open-question answers

- **outcome**: every campaign open question either answered at Stage 0 with
  live evidence or routed to its named stage as a recorded question.
- **write_scope** (exact): `triga/docs/factory/triga-hardening/open-questions.md`.
- **read_scope**: live tree evidence collected in §3 of this spec +
  `docs/factory/triga-hardening/CAMPAIGN.md` §Open Questions,
  `profile-v0.md` (from `tgh-s0-2`).
- **done_when**: all 8 campaign open questions present with status
  `answered` or `routed`:
  - Q1 profile (retention-vs-reduction): **answered** → retain (see
    `profile-v0.md`; sync text referenced, not duplicative).
  - Q2 NaN/Infinity policy default: **answered** (policy default = reject
    non-finite public inputs via typed errors at Stage 2; named degenerates
    preserved — `_radix_f32` clamps `≤0 → 0` but propagates NaN,
    `Quaternion.normata()` zero-length → identity `(0,0,0,1)`,
    `Vector3.normata()` zero → zero vector); the per-operation table is a
    **routed** Stage 2 unit.
  - Q3 fixed-size matrix/transform storage: **answered** — live Faber has a
    fixed-size register matrix type `matrix<T,[R,C]>` (see
    `faber/docs/EBNF.md` type table); live carriers are `list<f32>` today,
    so Stage 2/3 owns the migration-vs-checked-construction decision with an
    available language path (ABI `_code` integers are separate facts and stay
    frozen).
  - Q4 `faber test .` proba gap: **answered** — currently does NOT run
    co-located proba; record the live symptoms verbatim (`faber test .`
    `cannot read '.'`; `faber test src/math.proba` SEM001/SEM008 cascade);
    executed-proba tier stays **open**; the packaging/finder gap is a
    **routed** Radix-faber unit (Stage 1 canonical gate owns the final
    contract).
  - Q5 `ResourceHandle` boundary: **answered** at the live-fact level —
    `src/resource.fab` has zero imports, no backend object in any public
    genus (pure generation identity); Hosts is the sole allocation/disposal
    authority by construction. The formal boundary statement is a Stage 4
    deliverable and the Stage 7 proof proves replacement/teardown/device-loss;
    both **routed**.
  - Q6 published Faber artifact for public CI: **routed** to Stage 1
    (public-CI posture) and Stage 6 (clean-install evidence); operator/
    product boundary, no published artifact exists today.
  - Q7 license: **routed** to Stage 6; operator-selected, the campaign must
    not invent one.
  - Q8 stress contract values: **routed** to Stage 8 (freezes values before
    measuring); profile-size *assumptions* (not budgets) are in `profile-v0.md`.
  - Each `routed` entry names its owning stage and stays a recorded question
    in this file until the owning stage closes it.
  - `git diff --check` clean; committed path-limited.
- **sanity** (Hand): `git diff --check`; confirm every `routed` entry names a
  stage.
- **non_goals**: answering questions owned by later stages with invented
  values; editing campaign docs or `src/`.
- **risk**: low.

## 5. Integration / merge gate

None. All four units are additive docs/JSON/proof artifacts; each is
integrable alone on `triga` main in direct mode. No cross-repo write.

## 6. Lane-owned validation (named once, not copied onto Hands)

- **Lint (stages 1–2)** — run after the Stage-0 units land:
  `./scripta/check-source`; `./scripta/check-capabilities` (must stay green —
  ledger untouched); `git diff --check`. Note: `./scripta/check-source` and
  `check-capabilities` read `src/` and `proof/capabilities.json` respectively
  and are unaffected by docs/JSON units, so they are regression guards, not
  per-Hand gates.
- **Test (stages 3–4)** — not required by Stage 0's docs-only surface; if run,
  `./scripta/check-compile`, `./scripta/check-exempla-inventory`,
  `./scripta/check-transforms` must remain unchanged (no `src/` edits in this
  stage). The faber test/proba tier stays open until the Stage 1 canonical
  gate and the routed faber gap unit land.
- **Evidence audit** — the Stage-0 gate ("delivery audit" per assignment):
  independently verifies (a) inventory is live-only (module set == 26 derived
  from `find src`, no 61/75 counts), (b) Profile v0 rows are frozen with
  supported/unsupported splits + size assumptions + proof requirements and
  `capabilities.json` untouched, (c) scorecard check rejects stale line
  numbers / pre-split symbols / future modules, (d) open-question record has
  every question answered or routed. Auditors read `check-*` outputs and the
  generated JSONs; they never edit product code.

## 7. Open questions for Mind

- Commit shape: CAMPAIGN.md lands with this Stage-0 closeout, alongside the
  delivery receipt record; no separate campaign-document commit is needed.
- Stage-0 audit dispatch: recommend one auditor pass over `tgh-s0-1` +
  `tgh-s0-2` evidence (inventory derivation + profile decision), per the
  campaign's correctness/requirements-review rule.
- The faber test gap (Q4) will need a Radix-side unit once Stage 1's canonical
  gate names the exact parse/package route; the recorded symptoms in
  `tgh-s0-4` are the evidence handoff.

## 8. Stage 0 closeout receipts

Stage 0 landed on `triga` main. The four delivery units are recorded by their
commits:

| unit | receipt | landed outcome |
| --- | --- | --- |
| `tgh-s0-1` | `8dade06` | Live versioned inventory and validator |
| `tgh-s0-2` | `2e9daa0` | Core Graphics Profile v0 decision frozen |
| `tgh-s0-3` | `93750a3` | Live coverage scorecard and stale-report annotations |
| `tgh-s0-4` | `0dbf376` | Stage-0 open-question answers and routings |

The derived ABI figure for this closeout is **172 ABI field occurrences**,
from the committed inventory (`_code` 109, `offset_bytes` 20, `stride_bytes`
22, `source_name` 21). The inventory remains the source of truth for this
figure and for future regenerated counts.