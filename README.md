# Triga — the Faber Graphics and Geometry Library

**Triga** (Latin: "three-horse chariot"; a nod to three.js) is Faber's native
library for geometry, scene graph, material, and rendering types — the data
contract between compiled Faber output and the GPU runtime host.

Shapes are modeled closely after three.js abstractions for LLM familiarity and
migration ease. Triga is *not* a binding to three.js — these are native Faber
types that define the same structural domain.

Triga is also meant to be read as a small, real Faber library. The source is
organized into leaf modules, each file owns one import path, and the exempla
show the path from typed data to host-facing facts. Start with the short
examples before opening the larger scene and shader contracts.

## Start here

The smallest useful Triga program constructs a typed attribute and wraps it in
an indexed geometry value:

```fab
import from "triga:geometry/data" data
import from "triga:geometry/attribute" attribute
import from "triga:geometry/batch" batch

incipit {
    const _ position ← attribute.float32_attribute(
        "position", 0, 3, 3,
        [0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0, 0.0]
    )
    const _ triangle ← data.indexed_triangle_geometry(
        3,
        [position],
        [0, 1, 2],
        batch.DrawRange { start = 0, count = 3 },
        [batch.GeometryGroup { start = 0, count = 3, material_index = 0 }]
    )
    print triangle.vertex_count
}
```

Then follow the learning path in [`exempla/README.md`](exempla/README.md):

1. [`triga-basics.fab`](exempla/triga-basics.fab) — values, materials, and
   validation.
2. [`triga-transforms.fab`](exempla/triga-transforms.fab) — vectors, matrices,
   quaternions, bounds, and rays.
3. [`triga-geometry-attributes.fab`](exempla/triga-geometry-attributes.fab) —
   attributes, layouts, draw ranges, bounds, and primitive generators.
4. [`triga-scene-store.fab`](exempla/triga-scene-store.fab) — stable handles,
   hierarchy, visibility, and traversal.
5. [`triga-hello-voxel-pipeline.fab`](exempla/triga-hello-voxel-pipeline.fab) —
   the source-side facts that feed shader and host contracts.

The examples are intentionally ordinary Faber programs. They are the best
place to learn expression shape; the source modules explain why the data is
split the way it is.

## Status

| Layer | State |
| --- | --- |
| Math / transforms | Stable native Faber (`Vector*`, `Matrix4`, quaternions, …) |
| Scene store | Stable handles, graph edits, world transforms; exempla green |
| Buffer geometry | SoA attributes, draw batches, vertex-layout reflection |
| Primitive generators | Deterministic plane/box/sphere/… mesh builders |
| Host WebGPU path | Sibling `hosts/webgpu-browser` consumes compiled graphics artifacts; Triga owns source contracts, not the browser runtime |

CPU workloads typecheck and emit Rust. Stage 2 generated-Rust scene identity
and the direct Radix scene-store check for `exempla/triga-scene-store.fab` are
green. MIR/GPU parity continues to deepen on the Radix + host side; Triga's job
is to keep the typed contract honest and modular.

## Current Types

| Category | Types | Module | Mirror |
| -------- | ----- | ------ | ------ |
| **Math** | `Vector2`…`Ray`, matrices, quaternions, face-code tables | `triga:math` | THREE.Vector2 etc. |
| **Scene Graph** | `Object3D`, `Scene`, cameras | `triga:graph/{object,camera}` | THREE.Object3D etc. |
| **Lighting** | `Light` family | `triga:lighting/light` | THREE.Light family |
| **Geometry data** | `BufferGeometry`, `ColoredQuadMesh` | `triga:geometry/data` | THREE.BufferGeometry (field shape) |
| **Geometry (GPU layout)** | `BufferAttribute`, vertex layouts, draw batches | `triga:geometry/{attribute,layout,batch}` | buffer / vertex layout |
| **Primitives** | `plane_geometry`, `box_geometry`, … | `triga:primitives/basic` | THREE.*Geometry helpers |
| **Materials** | `Material` family | `triga:material/{base,basic,lit,standard}` | THREE.Material family |
| **Renderable** | `Mesh` | `triga:renderable/mesh` | THREE.Mesh composition |
| **Scene store** | `SceneStore`, `SceneHandle`, `visibilia` | `triga:scene` | stable identity graph |
| **Resources** | `ResourceHandle` (transition/lifecycle receiver methods + batch queries) | `triga:resource` | host resource identity |

Full module ownership: [`docs/module-map.md`](docs/module-map.md) (Norma-style multi-module package).

## Import

```fab
import from "triga:math" math
import from "triga:graph" graph
import from "triga:material" material
import from "triga:geometry" geometry
import from "triga:primitives" primitives
import from "triga:scene" scene
import from "triga:resource" resource
```

This is an orientation map. In application code, import the leaf that owns the
genus you use; the facade modules intentionally do not re-export types.

Radix and `faber` resolve provider imports from the shared library home:

```text
$FABER_LIBRARY_HOME/triga/src/**/*.fab
```

In local Faber development, `FABER_LIBRARY_HOME` is usually the parent
`faberlang/` directory that contains sibling checkouts:

```text
faberlang/
  radix/
  hosts/      # webgpu-browser product host
  norma/
  triga/      # this repo
```

## Design

- **Structure-of-arrays layout**: vertex attributes and matrix storage use flat
  `list<f32>`, not interleaved arrays. This maps directly to WGSL storage
  buffers and GPU buffer uploads.
- **Composition over inheritance**: `PerspectiveCamera.base` contains an
  `Object3D` rather than using type inheritance. `MeshStandardMaterial.base`
  contains a `Material`.
- **Three.js field alignment**: field names use Faber's snake_case convention
  but the structural hierarchy mirrors three.js (Object3D → Mesh → Scene,
  Material → MeshStandardMaterial, Camera → PerspectiveCamera).
- **Module seams**: Norma-style flat leaves — `math` / `graph` / `material` /
  `geometry` / `primitives` / `scene` / `resource` / `renderable`. Nested
  package dirs only when they hold 2–3+ modules (see `docs/module-map.md`).

## Reading the source

Read the library from the data contract outward:

```text
math → geometry/{attribute,layout,data} → primitives/basic
     → graph/{object,camera} → scene → renderable/mesh
     → shader_contract → sibling host
```

`math`, `geometry`, and `scene` own backend-agnostic values and invariants.
`primitives` assembles those values into useful meshes. `shader_contract`
names the facts that the compiler can validate and reflect. The browser host
is a separate sibling repository: Triga describes the contract; the host owns
device setup, resource allocation, and presentation.

This separation is deliberate. When reading a function, ask whether it is
constructing a value, validating a value, or describing a fact for a later
stage. That distinction is the central Faber design lesson in this package.

## Layout

```text
cista.toml     package identity + version (cista install)
faber.toml     library provider metadata for faber package resolution
src/           public `triga:*` Faber modules (`name.fab` + co-located `name.proba` tests)
exempla/       instructional demos for triga types
scripta/       source-library checks
docs/          policy + module map + factory history
proof/         capability / capstone ledgers
```

## Checks

The canonical local spine is `./scripta/check`. It discovers every live leaf
and proba by running the existing rungs in order. A red rung is evidence, not
a skip. Public CI is `.github/workflows/ci.yml` (no-Faber rungs only). Do not
re-list the rungs here; `AGENTS.md` names the same spine.

```bash
./scripta/check
```

The capability report is an honest campaign baseline: unsupported proofs score
zero, while browser availability and artifact freshness are reported
separately. See `docs/factory/triga-threejs-80/PROOF-HARNESS.md`.

The Hello Voxel contract check is a Triga-owned pre-browser gate, not part of
the spine. Live browser execution lives under sibling `hosts/webgpu-browser`
(`./scripta/webgpu-browser-proof` from that repo).

## Next Steps

- Keep scene identity (generated-Rust + direct Radix scene-store) green.
- Keep vertex-layout reflection and primitive generators aligned with host
  buffer upload seams.
- Grow materials / textures / lighting only after graphics-stage contracts stay
  green end to end on the host path.
- Optional further module splits (math vs materials, resource lifecycle) when a
  second real importer appears — not for aesthetics alone.
