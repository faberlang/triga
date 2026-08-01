# DS-S2 — Engine Runtime Extraction + Shared-Renderer Vertical Slice

**Campaign**: triga-engine (Wave 2 parallel delivery spec)
**Seam**: S2 — engine-runtime home (decision (b): extract `corpus/_host` into
`hosts/webgpu-browser` `public/src/{product,contract,engine,backend,presentation}`,
landed as the first S2 delivery) + the S2-First Engine Render vertical slice
(checkpoint report §5, §6.1; tracks T-E, T-F)
**Risk verdicts (frozen at S0)**: fork is one-commit (2026-07-31 `806aa21`), two-way
divergent; hosts `webgpu-browser` authoritative; corpus is small (2 demos) — the merge
blast radius is cheapest now; deferral guarantees a second migration (T-E §4)
**Status**: draft (Wave 2 lowered in parallel with DS-E, DS-A, DS-B, DS-D, DS-G)
**Dependency edges**:
- **DS-S2 Phase 2 depends on 80 Stage 5** (direct WebGPU first scene — the Hello
  Triga workload; report §7.1: S2 ← 80 Stage 5). Phases C and E of the factory
  chain gate on it.
- **DS-S2 Phase 1 depends on 80 Stage 4–5 graphics-MIR** only for the triga-lit
  artifact regeneration coordination (report §4.4, §8 row 3); the extraction itself
  does not.
- **No seam overlap with DS-E/DS-A/DS-B/DS-D/DS-G**: those are triga `.fab` splits;
  DS-S2 makes **no `.fab` changes** (see Gates).
- **DS-S2 lands before the S2 gate reads green**: the extraction is the S2
  precondition, not an S2.5 (report §5).

---

## Goal

Extract the corpus `_host` greybox renderer out of `triga/corpus/_host` into the
authoritative sibling host `hosts/webgpu-browser`, reconciling the two-way-divergent
`webgpu-runtime.js` forks into one shared backend, and then deliver **S2-First
Engine Render**: two unrelated demos (80 Stage 5's Hello Triga workload and the
corpus `webgl-geometry-terrain`) rendering through **one shared engine facade** —
same shader, same pipeline-cache identity, same state machine — with
numeric/pixel/structural/shared-instance oracles and four deterministic failure
states, and **no private renderer, pipeline, or shader copy in either demo**.

The interpreted unit is the checkpoint's frozen decision set (report §5–§6.1):
- decision (b) extraction, first S2 delivery, migration mapping, corpus build-flow
  changes, sequencing, risks (report §5 = T-E §4–§5);
- first engine artifact definition, host seams, success/failure oracles, deferrals,
  factory phase chain A→E (report §6.1 = T-F §2);
- artifact honesty: the three corpus `reflection.json` fixtures are stale relative
  to the live emitter and must be regenerated through radix; `buildDescriptorFrom
  Reflection` (greybox-host.js) is **retired**, not moved (report §4.4).

## Invariant

**Shared engine, no private renderer per demo**: every standard demo renders through
the one engine facade at `hosts/webgpu-browser` and carries no private renderer,
pipeline, shader copy, WGSL, or render loop of its own — the two corpus demos prove
this by sharing one shader-module/pipeline-cache identity (GOAL "Standard demos
contain no private renderer, pipeline, or shader copy"; T-E "The corpus demos become
the engine's first shared-path consumers, which is exactly the S2 gate").

Sub-rules that hold regardless:

1. **Hosts is authoritative.** `hosts/webgpu-browser` is the origin and the GOAL's
   named long-term authority for "Browser device and GPU execution". The corpus
   `_host` files are seed bytes only; nothing grows there.
2. **Merge first, split after.** The two `webgpu-runtime.js` forks are reconciled
   into one file tree before any engine refactor; the merged backend keeps both
   consumer workloads (hosts proof harnesses + corpus demos) as regression gates.
3. **Admission is the only path.** Demos route through `contract/artifact-admission.js`
   (`loadFaberGraphicsPipeline`); `buildDescriptorFromReflection` (hand-rolled
   old-format admission) is **deleted**, asserted by grep.
4. **Artifacts are radix-regenerated.** `triga-lit.wgsl` + `triga-lit-reflection.json`
   are regenerated through radix to the current format (`schema_version`/`target`
   present), coordinated with 80 Stage 4–5; the corpus stale fixtures are not moved
   into `generated/`.
5. **DOM facts contract is preserved.** The demos' Faber controllers do not change:
   `data-scene-geometry`, `data-transform-payload`, `.triga-canvas`, `.triga-facts`,
   `data-fog-density` (terrain) keep working unchanged (T-E §5 risk 3).
6. **No `.fab` changes.** `check-source`/`check-compile` are untouched by this
   delivery (both remain exactly as today — RED on the two acknowledged items, which
   DS-E and the faber emitter own).

## Repo-Aware Baseline

### The fork (verified at spec time)

| File | hosts/webgpu-browser | triga/corpus/_host | Verdict |
| --- | --- | --- | --- |
| `faber-kernel.js` | `public/src/faber-kernel.js`, 719 ln | `public/faber-kernel.js`, 719 ln | **Byte-identical** (`diff -q` verified) |
| `webgpu-runtime.js` | `public/src/webgpu-runtime.js`, 2629 ln | `public/webgpu-runtime.js`, 2442 ln | **Divergent fork** (~39 diff hunks). Hosts-only: reduction-combine helpers (`normalizeCombineMetadata`, `combineReductionPartials`, `storageBufferByBinding`, `bufferIndexByBinding`, `combineMetadata` params, Wave-6 fail-closed chain checks). Corpus-only: MSAA 4× (`GRAPHICS_SAMPLE_COUNT`, `createMsaaColorTexture`, `msaaColorAttachment`), `BUFFER_USAGE.uniform`, `createDepthTexture(width,height,sampleCount)`. Neither is a strict superset. |
| `greybox-host.js` | — | `public/greybox-host.js`, 596 ln | Corpus-only greybox scene renderer; `buildDescriptorFromReflection` hand-rolls old-format admission and **bypasses** `loadFaberGraphicsPipeline` (which would reject its format) |
| `host-init.js` | — | `public/host-init.js`, 439 ln | Corpus-only host session + frame loop (rAF, resize, device-loss, readback proof, `.triga-facts` publishing) |
| `shaders/kernel.wgsl` | — | `shaders/kernel.wgsl`, 127 ln | Hand-authored lit shader: pos/normal/color (stride 36), transform storage + lighting uniform, hemisphere Lambert, ACES, sRGB, exp2 fog. **Stale** (not radix-emitted). |
| `shaders/reflection.json` | — | `shaders/reflection.json`, 173 ln | Old format: `"kind": "UniformBuffer"`/`"role": "Uniform"` (un-emittable by any radix enum); **no `schema_version`/`target`**. Cannot pass `loadFaberGraphicsPipeline`. |

### Hosts current state (verified)

- `public/src/webgpu-runtime.js` — compute product proof + graphics single-frame
  proof (single-sample, no MSAA); chunk resource lifecycle; gradient buffers;
  placement op set. **No engine layer**: no `engine/` dir, no scene extraction, no
  frame loop product, no host session, no canvas/input/presentation surface.
- `public/src/faber-kernel.js` — full admission (`loadFaberKernel` compute +
  `loadFaberGraphicsPipeline` graphics); requires `schema_version: 1` and
  `target: "wgsl-text"`; draws from `launch.webgpu_adapter`.
- `public/generated/` — compiler-owned: `kernel.wgsl`, `reflection.json`,
  `graphics.wgsl`, `graphics-reflection.json`, `graphics-*.bin`, `draw.json`. The
  graphics artifacts are already emitted **in the current format**
  (`schema_version`/`target`/`launch.webgpu_adapter` present) via
  `./scripta/webgpu-browser-proof generate` from
  `triga/exempla/triga-hello-voxel-shaders.fab` (radix `emit --reflection -t wgsl-text`).
- Consumers: `public/src/app.js`, `app-matmul.mjs`, and **10 node harnesses** — 8
  `*-check.mjs` (chunk/compute-resource-lifecycle, device-limit, gradient-handle,
  graphics-storage-update, placement-execution-v1, product-boundary,
  reduction-partial-combine) + `placement-contract-oracle.mjs` +
  `reduction-partial-combine-proof.mjs` — importing `./faber-kernel.js` and
  `./webgpu-runtime.js`.
- `scripta/webgpu-browser-proof {generate,check,serve}` at the hosts repo root;
  `check` regenerates into a temp dir and compares freshness + runs
  `product-boundary-check.mjs`. **Not executed in this draft** (read-only) — listed as
  referenced, unconfirmed.

### Corpus current state (verified)

- Both demos' `tests/run.sh` are byte-identical in the copy section:
  `HOST_DIR="$APP_DIR/../_host"` → `rm -rf public src/shaders` →
  `cp -R "$HOST_DIR/public" → public/` → `cp kernel.wgsl reflection.json` into
  `public/` and `src/shaders/test-data/` → write `faber.lock` (sibling packages
  `$WORKSPACE/faber-web` + `$WORKSPACE/triga`) → `faber check` each `.fab` →
  `faber build --package .` → contract greps:
  `dist/public/{host-init,greybox-host,webgpu-runtime}.js` + `kernel.wgsl` +
  `reflection.json` exist; `host-init.js` contains `renderGreyboxSceneFrame`,
  `.triga-canvas`, `.triga-facts`, `requestAnimationFrame`; page contains
  `mountControllers`, `triga-canvas`, `triga-facts`.
- Both `pages/index.html` import `initHost` from `../public/host-init.js` and await
  it after `mountControllers`.
- `faber.toml` `[product.shaders] source = "src/shaders/test-data"` consumes the
  shader artifacts as build input; `dist/generated/` == `_host/shaders/` (verified).
- Demo `public/` + `dist/` + `src/shaders/` are **gitignored** generated dirs
  (per-demo `.gitignore`); `corpus/_host/` itself is tracked.
- `corpus/serve.sh` + `serve.mjs` iterate `tests/run.sh` then serve `dist/`;
  `serve.mjs` skips underscore/dot dirs and never depends on `_host`.
- `webgl-geometry-terrain` also publishes `data-camera-yaw/pitch/distance` and sets
  `data-fog-density` on the canvas element (read by the host session).
- Headless-Chrome WebGPU proof precedent exists in triga `scripta/w4-06d-gpu-relu-proof.mjs`
  (puppeteer + Chrome for Testing + `--enable-unsafe-swiftshader`).

### Tree-cleanliness caveat (honest)

T-E's "both trees currently clean" was true at track time (2026-08-01). At spec time:
triga has **untracked campaign WIP** (`docs/factory/triga-engine/`, `proof/engine/`,
plus modified `docs/factory/README.md`, `docs/module-map.md`) and hosts has a
modified `Cargo.lock` (unrelated build artifact). Commit boundaries (below) exclude
all of it under the foreign-work rule.

---

## Scope — Files In / Files Out (exact, both repos)

### Phase 1 (extraction) — hosts repo files

| Source (hosts) | Lands as | Disposition |
| --- | --- | --- |
| `public/src/faber-kernel.js` (719 ln) | `public/src/contract/artifact-admission.js` | **Move** (keep hosts copy — it *is* the copy). `FaberKernelContractError` moves to `public/src/product/diagnostics.js` (shared infra for contract + engine lanes; the failure-kind taxonomy `artifact-fetch/reflection/webgpu/product` lives there). Update imports in `app.js`, `app-matmul.mjs`, all `*-check.mjs`. |
| `public/src/webgpu-runtime.js` (2629 ln) | `public/src/backend/webgpu-device.js`, `webgpu-resources.js`, `webgpu-pipelines.js`, `webgpu-render.js`, `webgpu-compute.js`, `webgpu-readback.js`; generation/lifecycle → `public/src/engine/resource-manager.js` | **Merge first** (hosts base + corpus deltas — reconciliation list below), **then split**. Update imports in `app.js`, `app-matmul.mjs`, all `*-check.mjs`. |
| (new) | `public/src/contract/capability-admission.js` | New seam (GOAL host-side structure): fail-closed capability checks consumed by the engine facade. Small; used by the unsupported-capability failure oracle. |
| (new) | `public/src/product/diagnostics.js` | New: `FaberKernelContractError` + failure-kind taxonomy + `data-render-status`/`data-device-status` vocabulary. |
| (new) | `public/src/engine/engine.js` | Move of `greybox-host.js`'s facade (Phase 1: preserve current rendering behavior; Phase 2: upgrade to the explicit state machine). |
| (new) | `public/src/engine/scene-extractor.js` | Move of `parseSceneGeometryBlob` (Phase 1); Phase 2 adds the Triga-scene-store → render-items path. |
| (new) | `public/src/engine/frame-scheduler.js` | Move of host-init's rAF + readback phases + resize ordering. |
| (new) | `public/src/product/bootstrap.js` | Move of host-init's session + DOM bridge. Exports `initEngine()` (the page entry). |
| (new) | `public/src/presentation/canvas.js` | Canvas lookup, backing-size, `webgpu` context configure, resize. |
| (new) | `public/src/presentation/debug-overlay.js` | `.triga-facts` attribute publishing. |
| (new) | `public/generated/triga-lit.wgsl` | **Regenerated through radix** (see Fixtures) — replaces `kernel.wgsl`. |
| (new) | `public/generated/triga-lit-reflection.json` | **Regenerated through radix** to the current format (`schema_version: 1`, `target: "wgsl-text"`, `launch.webgpu_adapter`). Replaces `reflection.json`. |
| `public/faber-webgpu-product.json`, `README.md` | unchanged paths | Update the generated-artifact list + browser-host API section for `triga-lit.*` and the new module surface. |
| `scripta/webgpu-browser-proof` | unchanged path | Extend `generate`/`check` to cover `triga-lit.wgsl` + `triga-lit-reflection.json` (radix emit from the lit fixture). |

### Phase 1 (extraction) — triga repo files

| Source (triga) | Lands as | Disposition |
| --- | --- | --- |
| `corpus/_host/public/faber-kernel.js` | — | **Delete** (hosts copy kept). |
| `corpus/_host/public/webgpu-runtime.js` | — | **Delete** after the merge into hosts. |
| `corpus/_host/public/greybox-host.js` | — | **Delete** after the move to `engine/{engine,scene-extractor,resource-manager}`. `buildDescriptorFromReflection` retired (deleted, not moved). |
| `corpus/_host/public/host-init.js` | — | **Delete** after the move to `product/bootstrap` + `engine/frame-scheduler` + `presentation/{canvas,debug-overlay}`. |
| `corpus/_host/shaders/kernel.wgsl` | — | **Delete** (moves to hosts `generated/triga-lit.wgsl`, regenerated). |
| `corpus/_host/shaders/reflection.json` | — | **Delete** (stale old format; never moved as-is). |
| `corpus/_host/` | `corpus/_host/README.md` | **Reduce to a pointer note** (recommended): one tracked README stating the shared engine now lives in `$WORKSPACE/hosts/webgpu-browser` (`public/src/{product,contract,engine,backend,presentation}`), artifacts in `public/generated/triga-lit.*`, with a link to the run.sh copy instructions. Delete the two dirs (`public/`, `shaders/`). |
| `corpus/webgl-geometries/tests/run.sh` | same path | Rewire `HOST_DIR` to `$WORKSPACE/hosts/webgpu-browser`; update copy set + contract greps (below). |
| `corpus/webgl-geometry-terrain/tests/run.sh` | same path | Identical changes; keep the two copy sections byte-identical (T-E §5 risk 1). |
| `corpus/webgl-geometries/pages/index.html` | same path | Import `{ initEngine }` from `../public/src/product/bootstrap.js` instead of `../public/host-init.js`. |
| `corpus/webgl-geometry-terrain/pages/index.html` | same path | Same import swap. |
| `corpus/README.md` | same path | Layout section: `_host/` block → shared engine in the sibling host repo; note the demos no longer own host assets. |
| `corpus/serve.sh`, `serve.mjs`, demo `serve.sh`, `faber.toml`, `faber.lock` | unchanged | Structurally unaffected (T-E §4). |

### Phase 2 (vertical slice) — new files

| File | Role |
| --- | --- |
| `hosts/public/src/contract/capability-admission.js` (created in Phase 1) | Full capability admission used by the facade: MSAA sample-count request, color-format admission, device-limit checks → typed rejection **before** draw. |
| `hosts/public/src/engine/engine.js` (upgraded) | Explicit state machine `startup→ready→suspended→device-lost→recovering→failed`; session facade (`initEngine`); owns the standard material instance + minimal pipeline cache (shared-instance oracle anchor). |
| `hosts/public/src/engine/frame-scheduler.js` (upgraded) | `update → frame → present` ordering; resize (canvas size → viewport/aspect → deterministic next frame). |
| `hosts/public/src/engine/scene-extractor.js` (upgraded) | Triga scene store → render items, consuming 80 Stage 4 reflection (explicit render facts; **no host guessing** — the S0 reflection boundary). |
| `hosts/public/src/engine/resource-manager.js` (Phase 1 split carries the lifecycle half) | Minimal residency: geometry upload, material uniform, generation checks. |
| `proof/engine/s2/` fixtures (triga) | Extractor fixture scene, expected transform sequence, pixel references (see Fixtures). |
| `triga/scripta/s2-engine-oracle.mjs` | Oracle runner (headless Chrome; precedent `w4-06d-gpu-relu-proof.mjs`). |

Nothing is created under `corpus/_host`; nothing in either repo that is demo-authored
becomes a renderer.

### Fork-merge reconciliation list (the exact merge unit)

Merge into the hosts base (2629 ln), **re-applying these corpus-only deltas**:

1. `BUFFER_USAGE.uniform` entry — `uniform: () => GPUBufferUsage.UNIFORM | GPUBufferUsage.COPY_DST`.
2. `GRAPHICS_SAMPLE_COUNT = 4` — moves out of the backend into the engine facade as a
   **capability-request default** (admission checks it; not a bare constant).
3. `createGraphicsResources` MSAA block — depth texture created at
   `GRAPHICS_SAMPLE_COUNT`, `msaaTexture = createMsaaColorTexture(...)`, pipeline
   `multisample: { count: GRAPHICS_SAMPLE_COUNT }`, returned resources carry
   `msaaTexture` + `sampleCount`.
4. `msaaColorAttachment(resources, canvasView, clearValue, loadOp)` helper — used by
   `runGraphicsFrame` and `runGraphicsFrameWithTexture`; draws into the multisampled
   target and resolves into the canvas view when present, else straight to the canvas.
5. `replaceDepthTextureOnResize` — recreates the depth texture at `sampleCount` and,
   when `resources.msaaTexture` exists, destroys + recreates the MSAA color texture.
6. `createDepthTexture(device, width, height, sampleCount = 1)` — sampleCount param
   (hosts has the single-sample arity).
7. `createMsaaColorTexture(device, width, height, format, sampleCount)` — new function.
8. `createStorageBuffers`/`writeGraphicsStorageInput` uniform-role handling —
   `needsInit = entry.role === "input" || entry.role === "uniform"`;
   `mappedAtCreation: needsInit`.

**Hosts-only deltas that win (preserve, do not regress):**

- `normalizeCombineMetadata`, `combineReductionPartials` (D-A2-A reduction combine),
  `storageBufferByBinding`, `bufferIndexByBinding`;
- `buildChainFromReflection(..., combineMetadata)` and
  `dispatchChainFromDescriptor(device, resources, descriptor, combineMetadata)` —
  the extra param is **optional** (defaults to `null`), so the corpus call sites pass
  three args unchanged;
- the Wave-6 fail-closed chain checks (buffer_identities / layout buffer_index /
  output_bindings buffer_index absent declarations throw typed errors, no silent skip).

**Common to both, no conflict:** compute dispatch path, placement op set, chunk
resource lifecycle, gradient buffers, validation helpers.

Both consumer workloads become merge regression gates: hosts `*-check.mjs`
(reduction readback, chain, chunk lifecycle) and both corpus demos (MSAA resolve,
per-object draws).

---

## Implementation Stage Graph

### Phase 1 — Extraction (decision (b)); five sub-stages, serialized

```text
P1.1  hosts: merge webgpu-runtime forks + split into backend/webgpu-{device,
      resources,pipelines,render,compute,readback}.js + engine/resource-manager.js;
      move faber-kernel.js → contract/artifact-admission.js; error type →
      product/diagnostics.js; update ALL hosts consumers (app.js, app-matmul.mjs,
      *-check.mjs).                     → gate: every *-check.mjs green
P1.2  hosts: greybox-host.js → engine/{engine,scene-extractor,resource-manager};
      host-init.js → product/{bootstrap,diagnostics} + engine/frame-scheduler +
      presentation/{canvas,debug-overlay}; buildDescriptorFromReflection DELETED;
      bootstrap exports initEngine() preserving the current greybox behavior.
                                       → gate: hosts proof page + node harnesses
P1.3  hosts: regenerate triga-lit.wgsl + triga-lit-reflection.json through radix
      (extend scripta/webgpu-browser-proof generate/check); update product manifest
      + README.                        → gate: webgpu-browser-proof check green
P1.4  triga: rewire run.sh ×2 (HOST_DIR, copy set, contract greps) + pages ×2
      (import swap) + corpus README + reduce _host to a pointer note. All in ONE
      commit (keeps the corpus coherent).  → gate: both demos build + render
P1.5  cross-repo integration: hosts scripta check + corpus serve → both demos
      render through the shared facade (manual/headless evidence).
```

### Phase 2 — S2-First Engine Render; factory phase chain A→E (report §6.1)

```text
A  facade + state machine    engine/engine.js (explicit states, session facade,
                             standard-material identity, minimal pipeline cache) +
                             contract/capability-admission.js (typed rejection).
B  extractor + resource      engine/scene-extractor.js (Triga scene store → render
   manager                   items, consuming 80 Stage 4 reflection; NO host
                             guessing) + engine/resource-manager.js (geometry
                             upload, material uniform, generation checks).
C  wire Demo A               80 Stage 5 Hello Triga workload through the facade.
                             [PRECONDITION: 80 Stage 5 lands]
D  wire Demo B               corpus webgl-geometry-terrain through the SAME facade.
E  oracle suite              numeric/pixel/structural/shared-instance oracles +
                             deterministic failures + no-private-copy gate;
                             world-capstone ledger update (items 3/4/10 evidence).
```

Phase edges: A→B are independent of 80 Stage 5 (A/B need Phase 1 + 80 Stage 4
reflection only). C gates on 80 Stage 5. D gates on B (needs the extractor/resource
manager). E gates on C+D. Sequencing per the checkpoint: hosts side first, then the
triga rewire; gate on hosts `*-check.mjs` + both demos.

---

## Cross-Repo Sequencing And Serialization Rules

1. **Hosts first.** P1.1–P1.3 land in `hosts/webgpu-browser` before any triga rewire;
   the corpus demos only break once `run.sh` changes, so the hosts copy must exist
   first (T-E §5 risk 7).
2. **Triga rewire is one serialized commit** (P1.4): both `run.sh`, both pages, the
   README, and the `_host` disposition ship together so the corpus is never half-wired.
3. **No same-file overlap across repos.** The two Phase-1 sides touch disjoint file
   trees; no worktree required. The only cross-repo coupling is the artifact
   regeneration (hosts `generated/`, triga/80 fixture source) — a coordinated but
   non-overlapping change; coordinate its landing with 80 Stage 4–5 (report §7.3).
4. **Serialized cross-repo edits.** Cross-repo edits serialize; no Git cleanup of
   another session's work (foreign-work rule). The campaign WIP (`docs/factory/triga-engine/`,
   `proof/engine/`), the modified triga docs, and the hosts `Cargo.lock` are foreign
   dirt — never touched, committed, or reverted by this delivery.
5. **Both trees must be clean at each gate read** except the acknowledged items.

## Fixtures

### Existing fixtures reused as regression gates (hosts)

- All **10 node harnesses** (8 `*-check.mjs` + `placement-contract-oracle.mjs` +
  `reduction-partial-combine-proof.mjs`) — with import paths re-pointed at the new
  module surface.
- `fixtures/*.json` negative admission fixtures (malformed chain descriptors).
- `scripta/webgpu-browser-proof check` (regenerate-compare + product-boundary).

### Existing fixtures reused as workloads (triga)

- `corpus/webgl-geometries` — the corpus's other demo (geometries). **Demo B is
  `webgl-geometry-terrain`** per report §6.1. The geometries demo is not a required
  S2-gate consumer, but it is rewired in P1.4 with the same `run.sh`/page changes and
  stays a regression consumer of the shared engine.
- `corpus/webgl-geometry-terrain` — **Demo B** (48² heightfield, ~4.6k triangles,
  value noise, per-vertex colors, `data-fog-density`).
- 80 Stage 5 Hello Triga workload — **Demo A** (hierarchical world from the Stage 2
  scene store: rotating indexed mesh, one opaque engine-owned standard material, one
  directional light, perspective camera). Consumed, not invented (T-F §2).

### New fixtures defined by this delivery

**Hosts:**
- `scripta/webgpu-browser-proof` `generate`/`check` extended with `triga-lit.wgsl` +
  `triga-lit-reflection.json` (radix emit from the lit fixture — the fixture's `.fab`
  source is authored by the 80 Stage 4–5 graphics-MIR lane, coordinated; DS-S2 adds
  no `.fab`).
- `public/src/engine-admission-check.mjs` — stale/missing artifact rejection through
  `artifact-admission` (negative fixtures: reflection missing `schema_version`/
  `target`); asserts `buildDescriptorFromReflection` is **absent** from the tree.
- `public/src/engine-state-machine-check.mjs` — pure-JS state-transition table for
  `startup→ready→suspended→device-lost→recovering→failed` (invalid transitions
  rejected; device-loss/resume simulated).
- `public/src/engine-extractor-check.mjs` — extractor-equals-traversal on a frozen
  fixture scene: render items output equals a reference traversal.
- `public/src/engine-resource-manager-check.mjs` — generation checks:
  create-before-retire, generation-mismatch rejection (extends the existing
  chunk/compute lifecycle harnesses).
- `public/src/engine-shared-instance-check.mjs` — asserts both demo bundles resolve
  the engine from the same module set and that the standard-material pipeline-cache
  key is one deterministic identity.

**Triga:**
- `proof/engine/s2/extractor-fixture-scene.json` — frozen scene-store snapshot in the
  `triga-scene.json` format family (`schema: triga.threejs-host-demo.v1` precedent;
  stable node names/UUIDs, no GPU handles) feeding the extractor-equals-traversal
  oracle.
- `proof/engine/s2/expected-transforms.json` — Demo A world-transform sequence over N
  frames (rotation-angle series per frame vs the engine's published transform facts).
- `proof/engine/s2/reference/<demo>/frame-0000.png` (+ `frame-resize.png`) —
  deterministic pixel references at a fixed canvas size (single-region readback or
  full capture). Engine-owned; re-baselined **only** through the radix regeneration
  path (recorded), never hand-edited.
- `scripta/s2-engine-oracle.mjs` — headless-Chrome oracle runner (precedent
  `w4-06d-gpu-relu-proof.mjs`): builds both demos, serves the corpus, loads each page,
  collects `.triga-facts`, captures pixel readback, asserts the four oracle families +
  the four deterministic failures.

### Oracle suite (T-F §2 vocabulary, shared with 80 manifests)

- **Numeric** — Demo A world-transform sequence (rotation angle over N frames vs
  `expected-transforms.json`); extractor-equals-traversal (frozen fixture);
  draw counts (`data-scene-object-count`, `draw_count` facts).
- **Pixel** — deterministic reference images per demo at a fixed canvas size; resize
  to a fixed known size produces a deterministic aspect-correct frame (oracle
  re-runs).
- **Structural** — demo-authored code (`src/**/*.fab`, `pages/*.html`) contains
  **zero** matches for `@vertex|@fragment|createRenderPipeline|createShaderModule|
  beginRenderPass|requestAnimationFrame|acquireWebGpuDevice|device\.createShaderModule`;
  demo `public/` file set equals the engine copy set (grep-able); the old flat names
  (`host-init.js`, `greybox-host.js`, `webgpu-runtime.js`, `kernel.wgsl`,
  `reflection.json`) are absent from `dist/public/`.
- **Shared-instance** — Demo A and Demo B use the **same** shader-module/pipeline-cache
  identity for the shared standard material (facts attribute + static module-set
  equality + node harness).

### Deterministic failures (each executes before any draw or rejects cleanly)

1. **Unsupported capability** — request MSAA 8 (or a non-admitted color format);
   `capability-admission` throws a typed rejection before draw; diagnostics name
   layer/artifact/pass/capability.
2. **Stale/missing artifact** — run with a stale or missing `triga-lit-reflection.json`;
   `artifact-admission` rejects; render status → `failed`; no draw.
3. **Device loss** — test switch destroys the device mid-frame; state machine
   observes `suspended → recovering` (recreate resources, resume) or clean `failed`;
   `data-render-status`/`data-device-status` transitions observed.
4. **Resize** — canvas resized to a fixed known size; next frame is aspect-correct
   and the pixel oracle re-runs on it.

## Gates

1. **Hosts check harnesses green** — every `*-check.mjs` (existing 10 + the four new
   engine harnesses) and `scripta/webgpu-browser-proof check` pass with the merged +
   split runtime and the re-pointed imports.
2. **Both corpus demos render through the shared facade** — P1.4 rewire is green
   (both `tests/run.sh`), and each demo page renders through
   `public/src/product/bootstrap.js` → the shared engine facade with the facts
   contract intact (`data-scene-geometry`, `data-transform-payload`, `.triga-facts`,
   `data-fog-density`).
3. **Structural no-private-copy gate** — the oracle suite's structural greps pass:
   no WGSL, no render-loop/pipeline creation, no old flat host names in either demo's
   authored source or `dist/public/`.
4. **Shared-instance oracle** — both demos report one shader-module/pipeline-cache
   identity.
5. **`buildDescriptorFromReflection` retired** — absent from the hosts tree
   (`engine-admission-check.mjs` grep).
6. **Triga `.fab` gates unaffected** — **no `.fab` changes in Phase 1; Phase 2 adds
   none either.** `./scripta/check-source` and `./scripta/check-compile` must read
   exactly as today: RED only on the two acknowledged pre-existing items (naming lint
   owned by DS-E; generated-code lowering regression owned by the faber emitter via
   the 80 generated-Rust lane). This delivery must not worsen either gate.
7. **Deterministic-failure suite** — the four failure oracles pass with structured
   diagnostics, no uncaught errors.

## Validation Commands

Hosts (after each P1 sub-stage):

```bash
cd /Users/ianzepp/work/faberlang/hosts
./scripta/webgpu-browser-proof check
for f in webgpu-browser/public/src/*-check.mjs webgpu-browser/public/src/placement-contract-oracle.mjs webgpu-browser/public/src/reduction-partial-combine-proof.mjs; do node "$f"; done
node webgpu-browser/public/src/product-boundary-check.mjs
./scripta/webgpu-browser-proof serve   # manual browser evidence (optional, non-GPU gates already cover regression)
```

Triga (after P1.4 and at each Phase 2 gate):

```bash
cd /Users/ianzepp/work/faberlang/triga
./scripta/check-source          # expected: RED only on the acknowledged DS-E lint item
./scripta/check-compile         # expected: RED only on the acknowledged faber-emitter item
corpus/webgl-geometries/tests/run.sh
corpus/webgl-geometry-terrain/tests/run.sh
cd corpus && ./serve.sh --no-build   # manual browser evidence
```

Oracle suite (Phase 2 E):

```bash
cd /Users/ianzepp/work/faberlang/triga
node scripta/s2-engine-oracle.mjs --demo webgl-geometry-terrain --frames 120
node scripta/s2-engine-oracle.mjs --demo <hello-triga-demo> --frames 120   # Demo A (post-80-Stage-5)
```

## Out Of Scope

- **The fine-grained 9-file `engine/*` lane split** (`shader-library.js`,
  `pipeline-cache.js`, `render-graph.js`, `world-streamer.js` as separate files) is
  **named but not implemented** — it lands progressively as S2/S3 stabilize contracts
  (report §5, T-E §4). Phase 2 keeps a minimal pipeline-cache inside `engine.js`
  (enough for the shared-instance oracle); the full cache/specialization seam is S3.
- **Render-plan execution** — S2 runs the shared imperative pass path; the pass-DAG /
  hazard layer and render-plan execution are S4 (report §6.1 deferrals, GOAL Horizon 4).
- **S3 materials** — PBR/metallic-roughness, textures/samplers, multi-light,
  transparency; the S2 "standard material" is a **single engine-owned opaque material**
  derived from the lit shader (flat color + one directional light + depth) (T-F §2
  interpretation note).
- **Deliberate deferrals (T-F §2)**: shadows/offscreen/post (S4), instancing/particles/
  compute (S6), glTF ingestion + animation (S5), world regions/terrain persistence/
  streaming/prefabs (S5–S6), spatial queries/picking/placement (S6), second backend,
  programmable materials, editor/physics/audio seams.
- **World persistence** — schema stub only; not load-bearing at S2 (report §6.3).
- **Demo A authorship** — the Hello Triga workload is 80's Stage 5 artifact; DS-S2
  wires it, never authors a new scene.
- **No `.fab` changes** in either phase (see Gates).

## Commit Boundaries

All commits are execution-time (this draft changes nothing); each is serialized, in
order:

**Hosts (`/Users/ianzepp/work/faberlang/hosts`):**
- **H1 (P1.1)** — merge `webgpu-runtime.js` forks + split into
  `backend/webgpu-{device,resources,pipelines,render,compute,readback}.js` +
  `engine/resource-manager.js`; move `faber-kernel.js` → `contract/artifact-admission.js`;
  `FaberKernelContractError` → `product/diagnostics.js`; update all consumers
  (`app.js`, `app-matmul.mjs`, `*-check.mjs`). Message prefix e.g.
  `refactor(webgpu-browser): merge corpus runtime fork and split backend lanes (DS-S2 P1.1)`.
- **H2 (P1.2)** — `greybox-host.js` → `engine/{engine,scene-extractor,resource-manager}`;
  `host-init.js` → `product/bootstrap` + `engine/frame-scheduler` +
  `presentation/{canvas,debug-overlay}`; delete `buildDescriptorFromReflection`.
- **H3 (P1.3)** — regenerate `generated/triga-lit.*` through radix; extend
  `scripta/webgpu-browser-proof`; update `faber-webgpu-product.json` + README.
- **H4 (Phase 2)** — facade + state machine + capability-admission (A); extractor +
  resource-manager (B); engine harnesses; optionally split per phase A→E.

**Triga (`/Users/ianzepp/work/faberlang/triga`):**
- **T1 (P1.4)** — one commit: rewire `corpus/webgl-*/tests/run.sh` + `pages/index.html`
  ×2, update `corpus/README.md`, delete `corpus/_host/{public,shaders}`, add the
  `corpus/_host/README.md` pointer note.
- **T2 (Phase 2 C/D)** — Demo A wiring (post-80-Stage-5), Demo B facade wiring.
- **T3 (Phase 2 E)** — `proof/engine/s2/` fixtures, `scripta/s2-engine-oracle.mjs`,
  and the `proof/engine/capstones/world-capstone.json` update (items 3, 4, 10 →
  `engine-evidence`/state with evidence paths; 80's `proof/capstones/*.json` stays
  **read-only** — T-F §4).

Excluded from every commit: the untracked campaign docs (`docs/factory/triga-engine/`,
`proof/engine/` — the spec files themselves), the modified `docs/factory/README.md` +
`docs/module-map.md`, and hosts' `Cargo.lock` (foreign dirt, foreign-work rule).
No commit touches `src/**/*.fab`.

## Companion Skill Plan

- `factory` execution with the two-phase lane: P1 is a bounded mechanical migration
  (merge, split, rewire) executed per the hosts-then-triga order; P2 is a
  discovery-first slice (report §0 batching: S2 discovery-first).
- `polish` for the node harnesses and the oracle runner; `vivi` for the radix
  regeneration acceptance (lit-shader MIR lowering) coordinated with the 80 Stage 4–5
  graphics-MIR lane.
- Headless-Chrome proof execution follows the `w4-06d-gpu-relu-proof.mjs` precedent
  (puppeteer, Chrome for Testing, `--enable-unsafe-swiftshader`).

## Open Questions

- **Triga-lit regeneration source**: 80 Stage 4–5 graphics-MIR must express the lit
  shader (pos/normal/color stride-36 + storage transform + uniform lighting +
  hemisphere/Lambert/ACES/fog) as radix-lowerable Faber source. If not yet fully
  expressible at P1.3, the interim is the nearest radix-lowered equivalent with the
  pixel references re-baselined (recorded change), and the full lit shader lands with
  80 Stage 4–5. This is a coordination item, not a DS-S2 `.fab` change.
- **Demo A physical home**: the 80 Stage 5 artifact's package location (triga corpus
  entry vs `examples/`) is pinned at execution in coordination with 80; DS-S2 wires
  the workload, it does not create it.
- **`_host` disposition**: pointer-note (recommended) vs full deletion — the pointer
  note keeps the provenance of `806aa21` discoverable.
- **Entry naming**: `initEngine` from `product/bootstrap.js` (recommended, dissolves
  the `renderGreyboxSceneFrame`/`initHost` contract greps honestly) vs keeping
  `initHost` for page churn minimization.
- **Pipeline-cache placement**: minimal cache inside `engine.js` at S2 (recommended)
  vs creating `engine/pipeline-cache.js` early; the full lane split is S3.
- **`FaberKernelContractError` home**: `product/diagnostics.js` (recommended, shared
  by contract + engine lanes) vs staying in `contract/artifact-admission.js` until a
  later split.

## Revision: Draft Status Note

This spec is the Wave-2 draft (parallel with DS-E/DS-A/DS-B/DS-D/DS-G). It changes
no files: the corpus `_host` tree, the hosts runtime, both demos, and both gates are
untouched until the delivery is executed. Fork-identity and tree-cleanliness claims
were verified read-only at spec time (2026-08-01); the hosts scripta proof entry was
**not executed** (outside the read-only scope) and is listed as referenced,
unconfirmed.
