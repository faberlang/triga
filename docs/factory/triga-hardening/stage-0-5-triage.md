# Triga Hardening — Stage 0.5 Triage Receipt

**Unit**: `tgh-s05-0` — record triage and external routes
**Date**: 2026-08-16
**Delivery**: [`stage-0-5-delivery.md`](./stage-0-5-delivery.md) §2 and §5
**Campaign**: [`CAMPAIGN.md`](./CAMPAIGN.md), Stage 0.5 operator amendment
**Type**: record-only triage/routing receipt. Contains no Radix implementation and
no Triga source or scorecard edits.

**Update (2026-08-17)**: the original `rdx-s05-2` route was superseded by
`rdx-s05-3` after block-ship evidence (`76f5a125`). Radix then landed the
package-test route in `018cc8b25`: `faber test` links the test-bearing package
scope once and runs its cases against the shared validated MIR. The scalar
collection-result repair landed in `736b14766`; the recorded official
converted three-case math fixture is green (`3 passed, 0 failed`). Later Triga
visibility repairs (`94c8da7`, `cdf8c0e`, `9d9246c`, `91b3389`, `ef48638`,
`b8def7c`)
addressed export-surface failures. Stage-0.5 evidence remains open only for
coverage-specific visibility, MIR, and provider/runtime residuals, not for the
superseded package-link route.

The original command set was run from the Triga root on 2026-08-16 with the
in-workspace binaries `radix/target/debug/faber` and `radix/target/debug/radix`
(built 2026-08-16 20:06; includes the proba-runner extraction commits
`740bfc71c` / `6721fedc`). Those command results are historical unless the
updated route or a current residual is explicitly named below.

## 1. Coverage gap (delivery §2.1)

At the original 2026-08-16 triage snapshot:

```bash
cd /Users/ianzepp/work/faberlang/triga
find src -type f -name '*.fab' | sort | wc -l       # 26
find src -type f -name '*.proba' | sort            # src/math.proba only
```

- The module set was the live 26-module set: `proof/inventory/triga-inventory.json`
  listed 26 modules (schema v1, revision 1). The 75-import-path / 61-leaf
  horizon in the archival module map was not the current set.
- `src/math.proba` was 27 lines with three cases (`addita combines two vectors`,
  `normata returns unit vector`, `normata returns zero for zero-length`).
- The Stage-0 scorecard therefore recorded one co-located test source and 25
  structural-only module rows. **Historical verdict: 26/1 coverage gap.**

## 2. Stale-Latin probe diagnosis (delivery §2.2)

The following facts and commands belong to the original 2026-08-16 triage
snapshot, before the English coverage wave and the later visibility repairs:

- `src/math.fab` existed; `Vector3` was public; `vector3`, `Vector3.addita`, and
  `Vector3.normata` existed in that module.
- `radix check --locale en src/math.fab` exited 0 with warnings only.
- The probe used the retired Latin surface: `importa ex "./math" privata math`,
  `probandum`, `proba`, `adfirma`, `fixum`. The parser rejected the old import
  privacy modifier (`PARSE050.import_privata_removed`).

Reproduced commands and historical verdicts:

```text
faber test /Users/ianzepp/work/faberlang/triga/src/math.proba
  -> exit 1; 49x SEM001.unknown_identifier + 49x SEM008.undefined_name
     (23x LOCALE002 warnings stream first; error tail is SEM008)

radix check --locale en src/math.proba
  -> exit 1; 49x SEM001.unknown_identifier + 49x SEM008.undefined_name
```

**Historical verdict**: SEM001/SEM008 cascade confirmed on the triage binary.
The symptoms were a stale proba surface plus a semantic cascade, not evidence
that the math module disappeared.

**Historical classification** — Triga test source: stale Latin probe against
the `en` locale; not a module rename. **Consequence**: rewrite as `en` in
`tgh-s05-c01`; no compatibility alias, no math-module edit. The later English
coverage and visibility commits supersede this source-state diagnosis.

## 3. `faber test .` package-path defect (delivery §2.3)

The following commands and verdicts are historical. Radix `9919d480c` fixed
this package-path route; the old failure is no longer an active prerequisite.

Reproduced commands and historical verdicts:

```text
cd /Users/ianzepp/work/faberlang/triga
faber test .
  -> error: cannot read '.': No such file or directory (os error 2)
  -> error: package analysis failed

faber test src
  -> error: cannot read 'src/main.fab': No such file or directory (os error 2)
```

Root cause as recorded in the delivery body: the CLI passes the raw `PathBuf`
from `radix/crates/faber/src/commands/test.rs` to
`analyze_package_for_tests`, whose contract requires absolute inputs;
`radix-package::normalize_path` is lexical, so normalizing `.` drops the
`CurDir` component and leaves an empty relative path, misdirecting discovery.
A source directory without a manifest is treated as a legacy package whose
entry is `main.fab`, which is not the Triga package form.

**Historical classification** — Radix/Faber package route: relative
package-path normalization defect. **Resolution**: `rdx-s05-1` landed in
`9919d480c`; retain the reproduction as route history, not as a current gate.

## 4. Converted English probe MIR-lowering route (delivery §2.4)

The earlier temporary-package reproduction recorded two MIR errors for the
public `Vector3` method and field shapes:

```text
unsupported MIR lowering: method call before runtime/provider MIR lowering
unsupported MIR lowering: projection base that does not resolve to a local value
```

That reproduction is historical route evidence, not the current package-test
architecture. Radix `018cc8b25` selected and implemented link-then-run: the
package test command collects every test-bearing root, links the package scope
once, and runs each discovered case through the shared validated MIR. Radix
`736b14766` then preserved the scalar collection-length result at the nullable
expression boundary. The recorded official converted three-case math fixture
is green: `3 passed, 0 failed`. That receipt is distinct from the later
expanded `src/math.proba` coverage file, whose cases remain subject to the
residuals below.

The later Triga visibility series (`94c8da7`, `cdf8c0e`, `9d9246c`, `91b3389`,
`ef48638`, `b8def7c`) repaired public math, graph, geometry/face,
material/lighting, renderable, shader, and facade exports. Remaining
Stage-0.5 failures are coverage-specific: broader probes still expose MIR
method-call, projection-base, and unresolved-path shapes, while resource and
shader-contract probes expose provider/runtime gaps. These are named residuals
for the Triga coverage wave; they are not evidence that `faber test` uses the
superseded isolated-lowering route.

**Classification** — Radix package-link route: `018cc8b25` and `736b14766`
landed; the link-then-run fork is closed. **Consequence**: keep each Triga
module below `executed-proba` until its actual coverage probe passes, and do not
replace method/field assertions with count-only tests.

## 5. Triage conclusion (delivery §2.5)

The live honest package-link receipt (`3b676ac`,
`proof/coverage-scorecard.json`, coverage revision 2) records **9/26** module
selections at `executed-proba`. The remaining 17 rows comprise 1
`analysis-error` row (`src/graph/camera.fab`) and 16 `runner-failure` rows.
`src/primitives/basic.fab` is now a `runner-failure` after `79a7f6d04`, and
`src/geometry/data.fab` is a `runner-failure` after the release Faber update at
`17854f61e`; neither is counted among the analysis errors. The current receipt
has no `PARSE050` row;
`PARSE050.import_privata_removed` is historical evidence from the retired
import-modifier and single-file/roundtrip routes, not the current Triga
package-link verdict.

The Stage-0 Q4 conclusion remains in force: the executed-proba tier is open.

| Symptom | Owner | Classification | Stage-0.5 consequence |
| --- | --- | --- | --- |
| stale-Latin `src/math.proba` history | Triga test source | superseded by the English coverage wave and later visibility repairs | judge the current probe result, not the historical syntax failure |
| `faber test .` package-path history | Radix/Faber package route | fixed by `9919d480c`; the package path is no longer an active Stage-0.5 prerequisite | retain the path regression as historical evidence |
| converted probe method/field shapes | Radix package-link route | fixed by link-then-run `018cc8b25`, with the scalar-result repair in `736b14766`; the recorded official three-case probe is green | keep method/field assertions and track only actual Triga coverage residuals |
| later Triga coverage failures | Triga visibility and MIR/provider seams | visibility repairs landed, but broader probes still expose MIR method/projection/path and provider/runtime residuals | keep affected module rows below `executed-proba` until their cases pass |

Coverage units may author their `.proba` files while their own visibility and
MIR/provider residuals are in flight. **No coverage unit may claim
executed-proba completion until its actual cases pass through the package gate.**
The Stage-0.5 tier remains open until the aggregate gate reports 26/26 passing
modules.

## 6. Named external routes (delivery §5)

- **`rdx-s05-1`** (repo `radix`) — **landed** in `9919d480c`.
  `faber test .`, a relative package path, and an absolute package path now
  enter the same normalized package discovery route. The old `cannot read '.'`
  result is retained only as historical diagnosis.
- **`rdx-s05-3`** (repo `radix`) — **landed** through `e56d45f70`,
  `018cc8b25`, and `736b14766`. The package linker supplies imported nominal
  method targets; `faber test` links the test-bearing package scope once and
  runs the cases against shared validated MIR; the scalar collection-length
  repair preserves the nullable result contract. The recorded official
  three-case `math.proba` receipt is `3 passed, 0 failed`. No head-cto fork
  remains open.

Both owning-repository routes are complete in `radix/`; `rdx-s05-2` remains a
superseded route, not an active prerequisite. This receipt contains **no Radix
implementation**; routing and evidence only.

## 7. Sanity / verification log

- The original triage snapshot recorded 26 modules and one three-case
  `.proba`; the later coverage wave expanded that surface and the later
  visibility commits repaired its public export seams.
- The original `faber test .` / `faber test src` package-path failures and the
  single-file SEM cascades remain historical reproductions in §§2–§3.
- The route update records Radix `9919d480c`, `018cc8b25`, and `736b14766`,
  plus the later Triga visibility series; current coverage residuals remain
  owned by the affected Triga probes.
- No span of this receipt edits `src/**/*.fab`, `src/**/*.proba`,
  `proof/**`, or Radix files.