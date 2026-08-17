# Triga Hardening — Stage 0.5 Triage Receipt

**Unit**: `tgh-s05-0` — record triage and external routes
**Date**: 2026-08-16
**Delivery**: [`stage-0-5-delivery.md`](./stage-0-5-delivery.md) §2 and §5
**Campaign**: [`CAMPAIGN.md`](./CAMPAIGN.md), Stage 0.5 operator amendment
**Type**: record-only triage/routing receipt. Contains no Radix implementation and
no Triga source or scorecard edits.

All commands were re-run live from the Triga root on 2026-08-16 with the
in-workspace binaries `radix/target/debug/faber` and `radix/target/debug/radix`
(built 2026-08-16 20:06; includes the proba-runner extraction commits
`740bfc71c` / `6721fedc8`).

## 1. Coverage gap (delivery §2.1)

```bash
cd /Users/ianzepp/work/faberlang/triga
find src -type f -name '*.fab' | sort | wc -l       # 26
find src -type f -name '*.proba' | sort            # src/math.proba only
```

- The module set is the live 26-module set: `proof/inventory/triga-inventory.json`
  lists 26 modules (schema v1, revision 1). The 75-import-path / 61-leaf horizon
  in the archival module map is not the current set.
- `src/math.proba` is 27 lines with three cases (`addita combines two vectors`,
  `normata returns unit vector`, `normata returns zero for zero-length`).
- The Stage-0 scorecard therefore correctly records one co-located test source
  and 25 structural-only module rows. **Verdict: 26/1 coverage gap confirmed.**

## 2. Stale-Latin probe diagnosis (delivery §2.2)

Live facts:

- `src/math.fab` exists; `Vector3` is public; `vector3`, `Vector3.addita`, and
  `Vector3.normata` exist in that module.
- `radix check --locale en src/math.fab` exits 0 with warnings only.
- The probe uses the retired Latin surface: `importa ex "./math" privata math`,
  `probandum`, `proba`, `adfirma`, `fixum`. The current parser rejects the old
  import privacy modifier (`PARSE050.import_privata_removed`).

Reproduced commands and verdicts:

```text
faber test /Users/ianzepp/work/faberlang/triga/src/math.proba
  -> exit 1; 49x SEM001.unknown_identifier + 49x SEM008.undefined_name
     (23x LOCALE002 warnings stream first; error tail is SEM008)

radix check --locale en src/math.proba
  -> exit 1; 49x SEM001.unknown_identifier + 49x SEM008.undefined_name
```

**Verdict**: SEM001/SEM008 cascade confirmed on the current binary. The symptoms
are a stale proba surface plus a semantic cascade, not evidence that the math
module disappeared.

**Classification** — Triga test source: stale Latin probe against the current
`en` locale; not a module rename. **Consequence**: rewrite as `en` in
`tgh-s05-c01`; no compatibility alias, no math-module edit.

## 3. `faber test .` package-path defect (delivery §2.3)

Reproduced commands and verdicts:

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

**Classification** — Radix/Faber package route: relative package-path
normalization defect. **Consequence**: named prerequisite `rdx-s05-1`.

## 4. Converted English probe MIR-lowering defect (delivery §2.4)

Recorded diagnosis (delivery body, 2026-08-16 19:20): a temporary package
containing the unchanged `src/math.fab` and only a converted English
`math.proba` passed package analysis, then the MIR runner failed all three
cases:

```text
unsupported MIR lowering: method call before runtime/provider MIR lowering
unsupported MIR lowering: projection base that does not resolve to a local value
```

Live re-verification (2026-08-16, current binary): reproduced head-on with a
temporary package — unchanged `src/math.fab`, converted English probe, manifest
identical to Triga's except the provider renamed. Package analysis passes; the
runner fails all three cases with exactly the two recorded lowering errors:
`test result: FAILED. 0 passed; 3 failed; 0 skipped`.

Manifest nuance observed during re-verification: with the package identity
(name and provider) left as `triga` in the temporary manifest, package analysis
fails first (`SEM002.unknown_qualified_type` x7,
`SEM004.namespace_missing_export` x4) and the runner defect does not surface;
renaming the provider name lets analysis pass and the recorded runner defect
appear unchanged. The distinguishing variable was the triga package identity,
not the `targets` list (checked both ways). This package-route variance does
not change the triage conclusion; it is recorded here so the coverage gate
re-tests both surfaces after the Radix prerequisites land.

**Classification** — Radix MIR runner: unsupported lowering defect for method
calls and field projections. **Consequence**: named prerequisite `rdx-s05-2`; no
assertion weakening or count-only substitutions.

## 5. Triage conclusion (delivery §2.5)

The Stage-0 Q4 conclusion remains in force: the executed-proba tier is open.

| Symptom | Owner | Classification | Stage-0.5 consequence |
| --- | --- | --- | --- |
| `src/math.proba` emits SEM001/SEM008 | Triga test source | stale Latin probe against the current `en` locale; not a module rename | rewrite as `en` in `tgh-s05-c01` |
| `faber test .` emits `cannot read '.'` | Radix/Faber package route | relative package-path normalization defect | named prerequisite `rdx-s05-1` |
| converted probe reaches runner but MIR lowering rejects method/field shapes | Radix MIR runner | unsupported lowering defect | named prerequisite `rdx-s05-2` |

Coverage units may author their `.proba` files while the owning-repo routes are
in flight, but **no coverage unit may claim executed-proba completion until
`rdx-s05-1` and `rdx-s05-2` land and the gate runs the cases successfully**.
Executed-proba evidence remains open until those prerequisites land.

## 6. Named external routes (delivery §5)

- **`rdx-s05-1`** (repo `radix`) — normalize
  package-test path inputs. Write scope: `radix/crates/faber/src/commands/test.rs`,
  `radix/crates/radix-package/src/discovery.rs` or the owning
  path-normalization seam, plus focused package/test regressions. Done-when:
  from the Triga root, `faber test .` no longer emits `cannot read '.'`; a
  relative Triga package path from the workspace parent and an absolute Triga
  package path enter the same package discovery path.
- **`rdx-s05-2`** (repo `radix`) — lower the converted Triga
  method/projection probe. Write scope: `radix/crates/radix/src/mir/lower/place.rs`,
  `radix/crates/radix/src/mir/lower/runtime.rs`, and focused MIR/proba
  regression fixtures. Done-when: a package fixture containing the unchanged
  Triga math module and the converted three-case `math.proba` reaches
  `3 passed, 0 failed`, naming both observed lowering failures.

Both are owning-repository units dispatched in `radix/`. This receipt contains
**no Radix implementation**; routing only.

## 7. Sanity / verification log

- `proof/inventory/triga-inventory.json` module list length: 26 — matches
  `find src -type f -name '*.fab' | wc -l` of 26.
- Single `.proba`: `src/math.proba` (3 cases) — matches inventory row for the
  proba source.
- `faber test .` / `faber test src` package-path failures and the two
  single-file SEM cascades re-ran green-to-red as recorded in §2–§4 above.
- No span of this receipt edits `src/**/*.fab`, `src/**/*.proba`,
  `proof/**`, or Radix files.