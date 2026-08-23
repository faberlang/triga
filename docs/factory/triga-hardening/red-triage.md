# Triga Hardening — Stage 1 Known-Red Triage Map

**Status**: complete (2026-08-23 planner pass, task `0ebb9e29`)
**Kind**: goal-check + red triage (planner artifact; no product code)
**Campaign**: [`CAMPAIGN.md`](./CAMPAIGN.md) — goal-check target
**Consumer**: Mind (unit dispatch + campaign status reconciliation)
**Tip measured**: triga `b657f3c`; sibling radix `0917e2b28` (binary
`radix/target/debug/faber`, 2026-08-23 build, ~17 min older than the last
radix commit — commits in that window are docs/test-only)

## 1. Goal-check summary

| Field | Value |
| --- | --- |
| Artifact | `docs/factory/triga-hardening/CAMPAIGN.md` (Status line + Current State table) |
| Evaluator mode | cold self-pass against live `scripta/`, exempla, scorecard, and current sibling binaries |
| Intended consumer | Mind (red-triage routing + status refresh) |
| Verdict | **NEEDS STATUS REFRESH** (not a NOT-READY goal: the campaign's architecture locks are intact; the known-red list itself is stale against the tip) |

The campaign's known-red list (`source-lint [intentional], exempla PARSE050,
proba 22/26, WGSL PARSE family`) was written 2026-08-17. Two of its four
entries no longer reproduce, one is a different defect than named, and one is
half-stale with its remainder toolchain-blocked. Mind should refresh the
Status line / Current State rows from this map (status execution is Mind's,
not planner's).

## 2. Red-triage map

Each named red classified; "smallest validation" is the command that proves
the classification. Executed checks are marked ✔ with date.

### 2.1 `source-lint [intentional]` — **stale-entry-already-fixed**

- **Classification**: stale-list entry. The intentional red (complete-genus
  lint reporting resource/material free-function families until Stage 2) was
  resolved by the early Stage 2 receiver-method migration `f309930`
  (2026-08-21, "stage-2 receiver-method migration per api-shape-policy §1/§5").
- **Owning surface**: triga `src/**` API shape (Stage 2 pattern landed ahead
  of the Stage 2 gate).
- **Smallest validation**: `./scripta/check-source` → exit 0. ✔ executed
  2026-08-23: silent exit 0 at tip.

### 2.2 `exempla PARSE050 (import_privata_removed)` — **stale entry; the live exempla red is a different, mechanical defect**

- **Classification**: PARSE050 does not reproduce. `faber check` exits 0 on
  all 15 README-documented exempla (✔ executed 2026-08-23, including every
  historically-red file). The `privata` spelling survives only inside
  frontmatter `syntax = "…"` documentation strings, which the checker ignores.
- **Live red at tip (new finding)**: the canonical structural tier exits 1 at
  `check-exempla-inventory`'s per-file `radix check --locale en` loop with
  `PARSE030:expected_expression` at `exempla/triga-basics.fab:1` (`+++` TOML
  frontmatter). The raw radix CLI rejects exempla frontmatter; the faber
  product CLI accepts the same files (rc=0). ✔ executed 2026-08-23:
  `faber check exempla/triga-basics.fab` → rc 0; `radix check --locale en` →
  rc 1.
- **Owning surface**: triga `scripta/check-exempla-inventory` (route choice),
  not radix and not the exempla sources.
- **Smallest validation**: `FABER_BIN=<sibling radix debug faber>
  ./scripta/check-exempla-inventory` → exit 0 after the route fix (§3).
- **Dispatchable**: yes — lowered as unit `tgh-rt-1` (§3).

### 2.3 `proba 22/26` (`tgh-s05-gate`) — **real blocker, owned by radix MIR runner**

- **Classification**: real defect class, but the owning surface is the radix
  MIR runner, not triga. Committed receipt `76ded8b` (2026-08-17) records
  22/26 with 4 blocked rows (`material/base`, `material/lit`,
  `material/standard`, `scene`) on `unsupported MIR lowering` diagnostics.
- **Fresh evidence (foreign WIP, uncommitted)**: the dirty
  `proof/coverage-scorecard.json` in the shared tree is a 2026-08-21 re-run
  recording **4/26 executed, 22 blocked** — the Stage 2 receiver-method
  migration (`f309930`) moved probas onto method calls that the MIR runner
  cannot lower (`method call before runtime/provider MIR lowering`, map value
  iteration, non-local projection bases). One row is a genuine
  runner-executed failure (`material/base` "texture descriptor preserves its
  placeholder shape"). This re-run is foreign dirt: not committed, not
  overwritten; Mind should reconcile it with its owner before it becomes the
  receipt of record.
- **Owning surface**: radix MIR lowering (runner support for method calls /
  provider resolution); one candidate triga-side test expectation
  (material/base placeholder-shape case) once the runner unblocks.
- **Smallest validation**: after radix MIR method-call lowering lands,
  `./scripta/check-proba-coverage` → 26/26, `stage0_5.complete: true`.
- **Dispatchable in triga now**: no. Campaign overlap rule already routes
  these residuals through the owning gate/Radix MIR, not a triga Hand.

### 2.4 `WGSL PARSE family` — **parse half stale; remainder toolchain-blocked**

- **Classification**: the PARSE-family diagnostics
  (`PARSE001:retired_prefix_predicate`, `PARSE050`, `PARSE060`) from the
  tgh-s1-3 receipt (2026-08-17, worktree radix `6d2fb3bc2`) do not reproduce
  at the tip: all 7 `exempla/conformance/shader-contract/*.fab` programs and
  the root exempla parse clean (`faber check` rc=0, 0 errors each; ✔ executed
  2026-08-23). `not is null`, `#` comments, and frontmatter all parse on the
  current product route.
- **Remainder (unmeasured, blocked)**: the full conformance suite
  (emit → WGSL needles → Naga) cannot run at the tip because the suite's
  intentional staleness guard rejects the sibling faber binary (radix
  `crates/` commit time is newer than both `target/{release,debug}/faber`
  mtimes), and a fresh rebuild is currently blocked by foreign radix WIP
  (`radix-mir-metal` does not compile — E0425 — with a foreign session
  mid-edit/mid-build on shared main). This is toolchain/foreign-work
  contention, not a triga defect and not grounds to bypass the guard.
- **Owning surface**: radix build freshness (foreign session), then triga
  `scripta/check-wgsl-shader-contract-conformance`.
- **Smallest validation**: once a fresh sibling faber builds, rerun
  `./scripta/check-wgsl-shader-contract-conformance` and reclassify its
  emit/needle/Naga results.
- **Dispatchable in triga now**: no.

### 2.5 Rungs not on the known-red list (verified green at tip)

- `./scripta/check-capabilities` — exit 0. ✔ executed 2026-08-23.
- `./scripta/check-compile` own exempla checks + `check-transforms` — green;
  the rung's only failure is the exempla-inventory PARSE030 route red (§2.2).
  ✔ executed 2026-08-23 (full run, exit 1 attributable solely to §2.2).

## 3. P3 lowering — dispatchable units

Exactly one dispatchable unit survives the map. Everything else is blocked on
`tgh-s05-gate` / radix MIR / foreign radix build WIP; per the task contract,
the map is the deliverable for those.

### `tgh-rt-1` — exempla-inventory per-file checks use the faber product route

| Field | Value |
| --- | --- |
| id | `tgh-rt-1` |
| outcome | `check-exempla-inventory` checks each documented exempla through the sibling faber product CLI (the same `FABER_BIN` route `check-compile` already uses), replacing the raw `radix check --locale en` loop that rejects exempla TOML frontmatter with PARSE030 |
| write_scope | `triga/scripta/check-exempla-inventory` only |
| done_when | `FABER_BIN=<current sibling radix target/debug/faber> ./scripta/check-exempla-inventory` exits 0 (all 15 documented exempla checked, no PARSE030), and `./scripta/check-compile` no longer fails at the exempla-inventory rung |
| depends_on | none |
| sanity | one standalone `check-exempla-inventory` run with `FABER_BIN` set |
| read_scope | unrestricted |
| non_goals | no exempla content rewrites; no frontmatter removal from exempla; no radix CLI change; no compile-allowlist edits; no WGSL or proba work |
| risk | low — the faber route is proven green on all 15 documented exempla at the tip (§2.2); the change is a route swap inside one script |
| integrable | yes |

Implementation shape (advisory, not binding): resolve `FABER_BIN` the same way
`check-compile` does (`FABER_BIN` env, else sibling
`radix/target/{release,debug}/faber`), then replace the `"$RADIX_BIN" check
--locale en` loop with `"$FABER_BIN" check`. The faber binary already applies
the package locale from `faber.toml`.

## 4. Open questions for Mind

1. Foreign dirt: `proof/coverage-scorecard.json` (dirty, 2026-08-21 re-run at
   4/26) — identify its owner and reconcile; do not overwrite. It is the best
   current evidence that the executed-proba tier regressed after `f309930`,
   which Mind should surface to the radix MIR lane.
2. Foreign radix WIP currently breaks `cargo build -p faber` on shared main
   (`radix-mir-metal` E0425). The WGSL conformance remainder (§2.4) stays
   unmeasured until that session lands.
3. Campaign Status line and Current State rows for the known-red list are
   stale per this map; refresh is Mind bookkeeping, not planner scope.

## 5. Validation

```bash
./scripta/check-source                       # green at tip (§2.1)
FABER_BIN=../radix/target/debug/faber \
  ./scripta/check-exempla-inventory          # red at tip: PARSE030 (§2.2) — tgh-rt-1 turns this green
./scripta/check-capabilities                 # green at tip (§2.5)
../radix/target/debug/faber check \
  exempla/conformance/shader-contract/vertex-body-emits-wgsl.fab   # green at tip (§2.4)
git diff --check
```
