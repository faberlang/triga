# Triga Stage-0.5 proba coverage

`../../scripta/check-proba-coverage` is the executed-proba gate for the live
Triga package. Run it from `triga/` with the workspace Faber environment:

```bash
FABER_LIBRARY_HOME=/Users/ianzepp/work/faberlang \
  ./scripta/check-proba-coverage
```

The gate discovers `src/**/*.fab`, requires exactly one sibling
`src/**/*.proba` for every module, and invokes the package-aware runner with
an absolute package path and a relative proba filter:

```text
<FABER_BIN> test /absolute/path/to/triga --filter src/math.proba
```

`FABER_BIN` may be set explicitly. Otherwise the gate uses
`$FABER_LIBRARY_HOME/radix/target/debug/faber`. `PROBA_TIMEOUT_SECONDS` may
bound one module run; its default is 180 seconds.

## Evidence rules

A module is `executed-proba` only when all declared `test` cases are reported
as passed, with zero failed and zero skipped cases, and the runner exits zero.
A parsed source, structural check, case count, or facade file by itself cannot
promote a row. Missing probes, orphan probes, package analysis errors, MIR
lowering errors, runner failures, and count-only output keep the row below the
executed tier and make the gate exit non-zero.

The gate writes its receipt before returning. The scorecard's `stage0_5` object
contains the aggregate counts, exact command template, absolute package and
Faber paths, prerequisite observations, diagnostic-code counts, and every red
module. Each module row contains `proba_execution` with its relative proba
path, declared and observed counts, exit status, failures, diagnostics, and
actual evidence tier. The pre-existing structural fields remain the Stage-0
inventory frame; they are not execution proof.

A red result is intentional evidence. In particular, `PARSE050`, `SEM006`, and
MIR/provider-lowering failures must remain visible in the receipt. Do not turn a
failed imported-module run into a skip or a count-only pass.

The Stage-0.5 tier is open unless the receipt reports `26/26` modules at
`executed-proba` and marks the aggregate `complete: true`. The current live
workspace may therefore produce a non-zero gate result while still updating
`proof/coverage-scorecard.json`; that is the honest outcome.

`proof/inventory/triga-inventory.json` is read-only foreign evidence for this
unit. The gate checks its live module set but never edits or regenerates it.
