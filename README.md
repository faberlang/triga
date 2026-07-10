# Triga — the Faber Graphics and Geometry Library

**Triga** (Latin: "three-horse chariot"; a nod to three.js) is Faber's native
library for geometry, scene graph, material, and rendering types — the data
contract between compiled Faber output and the GPU runtime host.

Shapes are modeled closely after three.js abstractions for LLM familiarity and
migration ease. Triga is *not* a binding to three.js — these are native Faber
types that define the same structural domain.

## Status

Initial type definitions only. Types compile; no geometry generators,
transform methods, or render pipeline integration yet.

## Current Types

| Category | Types | Mirror |
| -------- | ----- | ------ |
| **Math** | `Vector2`, `Vector3`, `Vector4`, `Matrix3`, `Matrix4`, `Quaternion`, `Euler`, `Color`, `Box3`, `Sphere`, `Plane`, `Ray` | THREE.Vector2 etc. |
| **Scene Graph** | `Object3D`, `Scene`, `PerspectiveCamera`, `OrthographicCamera`, `Light`, `AmbientLight`, `DirectionalLight`, `PointLight` | THREE.Object3D etc. |
| **Geometry** | `BufferGeometry` (SoA layout: positions, normals, uvs, indices, …) | THREE.BufferGeometry |
| **Material** | `Material`, `MeshStandardMaterial` (PBR), `MeshBasicMaterial`, `MeshPhongMaterial` | THREE.Material etc. |
| **Mesh** | `Mesh` (Object3D + geometry + material) | THREE.Mesh |

## Import

```fab
importa ex "triga:triga" privata triga
```

Radix and `faber` resolve provider imports from the shared library home:

```text
$FABER_LIBRARY_HOME/triga/src/**/*.fab
```

In local Faber development, `FABER_LIBRARY_HOME` is usually the parent
`faberlang/` directory that contains sibling checkouts:

```text
faberlang/
  radix/
  norma/
  triga/      # this repo
```

## Design

- **Structure-of-arrays layout**: vertex attributes and matrix storage use flat
  `lista<f32>`, not interleaved arrays. This maps directly to WGSL storage
  buffers and GPU buffer uploads.
- **Composition over inheritance**: `PerspectiveCamera.base` contains an
  `Object3D` rather than using type inheritance. `MeshStandardMaterial.base`
  contains a `Material`.
- **Three.js field alignment**: field names use Faber's snake_case convention
  but the structural hierarchy mirrors three.js (Object3D → Mesh → Scene,
  Material → MeshStandardMaterial, Camera → PerspectiveCamera).

## Layout

```text
cista.toml     package identity + version (cista install)
faber.toml     library provider metadata for faber package resolution
src/           public `triga:*` Faber modules
exempla/       instructional demos for triga types
scripta/       source-library checks
```

## Checks

```bash
./scripta/check-capabilities
./scripta/check-source
./scripta/check-compile
```

The capability report is an honest campaign baseline: unsupported proofs score
zero, while browser availability and artifact freshness are reported
separately. See `docs/factory/triga-threejs-80/PROOF-HARNESS.md`.

## Next Steps

- Implement geometry generators (`BoxGeometry`, `SphereGeometry`, …) as native
  Faber functions
- Add transform methods (`transforma`, `norma`, `collide`, …)
- Integrate with `radix/hosts/webgpu-browser` as the first render-pipeline consumer
- Design the Texture type family
