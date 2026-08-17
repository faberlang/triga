# Triga Hardening — Stage 1 Delivery Spec
## Canonical validation and continuous-evidence spine (gate-independent units)

**Status**: delivery — five gate-independent units landed on triga main
2026-08-17 (hands 10/13/15: complete-genus source lint `1172762`;
all-26-leaf compile + sibling Radix faber CLI `5eb7971`; WGSL pin retirement
`a01cc28`; no-Faber public CI `2fe90f5`; canonical `./scripta/check` + AGENTS
pointer `7c6caf4`). The hard-green executed-proba rung (`tgh-s1-proba-rung`)
remains **not lowered** until `tgh-s05-gate` reads 26/26; the known-red list
(source-lint [intentional], exempla PARSE050, proba 22/26, WGSL PARSE family)
stays documented in the campaign and in §1 below.
**Date**: 2026-08-17
**Planner**: `planner` handle `80460d33`
**Campaign**: [`CAMPAIGN.md`](./CAMPAIGN.md) Stage 1
**Landed prior**: Stage 0 (`delivery.md`); Stage 0.5 sources c01–c09 (`stage-0-5-delivery.md`); Stage 1 units per the status line above
**Blocked prior**: `tgh-s05-gate` — not a start dependency for these units
**Repository**: `/Users/ianzepp/work/faberlang/triga`
**Scope**: Triga `scripta/`, public-CI workflow, API-shape lint policy, WGSL
ledger pin retirement, and AGENTS validation pointer. No `src/**/*.fab`
implementation repair. No remasure of the Stage-0.5 scorecard.

## 0. Goal-check (Stage 1)

| Field | Value |
| --- | --- |
| Artifact | `docs/factory/triga-hardening/CAMPAIGN.md` §Stage 1 |
| Evaluator mode | cold self-pass against live `scripta/` and the scorecard ledger |
| Intended consumer | delivery (this spec) |
| Verdict | **READY** for gate-independent Stage 1 units |

**Reasoning.** Stage 1’s end state is one local/CI spine that discovers every
live leaf and proba, uses the current sibling Radix/Faber product CLI, executes
what the toolchain can execute, and labels every other tier honestly. Those
architecture locks are already in the campaign (split-on-boundary; sibling
Radix for local work; public CI must not pretend a private checkout is
consumable). The live scripts name the exact starting files. The blocked
`tgh-s05-gate` 22/26 receipt is an executed-proba closeout, not a missing Stage 1
design.

**Key points**

- Desired end state is a spine, not 26/26 green probas.
- Live compile/WGSL scripts still target a retired public-`faber` Cargo layout
  and a hardcoded 18-leaf list / revision pin — those are the Stage 1 repairs.
- Q6 (published Faber artifact) is answered: none exists; public CI reports
  that gap. It does not block local spine work.
- Campaign Current State still says “one `.proba`, three Vector3 cases.” That
  claim is stale against the 26 sibling `.proba` files. It does not change the
  Stage 1 write path.
- `tgh-s05-gate` 26/26 is an explicit dependency of a later hard-green
  executed-proba rung. That rung is named and **not** lowered here.

**Recommended next step:** file the five units in §4. Do not wait for
`tgh-s05-gate` to go green before those Hands start.

> **Landing note (2026-08-17).** The five units in §4 all landed on triga main
> via hands 10/13/15 (`1172762`, `5eb7971`, `a01cc28`, `2fe90f5`, `7c6caf4`).
> The "Today:" baseline below describes the pre-landing state those units
> repaired; the live `./scripta/check` spine and its known reds are documented
> in the CAMPAIGN Current State table and §7. Keep `tgh-s1-proba-rung`
> unlowered until `tgh-s05-gate` is 26/26.

## 1. Interpreted theme

Stage 1 replaces the obsolete validation checkout with one honest spine.

Today:

- `scripta/check-source` walks every file but only rejects a selected
  genus-prefix vocabulary, so resource/material free-function families are
  invisible to the lint.
- `scripta/check-compile` hardcodes 18 of 26 leaves and looks for
  `faber/Cargo.toml` beside Triga. That file does not exist. The product CLI
  is `radix/crates/faber`.
- `scripta/check-wgsl-shader-contract-conformance` still pins Radix
  `41b4c0411` and fails on later `crates/` drift. It also uses the same missing
  public-`faber` Cargo path.
- There is no committed workflow and no single command that labels structural,
  executed-proba, WGSL, and public-execution tiers.

Stage 0.5 already added the 26 sibling `.proba` files and the package-link
gate `scripta/check-proba-coverage`. That gate’s last committed receipt is
**blocked at 22/26** (`complete: false`). Stage 1 must invoke that gate and
label the blocked receipt honestly. Stage 1 must not turn 22/26 into a skip,
must not remasure or repair `src/**/*.fab`, and must not wait for 26/26
before repairing the spine.

## 2. Normalized spec

One delivery-sized outcome:

> One canonical local command discovers every live `src/**/*.fab` and sibling
> `.proba`, checks source shape against the full exported surface, typechecks
> every live leaf through the sibling Radix/Faber product route, asserts WGSL
> contract behavior without a repository-revision pin, and writes or prints a
> per-tier label. A committed public workflow runs every tier that does not
> need a private checkout and names the missing published-Faber dependency for
> the rest.

Non-goals:

- no `src/**/*.fab` API migration (Stage 2 owns receiver-method alignment)
- no weakening, deleting, or skipping red proba cases
- no remasure / refresh of `proof/coverage-scorecard.json`
- no claim that `tgh-s05-gate` is complete
- no invented published Faber artifact
- no private Radix checkout in public CI
- no capability-ledger upgrade
- no browser, target-equivalence, stress, or clean-install claim
- no Radix implementation in the Triga checkout

### Locked routing vs `tgh-s05-gate`

| Claim | Owner | Stage 1 consequence |
| --- | --- | --- |
| 26 sibling `.proba` sources exist | Stage 0.5 c01–c09 (landed) | discover them; do not re-author |
| executed-proba **22/26**, status `blocked`, `complete: false` | `tgh-s05-gate` ledger | invoke the gate; report the blocked receipt honestly |
| 26/26 executed-proba + `complete: true` | `tgh-s05-gate` close | **not** a start dependency; named as `tgh-s1-proba-rung` |
| Spine cannot find a leaf, cannot invoke sibling `faber`, or pins a revision | Stage 1 | must fix before Stage 1 closes |
| Per-module MIR / assertion reds on the 4 remaining rows | `tgh-s05-gate` + owning Radix residual units | report honestly; do not fix in Stage 1 Hands |

Default: Stage 1 campaign close is the spine, not 26/26. The campaign sentence
“compiler/CLI defects must land before this stage closes” applies to defects
that break the spine, not to every remaining module red.

## 3. Repo-aware baseline (live, not remasured)

> **Capture note.** This section is the pre-landing baseline (as of this
> spec's receipt `54e4c65`). The units in §4 landed on 2026-08-17 via hands
> 10/13/15; claims below that the compile route hardcodes leaves, requires a
> missing `../faber/Cargo.toml`, pins a revision, or says no CI/workflow exists
> describe the retired state and are superseded by the landed spine (see §1
> landing note and the CAMPAIGN Current State table).

### 3.1 `tgh-s05-gate` ledger (read first; not remasured)

This spec rebases the Stage 1 baseline off the retired 9/26 freeze onto the
live `54e4c65` receipt.

Source of truth: `proof/coverage-scorecard.json` object `stage0_5`, coverage
revision 2, receipt `run_at_utc = 2026-08-17T17:58:11Z` (commit `54e4c65`,
Faber `/Users/ianzepp/work/faberlang/worktrees/hand-35/radix/target/debug/faber`).

| Field | Ledger value |
| --- | --- |
| `unit` | `tgh-s05-gate` |
| `status` | `blocked` |
| `complete` | `false` |
| `module_count` | 26 |
| `proba_source_count` | 26 |
| `executed_module_count` | **22** |
| `executed_tier` | `executed-proba` |
| `filter_mode` | `package-include-per-proba` |
| `discovery_errors` | `[]` |
| `prerequisites.rdx-s05-1` | `not-observed` |
| `prerequisites.rdx-s05-3` | `unresolved` |

The `prerequisites` fields are receipt-derived heuristics inside
`scripta/check-proba-coverage`, not a reopening of the landed Radix routes
`9919d480c` / `018cc8b25` / `736b14766`. Do not treat them as a new Stage 1
Radix fork.

**22 executed-proba rows:** `src/face.fab`, `src/geometry.fab`,
`src/geometry/attribute.fab`, `src/geometry/batch.fab`,
`src/geometry/bounds.fab`, `src/geometry/data.fab`, `src/geometry/layout.fab`,
`src/graph.fab`, `src/graph/camera.fab`, `src/graph/object.fab`,
`src/lighting.fab`, `src/lighting/light.fab`, `src/material.fab`,
`src/material/basic.fab`, `src/math.fab`, `src/primitives.fab`,
`src/primitives/basic.fab`, `src/renderable.fab`, `src/renderable/mesh.fab`,
`src/resource.fab`, `src/shader_contract.fab`, `src/triga.fab`.

**4 runner-failure rows** (ledger text, not remasured):

| Module | First recorded failure |
| --- | --- |
| `src/material/base.fab` | assertion: texture descriptor preserves its placeholder shape |
| `src/material/lit.fab` | assertion: Phong defaults remain explicit carrier values |
| `src/material/standard.fab` | assertion: standard defaults remain explicit carrier values |
| `src/scene.fab` | `invalid MIR: option unwrap operand is not nullable` |

Stage 1 Hands must not remasure the scorecard and must not repair
`src/**/*.fab`.

### 3.2 Compile gate (live `scripta/check-compile`)

Hardcoded leaves (18): `math`, `graph`, `material`, `face`, `geometry`,
`primitives`, `scene`, `resource`, `triga`, `shader_contract`, `graph/object`,
`graph/camera`, `lighting/light`, `geometry/{layout,bounds,batch,attribute,data}`.

Omitted live modules (8): `lighting`, `material/{base,basic,lit,standard}`,
`primitives/basic`, `renderable`, `renderable/mesh`.

Faber resolution: `$ROOT/../faber/Cargo.toml` then `$ROOT/../../../faber`.
Neither path exists. Product CLI: `radix/crates/faber` (`faber` 1.7.0).
Built binaries exist at `radix/target/{debug,release}/faber`.
`check-proba-coverage` already defaults to
`$FABER_LIBRARY_HOME/radix/target/release/faber`.

Radix leaf checks use `radix check --locale en` (correct locale). The Faber
`cargo run --manifest-path "$FABER/Cargo.toml"` scene-store path is the broken
checkout assumption.

### 3.3 Source lint (live `scripta/check-source`)

Already walks `src/**/*.{fab,proba}`. Enforces comments, retired annotations,
route-call syntax, retired optional fields, and a **selected** genus-prefix
list: `vector[234]`, `box3`, `matrix[34]`, `quaternion`, `euler`, `sphere`,
`plane`, `ray`, `scene`, `geometry`, `transform_payload`.

Live free-function families **not** in that list include `resource_*` and
`material_*` / `mesh_basic_material_*` (and the same shape on other material
leaves). Expanding the lint to the complete exported surface will go red on
those families. That red is Stage 1 evidence. Stage 2 migrates the APIs.

### 3.4 WGSL gate (live `scripta/check-wgsl-shader-contract-conformance`)

Pin `41b4c0411` plus `git diff $PIN HEAD -- crates/` must be empty. Ledger:
`docs/factory/wgsl-shader-contract-boundary/ledger.md`. Corpus: seven
`exempla/conformance/shader-contract/*.fab` programs plus
`exempla/triga-stage4-source-facts.fab`, emitted with `faber emit -t wgsl-text`
and Naga-validated. Naga remains a hard requirement. The Faber binary is built
from the same missing public-`faber` Cargo path.

### 3.5 Public CI

`triga/.github/` does not exist. Q6 remains: no published Faber artifact.
`scripta/check-capabilities` is Python over `proof/capabilities.json` and
needs no Faber. `scripta/check-source` is bash/grep and needs no Faber.

### 3.6 Canonical command

No wrapper exists. `AGENTS.md` §Validation names only `check-source` and
`check-compile`. Campaign §Validation still lists the pre-Stage-1 rungs and
says Stage 1 defines the final command.

## 4. Hand unit graph (gate-independent only)

All five units write only the listed paths. `tgh-s1-1` through `tgh-s1-4` are
disjoint and may run in parallel. `tgh-s1-5` is serial after them.

### `tgh-s1-1` — complete exported-surface source lint

- **outcome**: `check-source` derives or enumerates the full live public genus
  set and rejects genus-prefixed free functions on that complete surface, with
  the existing constructor / scalar / documented-adapter exemptions.
- **write_scope**: `triga/scripta/check-source`,
  `triga/docs/api-shape-policy.md` (§5 Naming Lint only)
- **done_when**:
  1. every live public genus name that appears in
     `proof/inventory/triga-inventory.json` is subject to the prefix rule, or
     the script derives that set from the live tree so a new genus cannot stay
     invisible;
  2. existing exemptions (`scene_store(`, `matrix4_identitas(`,
     `geometry_vertex_layout_matches(`, …) remain explicit in policy §5;
  3. at least the live `resource_*` and `material_*` /
     `mesh_basic_material_*` free-function families are reported as lint
     failures (the spine now sees them);
  4. no `src/**/*.fab` symbol is renamed or moved.
- **depends_on**: none
- **sanity**: `./scripta/check-source` (expected non-zero on the known
  resource/material families)
- **read_scope**: `src/**/*.fab`, `proof/inventory/triga-inventory.json`,
  `docs/api-shape-policy.md`
- **non_goals**: Stage 2 receiver-method migration; new exemptions that hide
  the known families; proba edits
- **risk**: medium — other campaigns treat `check-source` as a green gate;
  the new red is intentional and must be named in the commit message
- **integrable**: yes

### `tgh-s1-2` — compile gate: all live leaves + sibling product CLI

- **outcome**: `check-compile` typechecks every live `src/**/*.fab` via
  `find`, and invokes the sibling Radix product `faber` the same way
  `check-proba-coverage` does (`FABER_BIN` or
  `$FABER_LIBRARY_HOME/radix/target/{release,debug}/faber`). The missing
  public-`faber/Cargo.toml` path is gone.
- **write_scope**: `triga/scripta/check-compile`
- **done_when**:
  1. omitted leaves `lighting`, `material/{base,basic,lit,standard}`,
     `primitives/basic`, `renderable`, `renderable/mesh` are checked;
  2. adding a 27th `.fab` is discovered without a script edit;
  3. default Faber/Radix resolution does not require
     `../faber/Cargo.toml`;
  4. `radix check --locale en` remains the per-leaf structural command;
  5. existing exempla / `check-transforms` / `check-exempla-inventory` rungs
     still run; FHIR/self-exempla comments are not weakened.
- **depends_on**: none
- **sanity**: `RADIX_ROOT=../radix FABER_LIBRARY_HOME=.. ./scripta/check-compile`
  after the path fix (Hand may use the in-workspace debug/release binary;
  do not add `--stage` / `--full`)
- **read_scope**: live `src/**/*.fab`, `radix/crates/faber`, current script
- **non_goals**: executed-proba, WGSL pin, public CI, exempla rewrite
- **risk**: medium — complete leaf discovery can surface check failures the
  old list hid; report them, do not drop leaves
- **integrable**: yes

### `tgh-s1-3` — WGSL contract assertion, no revision pin

- **outcome**: the WGSL suite asserts emitted-contract behavior (the seven
  conformance programs + source-facts fixture + Naga) against the current
  sibling Faber binary. Repository-revision and `crates/`-delta checks are
  removed. The ledger records the pin as retired.
- **write_scope**:
  `triga/scripta/check-wgsl-shader-contract-conformance`,
  `triga/docs/factory/wgsl-shader-contract-boundary/ledger.md`
- **done_when**:
  1. `PINNED_RADIX_REV` / `crates/` drift exit paths are gone;
  2. Faber resolution matches `tgh-s1-2` / `check-proba-coverage`
     (`FABER_BIN` or sibling `radix/target/.../faber`);
  3. Naga remains a hard requirement;
  4. the seven programs and the source-facts fixture still run as contract
     assertions;
  5. the ledger states that Stage 1 retired the pin in favor of live
     contract assertions; no silent rebuild story remains.
- **depends_on**: none
- **sanity**: `FABER_BIN=<sibling faber> ./scripta/check-wgsl-shader-contract-conformance`
- **read_scope**: `exempla/conformance/shader-contract/`,
  `exempla/triga-stage4-source-facts.fab`, current ledger
- **non_goals**: new conformance cases; adapter/`src/shader_contract.fab`
  edits; remasure of proba
- **risk**: medium — live Radix may fail an old WGSL needle; fail honestly,
  do not delete the assertion
- **integrable**: yes

### `tgh-s1-4` — public-CI posture and committed workflow

- **outcome**: a committed workflow runs every currently available
  no-Faber tier and names the unpublished-Faber dependency for every skipped
  tier. Private Radix is never cloned or implied.
- **write_scope**: `triga/.github/workflows/` (new), and at most a short
  pointer in `triga/AGENTS.md` §Validation if the workflow name must be
  cited. Prefer putting the canonical-command pointer in `tgh-s1-5` and
  keeping this unit workflow-only when possible.
- **done_when**:
  1. `.github/workflows/` exists and runs on pull_request / push to `main`;
  2. available-now rungs include `./scripta/check-source` and
     `./scripta/check-capabilities` (no Faber);
  3. `check-compile`, `check-proba-coverage`, and
     `check-wgsl-shader-contract-conformance` are either skipped with an
     explicit “public-execution tier open: no published Faber artifact
     (hardening Q6)” message, or run only if a published artifact is
     actually present — they must not check out `radix/`;
  4. a red `check-source` after `tgh-s1-1` is allowed and labeled
     `structural`; it must not be `continue-on-error`’d into a fake green
     unless the job still reports the non-zero and the workflow conclusion
     distinguishes “spine lint red (expected until Stage 2)” from “missing
     script”;
  5. the workflow never presents a private checkout as public consumability.
- **depends_on**: none (may land before `tgh-s1-1`; then `check-source` is
  still the old selected-vocabulary lint)
- **sanity**: workflow file parses; listed commands exist in-tree
- **read_scope**: `scripta/check-source`, `scripta/check-capabilities`,
  `docs/factory/triga-hardening/open-questions.md` Q6
- **non_goals**: publishing a Faber release; license; clean-install (Stage 6);
  making `check-proba-coverage` exit 0
- **risk**: medium — GitHub will not have sibling Radix; the honesty of the
  skip text is the unit
- **integrable**: yes

### `tgh-s1-5` — canonical local command

- **outcome**: one command from `triga/` discovers every live leaf and proba,
  runs the available local rungs through the sibling product CLI, and prints
  a per-tier label. It is the campaign’s “final canonical command.”
- **write_scope**: `triga/scripta/check` (new),
  `triga/AGENTS.md` (§Validation only)
- **done_when**:
  1. `./scripta/check` runs, in order, `check-source`, `check-compile`,
     `check-proba-coverage`, `check-wgsl-shader-contract-conformance`,
     `check-capabilities` (and may include `check-transforms` /
     `check-exempla-inventory` if `check-compile` does not already);
  2. each rung is labeled `structural`, `executed-proba`, `target`/`wgsl`,
     or `public-execution` as appropriate;
  3. `check-proba-coverage` is invoked; a non-zero 22/26 blocked receipt is a
     labeled `executed-proba` result, not a skip and not a rewrite of the
     scorecard schema;
  4. the wrapper’s overall exit is non-zero when any rung is red, including
     the known source-lint and executed-proba reds;
  5. `AGENTS.md` §Validation names `./scripta/check` as the local spine.
- **depends_on**: `tgh-s1-1`, `tgh-s1-2`, `tgh-s1-3`
- **sanity**: `./scripta/check` exists and prints tier labels (expected
  non-zero while `tgh-s05-gate` is blocked and while source-lint reds remain)
- **read_scope**: the four `scripta/check-*` scripts above
- **non_goals**: forcing executed-proba 26/26; public-CI YAML (that is
  `tgh-s1-4`); Radix fixes
- **risk**: low — orchestration only
- **integrable**: yes

## 5. Named, not lowered — depends on `tgh-s05-gate` green

### `tgh-s1-proba-rung` — executed-proba as a hard-green required rung

- **outcome**: the canonical command and/or public CI treat executed-proba
  26/26 (`stage0_5.complete == true`) as a required green rung rather than
  an honest-red label.
- **depends_on**: **`tgh-s05-gate`** (ledger `executed_module_count = 26` and
  `complete: true`)
- **status**: **not lowered**. Do not file this Hand until the gate receipt
  is green. Filing it now would force assertion weakening or a remasure.
- **write_scope** (when later lowered): `triga/scripta/check` and, if public
  Faber then exists, `triga/.github/workflows/`
- **non_goals now**: any Stage 1 Hand remasuring the scorecard, repairing
  `src/**/*.fab`, or treating 22/26 as 26/26

Owning-repo residuals visible in the 17:58:11Z ledger (not Triga Stage 1 write
scopes):

| Residual class | Modules in the receipt | Owner |
| --- | --- | --- |
| assertion: texture descriptor placeholder shape | `material/base` | remain on `tgh-s05-gate` / later correctness stages |
| assertion: Phong defaults / unsupported base facts | `material/lit` | remain on `tgh-s05-gate` / later correctness stages |
| assertion: standard defaults / unsupported base facts | `material/standard` | remain on `tgh-s05-gate` / later correctness stages |
| `invalid MIR: option unwrap operand is not nullable` | `scene` | Radix MIR |

Do not invent Radix architecture here. Mind routes those residuals; Stage 1
Hands do not.

## 6. Integration / merge gate

None for the five lowered units. Write surfaces are disjoint except that
`tgh-s1-5` reads the scripts `tgh-s1-1`–`tgh-s1-3` produce and should land
after them. Public CI (`tgh-s1-4`) may land in any order relative to the
local spine.

## 7. Checkpoints and gates

**Batching / split decision:** several Hands plus no merge gate. Split is
on write-surface / behavior-family (lint, compile route, WGSL pin, public
CI, wrapper). The hard-green proba rung is split out because it depends on
`tgh-s05-gate`.

**Hand sanity** is the one command on each unit. Do not put
`./scripta/test --stage`, `--full`, `--e2e`, or package `faber check` on a
child Hand.

**Lane-owned validation** (named once):

```bash
cd /Users/ianzepp/work/faberlang/triga
./scripta/check                 # after tgh-s1-5; expected non-zero while 22/26
./scripta/check-source
./scripta/check-compile
./scripta/check-proba-coverage  # must remain honest-red until tgh-s05-gate
./scripta/check-wgsl-shader-contract-conformance
./scripta/check-capabilities
git diff --check
```

`check-proba-coverage` is a receipt writer. A non-zero exit with an updated
scorecard is the current honest outcome. Stage 1 Hands other than a future
`tgh-s1-proba-rung` must not require that exit to be 0.

Release posture: `not-applicable`. Stage 1 is a validation spine; Triga has
no standalone release.

## 8. Validation vs this spec

This spec is done when Mind can file five Hand pointers (`tgh-s1-1` …
`tgh-s1-5`) without inventing architecture, and when `tgh-s1-proba-rung` is
visibly blocked on `tgh-s05-gate`.

It is not done by remasuring, implementing, or closing Stage 0.5.

## 9. Companion skill plan

- Hands implement from this spec (`$factory` / direct on `triga` main).
- Auditor, if dispatched, checks that no unit required 26/26 and that public
  CI does not clone `radix`.
- No Head fork is required for the locked spine-vs-gate split above.

## 10. Open questions for Mind

1. Confirm the default: Stage 1 campaign close = spine honesty, not 26/26.
   If Mind wants Stage 1 close to wait for `tgh-s05-gate`, do not file
   `tgh-s1-proba-rung` as a substitute — keep Stage 1 open instead.
2. After `tgh-s1-1`, `check-source` will be red on resource/material families
   until Stage 2. Other campaigns that assume `check-source` exit 0 need a
   Mind note, not a Stage 1 exemption list.
3. Scorecard `prerequisites.rdx-s05-3 = unresolved` is a heuristic on the
   17:58:11Z receipt. Do not reopen `rdx-s05-3`. Route remaining MIR strings as
   new owning-repo residuals if they survive a future gate refresh.
4. A future `tgh-s05-gate` refresh (not a Stage 1 Hand) may move the four
   remaining rows. Stage 1 Hands must not remasure or repair `src/**/*.fab`.
5. Public-CI `check-source` red after `tgh-s1-1`: workflow must not hide it.
   Default in `tgh-s1-4` is report-as-structural-red. If Mind wants public
   CI green while Stage 2 is open, that is a campaign amendment, not a
   Hand choice.

## 11. Delivery readiness

READY for factory dispatch of `tgh-s1-1` … `tgh-s1-5`.
NOT READY to file `tgh-s1-proba-rung` until `tgh-s05-gate` is green.
READY is a planner verdict, not a GO stamp.
