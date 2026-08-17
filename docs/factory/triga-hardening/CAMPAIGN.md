# Campaign: Triga Library Hardening

**Status**: active (2026-08-17 Stage 0 landed; Stage 0.5 sources landed, tgh-s05-gate blocked at 22/26 executed-proba; Stage 1 spine units landed on main — known-red list: source-lint [intentional], exempla PARSE050, proba 22/26, WGSL PARSE family) — professional source-library baseline
**Mode**: run — campaign control plane
**Owner repo**: `/Users/ianzepp/work/faberlang/triga`
**Participating repos**: `triga` (primary); `radix` and `hosts` for the mandatory
vertical-profile proof; `cista` and the Faber product release path as
clean-install/release consumers
**Vision source**: [Triga Engine And World-Building Architecture](../triga-engine/GOAL.md) — the world-building and engine contract this library serves
**Selected next stage**: Stage 1 — canonical validation and continuous-evidence spine
**Release posture**: pre-1.0 source package consumed through the Faber product;
Triga has no standalone release protocol

## Summary

This campaign turns Triga from a strong research-grade graphics contract into a
dependable, professionally consumable Faber source library. “Professional”
does not mean broad three.js feature parity. It means a bounded supported
profile with explicit invariants, typed failures, executable correctness
evidence, one complete Triga → Radix → WebGPU-host rendering path, documented
compatibility, and clean-install/release receipts.

The in-repo hardening remains the foundation: finite-number policy, valid-state
construction, deterministic value proofs, scene/resource lifecycle tests,
co-located probas, and machine-checked API/docs boundaries. The review exposed
that these are necessary but insufficient. A library whose current host
artifact is rejected before draw, whose default compile gate targets a retired
checkout shape, and whose public package has no legal/support/release surface
cannot be called professional solely because its source leaves are well tested.

The campaign therefore admits one narrow cross-repo vertical profile and
distribution proof. It still excludes broad engine expansion: textures, asset
pipelines, animation, skinning, shadows, post-processing, terrain, voxel, and
instancing remain separate feature campaigns unless the supported profile
requires a minimal existing fact to complete its proof.

## Scope Amendment

This 2026-08-16 amendment replaces the earlier **library-only / no cross-repo
artifact** completion contract.

- **Replaced contract:** harden existing `triga/src` leaves and stop at
  structural source/package evidence.
- **Replacement contract:** harden those leaves **and** prove one bounded
  graphics profile through the current compiler and browser host, then prove
  clean package consumption through the Faber release path.
- **Unchanged boundary:** Triga remains backend-neutral source. Radix owns
  lowering/reflection; Hosts owns WebGPU effects; Cista/Faber own
  install/product release mechanics. Owning-repo defects are fixed in their
  owning repos through separate delivery specs, never hidden in Triga shims.

## Invariant

Triga remains one backend-neutral, versioned Faber source package. Public
Triga values describe graphics semantics and validated facts; they do not carry
WebGPU objects, file handles, browser state, or compiler internals. Radix and
Hosts consume one versioned contract instead of maintaining independent
layout constants. No capability earns support status through naming,
compilation, count checks, or dated receipts alone: the claimed tier must be
reproduced by the campaign gate.

No god module, guessed host fact, stale compatibility alias, or private
backend handle is introduced. Pre-1.0 corrections use clean breaks with
consumer migrations. Existing frozen ABI names may change only in one
lockstep, cross-repo delivery that updates every reader and proves the new
schema; they are not silently renamed by a library-only unit.

## Problem

The S1 seam repairs created recognizable graph, lighting, geometry, material,
primitive, and renderable boundaries, but source quality, executable evidence,
host integration, and package consumption did not mature together.

### Live source and API

- The live tree has **26 `src/**/*.fab` modules**, not the 61 non-facade
  leaves/75 import paths sometimes repeated from the future target map.
  `docs/factory/test-decomposition-report.md` predates the split and
  `docs/module-map.md` mixes live and target-horizon inventories.
- Only `src/math.proba` exists, with three Vector3 cases. Every other public
  leaf lacks co-located package tests.
- Triga defines no typed public error vocabulary. Geometry, scene, resource,
  matrix, and material failures generally collapse to `false` or `null`, so
  malformed input, stale identity, unsupported topology, and genuine geometric
  absence are not reliably distinguishable.
- `math.fab::_angulus_reductus`,
  `geometry/data.fab::_geometry_radix_f32`, and
  `primitives/basic.fab::_primitives_radix_f32` use repeated loops without a
  finite-value guard. Infinity can prevent progress; NaN can evade ordered
  range checks. `Matrix3`/`Matrix4` carry arbitrary `list<f32>` values while
  operations index fixed positions without first enforcing length.
- `SceneStore.continet` checks only the upper handle bound, not a negative
  index. Scene storage is generation-aware and `detrahe` correctly detaches a
  parented leaf, but store/node representations remain easy to construct
  outside mutation invariants and five copied traversal bodies carry
  synchronization risk.
- The accepted receiver-method policy is not consistently reflected in live
  resource/material APIs, and `scripta/check-source` checks only a selected
  vocabulary rather than the complete exported surface.

### Validation and evidence

- `scripta/check-compile` looks for a sibling public `faber/Cargo.toml` that
  does not exist in the current workspace architecture; the supported Faber
  CLI lives under private Radix. The script also enumerates leaves manually and
  omits several nested material/renderable/primitive modules.
- `scripta/check-wgsl-shader-contract-conformance` pins Radix commit
  `41b4c0411` and rejects later `crates/` drift instead of asserting the live
  contract.
- No committed CI workflow continuously runs source, package-test, WGSL, or
  browser evidence. Exempla compilation and expected stdout are useful
  structural evidence, not a substitute for executed assertions.
- `proof/capabilities.json` honestly marks every broad capability
  `unsupported`, while README language calls several layers stable. The
  campaign needs one smaller admitted profile rather than upgrading the broad
  horizon by prose.

The first three items were superseded by the Stage 1 spine landings on main
2026-08-17 (canonical `./scripta/check` wrapper, complete-exported-surface
source lint, all-26-leaf compile with sibling Radix faber CLI, WGSL
revision-pin retirement, committed no-Faber public CI — merged via factory/
hand-10/13/15). The live reds those repairs intentionally preserve are the
known-red list: source-lint (complete-genus, intentional until Stage 2),
exempla PARSE050 (`import_privata_removed`), executed-proba 22/26, and the
WGSL PARSE family.

### Runtime and package boundary

- The current host documents `triga-lit` artifacts as old-format placeholders
  rejected by `loadFaberGraphicsPipeline`; **no draw happens**. This is an
  honest gated state, but it means the graphics path is not currently proven.
- Triga’s canonical `TransformPayload` is 32 floats/128 bytes, while committed
  host reflection describes 64 floats/256 bytes. Independent constants have
  already drifted and must be replaced by one generated/versioned authority.
- Cameras, lights, materials, and meshes are mostly disconnected carriers.
  The host supplies lighting separately and several material/depth/culling
  policies do not yet drive admitted pipeline behavior.
- Root package manifests are `0.2.0`, but all corpus packages still request
  Triga `0.1.0`. There are no release tags, CI, `LICENSE`, changelog,
  compatibility/support policy, security policy, or clean-install receipts.
- Gradus is a useful architecture benchmark for typed errors, per-leaf probas,
  API inventory, compatibility policy, and evidence-tier honesty. It is **not**
  an executed-production benchmark: its own default gate remains structural.

A feature-first approach would grow these weak seams. A tests-only approach
would leave the public package and rendering contract unproven. The campaign
must close both classes without turning Triga into the browser engine.

## Desired End State

At campaign closeout:

1. A generated or compiler-derived inventory names every live public module,
   type, function/method, error, and frozen ABI field. Live and future module
   maps are explicitly separated.
2. A bounded **Triga Core Graphics Profile v0** states exactly what is
   supported. Default profile: perspective camera; indexed triangle geometry;
   position/normal/UV attributes; model and view-projection transforms; depth
   and culling policy; one lit material path; ambient/directional lighting;
   resize and device-loss rejection/recovery semantics.
3. Invalid states are rejected at construction or mutation boundaries.
   Recoverable failures use typed errors; `null` is reserved for genuine
   absence such as no intersection or no optional parent.
4. Every public numeric boundary has a finite-input policy. Fixed-size matrix
   and transform carriers cannot be used with the wrong length; approximation
   error envelopes are documented and tested where compiler intrinsics are
   unavailable.
5. Every public leaf has co-located positive, negative, degenerate, and
   value-based proba evidence appropriate to its contract. Critical math and
   geometry use property/differential oracles in addition to examples.
6. Primitive generators pin exact positions, normals, UVs, winding, and
   indices. Cross-target output is equivalent for the supported profile.
7. Scene/store/resource semantics are explicit: generation identity, stale
   handles, cycle rejection, deletion, traversal, ownership authority,
   disposal, and device-loss interaction are tested without backend handles
   leaking into Triga.
8. Camera, material, light, mesh, and resource facts in the supported profile
   are consumed by the admitted render descriptor; no host default silently
   replaces a published Triga fact.
9. One versioned schema generates or validates transform/storage/layout facts
   across Triga, Radix reflection/WGSL, and Hosts. No independent
   128-vs-256-byte constants remain.
10. The canonical gate runs the complete live leaf set, package probas, WGSL
    and reflection conformance, and a headless-browser numeric/pixel oracle.
    Structural, executed, browser, and performance tiers are reported
    separately.
11. Reproducible stress budgets cover scene traversal/mutation, geometry
    generation, upload volume, resource churn, and leak-free teardown for
    declared profile sizes.
12. The public package has accurate API/diagnostic/compatibility/support docs,
    an operator-selected license, aligned versions, CI appropriate to the
    public/private compiler boundary, and clean Cista/Faber install receipts.
13. Every claim originates as a failing proof and then passes. No policy,
    oracle, or capability threshold is weakened to reach green.

## Development Posture

- **Source-library ownership.** Triga owns backend-neutral contracts. A
  cross-repo proof may change Radix or Hosts only through an owning-repo
  delivery; no Triga leaf imports or embeds those implementations.
- **Profile before breadth.** Complete Core Graphics Profile v0 before adding
  another capability family. Three.js familiarity informs names and mental
  models; it is not the acceptance matrix.
- **Repair before expand.** Existing leaves become sound before any new public
  family. New engine families remain outside this campaign.
- **Value over count.** A generator is proven by exact expected output, not by
  asserting its length.
- **Fail closed, at the leaf.** Unsupported layouts, invalid bounds, and
  out-of-range or non-finite inputs reject before producing a fact. Any
  intentional propagation or degenerate fallback is named and tested.
- **Errors use the error channel, not Option.** A recoverable failure is a
  failable call declared `⇥ E` and raised with `iace`; `∪ nihil` (Option) is
  reserved for genuine absence of a value and is never an error surrogate.
  `adfirma` stays fatal and is only for impossible invariant violations, not
  caller-recoverable rejection.
- **Invalid state is constrained at creation.** Constructors and mutation
  methods establish invariants once. Accessors do not repeatedly return
  nullable values for an invariant already guaranteed by the type boundary.
- **Red-green.** Every new proba or exempla assertion fails against the current
  tree before the fix lands.
- **Evidence tiers stay separate.** Parse/check, executed proba, target
  equivalence, browser draw, pixel/numeric oracle, stress, and clean-install
  are distinct claims. A lower tier never implies a higher one.
- **No policy weakening.** A failing gate is fixed at the owning source,
  harness, or contract. Assertions and support claims are never narrowed just
  to reach green.
- **ABI changes are lockstep.** Existing Radix-consumed fields and numeric codes
  are read-only for Triga-only units. A deliberate schema correction requires
  one cross-repo delivery, consumer migration, and generated conformance proof.
- **Public/private compiler boundary is explicit.** Local development may use
  the sibling private Radix checkout. Public CI and clean-install receipts must
  use a published Faber artifact or report that product-release dependency as
  open; they never pretend a private checkout is independently consumable.
- **Release follows workspace authority.** Triga does not invent a standalone
  release. Package metadata and clean-install evidence feed the Faber product
  protocol.

## Implementation Workflow

1. `delivery` lowers each stage into a durable spec with live file ownership,
   fixtures, gates, repo membership, and path-limited commit boundaries.
2. `factory` executes the spec: red test first, fix, re-run the affected
   stage gate, and commit only the owned paths in each participating repo.
3. Triga-only stages run directly in `triga/` by default. Cross-repo stages use
   explicit delivery ownership; no direct edits are inferred from this
   campaign artifact.
4. Progress lives in the stage goal or delivery spec. This campaign and the
   owning goal status line update whenever a stage changes state or evidence
   changes the route.
5. A correctness/requirements audit reviews each stage against this campaign,
   the API-shape policy, and its declared evidence tier before promotion.
6. The vertical-profile and closeout stages require independent evidence review
   because dated receipts and expected stdout are not current execution proof.

## Scope Routing

| Surface | Canonical owner | Campaign responsibility |
| --- | --- | --- |
| `triga/src/**` | `triga` | Invariants, typed errors, API shape, supported-profile facts |
| `triga/src/**/*.proba` | `triga` | Co-located positive/negative/degenerate/value tests |
| `triga/exempla/**` | `triga` | Instructional and executable consumer proofs; never sole evidence for a critical invariant |
| `triga/corpus/**` | `triga` | Supported-profile browser consumer and package-version migration |
| `triga/scripta/**` | `triga` | Canonical inventory/source/test/conformance gate; no stale checkout or revision pins |
| `triga/proof/**` | `triga` | Split broad unsupported horizon from admitted Core Graphics Profile v0 |
| `triga/docs/**` | `triga` | API, diagnostics, compatibility, support, benchmark/stress, release handoff |
| Language/test/package semantics | `radix` (`faber` product) | Owning-repo fix only when a Triga proof exposes a compiler/CLI defect |
| MIR, WGSL, reflection schema | `radix` | Generate/validate the admitted profile and one ABI authority |
| Browser admission, WebGPU effects, device loss, pixel oracle | `hosts/webgpu-browser` | Execute the admitted profile; no host guessing or silent fallback |
| Cista install/cache behavior | `cista` | Verification consumer; source change only for a proven Cista defect |
| Faber product release artifacts | `radix` release authority | Provide the public binary/dev-kit used by clean-install and public-CI evidence |
| Broad textures/assets/animation/shadows/post/terrain/voxel/instancing | separate campaigns | Explicitly outside this campaign unless required to complete an already-admitted profile fact |

## Batching And Split Policy

- **Stage 0** is **discovery-first**: freeze live inventory, evidence levels,
  the supported profile, and the scorecard before implementation.
- **Stage 1** is **split-on-boundary**: repair Triga’s local validation spine
  first; route actual Faber/Radix defects to owning-repo units.
- **Stages 2–5** are **batch-by-default** by coherent leaf family after one
  red-green pattern establishes the error/test shape.
- **Stage 6** is **batch-by-default** for docs/package metadata, but license
  selection and public-CI artifact availability are explicit operator/product
  boundaries.
- **Stage 7** is **split-on-boundary** by Triga contract, Radix artifact, and
  Hosts execution ownership; all slices are mandatory for the profile proof.
- **Stage 8** is **discovery-first** for budgets, then batch completion across
  the agreed stress matrix and closeout audit.

## Ground Truth Researched

### Live Triga authority

- [`src/`](../../../src/) contains 26 Faber modules. Large ownership seams are
  `math.fab`, `geometry/data.fab`, `scene.fab`, `resource.fab`, and
  `primitives/basic.fab`; the remaining graph/lighting/material/renderable/
  geometry/facade leaves are smaller.
- [`faber.toml`](../../../faber.toml) declares the `en` locale and package
  version `0.2.0`; [`cista.toml`](../../../cista.toml) agrees on `0.2.0`.
- Every live `src/**/*.fab` now has a sibling `.proba` (Stage 0.5 c01–c09).
  The executed-proba ledger is still blocked at **22/26** (`tgh-s05-gate`;
  receipt `76ded8b`, run 2026-08-17T17:58:11Z, `complete: false`).
- [`proof/capabilities.json`](../../../proof/capabilities.json) is the honest
  broad-horizon ledger: all current domain proofs are `unsupported`.
- [`API shape policy`](../../api-shape-policy.md) is accepted law; the
  exported-surface source lint is now complete (hand-13 `1172762`) and reports
  the resource/material free-function families as an intentional red until
  Stage 2 aligns them.
- [`module map`](../../module-map.md) is useful for ownership, but its size and
  target-map sections are stale/mixed. The 61/75 figures describe a future
  horizon, not the 26-module live package.
- [`test-decomposition-report.md`](../test-decomposition-report.md) is
  archival evidence from the pre-split tree. Its line numbers and symbol map
  are not implementation authority.
- [`scripta/check-compile`](../../../scripta/check-compile) and
  [`check-wgsl-shader-contract-conformance`](../../../scripta/check-wgsl-shader-contract-conformance)
  are live executable surfaces and therefore outrank old validation prose.

### Cross-repo authority

- The supported Faber product CLI lives in private `radix/crates/faber`; the
  public `faber/` sibling is not the old Cargo CLI checkout.
- `radix` owns WGSL lowering, reflection, and frozen graphics ABI readers.
- `hosts/webgpu-browser/public/src/contract/artifact-admission.js` owns
  graphics-artifact admission.
- `hosts/webgpu-browser/public/src/engine/engine.js` records the current
  placeholder-artifact rejection and no-draw state.
- `hosts/webgpu-browser/public/generated/graphics-reflection.json` currently
  describes a 64-float/256-byte transform buffer; `triga/src/math.fab`
  describes 32 floats/128 bytes.
- Gradus’s `src/**/*.proba`, typed module errors, API reference,
  compatibility policy, and release checklist are design references only.
  Gradus’s compile gate does not establish an executed-production standard.

### Consumer requirements

- [Triga Engine GOAL](../triga-engine/GOAL.md) supplies world/scene/resource
  consumers and stop conditions.
- [Three.js 80 campaign](../triga-threejs-80/CAMPAIGN.md) supplies breadth
  pressure but does not define this campaign’s supported profile.
- [Hello Voxel campaign](../hello-voxel/CAMPAIGN.md) supplies a concrete
  graphics consumer and first-draw pressure.
- Triga corpus packages supply browser-shaped consumers but currently pin
  `triga = "0.1.0"` and do not prove a current admitted draw.

## Supported-profile requirements trace

| Profile requirement | Canonical owner | Required evidence | Stage |
| --- | --- | --- | --- |
| Finite vectors, matrices, transforms, camera projection | Triga `math`, `graph/camera` | proba + differential/value oracle | 2–3 |
| Indexed triangle geometry with position/normal/UV | Triga `geometry/*`, `primitives/basic` | exact values + negative validation + target equivalence | 2–3 |
| Generation-safe scene identity and world transforms | Triga `scene` | mutation-sequence and stale/cycle/deletion probas | 2, 4 |
| Resource identity, replacement, removal, disposal facts | Triga `resource`; Hosts effect owner | lifecycle probas + host teardown/device-loss proof | 4, 7–8 |
| Camera/material/light/renderable composition | Triga graph/material/lighting/renderable leaves | typed construction + descriptor-consumption proof | 5, 7 |
| Versioned shader/storage/layout schema | Radix with Triga ABI inputs | generated reflection/WGSL conformance; no duplicate constants | 7 |
| Browser draw, resize, device loss, numeric/pixel output | Hosts | headless-browser executed oracle | 7–8 |
| Installable package and accurate public contract | Triga + Cista/Faber release path | clean install, API/diagnostic/compat docs, version/license checks | 6, 8 |

## Current State

| Track | State | Next action |
| --- | --- | --- |
| Supported profile | Core Graphics Profile v0 is frozen; the broad ledger remains honestly all-unsupported | Stage 1 spine landed on main 2026-08-17; hard-green executed-proba rung `tgh-s1-proba-rung` stays unlowered (gate `tgh-s05-gate` 22/26) |
| Live inventory | Versioned inventory records all 26 live modules; stale module/test reports remain annotated | Same gate + spec as Package tests; hard-green rung unlowered until `tgh-s05-gate` |
| Validation spine | Canonical `./scripta/check` landed on main 2026-08-17 (hands 10/13/15): complete-genus source lint, all-26-leaf compile with sibling Radix faber CLI, WGSL revision-pin retirement, committed no-Faber public CI, tier-labeled wrapper. Live reds (known-red list): source-lint (intentional), exempla PARSE050, proba 22/26, WGSL PARSE family | `tgh-s1-proba-rung` (hard-green executed-proba) stays unlowered until `tgh-s05-gate` is 26/26; [`stage-1-delivery.md`](./stage-1-delivery.md) records the landed units and receipts |
| Diagnostics | No typed public error families; `bool`/`null` collapse distinct failures | Stage 2 |
| Numeric invariants | Non-finite policy absent; repeated reduction/sqrt loops; arbitrary-length matrix carriers | Stages 2–3 |
| Package tests | 26 sibling `.proba` sources landed (Stage 0.5 c01–c09); `tgh-s05-gate` ledger blocked at **22/26** executed-proba (`proof/coverage-scorecard.json` `stage0_5`, receipt `76ded8b`, run 2026-08-17T17:58:11Z, `complete: false`) | `tgh-s05-gate` remains open; 4 runner-failure rows (`material/base`, `material/lit`, `material/standard`, `scene`). Residual fixes route through the owning gate/Radix MIR, not a Stage 1 Hand. Stage 1 spine already landed; hard-green `tgh-s1-proba-rung` stays unlowered. |
| Geometry/primitives | Useful validation/builders exist; exact-output and malformed-input proof is thin | Stage 3 |
| Scene/resource | Generation-aware foundation exists; negative index, traversal duplication, authority/disposal boundaries remain | Stage 4 |
| Appearance/composition | Cameras/lights/materials/meshes are mostly disconnected carriers | Stage 5 |
| Public package | 0.2.0 roots vs 0.1.0 corpus dependencies; no license/CI/API reference/compatibility/release receipts | Stage 6 |
| Graphics runtime | Host rejects placeholder artifact; transform ABI constants disagree; no current draw | Stage 7 |
| Scale/operations | No reproducible traversal/upload/resource/leak budget | Stage 8 |

## Campaign Path

### Stage 0 — Live baseline, supported profile, and scorecard

**Status**: complete (2026-08-16; Stage 0 landed; receipts in delivery §8)
**Source**: [test-decomposition-report.md](../test-decomposition-report.md),
[current module map](../../module-map.md), live `src/`, manifests, scripts,
capability ledger, host admission path
**Depends on**: nothing
**Why now**: every later unit needs one live inventory and one bounded support
claim; stale counts and the broad all-unsupported ledger cannot route work.
**Gate**: a versioned, machine-readable inventory names all 26 live modules,
public symbols, error/null contracts, tests, ABI fields, consumers, and current
evidence tiers. Core Graphics Profile v0 is frozen with explicit supported and
unsupported rows, profile-size assumptions, and proof requirements. The
coverage scorecard contains no stale line number, pre-split symbol, or future
module counted as live.
**Overlap rule**: discovery only; no source correction or support upgrade.
**Lowers to**: `delivery` → `factory`
**Batching**: discovery-first

### Stage 0.5 — Co-located proba coverage and executed-proba gate

**Status**: sources complete (c01–c09 landed); gate blocked (2026-08-17
`tgh-s05-gate` ledger 22/26 executed-proba, receipt `76ded8b`, `complete: false`)
**Source**: [`stage-0-5-delivery.md`](./stage-0-5-delivery.md),
[`stage-0-5-triage.md`](./stage-0-5-triage.md),
`scripta/check-proba-coverage`, `proof/coverage-scorecard.json`
**Depends on**: Stage 0
**Why now**: operator amendment — evidence cannot accumulate as a single
stale probe; every live module needs a sibling `.proba` and a machine gate.
**Gate**: 26/26 modules at `executed-proba` and `stage0_5.complete: true`.
The last committed receipt is 22/26 blocked (`76ded8b`, run
2026-08-17T17:58:11Z); it was not remasured for Stage 1.
**Overlap rule**: test-and-evidence only; remaining module reds stay on this
gate and owning-repo residuals. Stage 1 may invoke the gate and must not
close it.
**Lowers to**: already lowered (`stage-0-5-delivery.md`); remaining unit is
`tgh-s05-gate`
**Batching**: coverage families landed; gate is serial and still open

### Stage 1 — Canonical validation and continuous-evidence spine

**Status**: spine units landed on triga main 2026-08-17 (hands 10/13/15:
complete-genus source lint `1172762`; all-26-leaf compile + sibling Radix
faber CLI `5eb7971`; WGSL pin retirement `a01cc28`; no-Faber public CI
`2fe90f5`; canonical `./scripta/check` + AGENTS pointer `7c6caf4`). Known-red
list (documented, not papered over): source-lint (intentional), exempla
PARSE050, proba 22/26, WGSL PARSE family. The prior admission HELD posture
(CTO `e2ca2b57`) predates those landings; the hard-green executed-proba rung
(`tgh-s1-proba-rung`) remains explicitly **not lowered** until `tgh-s05-gate`
is 26/26.
**Source**: `scripta/check-*`, `faber.toml`, current Radix/Faber product route,
current proba discovery, corpus/browser runners
**Depends on**: Stage 0. Stage 0.5 *sources* are present. Stage 0.5 *gate
green* is **not** a start dependency; it is the named dependency of the
unlowered `tgh-s1-proba-rung` only.
**Why now**: hardening cannot accumulate evidence behind a broken, partial, or
revision-frozen gate.
**Gate**: one canonical command discovers every live source leaf and proba,
uses the current sibling Radix/Faber route for local work, executes assertions
when the toolchain supports them, and reports unsupported execution honestly.
WGSL conformance asserts schema behavior rather than repository revision.
Public CI either uses a published Faber artifact or clearly reports the
product-release dependency; no private checkout is presented as public
consumability. A committed workflow runs every currently available tier.
**Overlap rule**: repair Triga scripts locally; compiler/CLI defects become
separate Radix delivery units and must land before this stage closes.
**Lowers to**: `delivery` → `factory`
**Batching**: split-on-boundary

### Stage 2 — Failure model, valid-state construction, and API boundary

**Status**: planned
**Source**: all public Triga leaves, API-shape policy, live null/bool inventory
**Depends on**: Stages 0–1
**Why now**: domain tests need one consistent rule for malformed input,
genuine absence, finite numbers, and construction invariants.
**Gate**: each public rejection path has a typed module error and stable
`causa` rendering; `null` remains only for genuine absence. Negative
index/generation checks, finite-input checks, allocation/iteration ceilings,
and fixed-size carrier validation are centralized at creation/mutation
boundaries. Receiver-method policy and actual public exports agree. A generated
API/diagnostic inventory fails on undocumented drift.
**Overlap rule**: establish one leaf-family pattern, then migrate all public
families in dependency order; no half-migrated alias layer.
**Lowers to**: `delivery` → `factory`
**Batching**: batch-by-default after the first pattern

### Stage 3 — Math, geometry, layout, and primitive correctness

**Status**: planned
**Source**: `src/math.fab`, `src/graph/camera.fab`,
`src/geometry/{data,attribute,layout,bounds,batch}.fab`,
`src/primitives/basic.fab`
**Depends on**: Stage 2
**Gate**: vectors, matrices, quaternions, transforms, bounds, rays, camera
projection, attributes, layouts, batches, normals, and primitive generators
have co-located positive/negative/degenerate tests. Non-finite input cannot
hang. Approximation error envelopes are pinned. Plane, box, and sphere exact
positions/normals/UV/winding/indices are proven. Profile operations have
Rust/TypeScript or declared-target equivalence at the highest available
executed tier.
**Overlap rule**: math/transform precedes geometry consumers; geometry leaves
may batch once the numeric/error pattern is green.
**Lowers to**: `delivery` → `factory`
**Batching**: batch-by-default per leaf family

### Stage 4 — Scene identity, traversal, and resource lifecycle

**Status**: planned
**Source**: `src/scene.fab`, `src/resource.fab`, engine/world consumers
**Depends on**: Stages 2–3
**Gate**: empty/deep/orphaned/malformed stores; negative/stale handles;
self-attach, reparent, detach, leaf deletion, cycle rejection; dirty/world
transform propagation; visible/mesh/resource traversals; and generation
replacement/removal are covered by mutation-sequence probas. Traversal
variants are behavior-equivalent or collapsed through a supported language
mechanism. Triga defines semantic resource identity/disposal facts; Hosts
remains the physical allocation authority. No public value carries a backend
object.
**Overlap rule**: scene identity lands before resource-consuming traversal;
language gaps route to Radix rather than local duplication disguised as a new
abstraction.
**Lowers to**: `delivery` → `factory`
**Batching**: batch-by-default per family

### Stage 5 — Camera, material, light, and renderable composition

**Status**: planned
**Source**: `src/graph/*`, `src/material/*`, `src/lighting/*`,
`src/renderable/*`, profile v0 descriptor requirements
**Depends on**: Stages 2–4
**Gate**: the supported camera, material, ambient/directional light, mesh, and
pipeline-policy facts have typed constructors, validation negatives, and
composition tests. Profile semantics state which facts affect culling, depth,
opacity/alpha, and lighting. Unsupported material/light variants remain
explicitly outside the admitted profile rather than appearing operational by
name alone.
**Overlap rule**: Triga contract only; host consumption is Stage 7 and may not
be guessed or pre-implemented here.
**Lowers to**: `delivery` → `factory`
**Batching**: batch-by-default per profile family

### Stage 6 — Public package, documentation, compatibility, and support

**Status**: planned
**Source**: manifests, README/module map, generated API/diagnostic inventory,
Cista/Faber install route, workspace release authority
**Depends on**: Stages 0–5
**Gate**: root and corpus dependency versions agree; API reference,
diagnostics, compatibility, support, numeric tolerance, benchmark/stress, and
release-handoff docs are generated or mechanically checked against live
source. README stability language matches profile/evidence tiers. An
operator-selected license and appropriate security/support files are present.
A clean Cista/Faber install in a temporary home compiles a profile consumer
without sibling-path leakage. Triga still does not claim a standalone release.
**Overlap rule**: docs and metadata may batch; license choice and missing
published Faber artifacts are explicit operator/product gates.
**Lowers to**: `delivery` → `factory`
**Batching**: batch-by-default with named external gates

### Stage 7 — Versioned graphics ABI and admitted browser draw

**Status**: planned
**Source**: Triga shader/layout/transform facts, Radix MIR/WGSL/reflection,
Hosts artifact admission/engine/runtime
**Depends on**: Stages 1–6
**Gate**: one versioned schema resolves the 32/128 vs 64/256 transform
disagreement and generates or validates every Triga/Radix/Hosts reader.
Current WGSL and reflection artifacts are generated from the pinned source
profile and admitted by `loadFaberGraphicsPipeline`. A headless browser draws
the profile scene and passes deterministic numeric and pixel samples. Camera,
geometry, material, light, depth/culling, resize, resource teardown, and device
loss use published facts or reject explicitly; no host default silently
substitutes for a Triga contract.
**Overlap rule**: three owning-repo delivery slices—Triga contract, Radix
artifact, Hosts execution—land in dependency order. All are mandatory.
**Lowers to**: `delivery` → `factory`
**Batching**: split-on-boundary

### Stage 8 — Stress budgets, clean-install receipts, and closeout audit

**Status**: planned
**Source**: profile v0, stage evidence, engine/world consumer sizes, Faber
release receipt schema
**Depends on**: Stages 0–7
**Gate**: reproducible budgets cover declared scene size/depth, mutation churn,
geometry generation, draw count, upload bytes, resource replacement/removal,
device loss/recovery, and leak-free teardown. Clean-install and browser
receipts record repo commits, dirty state, exact commands, artifact hashes,
verdicts, and evidence tier. An independent requirements trace gives every
Desired End State item a current passing receipt or reopens its owning stage.
Only Core Graphics Profile v0 is upgraded from unsupported; every broader
capability remains explicitly unsupported.
**Overlap rule**: discovery sets budgets; clearing runs after all
behavior-affecting fixes and re-runs only affected evidence before final
aggregate closeout.
**Lowers to**: `delivery` → `factory` → independent audit
**Batching**: discovery-first, then batch completion

## Dependency Rules

- Triga-only stages do not edit sibling repos. Stages 1, 7, and 8 may cross
  repos only through explicit owning-repo delivery specs with named write
  scopes and evidence.
- A compiler, package, reflection, or host defect is fixed at its owner. Triga
  never ships a duplicate parser, handwritten reflection, host fallback, or
  compatibility facade to hide it.
- Existing ABI field names and numeric codes remain read-only in a Triga-only
  unit. A necessary ABI correction is one versioned Stage 7 schema migration
  across all readers, with no mixed-version compatibility path unless an
  external released contract proves it is required.
- The `scene` store/query split is gated on Radix language gaps G2/G3; this
  campaign pins behavior and records the dependency, it does not pre-split.
- Corpus packages are profile consumers. They may provide browser evidence only
  when the artifact is admitted and a numeric/pixel oracle executes; static
  build or source inspection remains structural evidence.
- Public ownership and module layout follow `AGENTS.md` and the corrected live
  module map: no empty facade, backend leakage, or type re-export.
- Profile v0 is the only capability set eligible for admission here. Broad
  Three.js/engine horizon rows remain unsupported at campaign closeout.
- `null`/Option never becomes a compatibility escape hatch for a recoverable
  typed failure.
- Public CI cannot depend silently on a private checkout. If no published
  Faber artifact can execute the package, the public-execution tier remains
  open and the campaign cannot claim independent public CI.
- An operator chooses the legal license; the campaign may not invent one.
- A red proof causes an owning-source or harness repair. Assertions, test
  selection, tolerances, pixel samples, and capability thresholds are not
  weakened for green.

## First Useful Milestones

1. Live 26-module inventory and Core Graphics Profile v0 are accepted
   (Stage 0).
2. One canonical local/CI gate discovers all leaves and probas without stale
   checkout or revision assumptions (Stage 1).
3. Typed errors, finite-input policy, and valid-state construction rules are
   mechanically enforced (Stage 2).
4. Math/geometry/primitive exact-output and degenerate proofs pass (Stage 3).
5. Scene and resource mutation/lifecycle sequences pass (Stage 4).
6. The profile’s camera/material/light/renderable facts compose without
   pretending unsupported variants render (Stage 5).
7. Public package metadata, license, docs, and clean-install evidence agree
   (Stage 6).
8. Current generated artifacts are admitted and the first deterministic
   browser draw passes (Stage 7).
9. Stress budgets and the independent closeout trace pass with every
   non-profile capability still marked unsupported (Stage 8).

## Acceptance Criteria

This campaign artifact is ready when:

- every stage has a status, source, dependency, gate, lowering path, and
  batching/overlap posture;
- the scope amendment explicitly replaces the old library-only completion
  contract;
- the supported-profile trace assigns every required proof to its owning repo
  and stage;
- stale live counts, obsolete CLI routes, the current no-draw state, ABI drift,
  and package/release gaps are recorded without converting them into claims;
- cross-repo work is bounded to validation and one admitted vertical profile;
- stop conditions prevent feature creep, backend leakage, hidden private
  dependencies, guessed facts, and declaration credit.

Campaign completion requires every Desired End State item and Stage 0–8 gate
to be implemented and verified at its declared tier. A generated plan,
successful source check, old execution receipt, or first browser draw alone
does not complete the campaign. Any open profile, package, stress, or
clean-install item keeps the campaign active.

## Validation

Artifact validation:

```bash
rg -n "Status|Depends on|Gate|Overlap rule|Lowers to|Batching|Stop Conditions" \
  docs/factory/triga-hardening
rg -n "library-only|no cross-repo|61 non-facade|75 import" \
  docs/factory/triga-hardening/CAMPAIGN.md
git diff --check
```

The second search must return only the explicit scope amendment, stale-count
diagnosis, and this validation command—never a current no-cross-repo
completion rule or a 61/75 live-inventory claim.

Stage 1 defines the final canonical command (`tgh-s1-5` → `./scripta/check`).
Until that unit lands, the known intended rungs are:

```bash
./scripta/check-source
./scripta/check-compile
./scripta/check-exempla-inventory
faber test .
./scripta/check-wgsl-shader-contract-conformance
# From hosts/ after current artifacts are generated:
./scripta/webgpu-browser-proof
```

Each command’s result is labeled structural, executed-proba, target,
browser-numeric/pixel, stress, or clean-install. Commands known to target a
retired checkout, omit leaves, or reject arbitrary later revisions are findings
until Stage 1 repairs them, not valid green receipts.

## Open Questions

- Does Stage 0 retain the default profile (perspective camera, indexed
  position/normal/UV geometry, model/view-projection transforms, one lit
  material, ambient/directional light, depth/culling, resize/device loss), or
  does live compiler/host evidence require a smaller first profile? Any
  reduction must still produce a useful deterministic draw, not a
  construction-only proof.
- Which NaN/Infinity behaviors are genuine mathematical projections versus
  caller errors? Default: reject non-finite public inputs through typed errors;
  preserve a defined degenerate value only where the API explicitly names it.
  Stage 2 records the per-operation table.
- Can current Faber express fixed-size matrix/transform storage directly?
  Otherwise Stage 2 must make construction private/checked and prevent
  unvalidated methods from indexing arbitrary lists.
- Does `faber test .` currently run co-located proba in this repo, or is there
  a packaging gap that must be routed to Faber before proba coverage can gate?
  A gap routes to Radix and keeps the executed-proba tier open; exempla
  compilation does not substitute for assertions.
- Is `ResourceHandle` intentionally only semantic identity, with Hosts as the
  sole allocation/disposal authority? Stage 4 must state that boundary and
  Stage 7 prove it through replacement, teardown, and device loss.
- Which published Faber artifact is available to public Triga CI and
  clean-install verification? Until one exists, local private-Radix evidence
  and public consumability remain separate.
- Which license does the operator select for this public source package?
- What scene size/depth, geometry volume, frame/upload budget, and resource
  churn define Profile v0’s stress contract? Stage 8 freezes values before
  measuring.

## Stop Conditions

Stop and revise if:

- a Triga-only delivery edits Radix/Hosts/Cista or introduces a backend
  dependency into a Triga public leaf;
- a cross-repo delivery lacks explicit owning paths, dependency order, or a
  versioned contract migration;
- a frozen ABI field/code changes outside the Stage 7 lockstep schema unit;
- the `scene` split is attempted without the G2/G3 language decision;
- a capability is claimed by declaration, count check, or exempla construction
  without the evidence tier required by Profile v0;
- structural compilation, dated receipts, expected stdout, or browser artifact
  admission is presented as an executed numeric/pixel result;
- a check, tolerance, pixel sample, stress budget, or supported-profile row is
  weakened to reach green;
- a new public module family is added under this campaign instead of routed to
  the engine campaign;
- a host silently substitutes hard-coded camera/light/material/layout facts for
  missing Triga/Radix facts;
- public CI or clean-install evidence silently depends on the private sibling
  Radix checkout;
- a license is selected without operator authority;
- any Desired End State item is relabeled optional/deferred instead of
  completing the scope amendment;
- existing foreign work in the shared repo is overwritten or bundled into a
  hardening commit.
