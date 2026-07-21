# Triga three.js host demo

This is a small browser fixture that proves Triga scene-model data can be handed
to three.js as a host renderer. It intentionally does **not** replace three.js at
compile time and does not exercise MIR, shader, WebGPU, or Stage 5 work.

## What it demonstrates

- Triga-style `BufferGeometry` structure-of-arrays attributes (`position`,
  `normal`, `uv`) plus indices become `THREE.BufferGeometry`.
- Stable scene handles and parent/child links become a three.js object graph.
- Triga `Matrix4` column-major transforms are loaded directly with
  `THREE.Matrix4.fromArray()`.
- Two scene nodes share one geometry resource but use different materials and
  local transforms.

## Open it

The demo fetches `triga-scene.json`, so open it through any static file server
rather than a `file://` URL:

```bash
cd /Users/ianzepp/work/faberlang/triga/exempla/threejs-host-demo
python3 -m http.server 8765
```

Then visit <http://127.0.0.1:8765/>. Internet access is required only for the
three.js ESM import from `unpkg.com`; the Triga scene data is local.

## Files

- `triga-scene.json` — Triga-shaped geometry, materials, scene graph, handles,
  camera, and transform matrices.
- `triga-three-host.js` — the thin browser host that maps the JSON into three.js.
- `index.html` — import map, canvas, and notes.

## Stage 4 MIR pipeline mapping

The demo renders through three.js, not through Radix MIR WGSL emission.
However, the scene data implies a concrete pipeline reflection that maps
to the Stage 4 `MirGraphicsPipelineReflection` types in Radix. This section
documents the mapping so a future Goal 05 host can consume the same facts
from MIR reflection rather than reconstructing them from scene JSON.

| Pipeline reflection field | Demo value | Source |
| --- | --- | --- |
| `color_target_formats` | `[Rgba8Unorm]` | three.js default canvas (single RGBA8 back buffer) |
| `primitive_topology` | `TriangleList` | geometry indices define triangle faces; no line/point topology in scene |
| `depth_stencil` | `Some { depth_write_enabled: true, depth_compare: Less }` | three.js `WebGLRenderer` enables depth testing by default |
| `vertex_input_count` | `3` | position (Float32x3, location 0), normal (Float32x3, location 1), uv (Float32x2, location 2) |
| `varying_count` | `2` | normal + uv passed from vertex to fragment (implied by MeshStandardMaterial lighting) |
| `vertex_count` | scene-dependent | geo-pyramid has 5 vertices; geo-panel has 4 |

These facts are **not** emitted by the demo; they describe what a MIR
reflection would carry for this scene. The three.js host resolves them
internally through its own renderer defaults.

## Gaps vs the Goal 01 locked contract

The demo uses three.js WebGL defaults which differ from the Goal 01
locked first-pipeline contract for direct WebGPU:

| Field | Demo (three.js) | Locked contract | Radix status |
| --- | --- | --- | --- |
| `color_target_formats` | `Rgba8Unorm` (canvas default) | `bgra8unorm` | ✅ `MirColorTargetFormat::Bgra8Unorm` landed (`ea95b924d`) |

Triga source facts are complete. All known radix ABI gaps are closed.
