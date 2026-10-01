# Triga library surface inventory

**Date**: 2026-10-01
**Rule**: a public genus is `typed` (checks), `proba` (spine/exempla), or `drawn` (presenter pixels).

| Import | Type | Layer | Notes |
| --- | --- | --- | --- |
| `triga:math` | `vector` / `matrix` carriers, `TransformPayload`, `Color`, `Quaternion`, `Box`, `Sphere`, `Plane`, `Ray`, `Euler` | proba / partial drawn | TransformPayload + matrices feed the presenter; MIR residual blocks `faber run` dumps |
| `triga:primitives/basic` | `plane`, `box`, `sphere`, … → `Geometry` | drawn | `box` is the presenter mesh |
| `triga:geometry/*` | `Geometry`, `Attribute`, layouts, bounds, batches | typed / proba | Drawn via evaluated `box()` lists, not live Geometry dump |
| `triga:graph/object` | `Object`, `Scene` | typed | Camera/light `base` |
| `triga:graph/camera` | `PerspectiveCamera` | drawn | View-projection in presenter transforms |
| `triga:graph/camera` | `OrthographicCamera` | typed | Fields only |
| `triga:renderable/mesh` | `Mesh` | typed | Not presenter input yet |
| `triga:scene` | `SceneStore`, `visible_meshes`, packets | drawn (library-draw) | Two mesh nodes → two presenter draws |
| `triga:resource` | `ResourceHandle`, transitions | proba | Scene mesh slots hold handles |
| `triga:material/basic` | `UnlitMaterial` | typed | Presenter uses shader sample, not this record |
| `triga:material/lit` | `PhongMaterial` | drawn | Presenter fragment tints + specular from the same consts as the record (`.power` not WGSL-emittable yet) |
| `triga:material/standard` | `StandardMaterial` | typed | Record |
| `triga:material/base` | `TextureDescriptor` | typed | Seed; PNG path is presenter-side |
| `triga:lighting/light` | `DirectionalLight`, `AmbientLight`, `PointLight` | drawn (dir+color+intensity) / typed | Ambient/Point still typed only |
| `triga:shader` | `Texture2D`, `Sampler`, `sample` | drawn | Bound sample on the box |
| `triga:shader_contract` | adapters | proba | Conformance exempla |
| `triga:face` | `FaceQuad` | typed | |

Corpus `webgl-*` demos are a separate era (DOM blob / three.js host). Two `scene.fab` files still fail to parse; not this inventory’s draw path.
