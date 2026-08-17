# Triga Stage-0.5 proba coverage

`../../scripta/check-proba-coverage` is the executed-proba gate for the live
Triga package. Run it from `triga/` with the workspace Faber environment:

```bash
FABER_BIN=/Users/ianzepp/work/faberlang/radix/target/release/faber \
FABER_LIBRARY_HOME=/Users/ianzepp/work/faberlang \
  ./scripta/check-proba-coverage
```

The gate discovers `src/**/*.fab`, requires exactly one sibling
`src/**/*.proba` for every module, and invokes Faber's package linker/test
runner once per proba file:

```text
<FABER_BIN> test /absolute/path/to/triga --include math.proba
<FABER_BIN> test /absolute/path/to/triga --include geometry/attribute.proba
```

The package path is absolute so Faber uses its package link-then-run route.
`--include` is relative to the package `src/` root and selects exactly one
proba source for that module. Imported `.fab` modules remain available to the
selected test. The gate continues through all 26 selections, so an analysis,
MIR, or runner failure is isolated to its module row rather than fail-closing
the remaining rows. The direct single-`.proba` route is deliberately not used;
it skips the package link step that resolves receiver methods before lowering.

The current receipt (`proof/coverage-scorecard.json`, coverage revision 2)
records **21/26** module selections at `executed-proba` through this package-link
route, using
`/Users/ianzepp/work/faberlang/worktrees/hand-35/radix/target/debug/faber`
built from packet radix `4d7402ba7` against triga `c1700d4` (after `dfe9eb5`
optional-field unwraps and `50e99c0` Material.side `int<u32>`). The passing
selections are `src/face.fab`, `src/geometry.fab`,
`src/geometry/attribute.fab`, `src/geometry/batch.fab`,
`src/geometry/bounds.fab`, `src/geometry/data.fab`, `src/geometry/layout.fab`,
`src/graph.fab`, `src/graph/camera.fab`, `src/graph/object.fab`,
`src/lighting.fab`, `src/lighting/light.fab`, `src/material.fab`,
`src/math.fab`, `src/primitives.fab`, `src/primitives/basic.fab`,
`src/renderable.fab`, `src/renderable/mesh.fab`, `src/scene.fab`,
`src/shader_contract.fab`, and `src/triga.fab`. The remaining five rows reach
the runner and fail cases. This is a partial package-link result, not 26/26.

This receipt was refreshed at `2026-08-17T17:37:09Z`. The prior 9/26 baseline
(`2026-08-17T11:39:03Z`, radix `60f495870`) had 17 reds, many of them MIR-link
(`named aggregate field type mismatch`, `option unwrap operand is not nullable`)
or earlier assertion/provider failures. After `dfe9eb5` + `50e99c0`, the
MIR-link class is gone from this receipt. Twelve previously red modules are
now executed-proba. The five remaining reds are assertion-time
`runner-failure` rows, a new residual class, not the known MIR-link blockers:

- `src/material/base.fab` 3 passed / 1 failed:
  `texture descriptor preserves its placeholder shape`
- `src/material/basic.fab` 2 passed / 1 failed:
  `basic material rejects invalid names and colors`
- `src/material/lit.fab` 1 passed / 2 failed: Phong defaults / unsupported-base
  facts
- `src/material/standard.fab` 1 passed / 2 failed: standard defaults /
  unsupported-base facts
- `src/resource.fab` 5 passed / 1 failed:
  `lifecycle accessors separate live current handles from retired handles`

The scorecard still marks `rdx-s05-3` unresolved because a passing test name
contains the word "unsupported"; no MIR or provider diagnostic codes were
observed. The gate exit is 1 (`blocked`, `complete: false`). The run remains
open at 21/26, not 26/26.

`FABER_BIN` may be set explicitly. Otherwise the gate uses
`$FABER_LIBRARY_HOME/radix/target/release/faber`. `PROBA_TIMEOUT_SECONDS` may
bound one module run; its default is 180 seconds.

## Evidence rules

A module is `executed-proba` only when all declared `test` cases are reported
as passed, with zero failed and zero skipped cases, and the runner exits zero.
A parsed source, structural check, case count, or facade file by itself cannot
promote a row. Missing probes, orphan probes, package analysis errors,
MIR lowering errors, runner failures, and count-only output keep the row below the
executed tier and make the gate exit non-zero.

The gate writes its receipt before returning. The scorecard's `stage0_5` object
contains the aggregate counts, exact command template, absolute package and
Faber paths, prerequisite observations, diagnostic-code counts, and every red
module. Each module row contains `proba_execution` with its relative proba
path, declared and observed counts, exit status, failures, diagnostics, and
actual evidence tier. The pre-existing structural fields remain the Stage-0
inventory frame; they are not execution proof.

A red result is intentional evidence. The current receipt has no `PARSE050`
row: `PARSE050.import_privata_removed` is historical evidence from the retired
import-modifier and single-file/roundtrip routes, not the current Triga
package-link result. Keep diagnostics emitted by a rerun visible in the
receipt; do not turn a failed imported-module run into a skip or a count-only
pass.

The Stage-0.5 tier is open unless the receipt reports `26/26` modules at
`executed-proba` and marks the aggregate `complete: true`. The current live
workspace may therefore produce a non-zero gate result while still updating
`proof/coverage-scorecard.json`; that is the honest outcome.

`proof/inventory/triga-inventory.json` is read-only foreign evidence for this
unit. The gate checks its live module set but never edits or regenerates it.
