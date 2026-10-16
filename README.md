# Triga — the Faber Graphics and Geometry Library

**Triga** (Latin: "three-horse chariot") is Faber's graphics and geometry
library — the data contract between compiled Faber output and the GPU runtime
host.

> **Experimental.** Like Faber itself, this library is experimental until
> Faber 2; APIs change without notice.

It is a first-class Faber library, not a three.js clone. Dimension lives in
types (`vector<f32, N>`, `matrix<f32, [R, C]>`, `Box<N>`). Industry domain
nouns stay (`Mesh`, `Ray`, `PerspectiveCamera`). three.js product names
(`Object3D`, `BufferGeometry`, `MeshBasicMaterial`) do not.

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

main {
    let _ position ← attribute.float32_attribute(
        "position", 0, 3, 3,
        [0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0, 0.0]
    )
    let _ triangle ← data.indexed_triangle_geometry(
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
4. [`triga-scene-store.fab`](exempla/triga-scene-store.fab) — generation-checked
   handles, hierarchy, visibility, and traversal.
5. [`triga-hello-voxel-pipeline.fab`](exempla/triga-hello-voxel-pipeline.fab) —
   the source-side facts that feed shader and host contracts.

The examples are intentionally ordinary Faber programs. They are the best
place to learn expression shape; the source modules explain why the data is
split the way it is.

## Status

| Layer | State |
| --- | --- |
| Math / transforms | Native Faber (`vector<f32, N>`, `matrix<f32, [R, C]>`, `Box<N>`, quaternions, …) |
| Scene store | Generation-checked handles, graph edits, world transforms; exempla green |
| Buffer geometry | SoA attributes, draw batches, vertex-layout reflection |
| Primitive generators | Deterministic plane/box/sphere/… mesh builders |
| Browser presenter | Thin WebGPU presenter in [`host/`](host/README.md) draws compiled graphics artifacts; Triga owns source contracts, not a full browser runtime |

CPU workloads typecheck and emit Rust. Generated-Rust scene identity and the
direct scene-store check for `exempla/triga-scene-store.fab` are green. MIR/GPU
parity continues to deepen on the compiler and host side; Triga's job is to
keep the typed contract honest and modular.

## Current Types

| Category | Types | Module | Mirror |
| -------- | ----- | ------ | ------ |
| **Math** | `vector<f32, N>`, `matrix<f32, [R, C]>`, `Box<N>`, `Ray`, quaternions, face-code tables | `triga:math` | language carriers + Triga domain genera |
| **Scene Graph** | `Object`, `Scene`, cameras | `triga:graph/{object,camera}` | industry cameras; no `Object3D` |
| **Lighting** | `Light` family | `triga:lighting/light` | industry light nouns |
| **Geometry data** | `Geometry`, `ColoredQuadMesh` | `triga:geometry/data` | SoA mesh contract |
| **Geometry (GPU layout)** | `Attribute`, vertex layouts, draw batches | `triga:geometry/{attribute,layout,batch}` | buffer / vertex layout |
| **Primitives** | `plane`, `box`, `sphere`, … | `triga:primitives/basic` | constructors returning `Geometry` |
| **Materials** | `Material`, `UnlitMaterial`, `PhongMaterial`, `StandardMaterial` | `triga:material/{base,basic,lit,standard}` | lighting-model nouns; no `Mesh*Material` |
| **Renderable** | `Mesh` | `triga:renderable/mesh` | `Object` + `Geometry` + material |
| **Scene store** | `SceneStore`, `SceneHandle`, `visibilia` | `triga:scene` | generation-checked identity graph |
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

Package installation is not yet available in the public toolchain: `faber`
never installs packages. Clone this repository and point `faber` at it.
`faber` resolves `triga:*` from a library home, a directory that holds this
repo as `triga/` (`--library-home <DIR>`, or `[paths] library_home` in your
`faber.toml`):

```text
<library home>/triga/src/**/*.fab
```

```bash
mkdir libs && git clone https://github.com/faberlang/triga libs/triga
faber doctor --library-home "$PWD/libs"      # library.triga.availability should be faber-package
faber run --library-home "$PWD/libs" main.fab
```

Install `faber` from the
[release page](https://github.com/faberlang/releases/releases/latest); docs are
at [faberlang.dev](https://faberlang.dev). Use an absolute library-home path.
Norma is embedded in the binary and needs no home.

## Design

- **Structure-of-arrays layout**: vertex attributes and matrix storage use flat
  `list<f32>`, not interleaved arrays. This maps directly to WGSL storage
  buffers and GPU buffer uploads.
- **Composition over inheritance**: `PerspectiveCamera.base` contains an
  `Object` rather than using type inheritance. `StandardMaterial.base`
  contains a `Material`.
- **Typed contract, not a vendor mirror**: field names use Faber's snake_case.
  Scene composition is `Object` → `Mesh` → `Scene`; materials compose through
  `base`. That is Triga's shape, not three.js product taxonomy.
- **Module seams**: Norma-style flat leaves — `math` / `graph` / `material` /
  `geometry` / `primitives` / `scene` / `resource` / `renderable`. Nested
  package dirs only when they hold 2–3+ modules (see `docs/module-map.md`).

## Reading the source

Read the library from the data contract outward:

```text
math → geometry/{attribute,layout,data} → primitives/basic
     → graph/{object,camera} → scene → renderable/mesh
     → shader_contract → presenter host
```

`math`, `geometry`, and `scene` own backend-agnostic values and invariants.
`primitives` assembles those values into useful meshes. `shader_contract`
names the facts that the compiler can validate and reflect. The browser
presenter under `host/` is a thin consumer: Triga describes the contract; the
host owns device setup, resource allocation, and presentation.

This separation is deliberate. When reading a function, ask whether it is
constructing a value, validating a value, or describing a fact for a later
stage. That distinction is the central Faber design lesson in this package.

## Layout

```text
cista.toml     package identity + version (for the separate package-store tool)
faber.toml     library provider metadata for faber package resolution
src/           public `triga:*` Faber modules (`name.fab` + co-located `name.proba` tests)
exempla/       instructional demos for triga types
scripta/       source-library checks
docs/          policy + module map + planning history
proof/         capability / capstone ledgers
```

## Checks

The canonical local spine is `./scripta/check`. It discovers every live leaf
and proba by running the existing rungs in order. A red rung is evidence, not
a skip. Faber-dependent rungs need a `faber` binary: set `FABER_BIN` to one.
Public CI is `.github/workflows/ci.yml` (no-Faber rungs only). Do not re-list
the rungs here; `AGENTS.md` names the same spine.

```bash
./scripta/check
```

The capability report is an honest campaign baseline: unsupported proofs score
zero, while browser availability and artifact freshness are reported
separately. See `docs/factory/triga-threejs-80/PROOF-HARNESS.md`.

The Hello Voxel contract check is a Triga-owned pre-browser gate, not part of
the spine. Live browser execution uses the Triga-owned presenter in `host/`
(`./scripta/host check` and `./scripta/host serve`; see
[`host/README.md`](host/README.md)).

## Next Steps

- Keep scene identity (generated-Rust + direct scene-store check) green.
- Keep vertex-layout reflection and primitive generators aligned with host
  buffer upload seams.
- Grow materials / textures / lighting only after graphics-stage contracts stay
  green end to end on the host path.
- Optional further module splits (math vs materials, resource lifecycle) when a
  second real importer appears — not for aesthetics alone.
