# Compiler-Lane Ledger

**Status**: active tracking surface (2026-08-01) — consolidated home for every
toolchain/language item routed out of the triga-engine campaign
**Owner question**: resolved per campaign decision (see §0) — small mechanical items
are executed by the engine campaign's compiler lanes (G1 precedent: faber `34a826d`);
language-scope items (G2/G3) remain decision-gated; the triga-threejs-80 campaign's
Radix stages remain the canonical long-term home for radix crate work.
**Monitoring**: weekly scheduled check (`compiler-lane-health`) reads this ledger +
the S0 report §8 and re-validates each item against live repo evidence.

## 0. Ownership statement

All items below are radix/faber crate changes. Nothing in this ledger has an
always-on executor: campaigns move when a session drives them. This ledger exists
so that whenever a session touches any of the three campaigns (80, 90, engine),
the routed items are the first thing checked — and the weekly monitor is the
safety net that surfaces drift even when no session runs.

Proposed routing (per campaign decision 2026-08-01):
- **G1b, G4, E0308 — engine campaign executes** (they block the engine's own
  validation gates: check-compile, faber test, corpus build). G1 precedent.
- **G2, G3 — user decision-gated** (language-scope changes; handoff:
  `language-lane-handoff.md`).
- The 80 campaign's Radix stages remain the canonical owner of radix crate work
  long-term; the engine executes only what blocks its own gates.

## 1. Item table

| ID | Gap | Repo / crate | Blocks | Status (2026-08-01) | Evidence | Owner |
| --- | --- | --- | --- | --- | --- | --- |
| G1 | faber TS emitter: nested library modules never emitted/mapped | faber `src/package/product.rs` | nested-package TS product builds (corpus) | **FIXED** — faber `34a826d`, corpus green | report §8; product.rs recursive walk | engine (done) |
| G1b | radix TS emitter: hollow (map-only) facade emits no namespace aggregate, importers always emit the alias import → TS2305 | radix `radix-codegen-ts` (`module.rs::write_module_exports` early-return on empty exports) | any facade imported as a namespace (hit via `triga.fab`→`triga:material` post-DS-A; triga-side fixed with leaf imports) | **OPEN** — triga-side worked around; emitter lane to fix | report §8; DS-A report | engine (mechanical, authorized) |
| G2 | cross-module `discretio` enum variant construction/matching | radix parser + semantic + codegen (Rust/TS) | DS-D scene split (SceneNodeKind) | **OPEN** — parked; probes in `/tmp/dsd-probe-1` | `language-lane-handoff.md` | user decision (language) |
| G2b | union (`∪`) member pattern-matching (`casu`) fails even same-module | radix semantic typecheck pattern pass (enum-only) | union consumers must use dedicated accessors | **OPEN** — documented; parser anticipates union variants | `/tmp/dsa-probe/`; DS-A report | user decision (language) |
| G3 | faber `PKG001` library import-cycle rejection | faber provider check | DS-D scene split (node↔store↔query cycle) | **OPEN** — parked | `language-lane-handoff.md`; `/tmp/dsd-probe-2` | user decision (language) |
| G4 | MIR stepper cannot lower receiver-method calls | radix MIR stepper (`faber test` runner) | `.proba` layer (all 3 of math.proba fail) | **OPEN** — repro recorded | report §8; `faber test .` → 0/3 | engine (mechanical, authorized) |
| E0308 | radix Rust emitter injects `&…clone()` args + `Some(…)` wraps (4 errors in regenerated `target/faber/src/main.rs`) | radix `radix-codegen-rust` | check-compile generated-Rust gate (red) | **OPEN** — fixtures verified correct in source; attributed to 80 generated-Rust lane, engine authorized to execute | report §8; exact errors main.rs:25/28/32/4273 | engine (mechanical, authorized) |

## 2. Gated campaign items (non-compiler, for completeness)

| Item | Gate | Status |
| --- | --- | --- |
| DS-S2 Phase 2 C+E (Demo A wiring, two-demo oracle acceptance) | 80 Stage 5 (Hello Triga / direct WebGPU host) | OPEN — A/B/D landed (hosts `befe85c`) |
| P1.3 artifact regeneration (triga-lit.* through radix) | 80 Stage 4–5 graphics-MIR; lit shader stays hand-authored (semantics un-emittable) | OPEN — map: `P13-regeneration-map.md` |
| DS-E C3 rename (`geometry_vertex_layout_matches` → receiver) | 80 Stage 4 reflection agreement closes | OPEN — name preserved verbatim until then |
| DS-D scene split | G2 + G3 (above) | OPEN — parked; relocation recipe in `/tmp/dsd-leaves` |

## 3. Validation hooks (how the monitor checks)

```bash
# G1 / G1b / corpus: the TS product path
cd corpus/webgl-geometries && ./tests/run.sh   # both demos, expect exit 0

# E0308: the generated-Rust gate
./scripta/check-compile                        # expect: leaf parses ok, then the 4 E0308s

# G4: the proba runner
faber test .                                   # expect: 0 passed / N failed (stepper)

# G2/G3: no live change until the language lands; re-probe only when radix
# advances (probes preserved at /tmp/dsd-probe-* and /tmp/dsa-probe/)
```

## 4. Definition of done per item

- **G1b**: a hollow facade imported as a namespace emits correctly (or importers
  skip the alias import); corpus + triga.facade build green without the triga-side
  leaf-import workaround being load-bearing.
- **G4**: `faber test .` runs `src/math.proba`'s 3 tests (2 pass + 1 zero-length),
  and new proba coverage can be added for the landed leaves.
- **E0308**: `./scripta/check-compile` fully green end-to-end.
- **G2/G3**: the DS-D tooling probe (radix check + faber check + faber run --compile
  on a scratch `triga:scene/store` import) passes, then DS-D executes per the
  preserved relocation recipe.
