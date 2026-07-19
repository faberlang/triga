# Hello Voxel Runtime Dependency Inventory

**Scope**: Triga-owned runtime renderer references that affect the Hello Voxel
clean-break goal.
**State**: current-state inventory only. No dependency removal is authorized
until HV-08A proves the direct WebGPU application path.
**Last checked**: 2026-07-19

## Invariant

HV-08 removes executable third-party renderer paths only after the direct
WebGPU proof passes. Historical prose can remain only when it cannot execute as
an alternate renderer.

## Current Executable Three.js Surface

The only Triga-owned executable browser fixture that currently imports a
third-party renderer is `exempla/threejs-host-demo/`.

| File | Runtime role | Current dependency | HV-08 action |
| --- | --- | --- | --- |
| `exempla/threejs-host-demo/index.html` | Browser page and import map | Imports `three` and `three/addons/` from `unpkg.com` | Delete or convert after HV-08A. It must not remain an admitted renderer route. |
| `exempla/threejs-host-demo/triga-three-host.js` | Browser renderer adapter | Imports `three` and `OrbitControls`; constructs `THREE.WebGLRenderer`, scene objects, materials, camera, controls, helpers, and render loop | Delete or convert after HV-08A. Do not wrap it behind a new adapter name. |
| `exempla/threejs-host-demo/triga-scene.json` | Local data fixture | Contains Triga-shaped scene data but no executable renderer import | May remain as historical data only if no browser page or script can execute it as a renderer. |

`exempla/README.md` also advertises the fixture. After HV-08B it must describe
the direct proof or mark the three.js material as historical only.

## Historical References

The repository contains many prose references to three.js because Triga is a
three.js-shaped source library and the older Triga Three.js 80 campaign remains
a breadth reference. These references are acceptable only as documentation.
They must not point to an admitted runtime path after HV-08.

Allowed historical/reference classes:

- comments in `src/triga.fab` that identify corresponding three.js concepts;
- `README.md` and campaign prose that explain Triga's origin and migration
  target;
- `docs/factory/triga-threejs-80/` and `docs/factory/triga-threejs-90/` as
  planning history and successor scope; and
- non-executable JSON or proof manifests that record unsupported capability
  state.

## Bounded Scan

Use this bounded Triga scan before HV-08B and after HV-08B:

```bash
rg -n -g '!docs/factory/hello-voxel/runtime-dependency-inventory.md' \
  "import .*three|from 'three|from \"three|THREE\\.|three@|three/addons|WebGLRenderer|OrbitControls" \
  exempla docs proof src README.md AGENTS.md
```

Expected current result:

- executable hits in `exempla/threejs-host-demo/index.html`;
- executable hits in `exempla/threejs-host-demo/triga-three-host.js`;
- historical prose hits in docs, README files, comments, and campaign plans.

Expected HV-08B result:

- no executable hits in admitted runtime paths;
- no import map or CDN import for `three` or `three/addons/`;
- no `THREE.*`, `WebGLRenderer`, or `OrbitControls` usage in browser code that
  remains runnable; and
- remaining hits are explicitly historical or reference-only.

## Stop Conditions

- Do not delete `exempla/threejs-host-demo/` before HV-08A proves the direct
  WebGPU path.
- Do not retain `triga-three-host.js` as a compatibility fallback after HV-08B.
- Do not count a documentation-only scan as proof that Hello Voxel renders.
- Do not upgrade `proof/capabilities.json` until browser evidence reaches the
  declared proof level.
