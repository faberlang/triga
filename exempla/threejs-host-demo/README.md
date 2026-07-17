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
