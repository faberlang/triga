# Triga — the Faber Graphics and Geometry Library

**Triga** (Latin: "three-horse chariot"; a nod to three.js) is Faber's native
library for geometry, scene graph, material, and rendering types — the data
contract between compiled Faber output and the GPU runtime host.

Shapes are modeled closely after three.js abstractions for LLM familiarity and
migration ease. Triga is *not* a binding to three.js — these are native Faber
types that define the same structural domain.

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
| **Scene Graph** | `Object3D`, `Scene`, cameras, lights | `triga:graph` | THREE.Object3D etc. |
| **Geometry (SoA shape)** | `MeshGeometry` | `triga:material` | THREE.BufferGeometry (field shape) |
| **Geometry (GPU layout)** | `BufferGeometry`, `BufferAttribute`, draw batches | `triga:geometry` | buffer / vertex layout |
| **Primitives** | `plane_geometry`, `box_geometry`, … | `triga:primitives` | THREE.*Geometry helpers |
| **Material / Mesh** | `Material` family, `Mesh` | `triga:material` | THREE.Material / Mesh |
| **Scene store** | `SceneStore`, `SceneHandle`, `visibilia` | `triga:scene` | stable identity graph |
| **Resources** | `ResourceHandle`, lifecycle free functions | `triga:resource` | host resource identity |

Full module ownership: [`docs/module-map.md`](docs/module-map.md) (Norma-style multi-module package).

## Import

```fab
importa ex "triga:math" privata math
importa ex "triga:graph" privata graph
importa ex "triga:material" privata material
importa ex "triga:geometry" privata geometry
importa ex "triga:primitives" privata primitives
importa ex "triga:scene" privata scene
importa ex "triga:resource" privata resource
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
  hosts/      # webgpu-browser product host
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
- **Module seams**: Norma-style flat leaves — `math` / `graph` / `material` /
  `geometry` / `primitives` / `scene` / `resource`. Nested package dirs only
  when they hold 2–3+ modules (see `docs/module-map.md`).

## Layout

```text
cista.toml     package identity + version (cista install)
faber.toml     library provider metadata for faber package resolution
src/           public `triga:*` Faber modules
exempla/       instructional demos for triga types
scripta/       source-library checks
docs/          policy + module map + factory history
proof/         capability / capstone ledgers
```

## Checks

```bash
./scripta/check-capabilities
./scripta/check-capabilities-stale-coupling
./scripta/check-source
./scripta/check-compile
./scripta/check-transforms
./scripta/check-exempla-inventory
./scripta/check-hello-voxel-contract
./scripta/check-hello-voxel-runtime-deps
```

The capability report is an honest campaign baseline: unsupported proofs score
zero, while browser availability and artifact freshness are reported
separately. `check-capabilities-stale-coupling` is the local regression check
for stale ledger/capstone revision detection. See
`docs/factory/triga-threejs-80/PROOF-HARNESS.md`.

The Hello Voxel contract check is a Triga-owned pre-browser gate. It validates
source facts, exempla, compile viability, capability honesty, and current
renderer-dependency classification. Live browser execution lives under sibling
`hosts/webgpu-browser` (`./scripta/webgpu-browser-proof` from that repo).

## Next Steps

- Keep scene identity (generated-Rust + direct Radix scene-store) green.
- Keep vertex-layout reflection and primitive generators aligned with host
  buffer upload seams.
- Grow materials / textures / lighting only after graphics-stage contracts stay
  green end to end on the host path.
- Optional further module splits (math vs materials, resource lifecycle) when a
  second real importer appears — not for aesthetics alone.
