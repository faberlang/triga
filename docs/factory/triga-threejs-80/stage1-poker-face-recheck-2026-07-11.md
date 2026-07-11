# Poker Face recheck — Stage 1 after Color call-arg fix (2026-07-11)

**Task:** Vivi `03b22b7`  
**Prior:** [`stage1-poker-face-2026-07-11.md`](stage1-poker-face-2026-07-11.md) — **NOT CLEARED** (HIGH Color call-arg)  
**Verdict:** **CLEARED** for Stage 1 **foundation gate** (selected paths); campaign may promote Stage 1 complete with documented non-goals

## HEADs (recheck)

| Repo | HEAD | Note |
| --- | --- | --- |
| radix | `3d804eb35` | includes `cbb87cc3f` Color Verte fix + GPU subset + HIR docs merge |
| faber | `f73da3b` | Color call-arg regression test |
| triga | `f9229aa` | Color call-arg exempla form restored |
| faber-runtime | `38be94a` | Arena (Stage2 unblock; not Stage1 gate) |
| examples | `55f97fc` | sqlite S3A+B (product; not Stage1 gate) |

## Requirement checklist (recheck)

| # | Requirement | Status |
| --- | --- | --- |
| G1 | Transform-chain workload (compose/inverse policy) | **SATISFIED** — `check-transforms`; stepper triga chain |
| G2 | Matrix ops execute on Triga CPU | **SATISFIED** |
| G3 | Provider path typecheck `triga:triga` | **SATISFIED** — `faber check exempla/triga-transforms.fab` |
| G4 | Generated-Rust compile+run transform exemplum | **SATISFIED** — `faber run --compile`; Color call-args emit `crate::triga::Color` |
| G5 | MIR CPU register matrix/vector subset | **SATISFIED** — lower + stepper suites |
| G6 | Selected GPU WGSL register matrix | **SATISFIED** — `f99b8fad7` + `wgsl_text_matrix_*` |
| G7 | Fail-closed metal/llvm matrix | **SATISFIED** — `2f3e3ccb1` + tests |
| G8 | Color library call-arg emit | **SATISFIED** — `cbb87cc3f` + `library_genus_record_call_arg_emits_correct_type` |
| G9 | Metal/llvm matrix **emit** (not just reject) | **NOT APPLICABLE** — selected Stage1 GPU path is WGSL; metal/llvm stay fail-closed by design |
| G10 | Full triga Matrix4 transform on GPU device | **NOT APPLICABLE** / deferred Stage4 graphics MIR — not Stage1 selected subset |
| G11 | Quaternion/Euler/color/spatial CPU families | **SATISFIED** |

## High misses

**None.** Prior HIGH (Color→Euler call-arg) is closed.

## Remaining open (non-blocking for foundation)

| Item | Owner later | Note |
| --- | --- | --- |
| metal/llvm matrix register emit | optional residual | fail-closed shapes stable |
| Matrix4 device/register product chain | graphics MIR | WGSL mat2x2 only today |
| Stage 2 scene graph | h5 after arena | runtime Arena on main `38be94a` |

## Validation (this recheck)

```text
triga: check-source=0 check-transforms=0
faber check exempla/triga-transforms.fab ok
faber run --compile exempla/triga-transforms.fab ok (exit 0)
emit: color_interpolata(&crate::triga::Color { ...
faber: library_genus_record_call_arg_emits_correct_type ok
radix: lowers_matrix_* 5 ok; stepper_runs_matrix* 5 ok
radix: wgsl_text_matrix_* 3 ok; metal/llvm matrix register reject ok
```

## Verdict

**CLEARED** for Stage 1 foundation (goal 01 selected paths).

**Why:** The only high miss blocking the prior poker-face is fixed and re-proven on the package path. Selected CPU / generated-Rust / MIR stepper / WGSL subset / metal-llvm fail-closed all green. Remaining GPU multi-backend emit is an explicit non-goal of the selected Stage1 path, not a silent gap.

**Completion estimate (secondary):** foundation ~95%; full multi-backend matrix product out of stage scope.

## Campaign Status action

Update CAMPAIGN Stage 1 to **complete (foundation)** with residual non-goals listed. Do not claim Stage 4 graphics MIR or metal matrix emit.
