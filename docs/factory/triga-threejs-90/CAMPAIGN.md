# Campaign: Triga Three.js 90

**Status**: parked successor (2026-07-10) — ready for routing only
**Mode**: draft/maintain — provisional campaign control plane
**Owner repo**: `/Users/ianzepp/work/faberlang/triga`
**Participating repos**: `triga`, `radix`, `faber`, `faber-runtime`, `examples`; host/runtime ownership to be reconciled at activation
**Predecessor**: [Triga Three.js 80](../triga-threejs-80/CAMPAIGN.md)
**Selected next stage**: none — wait for the predecessor's Stage 12 audit
**Release posture**: foundation-first; no public release is implied

## Summary

This parked successor campaign describes the capability surface for advancing a
verified Triga Three.js 80 result to 90 percent workload equivalence. It
concentrates the next ten points on programmable materials, advanced physical
rendering, efficient asset delivery, explicit render orchestration, backend
portability, and high-scale scenes. Those surfaces are chosen for the pressure
they place on Faber, Radix, MIR GPU, runtime/resource contracts, and package
boundaries rather than for API-symbol parity with three.js.

The campaign is intentionally not implementation-ready. Its goal files are
surface briefs only. After the 80-percent closeout, Stage 0 must reconcile the
live repositories and audit evidence, revise the point allocation if needed,
and lower the first selected goal through `delivery` before any factory work.

## Invariant

The 80-to-90 increment must add backend-neutral, workload-proven graphics
capabilities at their canonical Faber, Triga, Radix, MIR, runtime, or host seam;
no point is earned by host substitution, backend-specific public APIs,
declaration coverage, or three.js runtime delegation.

## Problem

The 80-percent campaign deliberately defers several difficult capability
families so it can first establish an honest scene, renderer, material, asset,
animation, and multipass foundation. The most valuable remaining families are
also the ones most likely to expose foundational limits:

- typed user programmability across shader stages;
- physically richer materials and environment lighting;
- compressed assets and bounded asynchronous resource delivery;
- nontrivial render-graph scheduling and image-quality passes;
- target-neutral contracts exercised by more than one backend;
- large-scene residency, batching, visibility, and indirect GPU work.

Defining detailed implementation now would guess at seams the predecessor is
supposed to discover. Leaving the successor entirely implicit, however, would
make it easy to spend the final 20 percent on low-pressure addon breadth. This
campaign records the intended direction without preempting the 80-percent
audit.

## Desired End State

At campaign closeout:

1. The inherited capability ledger verifies at least 90/100 points, with the
   predecessor's mandatory floors and capstones still intact.
2. Faber authors can construct a bounded programmable material without
   escaping to public shader strings or host-side shader assembly.
3. Representative advanced physical materials render under image-based
   environment lighting with explicit color, texture, and sampling contracts.
4. A compressed real-world asset follows bounded acquisition, decoding,
   parsing, residency, and GPU upload paths into public Triga objects.
5. An explicit render graph drives a nontrivial image-quality chain with
   validated resource lifetimes and hazards.
6. One unchanged Triga scene executes through WebGPU and a selected second
   backend without forking the public scene or material model.
7. A high-scale scene proves batching, visibility, residency, and GPU-driven
   work without per-object host orchestration erasing the result.
8. The remaining 10 percent, target limits, and deferred ecosystem families
   are documented without presenting 90 percent as production or source
   compatibility with three.js.

## Development Posture

- **Parked until evidence exists.** No campaign stage may be selected before
  the Three.js 80 Stage 12 audit is complete and internally consistent.
- **Surface-first planning.** These goal briefs name capability families and
  architectural pressure only. Delivery specs created later own invariants,
  implementation graphs, fixtures, acceptance criteria, and validation.
- **Clean breaks.** The successor may replace predecessor abstractions when the
  audit proves they cannot support the 90-percent surface cleanly.
- **Workload equivalence.** Scores measure representative scene capability,
  not class, method, addon, or shader-node counts.
- **Backend-neutral public model.** Target capability differences belong in
  compiler/reflection contracts and fail-closed negotiation, not parallel
  Triga APIs.
- **Three.js remains an oracle.** It may inform behavior and fixtures but may
  not become a runtime implementation layer.

## Implementation Workflow

After activation, each selected campaign stage must:

1. Use `delivery` to research the live repositories and compile a durable,
   implementation-ready spec from the corresponding surface brief.
2. State the cross-repo invariant and ownership boundaries discovered by the
   predecessor before implementation begins.
3. Use `factory` for implementation, validation, review, and cohesive commits
   in each affected repository.
4. Keep detailed progress in the delivery/factory artifacts rather than
   expanding these provisional goal briefs in advance.
5. Use `poker-face` for the final score and capstone audit.

## Scope Routing

| Surface | Likely canonical owners | Campaign pressure |
| --- | --- | --- |
| Programmable materials | `triga`, `radix` MIR GPU and reflection | Typed composition, stage legality, specialization, resource identity, diagnostics |
| Advanced PBR and environment lighting | `triga`, `radix`, graphics host/runtime | Physical parameters, IBL preprocessing, color science, texture sampling, numerics |
| Compressed and streamed assets | `triga`, `faber`, runtime/host providers, `examples` | Bytes, codecs, bounded decoding, async ownership, residency, upload |
| Render graph and image quality | `triga`, `radix`, graphics host/runtime | Pass DAGs, attachments, hazards, transient lifetimes, pipeline variants |
| Backend portability | `radix`, selected hosts/runtimes, `examples` | Target-neutral MIR/reflection, capability negotiation, consistent failure |
| High-scale rendering | `triga`, `radix`, graphics host/runtime | Batching, LOD/visibility, indirect work, dirty ranges, memory residency |

Physics, audio, WebXR, CSS renderers, editor tooling, production deployment,
exhaustive controls, exhaustive loader/effect catalogs, and total TSL or
three.js source parity remain outside this campaign.

## Provisional Increment Allocation

These are reserved increment points, not completion credit. Stage 0 may revise
the allocation from audit evidence but may not weaken the verified
80-percent baseline or hide unfinished predecessor work.

| Goal surface | Reserved increment |
| --- | ---: |
| Programmable materials | 3.0 |
| Advanced PBR and environment lighting | 2.0 |
| Compressed and streamed assets | 1.5 |
| Render graph and image quality | 1.5 |
| Backend portability | 1.0 |
| High-scale rendering | 1.0 |
| **Total** | **10.0** |

## Batching And Split Policy

- Stage 0 is **discovery-first** and must replace provisional claims with live
  evidence before routing implementation.
- Programmable materials, render-graph evolution, and the second backend are
  **discovery-first** because their first proofs establish shared contracts.
- Advanced material families, admitted codecs, image-quality passes, and scale
  features become **batch-by-default** after their first integrated pattern.
- Split only at a demonstrated semantic, target, ownership, codec/security,
  resource-lifetime, validation, or migration boundary.
- Do not pre-slice shader nodes, PBR parameters, compressed extensions, effects,
  or backend features into factory phases at campaign level.

## Ground Truth Researched

This provisional campaign derives from:

- the [Three.js 80 campaign](../triga-threejs-80/CAMPAIGN.md), especially its
  scorecard, dependency rules, deferred families, and Stage 12 audit contract;
- its [materials goal](../triga-threejs-80/goals/06-material-texture-lighting.md),
  which defers total node-material parity and advanced physical materials;
- its [asset goal](../triga-threejs-80/goals/09-gltf-asset-ingestion.md), which
  defers compressed geometry and texture delivery;
- its [multipass goal](../triga-threejs-80/goals/10-shadows-render-targets-postprocessing.md),
  which defers broader render-graph and image-quality work;
- its [GPU-scale goal](../triga-threejs-80/goals/11-instancing-particles-compute.md),
  which establishes the initial compute/render seam but not large-scene depth.

Live implementation authority must be researched again during Stage 0. This
document does not freeze current APIs, host ownership, MIR representation, or
backend choice.

## Current State

| Track | State | Next action |
| --- | --- | --- |
| Three.js 80 predecessor | Proposed with Stage 0 selected; final evidence does not yet exist | Complete its campaign through Stage 12 |
| Successor score | Six surfaces reserve ten provisional points | Reconcile against the verified 80 ledger in this campaign's Stage 0 |
| Goal briefs | Surface descriptions only | Compile one into a delivery spec only after activation |
| Backend choice | WebGPU remains the predecessor target; no second backend is selected | Compare WebGL2 and native `wgpu` from live constraints during Stage 0 |
| Release | Not selected | Reconsider only at the 90-percent closeout checkpoint |

## Campaign Path

### Stage 0 — Activate From The Verified 80 Audit

**Status**: gated; not selected
**Source**: [Three.js 80 Goal 12](../triga-threejs-80/goals/12-capstone-80-audit.md)
**Depends on**: verified completion of the predecessor campaign
**Surface**: reconcile the live score, residual gaps, ownership seams, target
constraints, performance evidence, and deferred families; then freeze the
90-percent ledger and select the first goal.
**Gate**: evidence-backed successor ledger, confirmed or revised increment
allocation, selected second-backend decision process, and one goal authorized
to lower through `delivery`.
**Lowers to**: `delivery` → `factory` for a bounded research/activation phase
**Batching**: discovery-first

### Stage 1 — Programmable Materials

**Status**: parked
**Source**: [`goals/01-programmable-materials.md`](goals/01-programmable-materials.md)
**Depends on**: Stage 0 and the predecessor's graphics/material contracts
**Surface**: a bounded Faber-native typed composition model spanning
vertex, fragment, and compute participation, resources, specialization, and
diagnostics.
**Lowers to**: `delivery` → `factory` after activation
**Batching**: discovery-first

### Stage 2 — Advanced PBR And Environment Lighting

**Status**: parked
**Source**: [`goals/02-advanced-pbr-environment.md`](goals/02-advanced-pbr-environment.md)
**Depends on**: Stages 0–1 and the predecessor's standard PBR path
**Surface**: a bounded advanced physical-material family plus HDR environment
lighting and image-based-lighting preprocessing.
**Lowers to**: `delivery` → `factory` after activation
**Batching**: prove one extension, then batch the coherent family

### Stage 3 — Compressed And Streamed Assets

**Status**: parked
**Source**: [`goals/03-compressed-streamed-assets.md`](goals/03-compressed-streamed-assets.md)
**Depends on**: Stage 0 and the predecessor's core glTF/GLB path; may overlap
Stage 1 after byte, codec, and ownership boundaries are frozen
**Surface**: compressed geometry/textures, HDR environment assets, bounded
decoding, asynchronous acquisition, residency, and upload.
**Lowers to**: `delivery` → `factory` after activation
**Batching**: discovery-first per codec boundary; batch admitted formats

### Stage 4 — Render Graph And Image Quality

**Status**: parked
**Source**: [`goals/04-render-graph-image-quality.md`](goals/04-render-graph-image-quality.md)
**Depends on**: Stage 0, predecessor multipass rendering, and the stable
programmable-material seam from Stage 1 where passes consume it
**Surface**: explicit render scheduling, transient resources, hazards,
multisampling, tone mapping, antialiasing, and a bounded post chain.
**Lowers to**: `delivery` → `factory` after activation
**Batching**: discovery-first for graph ownership; batch compatible passes

### Stage 5 — Backend Portability

**Status**: parked
**Source**: [`goals/05-backend-portability.md`](goals/05-backend-portability.md)
**Depends on**: Stages 0–1 and stable render/resource contracts from Stage 4
**Surface**: run unchanged Triga workloads through WebGPU and one selected
second backend with explicit capability negotiation and no public API fork.
**Lowers to**: `delivery` → `factory` after activation
**Batching**: discovery-first

### Stage 6 — High-Scale Rendering

**Status**: parked
**Source**: [`goals/06-high-scale-rendering.md`](goals/06-high-scale-rendering.md)
**Depends on**: Stage 0, the predecessor's instancing/compute proof, and the
render/resource model needed for measured large-scene workloads
**Surface**: batching, LOD/visibility depth, indirect work where supported,
streaming residency, dirty ranges, and high-cardinality scene evidence.
**Lowers to**: `delivery` → `factory` after activation
**Batching**: prove one scale path, then batch compatible mechanisms

### Stage 7 — Capstones And 90-Point Audit

**Status**: parked; source must be created after Stage 0 freezes the ledger
**Depends on**: every stage contributing to the claimed increment
**Surface**: integrated programmable-material, advanced-asset, render-graph,
dual-backend, and scale proofs; independent score and ownership audit; honest
remaining-10-percent record.
**Lowers to**: `delivery` → `factory`
**Batching**: split on audit boundaries; batch homogeneous residuals
**Release checkpoint**: choose release preparation, internal milestone, or
continued foundation work explicitly.

## Dependency Rules

- If the Three.js 80 audit has not verified its score, floors, capstones, and
  deferrals, do not select or lower a Three.js 90 implementation stage.
- Stage 0 may revise weights and ordering from evidence, but it may not transfer
  unfinished 80-percent requirements into this campaign to manufacture closure.
- Programmable material behavior must lower through typed Faber/Radix/MIR facts;
  public shader strings or host-assembled material programs do not qualify.
- Codec and network/provider work must remain separate from the public asset and
  scene model; unsupported or unbounded input fails closed.
- A second backend must consume the canonical Triga and compiler contracts. Do
  not fork the public API or regress WebGPU to accommodate it.
- Render-graph facts and resource hazards must be explicit above host command
  encoding; hosts may execute the graph but may not invent it.
- Performance thresholds and workload shapes must be frozen by later delivery
  specs from measured baselines, not guessed in these briefs.
- New Faber syntax or annotations require a separate language decision and
  coordinated grammar, diagnostics, reader, exemplar, and implementation work.
- Physics, audio, WebXR, controls, editors, and addon catalogs require a new
  campaign decision rather than opportunistic expansion here.

## First Useful Milestones

1. The verified 80-percent audit activates a frozen 90-percent ledger.
2. A typed programmable material drives custom vertex and fragment behavior.
3. An advanced physical asset renders under HDR environment lighting.
4. A compressed asset and explicit image-quality render graph run end to end.
5. One unchanged representative scene runs on WebGPU and a second backend.
6. The high-scale workload and independent 90-point audit pass.

## Acceptance Criteria

This provisional campaign artifact is ready when:

- the predecessor audit is an explicit activation gate and no stage is selected
  prematurely;
- the six goal surfaces reserve exactly ten provisional increment points;
- every implementation stage links to a lightweight goal brief and defers
  implementation criteria to a future delivery spec;
- cross-repo ownership, batching posture, exclusions, release posture, and stop
  conditions are explicit;
- Stage 0 is authorized to revise provisional routing from live evidence
  without weakening or relabeling the 80-percent result.

Campaign completion requires a verified 90/100 score, inherited floors and
capstones, successor capstones defined after activation, broad validation, and
an honest remaining-10-percent audit. Completing this planning artifact does
not activate or complete the campaign.

## Validation

Artifact validation:

```bash
find docs/factory/triga-threejs-90 -type f | sort
rg -n "Status|Depends on|Surface|Lowers to|Activation|Stop Conditions" \
  docs/factory/triga-threejs-90
git diff --check
```

Implementation validation is intentionally undefined until Stage 0 inspects
the predecessor's final fixtures, ledgers, target matrix, and live repository
owners. Each later delivery spec must define its own positive, negative,
cross-target, workload, and environment gates.

## Open Questions

- What score and residual capability map does the Three.js 80 audit actually
  produce?
- Which programmable-material representation is useful and typed without
  attempting total TSL/node parity?
- Which advanced physical parameters form one coherent implementation family?
- Which codecs belong in Faber/Triga, a runtime provider, or an external tool?
- Should the second backend be WebGL2 for browser breadth or native `wgpu` for
  systems-target pressure?
- Which image-quality and scale workloads produce useful architectural evidence
  without becoming a benchmark or effects catalog?

## Stop Conditions

- Work begins before the Three.js 80 Stage 12 audit verifies the predecessor.
- A surface brief is treated as implementation-ready without a delivery spec
  grounded in the live repositories.
- Point allocation is changed to hide a failed predecessor capability or lower
  an inherited proof requirement.
- Public Triga APIs fork by backend, expose host handles, or encode one target's
  descriptor model.
- Shader composition, asset decoding, render scheduling, or scale behavior is
  silently reimplemented in a browser/native host to make a capstone pass.
- Unsupported target, resource, codec, or graph behavior degrades through
  guessed defaults rather than failing closed.
- Scope expands into physics, audio, WebXR, editor tooling, production
  deployment, exhaustive addons, or source compatibility without a new
  campaign decision.
