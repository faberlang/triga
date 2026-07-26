# Goal Check: HV-05C Multi-Draw Host Path Residual

**Goal path:** `triga/docs/factory/hello-voxel/residuals/hv05c-multi-draw-host-path/goal.md`
**Planner:** planner-1
**Date:** 2026-07-26
**Evaluator mode:** goal-check (strict — pre-implementation readiness)
**Intended consumer:** delivery lowering → Hand implementation

## Verdict

**READY** — a mid-tier implementer can start without inventing architecture or
hidden scope.

## Reasoning

The goal is a single-file proof script rewrite with a well-defined API surface
proven by HV-07C tests. Every major claim is grounded in live artifacts. No
architecture decisions remain unresolved. Two minor surface questions (pixel
readback mechanism, depth texture resize) have default approaches that do not
require host runtime changes. Stop conditions are explicit and conservative.

## Key Points

| Category | Finding |
|---|---|
| **Desired end state** | Concrete: proof script uses multi-draw path, `draw_count === 4` in frame submits, pixel validation preserved. Not activity-based — it names the observable outcome. |
| **Grounding** | Every claim points to a specific file + line range. Live evidence from `draw.json`, `emit-package-geometry.mjs`, `webgpu-runtime.js`, `hv07c-resource-cycle-test.mjs`, and `main.fab` confirms the multi-draw path is complete and the only gap is the proof script. |
| **Architecture decisions** | No open decisions. Host API is frozen (`createChunkGraphicsResources`, `applyChunkResourceReplace`, `runChunkGraphicsFrame`). Per-chunk resource pair contract is frozen (positions + colors + indices, generation-tracked). Proof script is consumer-only — no API design required. |
| **Boundaries** | Goals (rewrite proof, preserve visual law), non-goals (no host/emit changes, no radix), constraints (path-disjoint from driver dirt), stop conditions (pixel readback gap → pause and report) are all explicit. |
| **Acceptance criteria** | Seven objective criteria: correct imports, per-chunk geometry loading, four chunk creates, `draw_count === 4`, `multi_draw === true`, `proof.ok === true`, resize + clear control preserved. All falsifiable without chat context. |
| **Validation** | Commands provided (`node scripta/emit-package-geometry.mjs`, `node scripta/run-hv04c-host-proof.mjs`). Manual browser inspection also specified. |
| **Implementation handoff** | Single file (`examples/hello-voxel/scripta/hv04c-host-proof-app.js`). Clear API surface to use. Working reference in `hv07c-resource-cycle-test.mjs`. Pixel readback adaptation and resize are the only novel surface beyond what HV-07C already exercises. |
| **Open questions** | Two open questions, both with defaults. Neither blocks implementation — defaults can be tried first. If either default fails, the stop condition triggers a pause, not silent drift. |
| **Staleness** | All claims verified against current repo state. `webgpu-runtime.js` multi-draw path exists at lines 1293–1632. `hv04c-host-proof-app.js` old path confirmed at lines 11–12 and 159–229. No drift. |

## Blocking Gaps

None. The two open questions have default approaches that are safe to attempt
first. If they fail, they surface as explicit stop conditions (not silent
assumptions).

## Escalation Reason

N/A — verdict is READY, not NEEDS FURTHER REVIEW.

## Recommended Next Step

**Delivery lowering** — one unit, implementable by a mechanical Hand.
