# Poker Face — Stage 1 close attempt (2026-07-11)

**Evaluator mode:** cold gate vs goal/delivery criteria, not implementer narrative.  
**Task:** Vivi `5f68f68`  
**Verdict:** **NOT CLEARED** (Stage 1 campaign must stay open)

## Original target

- Goal: [`goals/01-math-transform-foundation.md`](goals/01-math-transform-foundation.md)
- Delivery: [`01-math-transform-delivery.md`](01-math-transform-delivery.md)
- Campaign gate: reusable vector/matrix/quaternion/Euler/color/transform ops
  execute consistently on required **Rust** and **MIR/GPU** paths.

## HEADs (audit time)

| Repo | HEAD | Note |
| --- | --- | --- |
| triga | (this commit) | families+Euler + exempla Color call-arg workaround |
| triga merge | `c3f2972` | Stage1 families+Euler absorb |
| radix | `2f3e3ccb1` | metal/llvm fail-closed matrix |
| radix | `f99b8fad7` | WGSL matrix register subset |
| faber | `d9dd406` | Stage3 native lib path-link (adjacent) |

## Requirement checklist

| # | Requirement | Status | Class if not SATISFIED |
| --- | --- | --- | --- |
| G1 | Transform-chain workload: composition + inverse policy (zero-norm, singular) | **SATISFIED** — `exempla/triga-transforms.fab`; `./scripta/check-transforms`; stepper `stepper_runs_matrix4_transform_chain_matches_triga_cpu` | |
| G2 | Required matrix ops execute (not grammar-only) on Triga CPU | **SATISFIED** — Matrix4 compose/applica/inverse/affine path in `src/triga.fab` | |
| G3 | Provider path typecheck (`triga:triga`) | **SATISFIED** — `faber check exempla/triga-transforms.fab` | |
| G4 | Generated-Rust compile+run of transform exemplum | **PARTIAL** — works after binding Color locals; **inline library Color record literals as call args mis-emit as Euler** | **HIGH** residual (package library construct) |
| G5 | MIR CPU register matrix/vector shared subset | **SATISFIED** — lower+stepper matmul/applica/inversa/materialize | |
| G6 | Selected GPU: WGSL register matrix construct/cells | **SATISFIED** — `wgsl_text_matrix_*` on `f99b8fad7` (mat2x2, local construct, scalar return) | |
| G7 | Fail-closed unsupported GPU backends for matrix | **SATISFIED** — metal/llvm stable shapes `2f3e3ccb1` | |
| G8 | Metal/llvm matrix **register emit** parity | **MISSING** — intentional fail-closed; not selected Stage1 path | **MEDIUM** (only if gate requires all GPU backends) |
| G9 | Full triga Matrix4 transform chain on GPU | **MISSING** — WGSL path is small register matrices, not triga domain Matrix4 | **MEDIUM** |
| G10 | Quaternion/Euler/color/box/sphere/plane/ray CPU families | **SATISFIED** — on main + exempla proofs | |
| G11 | Package MIR `faber run` without `--compile` for library imports | **MISSING** — explicit “use compiled package execution” | **LOW** for Stage1 (compiled path exists) |
| G12 | No overclaim: campaign Status not “complete” until gate holds | **SATISFIED** if Status stays open | |

## Misses

### HIGH

1. **Library genus record literal as call argument → wrong Rust type**  
   - Repro: `importa ex "triga:triga"` + `color_interpolata(Color { r=… }, …)` emits `Euler { r,g,b }`.  
   - Assignment form `fixum Color a ← Color { … }` emits correctly.  
   - Flat combined source (check-transforms) emits correctly.  
   - **Owner:** hunter-1 (radix package/library codegen + faber package emit).  
   - **Workaround in exempla:** bind locals before call (this kill).

### MEDIUM

2. Full multi-backend matrix **emit** (metal/llvm) not implemented — fail-closed only.  
3. Selected GPU subset ≠ full triga transform-chain on device.

### LOW

4. `faber run` interpret/MIR path rejects library imports (use `--compile`).

## Validation commands (rerun)

```bash
# triga
./scripta/check-source
./scripta/check-compile
./scripta/check-transforms
FABER_LIBRARY_HOME=.. faber check exempla/triga-transforms.fab
FABER_LIBRARY_HOME=.. faber run --compile exempla/triga-transforms.fab

# radix
cargo test -p radix --lib lowers_matrix_
cargo test -p radix --lib stepper_runs_matrix
cargo test -p radix --lib wgsl_text_matrix_
cargo test -p radix --lib metal_text_matrix_register
cargo test -p radix --lib llvm_text_matrix_register
```

## Verdict

**NOT CLEARED** for Stage 1 campaign close.

**Why:** Core goal still requires cross-path agreement on the shared subset and
honest product Rust. The package-path Color call-arg emit bug is a high miss
until fixed at the compiler seam (workarounds do not clear the gate). Selected
WGSL + fail-closed metal/llvm + Triga CPU families are **green slices**, not a
full Stage 1 close.

**Completion estimate (secondary):** ~75% of foundation intent; gate blocked.

## Next step

1. Keep CAMPAIGN Stage 1 **not closed**.
2. File residual need for library call-arg record construct emit (HIGH).
3. Do not promote Stage 2 on a false Stage 1 close.
4. Optional later: metal matrix register emit as separate selected residual.
