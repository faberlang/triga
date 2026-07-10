# Campaign: Triga Three.js 80

**Status**: active (2026-07-10) — Stage 0 baseline complete
**Mode**: draft/maintain — campaign control plane
**Owner repo**: `/Users/ianzepp/work/faberlang/triga`
**Participating repos**: `triga`, `radix`, `faber`, `faber-runtime`, `examples`; `cista` only for an explicit distribution stage
**Selected next stage**: Stage 1 — core math and transform foundation
**Release posture**: foundation-first; no release required before the first direct-render checkpoint

## Summary

This campaign advances Triga from its initial three.js-shaped type shell into a
workload-proven Faber graphics stack covering at least 80 percent of the
capabilities used by ordinary three.js scenes. The visible outcome is that
Faber programs can build and run substantial GPU scenes. The primary purpose
is deeper: use those scenes to harden Faber source libraries, Radix semantics
and intrinsics, MIR GPU lowering and reflection, generated-code runtime types,
package workflows, and browser host boundaries under real graphics pressure.

The campaign routes stages; it does not implement directly. Each selected stage
must lower through `delivery`, then execute through `factory` with its own
repo-aware spec, validation, review, and commits.

## Invariant

Triga remains a backend-agnostic, three.js-shaped Faber library; every admitted
capability is represented above backend emission, proved by a real graphics
workload, and implemented at the canonical library, compiler, runtime, package,
or host seam without a permanent three.js runtime dependency.

## Problem

Triga currently defines recognizable math, scene, geometry, material, mesh,
camera, light, and texture descriptor shapes, but those declarations do not yet
form a usable graphics system. The largest gaps cross repository boundaries:

- the scene graph cannot yet represent heterogeneous renderable children;
- math records do not yet provide a coherent transform or matrix execution
  model across the Rust and MIR/GPU lanes;
- geometry attributes are lists without a complete buffer-layout contract;
- MIR GPU is compute-capable but has no admitted vertex/fragment stage model;
- the browser proof dispatches a Faber compute kernel but still uses three.js to
  render the visible scene;
- materials, textures, lights, shadows, animation, asset ingestion, culling,
  picking, instancing, and multipass rendering are absent or placeholders;
- validation proves type construction, not representative GPU scenes.

A library-only roadmap would hide compiler blockers. A compiler-only roadmap
would optimize abstractions without a demanding consumer. This campaign keeps
the workload and the foundational changes coupled while preserving repository
ownership.

## Desired End State

At campaign closeout:

1. Faber source can describe, update, and render representative hierarchical 3D
   scenes through a direct WebGPU host path without loading three.js at runtime.
2. Triga covers at least 80 points in the capability scorecard below, including
   all mandatory domain floors and capstone gates.
3. The same public Triga concepts remain backend-agnostic; WebGPU-specific
   resource and pipeline details stay in compiler reflection or host contracts.
4. Graphics-driven additions to vectors, matrices, collections, ownership,
   discriminated data, methods, MIR, diagnostics, reflection, and runtime
   execution become reusable Faber capabilities rather than Triga-only hacks.
5. Every claimed domain has an executable workload, expected result or visual
   contract, negative/fail-closed coverage, and a documented owner seam.
6. The campaign records which remaining three.js families form the final 20
   percent and why they are deferred.

## Development Posture

- **Foundation first.** The campaign optimizes for language/compiler stress and
  architectural truth, not immediate API polish or release readiness.
- **Clean breaks.** Triga has no compatibility obligation to its initial type
  sketch. Replace weak shapes rather than preserving aliases or wrappers.
- **Workload driven.** No score is earned by declarations, parser acceptance,
  emitted text snapshots, or host-side reimplementation alone.
- **WebGPU first.** Direct WebGPU is the execution target. WebGL2 fallback,
  native `wgpu`, and other backends are later consumers unless a stage exposes
  a target-neutral blocker.
- **Three.js as reference, not dependency.** It may be used as an API oracle,
  fixture generator, or comparison harness during development. Mandatory
  capstones must run without three.js.
- **Fail closed.** Unsupported layouts, shader-stage values, resource forms,
  and host descriptors must reject before execution rather than degrade through
  guessed defaults.
- **No grammar by aesthetic analogy.** New syntax requires a separate language
  decision. Prefer library APIs, existing annotations, and compiler intrinsics
  until a goal proves syntax is necessary.
- **No policy weakening.** Existing MIR GPU and hygiene gates remain intact;
  graphics work fixes exposed debt or records counted, ratcheting debt.

## Implementation Workflow

For every campaign stage:

1. Use `delivery` to compile the whole stage into a durable delivery spec.
2. State one cross-repo invariant before implementation.
3. Use `factory` for implementation, targeted validation, review, and cohesive
   commits in each touched repository.
4. Update this campaign only for routing/status changes; keep detailed progress
   in the selected goal or a stage ledger created by its delivery spec.
5. Use `poker-face` before milestone promotion and the final 80-point audit.

Compiler work follows Radix's compiler engineering rules and the existing MIR
GPU campaign. Source-library work follows Triga's `AGENTS.md`. Cross-repo
changes use non-overlapping worktrees or serialized edits; no stage may use Git
cleanup to remove another session's work.

## Scope Routing

| Surface | Canonical owner | Campaign responsibility |
| --- | --- | --- |
| Public graphics types and algorithms | `triga/src` | Scene, math, geometry, material, texture, animation, asset-facing APIs |
| Instructional library examples | `triga/exempla` | Small source-level demonstrations |
| Language semantics and compiler intrinsics | `radix/crates/radix` | Reusable vector/matrix/collection/graphics facts and diagnostics |
| MIR GPU and reflection | `radix/crates/radix/src/mir` | Stage IO, resources, layouts, pipelines, device legality, emitted artifacts |
| Browser proof runtime | `radix/hosts/webgpu-browser` until superseded | Direct WebGPU lifecycle and deterministic execution proof |
| Generated Rust runtime | `faber-runtime` | Runtime representations only when application-lane generated code needs them |
| Package/build workflow | `faber` | Provider imports and multi-artifact build/run orchestration |
| Public workload and capstone corpus | `examples` | Cross-repo scenes, assets, expected outputs, and end-to-end harnesses |
| Distribution | `cista` | Versioned installation only after an explicit release checkpoint |

The campaign does not own a web framework, editor, production deployment,
physics engine, audio engine, exhaustive file-format zoo, or three.js source
compatibility layer.

## Batching And Split Policy

- Stages 0, 4, and 5 are **discovery-first** because they establish the scoring
  harness, graphics-stage MIR model, and direct-render host pattern.
- Library family stages are **batch-by-default** after one implementation
  pattern is proven; complete the homogeneous family rather than issuing one
  factory phase per class or method.
- Cross-repo stages are **split-on-boundary** only for a named semantic,
  ownership, target-validation, artifact, browser-environment, or migration
  boundary.
- A delivery may split library and compiler commits by repository, but the
  stage gate is not satisfied until the integrated workload passes.
- Do not pre-slice individual material parameters, geometry constructors,
  lights, or animation tracks at campaign level.

## Ground Truth Researched

Local authority:

- [`src/triga.fab`](../../../src/triga.fab) and
  [`exempla/triga-basics.fab`](../../../exempla/triga-basics.fab) — current
  Triga source and only instructional proof.
- [MIR GPU campaign](../../../../radix/docs/factory/mir-gpu/CAMPAIGN.md) and its
  [progress ledger](../../../../radix/docs/factory/mir-gpu/progress-ledger.md) —
  compute, device view, vector, builtin, reflection, and host proof status.
- [Shader-stage goal](../../../../radix/docs/factory/mir-gpu/goals/08-shader-stage-model.md)
  — deferred vertex/fragment foundation that this campaign must reopen through
  evidence, not duplicate.
- [Target capability matrix](../../../../radix/docs/design/target-capability-matrix.md)
  — current executable and fail-closed target boundaries.
- [EBNF type surface](../../../../radix/EBNF.md),
  [compiler intrinsic implementation](../../../../radix/crates/radix/src/intrinsics),
  and [tensor intrinsic contract](../../../../radix/docs/design/tensor-intrinsics.md).
- [WebGPU browser host](../../../../radix/hosts/webgpu-browser/README.md) — current
  compute-only browser proof and reflection ownership boundary.
- Public GPU/vector/matrix exempla under
  [`examples/corpus`](../../../../examples/corpus) and workload rungs under
  [`examples/gpu-workload`](../../../../examples/gpu-workload).

External feature baseline, captured 2026-07-10 from official three.js sources:

- [Fundamentals](https://threejs.org/manual/en/fundamentals.html) — renderer,
  scene graph, mesh, geometry, materials, textures, lights, and animation loop.
- [Object3D](https://threejs.org/docs/pages/Object3D.html) and
  [BufferGeometry](https://threejs.org/docs/pages/BufferGeometry.html) — core
  hierarchy, transforms, bounds, attributes, groups, morphs, and indirect data.
- [WebGPURenderer](https://threejs.org/docs/pages/WebGPURenderer.html) — modern
  renderer and backend boundary.
- [Loading 3D models](https://threejs.org/manual/en/loading-3d-models.html) —
  glTF as the recommended runtime asset path spanning meshes, materials,
  textures, skins, morphs, animations, lights, and cameras.
- [AnimationMixer](https://threejs.org/docs/pages/AnimationMixer.html),
  [shadows](https://threejs.org/manual/en/shadows.html),
  [picking](https://threejs.org/manual/en/picking.html), and
  [post-processing](https://threejs.org/manual/en/post-processing.html) —
  representative advanced workflow families.

## Current State

| Track | State | Next action |
| --- | --- | --- |
| Triga public API | Initial 27-type shell; no operational math, scene, geometry, material, texture, or animation families | Stage 1 math and transforms |
| Library import/build | Sibling provider manifest and type-construction exemplar exist | Include in every source-library gate |
| Vector/tensor foundation | Source types and representative MIR GPU operations exist | Consume in Stage 1 and Stage 3; add only missing reusable facts |
| Matrix foundation | Grammar/type surface exists; current package/probe exemplar records backend rejection | Stage 1 selects and proves an executable representation |
| MIR GPU compute | Stages 0–4 complete; scalar/vector math, control flow, builtins, and reflection partly complete | Reopen only from concrete Triga blockers |
| Graphics shader stages | Deferred in MIR GPU Stage 8 | Stage 4 lowers that goal with Triga workloads |
| Browser host | Direct WebGPU compute dispatch; visible scene still rendered by three.js | Stage 5 replaces the visible path with direct Faber artifacts |
| Runtime/package artifacts | No scene/render artifact contract or graphics runtime representation | Route from Stages 4–6 based on evidence |
| Assets and animation | Absent | Stages 8–9 |
| End-to-end corpus | Stage 0 ledger and five unsupported capstone manifests exist; no GPU scene track | Stage 1 begins earning executable evidence |

## Three.js 80 Capability Scorecard

“80 percent” means workload capability, not API-symbol count. A domain earns
its points only when its required proof runs from Faber source through the
relevant library/compiler/runtime path and has durable positive and negative
validation. Partial credit is recorded only in the Stage 0 ledger against
predeclared sub-capabilities.

| Domain | Weight | Mandatory floor |
| --- | ---: | ---: |
| Core math and transforms | 10 | 7 |
| Scene graph and object lifecycle | 10 | 7 |
| Geometry and attributes | 10 | 7 |
| Renderer, cameras, visibility, and draw lifecycle | 12 | 9 |
| Materials and lighting | 14 | 10 |
| Textures and render resources | 10 | 7 |
| Animation, morphing, and skinning | 10 | 6 |
| glTF/GLB asset ingestion | 8 | 5 |
| Spatial queries, culling, and picking | 6 | 3 |
| Shadows, render targets, and post-processing | 6 | 3 |
| Instancing, particles, and compute integration | 4 | 2 |
| **Total** | **100** | **66 across all floors** |

Campaign closeout requires at least 80 total points, every mandatory floor, and
all mandatory capstones. Stage 0 may refine sub-capabilities and evidence, but
may not lower weights, floors, or capstone requirements without an explicit
campaign decision.

## Campaign Path

### Stage 0 — Capability baseline and proof harness

**Status**: complete — ledger, capstone manifests, and report harness landed
**Source**: [`goals/00-capability-baseline.md`](goals/00-capability-baseline.md)
**Why now**: freezes the scorecard, workload corpus, evidence rules, and first
cross-repo validation seam before implementation can game the target.
**Gate**: versioned capability ledger plus one red baseline for each mandatory
capstone family.
**Lowers to**: `delivery` → `factory`
**Batching**: discovery-first

### Stage 1 — Core math and transform foundation

**Status**: selected; ready for delivery
**Source**: [`goals/01-math-transform-foundation.md`](goals/01-math-transform-foundation.md)
**Depends on**: Stage 0
**Gate**: reusable vector, matrix, quaternion, Euler, color, and transform
operations execute consistently in required Rust and MIR/GPU paths.
**Lowers to**: `delivery` → `factory`
**Batching**: batch-by-default after representation proof

### Stage 2 — Scene graph and object model

**Status**: planned
**Source**: [`goals/02-scene-graph-object-model.md`](goals/02-scene-graph-object-model.md)
**Depends on**: Stages 0–1
**Gate**: heterogeneous hierarchical scenes update world transforms and preserve
shared geometry/material identity without copying the graph into backend code.
**Lowers to**: `delivery` → `factory`
**Batching**: discovery-first for identity; batch-by-default afterward

### Stage 3 — Geometry, attributes, and primitives

**Status**: planned
**Source**: [`goals/03-geometry-attributes-primitives.md`](goals/03-geometry-attributes-primitives.md)
**Depends on**: Stages 0–1; may overlap Stage 2 after identity policy is locked
**Gate**: indexed and non-indexed custom geometry plus a batched core primitive
family produce validated bounds, normals, UVs, groups, and GPU layout facts.
**Lowers to**: `delivery` → `factory`
**Batching**: discovery-first for attributes; batch-by-default for primitives

### Stage 4 — Graphics MIR and shader stages

**Status**: planned; deferred until Stage 1 representation facts and the Stage 3 attribute contract
**Source**: [`goals/04-graphics-mir-shader-stages.md`](goals/04-graphics-mir-shader-stages.md)
**Depends on**: Stages 0–1; consumes Stage 3 attribute contract
**Overlap rule**: reopens and updates MIR GPU Stage 8 instead of creating a
parallel shader-stage design.
**Gate**: typed vertex/fragment IO, graphics resources, pipeline reflection,
and fail-closed WGSL emission from a Faber fixture.
**Lowers to**: `delivery` → `factory`
**Batching**: discovery-first

### Stage 5 — Direct WebGPU host and first scene

**Status**: planned
**Source**: [`goals/05-direct-webgpu-first-scene.md`](goals/05-direct-webgpu-first-scene.md)
**Depends on**: Stages 1–4
**Gate**: a Faber-authored indexed scene renders in a browser through generated
WGSL/reflection and direct WebGPU lifecycle with no three.js runtime.
**Lowers to**: `delivery` → `factory`
**Batching**: discovery-first
**Release checkpoint**: decide whether to tag an internal proof milestone; no
publication is implied.

### Stage 6 — Materials, textures, and lighting

**Status**: planned
**Source**: [`goals/06-material-texture-lighting.md`](goals/06-material-texture-lighting.md)
**Depends on**: Stage 5; Stage 3 geometry attributes
**Gate**: unlit, normal-lit, and metallic-roughness textured scenes execute with
multiple light families and explicit color-space/sampler/resource contracts.
**Lowers to**: `delivery` → `factory`
**Batching**: discovery-first for resources; batch-by-default for coherent families

### Stage 7 — Cameras, culling, and picking

**Status**: planned
**Source**: [`goals/07-camera-culling-picking.md`](goals/07-camera-culling-picking.md)
**Depends on**: Stages 2, 3, and 5; may overlap Stage 6
**Gate**: perspective/orthographic cameras, frustum culling, bounds, raycasting,
and one deterministic picking path work in a dynamic scene.
**Lowers to**: `delivery` → `factory`
**Batching**: batch-by-default after camera/frustum proof

### Stage 8 — Animation and deformation

**Status**: planned
**Source**: [`goals/08-animation-deformation.md`](goals/08-animation-deformation.md)
**Depends on**: Stages 1–5
**Gate**: keyframe clips/mixing animate transforms and at least one morph or
skinned mesh through the render loop.
**Lowers to**: `delivery` → `factory`
**Batching**: discovery-first for bindings; batch-by-default for track families

### Stage 9 — glTF/GLB asset ingestion

**Status**: planned
**Source**: [`goals/09-gltf-asset-ingestion.md`](goals/09-gltf-asset-ingestion.md)
**Depends on**: Stages 3, 6, and 8
**Gate**: a representative glTF/GLB fixture loads meshes, hierarchy, materials,
textures, cameras/lights, and available animation without a three.js loader.
**Lowers to**: `delivery` → `factory`
**Batching**: discovery-first for format boundary; batch the selected core subset

### Stage 10 — Shadows, render targets, and post-processing

**Status**: planned
**Source**: [`goals/10-shadows-render-targets-postprocessing.md`](goals/10-shadows-render-targets-postprocessing.md)
**Depends on**: Stages 5–7
**Gate**: shadow mapping and a deterministic multipass render-target effect
execute from compiler-owned graphics reflection.
**Lowers to**: `delivery` → `factory`
**Batching**: discovery-first for multipass; batch compatible pass families

### Stage 11 — Instancing, particles, and compute integration

**Status**: planned
**Source**: [`goals/11-instancing-particles-compute.md`](goals/11-instancing-particles-compute.md)
**Depends on**: Stages 3–5; consumes existing MIR GPU compute facts
**Gate**: one high-count instanced scene and one compute-updated particle or
indirect-geometry workload render through shared resources without CPU copies
that erase the GPU proof.
**Lowers to**: `delivery` → `factory`
**Batching**: discovery-first for shared resources; batch-by-default afterward

### Stage 12 — Capstones and 80-point audit

**Status**: planned
**Source**: [`goals/12-capstone-80-audit.md`](goals/12-capstone-80-audit.md)
**Depends on**: all stages contributing to the claimed score
**Gate**: independent audit confirms at least 80 points, every mandatory floor,
all capstones, honest deferrals, and broad cross-repo validation.
**Lowers to**: `delivery` → `factory`
**Batching**: split on audit boundaries; batch homogeneous residuals
**Release checkpoint**: explicitly choose release prep, internal milestone, or
continued foundation work.

## Parallelism Windows

- Stage 4 may overlap Stages 2–3 once Stage 1 locks physical math facts and
  Stage 3 locks the vertex attribute contract needed by the first shader proof.
- Stages 6 and 7 may run in parallel with non-overlapping files and fixtures.
- Stage 8 may begin after the Stage 5 loop contract even while Stage 6 expands
  material families.
- Stage 11 may start after Stage 5 if it consumes existing material/texture
  subsets and does not preempt Stage 6 ownership.
- Stage 9 waits for the public types it must construct; it must not invent a
  private shadow scene model to start early.

## Dependency Rules

- If Triga needs a generally useful operation on `vector`, `matrix`, `tensor`,
  atomics, collections, or numeric types, route it to Radix intrinsics; do not
  duplicate compiler-owned receiver semantics in Triga.
- If a feature can be implemented as ordinary Faber over admitted primitives,
  keep it in Triga; compiler promotion requires target or semantic evidence.
- If MIR GPU already owns the fact, extend its campaign/ledger rather than
  creating Triga-specific MIR metadata.
- If a graphics resource or pipeline property is backend-specific, place it in
  reflection/host descriptors, not the public scene model, unless multiple
  backend consumers prove it is a domain concept.
- If generated Rust needs a representation unavailable in `faber-runtime`, add
  it there only after proving it is not a Triga-local type.
- If browser execution requires guessing a missing shader, layout, resource,
  draw, or pipeline fact, stop and route the fact back to Radix.
- If a goal proposes a new annotation or keyword, stop for a language-design
  decision and update EBNF, reader packs, diagnostics, and exempla together.
- If a goal touches asset transport, separate parsing from browser/network
  acquisition. Triga owns the asset model; host routes own bytes and URLs.
- If a goal requires three.js at runtime after Stage 5, classify it as an
  oracle-only harness or stop; runtime dependency violates the campaign.
- Physics, audio, WebXR, CSS renderers, exhaustive controls/helpers/loaders,
  production bundling, and editor tooling remain outside the 80-point claim.

## Mandatory Capstones

1. **Hello Triga** — indexed rotating geometry with camera and direct WebGPU
   rendering, no three.js runtime.
2. **Hierarchical lit scene** — heterogeneous nested objects, shared resources,
   multiple cameras/lights, transform propagation, culling, and picking.
3. **Asset scene** — glTF/GLB model with metallic-roughness material, textures,
   hierarchy, and at least one animation or deformation path.
4. **Multipass scene** — dynamic shadows plus an offscreen render target and one
   deterministic post-processing pass.
5. **GPU-scale scene** — instanced or particle workload whose state is updated
   by Faber-emitted compute and consumed by rendering without host round-trip.

## First Useful Milestones

1. Capability ledger and red capstone harness exist.
2. Triga math and scene graph can build/update a hierarchical scene on CPU.
3. Faber emits typed vertex/fragment WGSL plus graphics reflection.
4. Hello Triga renders through direct WebGPU with no three.js.
5. A textured, lit, animated glTF scene runs.
6. Shadows/multipass and GPU-scale workloads pass.
7. The independent scorecard audit reaches 80 points.

## Acceptance Criteria

This campaign artifact is ready when:

- every active stage has a linked goal, status, dependency, gate, lowering path,
  and batching posture;
- Stage 0 is selected as the next stage to lower;
- the scorecard totals 100 and locks the 80-point/floor rules;
- cross-repo ownership and MIR GPU overlap rules are explicit;
- mandatory capstones prevent type-only or host-reimplemented claims;
- release checkpoints and excluded families are explicit;
- risky or architecture-changing conditions stop instead of improvising.

Campaign completion requires the Desired End State, score, floors, capstones,
validation, and closeout audit—not merely completion of every planned document.

## Validation

Artifact validation:

```bash
find docs/factory/triga-threejs-80 -type f | sort
rg -n "Status|Depends on|Gate|Lowers to|Batching|Stop Conditions" \
  docs/factory/triga-threejs-80
git diff --check
```

Implementation validation is stage-owned. At major checkpoints it must include
the narrow Triga checks, affected Radix/Faber/runtime tests, public workload
harnesses, generated-artifact freshness, fail-closed cases, and browser proof
when the environment supports WebGPU. Full Radix release validation is reserved
for graphics-stage promotion and final closeout, not every library edit.

## Open Questions

- Which identity/ownership representation best supports heterogeneous scene
  graphs across generated Rust, MIR execution, and GPU resource caches?
- Should register matrices become executable across the required targets, or
  should Triga use a distinct storage/host matrix representation with explicit
  conversions?
- What is the smallest source-level shader-stage surface that remains useful
  outside Triga and avoids embedding a second shader language?
- Does the direct browser host remain under Radix after Stage 5, or should a
  reusable host/runtime repo become the canonical owner?
- Which glTF subset is sufficient for the mandatory asset capstone without
  turning the campaign into a general asset-tooling project?
- Which remaining 20 percent should be explicitly deferred at closeout rather
  than allowed to distort foundational work?

## Stop Conditions

- A delivery replaces the public Triga model with backend descriptor structs.
- A host or emitter guesses layout, bindings, transforms, shader IO, resource
  lifetime, or draw ordering.
- Three.js becomes a permanent runtime dependency or implementation layer.
- A type-only or text-emission test is presented as a functional scene proof.
- A Triga-specific compiler intrinsic is proposed without a reusable semantic
  contract and non-Triga exemplar.
- A graphics-stage MIR change considers only WGSL when other systems targets
  must consume, reject, or defer the same fact.
- A stage weakens MIR device legality, target capability gates, hygiene budgets,
  or negative tests to gain scorecard points.
- Cross-repo edits overlap another session's dirty work and cannot be safely
  partitioned.
- A stage expands into physics, audio, WebXR, editor tooling, deployment, or
  exhaustive three.js/addon parity without a new campaign decision.
