# T-E · Engine Runtime Home

**Track**: E — engine runtime home (S0 architecture checkpoint input)
**Date**: 2026-08-01
**Author**: research track (six parallel S0 tracks)
**Scope**: `triga/corpus/_host` vs `hosts/webgpu-browser`; seed-or-extraction decision for the shared engine runtime
**Decision asked**: (a) grow `_host` in place as the shared engine, (b) extract into `hosts/webgpu-browser` `product/engine/` now, or (c) defer extraction until after the S2 vertical slice

---

## 0. Executive verdict

**The corpus `_host` greybox renderer is the seed of the shared engine runtime, but it must not stay in `triga/corpus/_host`.** It is a one-commit fork of `hosts/webgpu-browser` runtime code (2026-07-31, commit `806aa21`) that has already diverged in both directions from the authoritative host copy. Recommendation: **(b) extract into `hosts/webgpu-browser`, landed as the first delivery of S2** — the S2 gate ("two unrelated demos render through one shared engine path with no private renderer, pipeline, or shader copy") cannot be met while the runtime is a demo-repo fork that demos copy per-build. Do not defer past S2: deferral guarantees a second migration of a larger codebase onto the same target structure, and the triga repo's own `AGENTS.md` and the GOAL's ownership corrections both already place browser runtime product code in `hosts/webgpu-browser`.

---

## 1. File-level responsibility map of `corpus/_host`

Source of truth: `/Users/ianzepp/work/faberlang/triga/corpus/_host/` (committed 2026-07-31, clean working tree). Per-demo `public/` and `src/shaders/` are gitignored build copies — not sources of truth. `dist/generated/{kernel.wgsl,reflection.json}` are byte-identical to `_host/shaders/` (faber build passes `[product.shaders]` source through to `dist/generated/`).

| File | Lines | What it does | Consumes `reflection.json`? | Where it lands in the vision's target structure |
| --- | --- | --- | --- | --- |
| `public/faber-kernel.js` | 719 | Reflection/admission contract. `FaberKernelContractError` (kinds: artifact-fetch/reflection/webgpu/product), `fetchFaberKernelArtifacts`, `loadFaberKernel` (compute, `launch.webgpu_adapter`), `loadFaberGraphicsPipeline` (graphics: vertex inputs, vertex buffer layouts, pipeline block, draw manifest, fragment↔vertex bind-group cohesion). Full validation of layout/group/binding index lists. | Yes — parses + validates. Requires `schema_version: 1` and `target: "wgsl-text"`. | `contract/artifact-admission.js`; the error type becomes shared infra (also feeds `product/diagnostics.js`). |
| `public/webgpu-runtime.js` | 2442 | Full backend layer. Adapter/device: `acquireWebGpuDevice`, `onDeviceLost`, device-limit gates. Compute: `createWebGpuResources`, `runKernel`, `runKernelChain`, `buildChainFromReflection`, `dispatchChainFromDescriptor`, `placement*` op set, gradient buffers. Graphics: `createGraphicsResources` (MSAA 4×, depth24plus, uniform + storage), `runGraphicsFrame`, `runGraphicsFrameWithTexture`, `readTexturePixelsRgba`, `mapPixelBuffers`, `replaceDepthTextureOnResize`, `updateGraphicsStorage`. Resource lifecycle: generation counters + create-before-retire for compute and per-chunk multi-draw. | No — consumes already-parsed descriptors. | Split across `backend/webgpu-device.js`, `webgpu-resources.js`, `webgpu-pipelines.js`, `webgpu-render.js`, `webgpu-compute.js`, `webgpu-readback.js`; logical-handle/generation lifecycle → `engine/resource-manager.js`. |
| `public/greybox-host.js` | 596 | Greybox scene renderer. `loadGreyboxPipeline` (fetches `./kernel.wgsl` + `./reflection.json` relative to `import.meta.url`), `buildDescriptorFromReflection` (hand-rolled admission — does **not** use `faber-kernel.js` admission), mesh buffer upload, `parseSceneGeometryBlob` (pipe-separated DOM blob → meshes), `initGreyboxRenderer`/`initGreyboxSceneRenderer`, `renderGreyboxSceneFrame` (one drawIndexed per object, MSAA resolve, per-object transform rewrite), `updateGreyboxTransform`, `resizeGreyboxRenderer`. | Yes — simplified parse of the older reflection format (no `schema_version`/`target`); **bypasses** `loadFaberGraphicsPipeline`, which would reject this file's format. | `engine/scene-extractor.js` (`parseSceneGeometryBlob`), `engine/engine.js` (greybox facade), `engine/resource-manager.js` (mesh upload); `buildDescriptorFromReflection` is a defect to be **retired** in favor of shared admission once artifacts are regenerated. |
| `public/host-init.js` | 439 | Host session bootstrap + frame loop. `initHost()`: acquire device, canvas `webgpu` context config (`bgra8unorm`, opaque), U2 triangle fallback + pixel-readback proof, `waitForSceneGeometry` + `data-transform-payload` DOM polling, rAF loop, resize (`ResizeObserver`), device-loss + `uncapturederror` handling, `destroy()`. Publishes `data-*` facts to `.triga-facts`. | No — calls `loadGreyboxPipeline` indirectly. | `product/bootstrap.js` (session + DOM bridge), `engine/frame-scheduler.js` (rAF + readback phases), `presentation/canvas.js` (canvas/resize), `presentation/debug-overlay.js` (facts attributes), `product/diagnostics.js` (device-lost/uncapturederror). |
| `shaders/kernel.wgsl` | 127 | Lit scene shader: pos/normal/color vertex format (stride 36), transform storage (model+view-proj) + lighting uniform (sun/ambient/fog), hemisphere ambient + Lambert, ACES + sRGB, exp2 fog. Hand-authored checked-in WGSL (the only shader; single variant). | — (it is an artifact) | Content for `engine/shader-library.js` (standard lit variant); raw-WGSL authoring through radix lowering is an S3 concern. |
| `shaders/reflection.json` | 173 | Compiler-style reflection for the greybox shader: `kernels[]` (vertex+fragment) with `resources`/`vertex_inputs`/`varyings` + `pipeline` block. **Older format**: no `schema_version`/`target` (hosts `generated/reflection.json` has both). | — (it is an artifact) | `generated/` — regenerate through the radix path to the current format before retiring `buildDescriptorFromReflection`. |

### Corpus demo → host contract (how demos call host knobs)

- Demo `src/main.fab` publishes `data-scene-geometry` (one-shot mesh blob) and `data-transform-payload` (32 f32) to `.triga-facts` via `dom.attr_set`; terrain adds `data-camera-*` and `data-fog-density` on the canvas element. Input (orbit/dolly/pan) lives **in the Faber controllers**, not in the host — the host has no input handling today.
- Demo `pages/index.html` imports `initHost` from `../public/host-init.js` (the copied `_host` file) plus `mountControllers` from the faber-built ESM, then `await initHost()`.
- `[product.shaders] source = "src/shaders/test-data"` in `faber.toml` consumes the copied shader artifacts as build input; the same files in `public/` are the runtime fetch targets.

### Corpus build flow today

`tests/run.sh` (both demos, identical copy section): `HOST_DIR="$APP_DIR/../_host"` → `rm -rf public src/shaders` → `cp -R _host/public → public/` → `cp _host/shaders/{kernel.wgsl,reflection.json} → public/` and `→ src/shaders/test-data/` → write `faber.lock` → `faber check` → `faber build --package .` → contract greps (`dist/public/{host-init.js,greybox-host.js,webgpu-runtime.js,kernel.wgsl,reflection.json}` exist; `host-init.js` contains `renderGreyboxSceneFrame`). `corpus/serve.sh` iterates every demo's `tests/run.sh` then serves `dist/` via `serve.mjs`. `serve.mjs` only skips underscore/dot dirs — it never depends on `_host`. Demo `serve.sh` serves its own `dist/` on a dedicated port.

---

## 2. `hosts/webgpu-browser` current-state summary

`/Users/ianzepp/work/faberlang/hosts/webgpu-browser` (clean working tree; runtime files continuously evolved since 2026-07-20, latest commit 2026-08-01).

Structure:

```text
webgpu-browser/
  README.md
  fixtures/                 # add-one.fab + malformed chain JSONs (negative admission fixtures)
  public/
    index.html              # proof page (compute result + three.js presentation chrome)
    matmul-proof.html
    styles.css
    faber-webgpu-product.json
    generated/              # compiler-owned checked artifacts: kernel.wgsl, reflection.json,
                            #   graphics.wgsl, graphics-reflection.json, graphics-*.bin, draw.json
    src/
      faber-kernel.js       # 719 lines — byte-identical to corpus/_host copy
      webgpu-runtime.js     # 2629 lines — superset of corpus copy (see §3)
      app.js                # 248 lines — proof harness (add_one 41→42, graphics single-frame proof)
      app-matmul.mjs
      *-check.mjs ×10       # node harnesses: placement, lifecycle, device-limit, gradient, product-boundary…
    vendor/three@0.180/     # three.js as presentation chrome only
```

What exists:
- **Compute product proof** — the reflection consumer (`loadFaberKernel`), backend runtime, placement contract, resource lifecycle with generations, and a rich negative-fixture admission set.
- **Graphics single-frame proof** — `loadFaberGraphicsPipeline` + `createGraphicsResources`/`runGraphicsFrame` against `generated/graphics.*`; single-sample (no MSAA), hidden 256×256 canvas.
- **No engine layer** — no `engine/` dir, no scene extraction, no frame loop product, no host session (no `host-init.js`/`greybox-host.js` equivalent), no canvas/input/presentation product surface.
- README documents `scripta/webgpu-browser-proof {serve,check,generate}` at the hosts repo root. **Not verified in this track** (outside the allowed root) — treat as referenced, unconfirmed.

Proof vs product: everything here is a *proof* — a scaffold product boundary whose success states are `window.faberWebGpuProof.ok === true`, `value === 42`. The README states it is "the browser-first WebGPU product boundary" but the code is a harness, not a consumable engine. `three.js` is presentation chrome, never a binding/launch authority.

---

## 3. Duplication check

**Yes — the same runtime logic exists in both repos, in two files.**

| File | hosts/webgpu-browser | triga/corpus/_host | Verdict |
| --- | --- | --- | --- |
| `faber-kernel.js` | `public/src/faber-kernel.js`, 719 lines | `public/faber-kernel.js`, 719 lines | **Byte-identical** (verified with `diff -q`). |
| `webgpu-runtime.js` | `public/src/webgpu-runtime.js`, 2629 lines | `public/webgpu-runtime.js`, 2442 lines | **Divergent fork** (450 diff lines). Hosts-only: reduction-combine helpers (`normalizeCombineMetadata`, `combineReductionPartials`, `storageBufferByBinding`/`bufferIndexByBinding`, `combineMetadata` params). Corpus-only: MSAA 4× graphics path (`GRAPHICS_SAMPLE_COUNT`, `createMsaaColorTexture`, `msaaColorAttachment`), `BUFFER_USAGE.uniform`, and the greybox scene layer. |

Plus, at build time each demo materializes a **third copy** of all four JS files + shaders into its `public/` and `dist/public/` — gitignored generated dirs, not sources of truth, but real deployed bytes that drift independently once built.

**Which is authoritative?** `hosts/webgpu-browser` — it is the origin (runtime present since 2026-07-20, `e0d07e8` "extract platform hosts into sibling hosts workspace"), continuously evolved (latest change 2026-08-01, one day before this checkpoint), and it is the GOAL's named long-term authority for "Browser device and GPU execution". `corpus/_host` is a single-commit (2026-07-31, `806aa21`) fork that copied `faber-kernel.js` verbatim and forked `webgpu-runtime.js`.

**Neither copy is a strict superset of the other.** The corpus fork carries forward progress hosts lacks (MSAA 4×, uniform-buffer usage, the greybox scene renderer, the host session) and hosts carries forward progress corpus lacks (reduction combine, chain fixes). Every future corpus demo or host proof widens the fork. The fork also carries a latent contract drift: the greybox path's `buildDescriptorFromReflection` hand-rolls admission from an older reflection format instead of using the shared `loadFaberGraphicsPipeline`, which would reject the checked-in `_host/shaders/reflection.json` (missing `schema_version`/`target`).

---

## 4. Recommendation: **(b) extract into `hosts/webgpu-browser` `product/engine/` now — landed as the first delivery of S2**

### Reasoning

1. **The target is not in question.** GOAL's host-side target structure places the engine under `hosts/webgpu-browser/public/src/{product,contract,engine,backend,presentation}`; the scope-routing table gives "Engine runtime (frame, extraction, residency, caches, passes, streaming)" to `hosts/webgpu-browser`; the correction table moves "corpus `_host` shader/runtime files → shared host engine package". Triga's own `AGENTS.md` says "Browser WebGPU runtime product code lives in sibling `hosts/webgpu-browser`, not here." Option (a) (grow `_host` in place) contradicts all three and guarantees a second migration of a larger codebase later.
2. **The fork is already active and two-way divergent.** Two copies of a ~3.3k-line runtime, with `faber-kernel.js` duplicated verbatim. Every bug fix and contract change is already a two-place edit; corpus-only MSAA and hosts-only combine helpers must be manually reconciled. The corpus is small (2 demos) — the merge blast radius is cheapest now.
3. **S2's gate requires it.** S2 = "two unrelated demos render through one shared engine path with no private renderer, pipeline, or shader copy" (Horizon 2: "Replace copied corpus host assets with a shared engine runtime path"). The corpus demos *are* the two-demo proof. Option (c) (defer past S2) either means S2 builds on the fork — so the extraction re-touches every S2 file — or means S2 quietly performs the extraction anyway, making "defer" a fiction. Extraction is the S2 precondition, not an S2.5.
4. **The extraction and the internal lane split are separable.** The low-risk move is: merge the two `webgpu-runtime.js` forks into one authoritative backend, move `greybox-host.js`/`host-init.js` into the host product structure, and rewire the demos' copy step. The fine-grained 9-file `engine/*` split can land progressively as S2/S3 stabilize contracts (the GOAL itself says the exact split "belongs to a host delivery after the current runtime contracts stabilize"). This removes the "too early" objection to (b).

### File-level migration mapping

Move from `triga/corpus/_host` into `hosts/webgpu-browser` (merge with the existing copies first):

| Source | Lands as | Notes |
| --- | --- | --- |
| `public/faber-kernel.js` (719) | `public/src/contract/artifact-admission.js` | Already identical in hosts — keep the hosts copy, delete the corpus copy. Error type shared by all lanes → extract to `public/src/product/diagnostics.js` (or contract error module) when lanes split. |
| `public/webgpu-runtime.js` (2442) | `public/src/backend/webgpu-device.js`, `webgpu-resources.js`, `webgpu-pipelines.js`, `webgpu-render.js`, `webgpu-compute.js`, `webgpu-readback.js`; lifecycle/counters → `public/src/engine/resource-manager.js` | **Merge first**: hosts' 2629-line file is the base; re-apply corpus-only deltas (MSAA `GRAPHICS_SAMPLE_COUNT`, `createMsaaColorTexture`, `msaaColorAttachment`, `BUFFER_USAGE.uniform`, `createDepthTexture(width,height,sampleCount)`). Both existing consumer workloads (hosts proof harnesses + corpus demos) become merge regression gates. |
| `public/greybox-host.js` (596) | `public/src/engine/engine.js` (greybox facade), `engine/scene-extractor.js` (`parseSceneGeometryBlob`), `engine/resource-manager.js` (mesh upload) | `buildDescriptorFromReflection` is **retired**, not moved: demos route through `contract/artifact-admission.js` (`loadFaberGraphicsPipeline`) once artifacts are regenerated. |
| `public/host-init.js` (439) | `public/src/product/bootstrap.js`, `engine/frame-scheduler.js`, `presentation/canvas.js`, `presentation/debug-overlay.js` | The demo page imports the bootstrap/facade instead of a private copied file. |
| `shaders/kernel.wgsl` (127) | `public/generated/triga-lit.wgsl` + content seed for `engine/shader-library.js` | Checked-in shader artifact moves with the runtime; `[product.shaders]` build-input copy still materializes it into demo `src/shaders/test-data/`. |
| `shaders/reflection.json` (173) | `public/generated/triga-lit-reflection.json` | **Regenerate through the radix path to the current format** (`schema_version`/`target` present) before the greybox path stops hand-building descriptors. |

### Corpus build flow under (b)

`corpus/_host` is deleted (or reduced to a pointer note). Each demo's `tests/run.sh` changes `HOST_DIR` from `$APP_DIR/../_host` to `$WORKSPACE/hosts/webgpu-browser` (the sibling repo — the same sibling-package precedent as `$WORKSPACE/faber-web` in `faber.lock`), and copies:

- hosts engine JS (`public/src/{product,contract,engine,backend,presentation}`) → `$APP_DIR/public/` (preserving the structure the page imports);
- hosts shader artifacts (`public/generated/triga-lit.*`) → `$APP_DIR/public/` (runtime fetch) and `$APP_DIR/src/shaders/test-data/` (faber build input).

Everything else is unchanged: `faber.lock` writing, `faber check`, `faber build --package .`, `dist/` serving via `serve.sh`/`serve.mjs`, per-demo `serve.sh`. The page import changes from `../public/host-init.js` to the shared bootstrap/facade path, and the contract greps in `run.sh` re-point at the new module surface. Optionally, once faber gains multi-artifact host-package support, demos could declare the engine as a package instead of copying — a later optimization, not a checkpoint requirement.

Sequencing: land the move+merge as the **first S2 delivery** (S2 is already discovery-first), with the two corpus demos as the acceptance workload and the hosts `*-check.mjs` harnesses as the non-GPU regression gate. The `engine/*` lane split follows within S2/S3.

---

## 5. Risks

1. **Corpus build flow (`tests/run.sh` ×2)** — the copy source moves from `corpus/_host` to the sibling `hosts` repo. Failure modes: hosts repo absent at `$WORKSPACE/hosts` (already implicitly required for `faber-web`, but now also required for the demos to *render*); path/subtree drift between the two demo scripts (they're currently byte-identical in the copy section — keep them that way). `serve.sh`/`serve.mjs`/demo `serve.sh` are unaffected structurally.
2. **`tests/run.sh` contract greps** — greps assert `host-init.js` contains `renderGreyboxSceneFrame` and `dist/public/{host-init,greybox-host,webgpu-runtime}.js` exist. These names dissolve in the lane split; the greps must target the new facade/bootstrap surface or the build goes red for the wrong reason.
3. **Host-init contract** — demo `pages/index.html` imports `../public/host-init.js`; the import path and the exported entry change to the engine bootstrap. Two demo pages to update, and the DOM facts/canvas contract (`data-scene-geometry`, `data-transform-payload`, `.triga-facts`, `.triga-canvas`) must keep working unchanged — the demos' Faber controllers don't change.
4. **Two-demo copy mechanism** — the copy step itself survives (the served `dist/` cannot reach outside the package), but the file set grows with the lane split and the source moves across repos. This is the point where a demo could accidentally start importing a private host file — the page must import only the engine's public bootstrap/facade.
5. **Fork merge regression** — reconciling the two `webgpu-runtime.js` versions is real work (MSAA + uniform additions are corpus-only; combine/chain additions are hosts-only; chunk lifecycle is in both). A botched merge silently breaks either corpus rendering (MSAA resolve, per-object draws) or the hosts proof harnesses (reduction readback). Mitigation: merge into hosts first, gate on `*-check.mjs` + both corpus demos.
6. **Artifact-format drift** — `_host/shaders/reflection.json` is the older reflection format and cannot pass `loadFaberGraphicsPipeline` (missing `schema_version`/`target`). If the engine is extracted but the shader artifacts are not regenerated through radix, the greybox path must keep its hand-rolled builder — perpetuating the "host recreates facts" defect. Regenerating is a radix-path dependency (cross-repo, coordinated with the 80 Stage 4–5 graphics-MIR work).
7. **Cross-repo coordination** — the move is a cross-repo edit (triga → hosts). Campaign rules require non-overlapping worktrees or serialized edits; the corpus demos break until the hosts copy lands, so land the hosts side first, then rewire `run.sh`. Triga gates (`check-source`, `check-compile`) are unaffected (no `.fab` changes). Both trees are currently clean.

### Uncertainty notes (stated honestly)

- `hosts` repo-root `scripta/webgpu-browser-proof` (`serve`/`check`/`generate`) is documented in the README but was **not verified** — outside this track's allowed root.
- Whether `_host/shaders/{kernel.wgsl,reflection.json}` are stale checked-in artifacts or current radix output was **not proven**; the reflection format's missing `schema_version`/`target` strongly suggests staleness or an older emit path, but regeneration behavior was not exercised (read-only track).
- The per-demo generated `public/`/`dist/` copies were not audited for drift against `_host` (gitignored, not source of truth); only `dist/generated/` == `_host/shaders/` equality was verified.

---

## Bottom line

`corpus/_host` is a proof-fixture fork, not the permanent renderer distribution. **Decision: (b) — extract into `hosts/webgpu-browser` `product/engine/` now, sequenced as the first S2 delivery.** The two corpus demos become the engine's first shared-path consumers, which is exactly the S2 gate. Deferring past S2 (c) doubles the migration; growing in place (a) builds the engine in the one repo the campaign rules explicitly say it does not belong in.
