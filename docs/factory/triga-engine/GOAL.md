# Goal: Triga Engine And World-Building Architecture

**Status**: active — S0 architecture checkpoint and S1 seam-repair evidence are landed; S2 shared-renderer vertical slice remains planned

**Owner repo**: `/Users/ianzepp/work/faberlang/triga`

**Participating repos**: `triga`, `radix`, `hosts`, `faber`,
`faber-runtime`, `examples`; `cista` only for an explicit distribution
checkpoint

**Lowers to**: architecture checkpoint → `delivery` → `factory`

**Batching posture**: discovery-first for the public seams and first vertical
slice; batch-by-default for repeated material, asset, and workload families
after the seams are proven

**Primary product target**: a production-oriented 3D engine that lets Faber
authors build persistent, interactive worlds without writing renderer-local
WGSL, duplicating WebGPU lifecycle code, or reimplementing scene infrastructure
in every demo

## Purpose

This goal records the architectural destination for Triga as a world-building
engine. It is intentionally a vision artifact, not an implementation-ready
delivery specification. It names the package/module boundaries, ownership
rules, target file inventory, engine responsibilities, and capstone outcomes
that later delivery work must refine against live compiler and host evidence.

The central decision is:

> Triga remains one versioned Faber source package, but it is organized as
> explicit importable modules representing the engine's semantic lanes. The
> engine runtime is implemented at the host boundary, while Triga owns the
> backend-neutral scene, resource, material, shader-intent, render-plan, and
> world contracts that the runtime executes.

The demos become consumers and acceptance workloads for that engine. They do
not become independent renderers.

## Vision

Faber authors should be able to construct a world from ordinary library values:

- terrain, regions, and reusable world instances;
- hierarchical objects, cameras, and lights;
- generated or imported geometry;
- standard materials, textures, and environment lighting;
- animation, deformation, and interaction-ready scene state;
- explicit world persistence and asset references;
- spatial queries, picking, culling, level of detail, and instancing;
- render-quality features such as shadows, render targets, and postprocessing.

The authoring program should describe the world and its behavior. A shared
engine should own frame execution, resource residency, shader selection,
pipeline caching, render-pass scheduling, diagnostics, and backend lifecycle.

The production-level outcome is not source compatibility with Unreal or
Three.js. It is a coherent Triga engine with the following user experience:

```text
Faber world package
  → Triga scene/material/world contracts
    → Radix lowering and reflection
      → shared engine runtime
        → selected host backend
          → presented world
```

Every standard demo should be able to use the same engine package and host
runtime. A demo may exercise a new engine capability, but it must not carry a
private copy of the renderer.

## Current baseline

Triga already has the beginning of this shape:

- one `triga` Faber source package;
- one `.fab` source module per `triga:<path>` import;
- a Norma-style flat module map for math, graph, material, geometry,
  primitives, scene, and resource concepts;
- a `triga:triga` facade that documents the leaves without owning genera;
- shared browser host assets for the current corpus demos;
- direct WebGPU execution in the sibling browser host;
- compiler-emitted graphics WGSL/reflection paths in Radix.

The current public module rules are defined by [`AGENTS.md`](../../../AGENTS.md),
the [module map](../../module-map.md), and the [API shape policy](../../api-shape-policy.md).
The current corpus demonstrates a shared greybox renderer and shared lit-mesh
shader under [`corpus/_host`](../../../corpus/README.md), but that runtime is not
yet a general production engine.

The current ownership boundary is:

| Area | Current authority | Long-term authority |
| --- | --- | --- |
| Backend-neutral scene and graphics vocabulary | `triga/src` | `triga/src` modules below |
| Language semantics and source lowering | `radix/crates/radix` | Radix's existing compiler/MIR lanes |
| WGSL and reflection | Radix graphics/MIR lowering | Radix, with stable reflection contracts |
| Browser device and GPU execution | `hosts/webgpu-browser` | Shared engine runtime plus backend adapter |
| Provider routing kernel | `hosts/crates/host-kernel` | Remains provider-neutral; not the renderer |
| Generated Rust representations | `faber-runtime` when required | Generated-code runtime only |
| Build/package orchestration | `faber` and `cista` | Build and distribution seams only |
| End-to-end workloads | `triga/corpus`, `examples` | World-building capstones and regression corpus |

Some predecessor campaign status text predates the current direct Triga corpus
proof. Live source, generated artifacts, and host behavior remain authoritative
when later delivery specs reconcile the baseline.

## Structural model

### Faber package and import terminology

Faber does not need a Cargo-style subcrate split for this architecture. Keep a
single `triga` source package and use source modules as the stable import
boundaries:

```text
src/math.fab              → triga:math
src/scene/store.fab       → triga:scene/store
src/render/pass.fab       → triga:render/pass
```

Nested directories are namespaces, not independently versioned packages. A
nested package should contain at least two modules and preferably three. A
facade such as `src/scene.fab` may document or compose the leaves, but current
Faber/Triga policy does not provide type re-export semantics. Consumers import
the leaf that owns the type.

The `triga:triga` facade must remain a map and orientation point. It must not
become a god module, a compatibility barrel, or an ownership escape hatch.

Faber import aliases such as `privata scene` are local names for imported
modules. They should not be treated as a Rust-style private-crate boundary.
Public module paths therefore require deliberate API ownership and stability.
Implementation helpers should remain inside their owning leaf unless a second
real importer justifies a new public module.

### Engine layers

The target architecture has five semantic layers:

1. **Domain foundation** — values, transforms, handles, geometry, materials,
   lights, animation, and world data.
2. **Render intent** — shader requirements, resources, draw items, pipeline
   facts, render passes, targets, and render graphs.
3. **Compiler contract** — Radix/MIR lowering, target capability checks, WGSL,
   reflection, and artifact validation.
4. **Engine runtime** — frame scheduling, scene extraction, resource
   residency, shader/pipeline caches, pass execution, and diagnostics.
5. **Backend adapter** — WebGPU device/resource/command operations, followed
   later by another backend selected from evidence.

The public Triga model stops at backend-neutral render intent. It must not carry
`GPUDevice`, `GPUBuffer`, `GPUTexture`, browser canvas handles, or other backend
objects. The host consumes compiler reflection and explicit render facts; it
does not infer bindings, layouts, passes, or resources from WGSL or object names.

### Dependency direction

The dependency graph must remain acyclic and point from stable semantics toward
execution:

```text
math / resource
      ↓
graph / geometry / material / lighting
      ↓
scene / renderable / animation / asset
      ↓
shader / render
      ↓
engine contract
      ↓
Radix lowering and host backend
```

The following reverse dependencies are architectural defects:

- `material` importing `graph` merely to define `Mesh`;
- `scene` importing WebGPU or shader code;
- `shader` importing browser runtime code;
- `render` reconstructing facts that belong to Radix reflection;
- the host recreating Triga scene or material semantics;
- demos importing private host implementation files.

## Proposed Triga file inventory

This is the target inventory. File names are proposed ownership markers, not a
commit to create every leaf in one change. A later delivery must split files
only at a demonstrated semantic, ownership, validation, migration, or
resource-lifetime boundary.

```text
triga/
  faber.toml
  cista.toml
  src/
    math.fab                         # existing foundation leaf
    resource.fab                     # existing handle/lifecycle leaf
    face.fab                         # existing specialized geometry helper

    graph.fab                        # graph facade/map after split
    graph/
      object.fab                     # Object3D and transformable node values
      camera.fab                     # camera models and projection facts
      light.fab                      # light attachment/node values

    scene.fab                        # scene facade/map after split
    scene/
      node.fab                       # heterogeneous scene-node values
      store.fab                      # stable identity and mutation store
      query.fab                      # visibility, traversal, and selection queries

    geometry.fab                     # geometry facade/map after split
    geometry/
      data.fab                       # MeshGeometry and CPU-side vertex data
      attribute.fab                  # BufferAttribute and typed attributes
      layout.fab                     # vertex layout and buffer-layout facts
      bounds.fab                     # bounds, spheres, boxes, and spatial extents
      batch.fab                      # geometry groups and draw-range data

    primitives.fab                   # primitive facade/map after split
    primitives/
      basic.fab                      # plane, box, circle, sphere, cylinder, cone
      procedural.fab                 # deterministic procedural generators
      terrain.fab                    # terrain-oriented mesh generation
      voxel.fab                      # voxel/chunk surface generation

    material.fab                     # material facade/map after split
    material/
      base.fab                       # common material state and pipeline facts
      basic.fab                      # unlit/basic material
      lit.fab                        # classic directional/Phong-style material
      standard.fab                   # metallic-roughness/PBR material
      texture.fab                    # texture slots and color-space intent
      sampler.fab                    # sampling and mip/wrap/filter intent

    lighting.fab                     # lighting facade/map
    lighting/
      light.fab                      # directional, point, spot, hemisphere
      model.fab                      # lighting-family and shader requirements
      environment.fab                # sky, environment, and image lighting intent
      shadow.fab                     # shadow-casting/receiving policy

    renderable.fab                   # renderable facade/map
    renderable/
      mesh.fab                       # Mesh = graph + geometry + material binding
      skin.fab                       # skin/deformation resource references
      morph.fab                      # morph-target resource references
      instance.fab                   # instanced renderable data

    shader.fab                       # shader facade/map; no WGSL strings
    shader/
      stage.fab                      # typed vertex/fragment/compute stage intent
      value.fab                      # backend-neutral typed shader expressions
      program.fab                     # composed material/shader program intent
      resource.fab                   # shader resource requirements
      variant.fab                    # specialization and cache identity

    render.fab                       # render facade/map
    render/
      item.fab                       # backend-neutral render item/draw intent
      pipeline.fab                   # pipeline topology/state requirements
      target.fab                     # color/depth/render-target declarations
      pass.fab                       # one render or compute pass
      graph.fab                      # pass DAG, dependencies, hazards, ordering
      batch.fab                      # batching, instancing, and submission groups
      capability.fab                 # target-neutral required/optional features

    engine.fab                       # small high-level authoring facade/map
    engine/
      renderer.fab                   # renderer/session contract, not WebGPU code
      frame.fab                      # frame lifecycle and update/submission facts
      session.fab                    # engine/world attachment and diagnostics
      capability.fab                 # engine-level capability negotiation

    asset.fab                        # asset facade/map
    asset/
      source.fab                     # asset identity, URI/package references
      gltf.fab                       # glTF/GLB semantic ingestion contract
      image.fab                      # image/texture payload and decode intent
      cache.fab                      # residency, version, and invalidation facts

    animation.fab                    # animation facade/map
    animation/
      clip.fab                       # clips, channels, and keyframes
      sampler.fab                    # interpolation and time sampling
      mixer.fab                      # animation evaluation and blending
      deformation.fab                # skinning/morph evaluation requirements

    world.fab                        # world-building facade/map
    world/
      region.fab                     # persistent world regions/chunks
      terrain.fab                    # terrain layers, heightfields, materials
      stream.fab                     # bounded acquisition/residency/eviction
      instance.fab                   # reusable prefabs and world instances
      query.fab                      # spatial queries, picking, placement rules

    triga.fab                        # orientation facade; no genera ownership

  exempla/
    ...                               # small module and contract examples
  corpus/
    ...                               # browser-rendered engine workloads
  docs/
    factory/triga-engine/GOAL.md      # this vision artifact
    ...
```

### Current-to-target ownership corrections

The first architectural cleanup should correct ownership before expanding
features:

| Current location | Target owner | Reason |
| --- | --- | --- |
| `material.fab: MeshGeometry` | `geometry/data` | Geometry data is not appearance state |
| `material.fab: Mesh` | `renderable/mesh` | Mesh composes graph, geometry, and material |
| `graph.fab: light fields` | `lighting/light` plus graph attachment | Node placement and lighting semantics are different concerns |
| `geometry.fab: mixed data/layout methods` | `geometry/data`, `attribute`, `layout` | CPU data, vertex layout, and host facts have distinct consumers |
| `scene.fab: store/query growth` | `scene/store`, `scene/query` | Identity mutation and read-only traversal need separate seams |
| corpus `_host` shader/runtime files | shared host engine package | Demo assets are proof fixtures, not the permanent renderer distribution |

These are clean-break architectural targets. Existing internal callers are not
automatically compatibility contracts. Any public migration must be justified
by live consumers and validated at the package boundary.

## Responsibilities by module family

### Foundation: `math` and `resource`

`math` owns backend-neutral numerical values and deterministic operations:
vectors, matrices, quaternions, colors, bounds, rays, and transform payloads.
It must not know about scenes, shaders, or a GPU backend.

`resource` owns logical identity and lifecycle facts: handles, generations,
transitions, residency identity, and invalidation. It must not allocate browser
resources or decide how a material is rendered.

### Scene and world description: `graph`, `scene`, `world`

`graph` owns node-local transforms, hierarchy-compatible values, cameras, and
attachments. `scene` owns stable identity, heterogeneous node storage,
mutation, traversal, visibility queries, and selection.

`world` is a higher-level composition layer. It owns persistent regions,
terrain, reusable instances, streaming policy, and placement/spatial queries.
It references scene, geometry, materials, assets, and resources; it does not
implement rendering.

World persistence must be explicit. A world should be serializable as stable
semantic data and asset references rather than as browser handles or incidental
GPU state.

### Geometry and renderables: `geometry`, `primitives`, `renderable`

`geometry` owns CPU-side data, attributes, index buffers, layout facts, bounds,
groups, and draw ranges. It must express all data needed for a host upload
without hardcoding a particular backend layout.

`primitives` owns deterministic generators and algorithms. Terrain and voxel
generators may begin here, but world-region ownership belongs in `world`.

`renderable` owns compositions such as Mesh, skinned mesh, morphable mesh, and
instanced mesh. It is the only layer that should bind graph placement to
geometry and material.

### Appearance: `material` and `lighting`

`material` owns declarative appearance semantics: unlit, classic lit,
metallic-roughness, transparency, alpha policy, texture slots, samplers, and
color-space intent.

`lighting` owns light families, environment lighting, shadow policy, and the
light-resource requirements consumed by materials. A material may request a
lighting family; it must not own the scene light registry or backend buffer
layout.

The standard engine path should support shared material instances and stable
specialization identities across many renderables.

### Programmability: `shader`

`shader` is a typed, backend-neutral description of shader intent. It owns:

- stage inputs and outputs;
- builtins and varyings;
- typed expressions and bounded composition;
- uniform, storage, texture, and sampler requirements;
- material specialization and cache identity;
- diagnostics for stage/resource/type mismatch.

It must not expose raw WGSL as the normal public material API. A later bounded
programmable-material surface may let authors customize vertex and fragment
behavior, but those programs must still pass through typed Radix lowering,
reflection, target checks, and engine caching.

### Render planning: `render`

`render` owns the explicit facts needed to turn a scene into execution:

- render items and draw ranges;
- pipeline topology and state;
- color/depth attachments and render targets;
- compute and render passes;
- pass dependencies and resource hazards;
- batching, instancing, and submission groups;
- required versus optional target capabilities.

The render graph is a semantic plan, not imperative browser code. It must be
possible to validate cycles, incompatible formats, stale sizes, unsupported
multisampling, and read/write hazards before command submission.

### Engine contract: `engine`

`engine` is the small high-level boundary consumed by applications. It owns
world/session attachment, frame lifecycle, update ordering, capability
negotiation, diagnostics, and submission of render plans.

The Faber `engine` modules describe this contract. The concrete engine runtime
belongs in the host repository and owns:

- adapter/device initialization and device loss;
- GPU resource creation, update, disposal, and residency;
- shader-module and pipeline caching;
- scene extraction and render-item generation;
- pass scheduling and command encoding;
- frame timing, resize, presentation, and readback;
- structured failure states and profiling hooks.

The engine runtime must consume Triga/Radix facts. It must not quietly replace
them with browser-only scene models.

## Host-side target structure

The browser host is currently a proof product with runtime logic spread across
files such as `webgpu-runtime.js`, `faber-kernel.js`, `greybox-host.js`, and
`host-init.js`. The production direction is to retain the host boundary while
separating its internal lanes:

```text
hosts/webgpu-browser/
  public/
    src/
      product/
        bootstrap.js                 # product entry and browser lifecycle
        diagnostics.js               # structured product/runtime errors
      contract/
        artifact-admission.js        # WGSL/reflection/draw admission
        capability-admission.js      # target/device capability checks
      engine/
        engine.js                    # shared renderer runtime facade
        frame-scheduler.js           # update/frame/present ordering
        scene-extractor.js           # Triga scene → render items
        resource-manager.js          # logical handles → GPU residency
        shader-library.js            # standard shader modules/variants
        pipeline-cache.js            # specialization and pipeline reuse
        render-graph.js              # pass planning and execution
        world-streamer.js            # world region residency and eviction
      backend/
        webgpu-device.js             # adapter/device/context lifecycle
        webgpu-resources.js          # buffers, textures, samplers, targets
        webgpu-pipelines.js          # reflection-driven pipeline creation
        webgpu-render.js             # render command encoding
        webgpu-compute.js            # compute dispatch and synchronization
        webgpu-readback.js           # result and image evidence
      presentation/
        canvas.js                    # canvas, resize, presentation state
        input.js                     # browser input bridge only
        debug-overlay.js             # diagnostics and profiling display
    generated/
      ...                            # compiler-owned checked artifacts
```

The exact file split belongs to a host delivery after the current runtime
contracts stabilize. `hosts/crates/host-kernel` remains the provider-routing
kernel described by its own contract. It must not become the renderer merely
because the word “kernel” also appears in WGSL artifact names.

## Compiler and package ownership

### Radix

Radix owns the language/compiler representation of typed shader and render
facts, including:

- stage legality and type checking;
- stage IO and varying lowering;
- resource and pipeline reflection;
- shader specialization identity;
- target capability negotiation;
- WGSL emission and fail-closed diagnostics;
- artifact freshness and reflection validation.

This goal does not freeze new Radix filenames. Delivery must map each stage to
the live compiler/MIR crate and preserve the existing internal-crate ownership
model rather than creating a Triga-specific compiler fork.

### Faber

`faber` owns package build/run orchestration, library-provider resolution, and
the application-facing workflow. It should not absorb renderer policy or
become a second scene graph.

### `faber-runtime`

`faber-runtime` receives only the generated-code representations that the
application lane actually needs. It must not become the browser WebGPU engine
or a duplicate of Triga's semantic contracts.

### Examples and corpus

`triga/corpus` owns small reference scenes that pressure the public Triga
modules. `examples` owns cross-repository world-building capstones, assets,
expected outputs, and end-to-end application packages. Neither repository may
hide missing engine capabilities behind demo-local host code.

### Cista

Distribution and versioned installation remain a later release checkpoint.
Internal engine modules should not become separately versioned Cista packages
until independent release cadence, dependency ownership, or target isolation is
proven.

## Engine capability vision

### Standard rendering

The engine must provide a standard path for:

- opaque and transparent meshes;
- indexed and non-indexed geometry;
- standard materials and shared material instances;
- directional, point, spot, hemisphere, and environment lighting;
- texture, sampler, normal, roughness, metalness, emissive, and alpha paths;
- depth testing, blending, culling, MSAA, and resize;
- instancing, batching, and stable resource reuse.

### Asset and world residency

The engine must support:

- package-relative and explicit asset references;
- glTF/GLB scene and material ingestion;
- image decode and texture upload contracts;
- bounded asynchronous acquisition;
- region/chunk residency and eviction;
- resource generation checks and disposal;
- deterministic behavior when assets are missing or unsupported.

### World-building behavior

The world layer must support:

- persistent regions and hierarchical placement;
- terrain and procedural world generation;
- reusable prefabs or instances;
- object selection, placement, and spatial queries;
- camera navigation and picking;
- visibility, frustum culling, and level of detail;
- instanced vegetation, props, and repeated structures;
- world save/load without GPU-handle leakage;
- frame-safe streaming and resource replacement.

Physics, audio, WebXR, and editor UI are separate products or adapters. The
engine must expose stable world and spatial seams for them without making those
systems mandatory dependencies of the core renderer.

### Quality and advanced rendering

The engine must grow toward:

- shadow-map passes;
- offscreen render targets;
- fullscreen postprocessing;
- multiple render targets where justified;
- environment reflections and refraction subsets;
- compute-driven particles and world effects;
- programmable but typed materials;
- explicit performance and memory budgets.

These are engine families, not additional demo-local shader copies.

### Production characteristics

The engine must be operationally trustworthy, not merely visually capable.
The production contract includes:

- explicit startup, ready, suspended, device-lost, recovering, and failed
  states;
- bounded allocation and residency budgets for buffers, textures, targets,
  world regions, and decoded assets;
- deterministic disposal and replacement for every logical resource;
- structured diagnostics that identify the owning layer, artifact, resource,
  pass, and target capability involved in a failure;
- versioned world and asset manifests with explicit migration policy;
- reproducible shader/material/pipeline cache identities;
- frame-time, upload-time, memory, residency, and pass-cost instrumentation;
- controlled debug views for bounds, normals, materials, shadow maps, render
  targets, culling, LOD, and streaming state;
- clean separation between development diagnostics and the minimal production
  presentation path.

World packages must be portable semantic artifacts. They may reference assets,
materials, and regions by stable identifiers, but they must not depend on the
current browser, GPU vendor, adapter limits, or incidental cache layout.

The first production engine need not provide an editor, physics simulation,
audio graph, or every Three.js effect. It must provide stable contracts that
those products can consume without forcing their implementation into the
renderer core.

## Proposed implementation horizon

This is a vision-level sequence. Each stage must later lower to its own
repo-aware delivery spec with an executable workload and negative coverage.

### Horizon 0 — Architecture checkpoint

- Freeze the module ownership map and dependency DAG.
- Decide which current public leaves remain stable and which receive a clean
  break.
- Confirm the Triga/Radix/host reflection boundary.
- Define the first engine artifact and world-building capstone.
- Record target file names only after live consumers and compiler seams are
  inspected.

### Horizon 1 — Domain seam repair

- Separate geometry data, materials, and renderables.
- Split scene identity from scene queries.
- Establish logical resource ownership and generation checks.
- Keep all existing source and generated-Rust gates honest.

### Horizon 2 — Shared renderer vertical slice

- Replace copied corpus host assets with a shared engine runtime path.
- Render a hierarchical world with camera, opaque mesh, standard material,
  depth, resize, and deterministic failure states.
- Prove that two unrelated demos consume the same engine without shader or
  pipeline duplication.

### Horizon 3 — Materials and shader variants

- Establish standard unlit, lit, and metallic-roughness families.
- Add texture/sampler/resource reflection.
- Add shader-library reuse, specialization identity, and pipeline caching.
- Keep raw shader authoring out of the normal demo path.

### Horizon 4 — Render graph and quality

- Add explicit passes, targets, attachments, and hazards.
- Prove shadows and one deterministic postprocessing chain.
- Move the host from imperative greybox rendering to render-plan execution.

### Horizon 5 — Assets, animation, and world data

- Ingest representative glTF/GLB assets.
- Add animation, deformation, and material/texture residency.
- Add persistent world regions, terrain, reusable instances, and bounded
  streaming.

### Horizon 6 — World-building scale

- Prove culling, LOD, batching, instancing, and region streaming on a larger
  world.
- Add spatial queries, picking, placement, and camera navigation.
- Establish frame-time, memory, upload, and residency measurements.

### Horizon 7 — Programmability and backend expansion

- Add bounded typed programmable materials across supported stages.
- Select and prove one second backend only after the public contracts are
  stable.
- Keep target differences explicit and fail closed.

## Capstone vision

The goal should not be considered production-oriented until a world-building
capstone can:

1. Build a persistent world package from Faber source.
2. Load or generate terrain and multiple reusable object instances.
3. Render hierarchical geometry through the shared engine with no three.js
   runtime dependency.
4. Use standard materials, textures, lights, depth, and camera controls.
5. Demonstrate at least one animated or deformed asset.
6. Demonstrate picking or spatial placement.
7. Stream or replace a bounded world region without invalid resource use.
8. Exercise culling, batching, instancing, or LOD at a meaningful scale.
9. Execute at least one shadow or offscreen/postprocessing path.
10. Report structured success, unsupported capability, device failure, and
    stale-artifact outcomes.

The capstone is a workload proof, not an editor claim. A future world editor
can be built on these APIs, but the engine must first make the runtime world
model, persistence, rendering, resource, and query boundaries sound.

## Invariants

- One `triga` source package remains the default distribution unit.
- Every public module has one clear semantic owner.
- No dependency cycle exists between scene, material, geometry, shader, render,
  and engine modules.
- Triga public types remain backend-neutral.
- Host code consumes reflection and explicit render facts; it does not parse
  WGSL or recreate scene semantics.
- Standard demos contain no private renderer, pipeline, or shader copy.
- Resource identity and disposal are explicit and generation-safe.
- Render passes, attachments, hazards, and target capabilities are explicit.
- Unsupported behavior fails before draw or dispatch.
- World persistence does not serialize browser or GPU handles.
- A capability claim requires an executable workload and negative evidence.
- Three.js may remain a reference/oracle, but not a permanent runtime layer.

## Stop conditions

Stop and revise the architecture if:

- `triga:engine` becomes a god module that owns every domain type;
- every new demo still carries a WGSL file or host renderer;
- materials are selected by browser-side switches over Triga type names;
- render graph order exists only as imperative host code;
- the host guesses bindings, layouts, resources, or draw topology;
- world streaming leaks GPU handles into public Faber values;
- a new feature requires a backend-specific public Triga module;
- a campaign score is earned by declarations, static WGSL, or a three.js visual
  substitute rather than a real engine workload;
- production readiness is claimed without the world-building capstone and
  documented performance/environment limits.

## Validation direction

Every implementation stage must validate at the strongest honest rung:

```text
source checked
  → compiler lowered
    → reflection complete
      → host instantiated
        → submitted
          → presented/read back
            → world result checked
```

Required validation families include:

- Triga source and module-map checks;
- generated-Rust acceptance where the application lane consumes the types;
- Radix stage, reflection, and negative target checks;
- host resource/pipeline/pass contract checks;
- browser execution with explicit adapter/device evidence;
- deterministic structural or pixel oracles for render workloads;
- asset, world, streaming, disposal, and device-loss failure cases;
- performance and memory measurements once world scale is claimed.

Static source, generated WGSL, or reflection freshness alone cannot claim a
working world renderer.

## Later delivery questions

The following questions are intentionally left for architecture checkpoint and
delivery research rather than guessed here:

- Which current Triga public types require a clean break before the first
  engine vertical slice?
- Does Faber need a new visibility mechanism for truly private source modules,
  or are public leaf policies sufficient?
- What is the minimum typed representation for shader programs that supports
  standard materials without becoming total TSL parity?
- Which render-graph facts belong in Triga versus Radix/MIR reflection?
- What runtime package boundary should the browser engine use without creating
  a second public scene model?
- Which asset and world persistence format is canonical for the first capstone?
- What scale target makes culling, LOD, instancing, and streaming meaningful?
- Which second backend gives the most architectural information after WebGPU?
- Which physics, editor, and input seams should remain adapters rather than
  core engine dependencies?

## Completion posture

This document is complete as a production vision when it can guide later
delivery work without requiring each stage to rediscover the ownership model.
It is not complete as an implementation plan. No factory phase should begin
from this document alone. The next authorized step is an architecture
checkpoint that converts one bounded horizon into a delivery spec with live
file ownership, fixtures, gates, and commit boundaries.
