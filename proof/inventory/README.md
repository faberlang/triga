# Triga live inventory

`triga-inventory.json` is the committed, schema-versioned inventory of the
live `src/` tree. Its counts are derived from the source files; do not edit the
JSON by hand.

From the `triga/` repository root, regenerate the inventory with:

```sh
./proof/inventory/derive-inventory.sh
```

The generator walks `src/**/*.fab` and co-located `src/**/*.proba` files. It
records the source revision, package versions, generation timestamp, module
counts, null/error facts, ABI field occurrences, tests, consumer imports, and
evidence tiers. When the derived facts are unchanged, it preserves the
provenance fields so a repeat run is byte-identical.

Validate the committed inventory with the restored executable caller
(the invocation `ca784f6` removed from `check-scorecard`):

```sh
./proof/inventory/test-check-inventory
```

That caller runs `./proof/inventory/check-inventory` against the committed
tree, then proves a 1-proba committed baseline is rejected. It never rewrites
`triga-inventory.json` and never treats a short committed proba list as 26/26
progress.

```sh
./proof/inventory/check-inventory
```

The validator re-derives the inventory in a temporary file, compares all facts
(the timestamp and source revision are expected to differ during validation),
checks the fixed schema fields, and requires the module set to equal the live
`find src -name '*.fab'` set of 26 modules. A committed `co_located_tests`
set that does not equal the live `find src -name '*.proba'` set is a reported
mismatch (counts plus missing/extra paths), not a silent 26/26 pass. It exits
non-zero for malformed, stale, incomplete, or future inventory data.
