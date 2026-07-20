# Triga — the Faber Graphics and Geometry Library

**Triga** (Latin: "three-horse chariot"; a nod to three.js) is Faber's native
library for geometry, scene graph, material, and rendering types — the data
contract between compiled Faber output and the GPU runtime host.

Shapes are modeled closely after three.js abstractions for LLM familiarity and
migration ease. Triga is *not* a binding to three.js — these are native Faber
types that define the same structural domain.

## Status

Math transforms, stable scene storage, deterministic geometry generators, and
typed vertex-layout reflection are implemented as native Faber source. The CPU
workloads typecheck and emit Rust, and Stage 2 generated-Rust scene identity
acceptance is green. The direct Radix scene-store check is also green for
`exempla/triga-scene-store.fab`; MIR/GPU graphics-stage parity and render
pipeline integration remain future work.

## Current Types

| Category | Types | Mirror |
| -------- | ----- | ------ |
| **Math** | `Vector2`, `Vector3`, `Vector4`, `Matrix3`, `Matrix4`, `Quaternion`, `Euler`, `Color`, `Box3`, `Sphere`, `Plane`, `Ray` | THREE.Vector2 etc. |
| **Scene Graph** | `Object3D`, `Scene`, `PerspectiveCamera`, `OrthographicCamera`, `Light`, `AmbientLight`, `DirectionalLight`, `PointLight` | THREE.Object3D etc. |
| **Geometry** | `MeshGeometry` (SoA layout: positions, normals, uvs, indices, …) | THREE.BufferGeometry |
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
./scripta/check-transforms
./scripta/check-hello-voxel-contract
./scripta/check-hello-voxel-runtime-deps
```

The capability report is an honest campaign baseline: unsupported proofs score
zero, while browser availability and artifact freshness are reported
separately. See `docs/factory/triga-threejs-80/PROOF-HARNESS.md`.
The Hello Voxel contract check is a Triga-owned pre-browser gate. It validates
source facts, exempla, compile viability, capability honesty, and current
renderer-dependency classification, but it does not claim direct WebGPU browser
execution.

## Next Steps

- Keep the stable scene identity generated-Rust acceptance and direct Radix
  scene-store check green.
- Lower Triga's typed vertex-layout contract through Radix graphics MIR and
  prove compiler reflection agrees with the source facts.
- Integrate the admitted graphics pipeline with a direct WebGPU host.
- Add the material, texture, and lighting families after the graphics-stage
  contract is proven end to end.
