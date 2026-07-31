# Triga corpus

Browser-rendered demo scenes that exercise the `triga:*` library surface
end-to-end: Faber scene facts → `faber build --package .` browser product →
direct WebGPU. Sibling of `exempla/` (instructional module demos) and of
`radix/corpus/` (language keyword examples).

Each demo recreates a [three.js example](https://threejs.org/examples/) as a
reference, named after its slug:

| Corpus entry | three.js reference | What it pressures |
| --- | --- | --- |
| `webgl-geometries/` | `webgl_geometries` | Every `triga:primitives` generator (plane, box, circle, sphere, cylinder, cone, torus), per-mesh colors, BufferGeometry → interleaved host payload |
| `webgl-geometry-terrain/` | `webgl_geometry_terrain` | Procedural mesh generation at scale (48² heightfield, 4.6k triangles), value noise, central-difference normals, elevation color ramp via `triga:math.color_interpolata` |

Adaptations vs. the originals are deliberate: triga primitives are low-poly
(the "sphere" is an octahedron), shapes do not rotate yet (the host publishes
one model matrix), and materials are per-vertex colors rather than textures.

## Layout

```text
corpus/
  serve.sh                # build all demos + single corpus server (default port 8780)
  serve.mjs               # dependency-free node server: index page + /<slug>/ → <slug>/dist/
  _host/                    # shared host assets, single source of truth
    public/                 # WebGPU runtime + greybox host + host-init (JS transport only)
    shaders/                # kernel.wgsl + reflection.json; copied to each demo's
                            #   public/ (runtime fetch) and src/shaders/ (build input)
  webgl-geometries/         # self-contained browser-app package
    src/*.fab               # scene, camera, controller
    pages/ styles/          # product templates
    tests/run.sh            # asset sync + faber check + build + contract greps
    serve.sh                # focused per-demo server (debugging; corpus server is default)
```

`public/` and `src/shaders/` inside a demo are **generated** (gitignored):
`tests/run.sh` copies them from `corpus/_host/` before checking and building.
Edit host JS/WGSL only under `corpus/_host/`.

Per-demo knobs on the host contract:

- `<canvas data-fog-density="…">` — exp2 fog density (0 = shader default 0.010).
  Scene-scale dependent: bridge-scale scenes like 0.010, terrain-scale 0.0032.

## Run

Single entry point for the whole corpus (builds every demo, then serves):

```sh
cd triga/corpus && ./serve.sh          # http://127.0.0.1:8780/
cd triga/corpus && ./serve.sh --no-build   # serve existing dist/ output
```

The index page lists every built demo; each demo lives under its slug
(`http://127.0.0.1:8780/webgl-geometries/`, `…/webgl-geometry-terrain/`).
Adding a demo needs no server change — any `<slug>/dist/pages/index.html`
is discovered automatically. `serve.sh` is a thin wrapper over `serve.mjs`
(dependency-free node static server; `PORT` env or `--port`).

Check without serving: `./tests/run.sh` in any demo dir. Each demo also keeps
its own `serve.sh` (dedicated port) for focused debugging, but the corpus
server is the default.

Camera controls (all demos): arrows orbit, `W`/`S` dolly, `A`/`D` pan,
`Q`/`E` pan along the view axis.

## Library gaps this corpus has already fed

- `BufferAttribute.float32_values()` (`triga/src/geometry.fab`) — consumers
  cannot `discerne` over `AttributeData` from another module (variants are not
  in scope cross-module), so the payload projection lives next to the enum.
  Adding a demo that needs enum access should pressure a compiler fix or more
  same-module accessors, not workarounds in demos.
