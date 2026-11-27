# Triga — the Faber Graphics and Geometry Library

**Triga** (Latin: "three-horse chariot") is Faber's graphics and geometry
library. It is the data contract between compiled Faber output and a GPU host.

> **Experimental.** Like Faber itself, this library is experimental until
> Faber 2; APIs change without notice.

It is a first-class Faber library, not a three.js clone. Dimension lives in
types (`vector<f32, size N>`, `matrix<f32, [R, C]>`, `Box<N>`). Industry domain
nouns stay (`Mesh`, `Ray`, `PerspectiveCamera`). three.js product names
(`Object3D`, `BufferGeometry`, `MeshBasicMaterial`) do not.

Triga is also meant to be read as a small, real Faber library. Each file owns
one import path, and the exempla show the path from typed data to host-facing
facts. Start with the short examples before opening the larger scene and
shader contracts.

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

Then follow the learning path in [`exempla/README.md`](exempla/README.md).

## Modules

One `.fab` file is one import path. The package facades (`triga:geometry`,
`triga:graph`, `triga:material`, …) are orientation maps only; import the leaf
that owns the type you use.

| Import | Owns |
| --- | --- |
| `triga:math` | `Box<N>`, `Ray`, `Sphere`, `Plane`, `Quaternion`, `Euler`, `Color`, transform payloads, face-code tables, builders over the language's own vectors and matrices |
| `triga:face` | `FaceQuad` voxel face builders |
| `triga:geometry/attribute` | `Attribute`, `AttributeData`, `AttributeUsage` |
| `triga:geometry/layout` | `VertexAttributeLayout`, `VertexFormat`, `VertexStepMode` |
| `triga:geometry/data` | `Geometry`, `ColoredQuadMesh`, `PrimitiveTopology` |
| `triga:geometry/batch` | `DrawRange`, `GeometryGroup`, draw-command and draw-batch facts |
| `triga:geometry/bounds` | `BoundingBox`, `BoundingSphere` |
| `triga:primitives/basic` | deterministic plane, box, sphere, … generators returning `Geometry` |
| `triga:graph/object` | `Object`, `Scene` |
| `triga:graph/camera` | `PerspectiveCamera`, `OrthographicCamera`, projection facts |
| `triga:lighting/light` | `Light`, `AmbientLight`, `DirectionalLight`, `PointLight` |
| `triga:material/base` | `Material`, `MaterialPipelineFacts`, `TextureDescriptor` |
| `triga:material/basic` | `UnlitMaterial` |
| `triga:material/lit` | `PhongMaterial` |
| `triga:material/standard` | `StandardMaterial` |
| `triga:renderable/mesh` | `Mesh` (object + geometry + material) |
| `triga:scene` | `SceneStore`, `SceneHandle`, generation-checked hierarchy and traversal |
| `triga:resource` | `ResourceHandle` identity and lifecycle |
| `triga:shader` | opaque `Texture2D` and `Sampler` |
| `triga:shader_contract` | Triga's shader-contract roles and pipeline defaults |

## Using Triga

`faber` never installs packages. Clone this repository and point `faber` at
it. `faber` resolves `triga:*` from a library home, a directory that holds
this repo as `triga/` (`--library-home <DIR>`, or `[paths] library_home` in
your `faber.toml`):

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
Norma is built into the binary and needs no home.

## Design

- **Structure-of-arrays layout.** Vertex attributes and matrix storage use flat
  `list<f32>`, not interleaved arrays. This maps directly to GPU storage
  buffers and buffer uploads.
- **Composition over inheritance.** `PerspectiveCamera.base` contains an
  `Object`; `StandardMaterial.base` contains a `Material`.
- **Typed contract, not a vendor mirror.** Field names use Faber's snake_case.
  Scene composition is `Object` → `Mesh` → `Scene`; materials compose through
  `base`.
- **Leaf modules.** Nested package directories exist only when they hold at
  least two modules.

## Reading the source

Read the library from the data contract outward:

```text
math → geometry/{attribute,layout,data} → primitives/basic
     → graph/{object,camera} → scene → renderable/mesh
     → shader_contract → presenter host
```

`math`, `geometry` and `scene` own backend-agnostic values and invariants.
`primitives` assembles those values into meshes. `shader_contract` names the
facts the compiler validates and reflects. The browser presenter under
`host/` is a thin consumer: Triga describes the contract; the host owns device
setup, resource allocation and presentation.

## Layout

```text
faber.toml     library manifest (provider, targets, WGSL bindings)
cista.toml     package identity and version for the package-store tool
src/           public `triga:*` modules
exempla/       instructional programs
bindings/      target bindings (WGSL)
locale/        Latin reader surface for Triga's names
host/          thin WebGPU presenter
corpus/        browser demo scenes
scripta/       checks and the presenter driver
```

## Checks

```bash
./scripta/check
```

This runs `faber check` on every module and exemplum, then `faber test` on the
package. It uses `FABER_BIN` if set, otherwise a sibling `../radix` build.
The presenter has its own driver: `./scripta/host check` and
`./scripta/host serve` (see [`host/README.md`](host/README.md)).

## License

Licensed under either of [Apache License, Version 2.0](LICENSE-APACHE) or
[MIT license](LICENSE-MIT) at your option.
