# GOAL: Closed browser loop

**Status**: active — Units 1–4 landed 2026-10-01 (R1–R3 visible); Unit 5 blocked on radix texture/sampler emit
**Created**: 2026-10-01
**Campaign:** —
**Source:** operator request 2026-10-01 after Triga 0.3.0: continue the library as what a browser user actually needs, not more genera
**Repos:** `triga` (presenter + library + first fixture); `radix` / `faber` (WGSL and graphics-reflection emit only); `examples` only after a visible Triga presenter exists. `hosts/webgpu-browser` is not a write surface for this goal
**Related:** [`../triga-engine/GOAL.md`](../triga-engine/GOAL.md) (S2 assumed the hosts engine; superseded here for the browser runtime); [`../hello-voxel/CAMPAIGN.md`](../hello-voxel/CAMPAIGN.md) (second caller, not the first draw); [`../faber-native-surface/GOAL.md`](../faber-native-surface/GOAL.md) (identity break landed; not this loop); [`../../../radix/docs/factory/faber-2-repository-migration/CAMPAIGN.md`](../../../radix/docs/factory/faber-2-repository-migration/CAMPAIGN.md) (Q4 “move whole into triga” — overturned for Triga’s runtime by the operator 2026-10-01; see Settled)

---

## Invariant

A Faber author builds a Triga mesh and a camera, and pixels appear in the browser on a canvas they can see. Triga owns the typed contract **and** a thin browser presenter. Radix/Faber emit WGSL and reflection. Triga never emits shaders. No `triga:engine` / `triga:render` leaves. `hosts/webgpu-browser` is not Triga’s runtime.

## Problem

Triga 0.3.0 (`v0.3.0`, `a2e3767`) is a CPU-side contract. The public surface has math, primitives, `Geometry`, `Mesh`, `SceneStore`, `PerspectiveCamera`, and shader-contract adapters. It does not close a browser loop.

Observable at HEAD, not inferred from older campaign prose:

1. **No Triga-owned draw.** `hosts/webgpu-browser` is a compute-first proof product (`add_one` → `42`) with graphics as a side fixture. `fixtures/graphics.fab` builds a `plane` and asserts contract facts; its `@ vertex` / `@ fragment` bodies are empty. Radix fills real WGSL. That draw goes to a hidden 256×256 canvas. The visible picture on the page is a three.js box whose height is the compute result.
2. **The host is the wrong owner.** That tree is ~13k lines of our JS plus vendored three.js, mostly compute (matmul, placement, gradients, kernel chains). Triga is a graphics library. Gradus is the ML/compute library. Moving the product into `triga/` would make that type error permanent. Faber 2 Q4 (“move whole into triga”) assumed Triga was the only live consumer; radix GPU proofs also use this JS.
3. **Geometry crosses the old seam as a string.** Corpus controllers publish `data-scene-geometry` as a pipe-separated blob (`pos3+normal3+color3`, stride 36). The hosts extractor parses that blob. That is transport, not the library’s scene graph, and it is not this goal’s first path.
4. **Two showcase demos cannot parse.** `triga/corpus/webgl-geometries/src/scene.fab` and `triga/corpus/webgl-geometry-terrain/src/scene.fab` still contain `class_corpus_placeholder)`. Hygiene; not the R1 gate.
5. **Camera and materials stop at values.** `PerspectiveCamera` can build a projection. `OrthographicCamera` is fields only. `PhongMaterial`, `StandardMaterial`, and the light family are records. `TextureDescriptor` is a seed. Nothing in a Triga-owned presenter binds “this camera looks at this mesh” yet.

A browser user needs something on the canvas, a camera they can move, a material that is more than leftover vertex color, and a way to put an image on a mesh. The types for the first two exist. The join does not, and the existing host is not the join to inherit.

## Proposal

Write a **thin Triga presenter**. Leave `hosts/webgpu-browser` where it is until that repo goes away. Close the loop in the order a user feels it. Do not grow genera ahead of a caller that draws. Do not move or strip the compute product.

The presenter speaks the existing radix graphics contract: admit `schema_version: 1` WGSL + reflection, upload buffers, `drawIndexed`. It does not invent a second pipeline dialect. Admission rules may be copied from `hosts/webgpu-browser/public/src/contract/artifact-admission.js` (`loadFaberGraphicsPipeline` and its parsers). The compute product, three.js chrome, greybox `engine.js`, and the DOM-blob extractor are not copied.

| # | Requirement | What “done” means | Owner |
| --- | --- | --- | --- |
| R1 | Honest first draw | A Triga primitive (`plane` or `box`) is visible on a Triga-owned canvas through one admitted radix graphics pipeline. Three.js does not count. A hidden canvas does not count. | triga presenter + a Triga fixture; radix/faber emit |
| R2 | Live camera / transform | A `PerspectiveCamera` plus mesh transform writes the 32-float `TransformPayload` the presenter binds. | triga contract + presenter frame write |
| R3 | One shading material | The admitted shader uses unlit / vertex color. Phong / Standard stay records until a shader reads them. | presenter shader consume + existing `UnlitMaterial` |
| R4 | One texture | A PNG (or equivalent) on a quad or box in the browser. Small Triga descriptor plus presenter upload/sampler. No `triga:asset` tree. | presenter + `TextureDescriptor` (or its first real leaf) |

R1 is the gate. R2–R4 wait until a mesh is visible. `examples/hello-voxel` already imports current leaves; it is the second caller after R1, not the first canvas.

Vertex layout for R1 matches the current radix graphics emit: separate position and color buffers, stride 12, no normals. Do not adopt the corpus interleaved `pos+normal+color` blob to get a first pixel.

Default on-disk home for the presenter: `triga/host/` (revisitable; see Open questions).

### Non-goals

- Moving `hosts/webgpu-browser` into this repo (Faber 2 Q4 “move whole,” overturned for Triga’s runtime).
- Inheriting compute proofs, matmul/placement/gradient pages, or vendored three.js.
- Using the corpus DOM-blob path or `triga-lit.*` as the first draw.
- New leaves: `triga:engine`, `triga:render`, `triga:world`, `triga:animation`, `triga:asset`.
- Filling Phong / PBR / light evaluation in `src/` before an admitted draw.
- Resuming `triga-threejs-80` / `-90` as a score.
- Metal or a second backend for Triga.
- Merging 3D into `tela` (`tela:canvas2d` stays 2D).
- Scene-store split (G2/G3).
- Closing the `math.proba` MIR residual from `faber-native-surface`.
- Renaming frozen `*_code` / shader-contract ABI fields.
- Inventing a Triga-owned shader dialect or emitting WGSL from Triga.

## Requirements register

This table is the remaining-work authority. Advance a cell only when the code is in that state.

| ID | Requirement | Status |
| --- | --- | --- |
| R1 | Honest first draw of a Triga mesh on a Triga presenter | done |
| R2 | Camera + `TransformPayload` as the live frame write | done |
| R3 | Admitted shader uses unlit color | done |
| R4 | One image on a mesh | pending |
| later | SceneStore (or equivalent values) as presenter input | pending |
| later | Directional light actually shades | pending |
| later | glTF / model load | pending |
| later | Repair the two broken corpus `scene.fab` files | pending |

## Units (lowering sketch — refine via `$delivery`)

| Unit | Scope | Depends on | Hand evidence |
| --- | --- | --- | --- |
| 1 | Thin presenter: acquire device, admit one graphics reflection, visible canvas, one `drawIndexed` | — | none |
| 2 | First mesh is a Triga primitive: fixture in this repo, radix/faber emit, position+color from `basic.plane` or `basic.box` | 1 | none |
| 3 | Bind `PerspectiveCamera` + mesh transform to the 32-float / 128-byte payload | 2 | none |
| 4 | Unlit color through the admitted shader (R3) — no-op if Unit 2 already passes vertex color | 2 | none |
| 5 | One texture upload + sampler on a mesh (R4) | 3, 4 | none |

Do not merge R1 with R4. Do not block Unit 1 on corpus parse repair.

## Validation

Goal-closeout is a visible loop, not suite-green alone:

```bash
# from triga/
./scripta/host check    # emit host/fixtures/box.fab + admit
./scripta/host serve    # http://127.0.0.1:8788/
```

Browser GPU evidence is a **visible** canvas showing a Triga mesh. `submittedFrameCount > 0` on a `display: none` element does not count. The hosts `webgpu-browser-proof` page and its three.js chrome do not count.

## Delivery checklist

| Check | Enforced by |
| --- | --- |
| Presenter lives under `triga/` and does not import `hosts/webgpu-browser` at runtime | review |
| One admitted graphics pipeline matches current reflection schema | Unit 1/2 + emit + admission |
| Vertices come from a Triga primitive, not a hand-authored hidden bin with no typecheck | Unit 2 |
| Transform wire stays 32 f32 / 128 bytes | existing payload contract; Unit 3 must not widen to the old 64-float lit artifact |
| No new empty `triga:*` leaves | review |
| Frozen `*_code` fields unchanged | review |
| Compute fixtures / three.js vendor not copied into this repo | review |

## Ledger

| Unit | Status | Hand | Receipt | Notes |
| --- | --- | --- | --- | --- |
| 1 | done | — | `./scripta/host check` green | thin presenter under `triga/host/` |
| 2 | done | — | `./scripta/host check` green; fixture `host/fixtures/box.fab` | `basic.box` mesh; bins from `box()` source (MIR run blocked) |
| 3 | done | — | `./scripta/host check` green; transform 32 f32 / 128 B | `PerspectiveCamera` + `TransformPayload` in fixture; bins evaluate `triga:math` formulas |
| 4 | done | — | Unit 2 vertex color through admitted unlit shader | no-op, as lowered |
| 5 | pending | — | — | blocked: shader-contract resource kinds are storage-buffer + runtime-extent only |

## Settled

Operator 2026-10-01, this session.

1. **Thin presenter in Triga, not a host move.** Do not move `hosts/webgpu-browser` into this repo. Do not strip that product down to a graphics host. Write what Triga needs. Leave the compute-first tree in `hosts/` until that repo is retired; its compute proofs are radix/Gradus, not Triga.

2. **Faber 2 Q4 overturned for Triga’s runtime.** The campaign line “`webgpu-browser` moves whole into `triga`” does not apply to this goal. When `hosts/` goes away, compute browser proofs do not land here. A later generic browser runtime (gpu-reset S6) is a product-repo question, not a reason to inherit the current page.

3. **Keep the compiler seam.** Triga never emits WGSL. The presenter admits radix/faber `wgsl-text` + `schema_version: 1` reflection. Copy admission parsers if that avoids re-typing the schema. Do not invent a second pipeline dialect.

4. **R1 is a visible Triga mesh.** Hidden canvas and three.js chrome are not success. First layout is position + color (current graphics emit), not the corpus blob and not `triga-lit.*`.

## Open questions

1. **Presenter path.** Default: `triga/host/`. Revisit if `browser/` or `webgpu/` is clearer once Unit 1 lowers.

2. **First primitive.** `basic.box` via `host/fixtures/box.fab`. Not hello-voxel, not the animation corpus blob. `faber run` cannot import `triga:geometry/data` (named MIR vector-method residual); presenter bins evaluate `box()` lists from `src/primitives/basic.fab` instead of dumping a live Geometry.

3. **R3 vs R2 order.** R2 landed first. R3 is the Unit 2 vertex-color path (no-op).

4. **How much admission to copy.** Default: copy `loadFaberGraphicsPipeline` and the parsers it needs; do not copy `loadFaberKernel` or compute resource lifecycle. Rewrite only the page and the upload/draw.

5. **Unit 5 texture seam.** Operator visual 2026-10-01: Unit 3 camera payload unchanged on screen. R4 is blocked until radix graphics emit can name a texture/sampler binding. Do not hand-write WGSL or admit a second pipeline dialect. `TextureDescriptor` is only a seed. A storage-buffer texel atlas is not a sampler.
