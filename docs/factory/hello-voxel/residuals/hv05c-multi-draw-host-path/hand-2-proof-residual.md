# Residual: HV-05C live proof re-try — WebGPU host runtime error

**From**: hand-1  
**Date**: 2026-07-26  
**Task**: b02c0a82 — proof body: HV-05C live multi-draw re-try after pure-lib P5 31f271a  
**Status**: RED — multi-draw host proof attempted but WebGPU host runtime fails

## Summary

The pure-lib P5 changes (commit `31f271a`, deleted `link-triga-ts.mjs`) unblocked the
faber-native build path. The structural tests pass. The `emit-package-geometry.mjs`
produces correct 4-chunk multi-draw artifacts. However, the automated WebGPU host
proof (`run-hv04c-host-proof.mjs`) fails with a `createBindGroup` error in the
host's `webgpu-runtime.js` — a host-side runtime issue.

## Evidence

### 1. `faber build --package .` succeeds (GREEN)

The faber build exits 0, producing `dist/faber-esm/faber-browser.js`,
`dist/controllers.json`, and all generated ESM/TS output.

### 2. Structural fixture tests pass (GREEN)

```
browser-fixture-test:  7 passed, 0 failed
hv04b-payload-test:   70 passed, 0 failed
```

### 3. `emit-package-geometry.mjs` succeeds (GREEN)

Produces 4-chunk multi-draw artifacts at `dist/generated/chunks/<slot>/`:

```
  chunks=4 non_empty=4 faces=2622 indices=15732
  resource_pairs=4 draws=4
```

Per-chunk files verified present with correct sizes.

### 4. WebGPU host proof attempted — RED

**Command:**
```
cd examples/hello-voxel
HV04C_CHROME="/Users/ianzepp/Library/Caches/ms-playwright/chromium-1223/chrome-mac-arm64/.../Google Chrome for Testing" \
  node --import ../browser-app/tests/register-hooks.mjs \
  scripta/run-hv04c-host-proof.mjs
```

**Stdout/stderr:**
```
run-hv04c-host-proof: serving http://127.0.0.1:56977/
  chrome=.../Google Chrome for Testing
Failed to load resource: the server responded with a status of 404 (Not Found)
run-hv04c-host-proof: browser state {
  ok: false,
  status: 'error',
  frames: undefined,
  error: "Failed to execute 'createBindGroup' on 'GPUDevice': Failed to read
          the 'entries' property from 'GPUBindGroupDescriptor': Failed to read
          the 'resource' property from 'GPUBindGroupEntry': Failed to read
          the 'buffer' property from 'GPUBufferBinding': Required member is
          undefined."
}
```

**Root cause:** `webgpu-runtime.js` creates a bind group entry with an undefined
buffer — likely a missing or null buffer slot in the per-chunk multi-draw path.

## Issues discovered

| # | File | Issue | Scope |
|---|---|---|---|
| D1 | `dist/faber-esm/voxel.js` (and TS) | Radix compiler emits float division for `numerus / numerus` (`x / chunk_size()` → `0.0625`, not `0`). Fixed with `Math.floor()` in generated output. | Radix compiler (out of scope for this task) |
| D2 | `examples/browser-app/tests/loader-hook.mjs` | The hook intercepts bare specifier `web:dom` but the compiler rewrites it to `./web-dom.js` (relative path), bypassing the hook. Fixed by adding `./web-dom.js` → runtime-bridge intercept. | Loader hook (fixed in this unit) |
| D3 | `scripta/emit-package-geometry.mjs` | Checks model matrix change across frames, but model is always identity (by design in multi-draw path). Fixed by checking view-projection matrix instead. | Emit script (fixed in this unit) |
| H1 | `hosts/webgpu-browser/public/src/webgpu-runtime.js` | `createBindGroup` fails with undefined buffer in bind group entry. Per-chunk multi-draw host path has a resource binding bug. | Host runtime (out of scope for this task) |

## Tip SHAs

| Repo | SHA | Subject |
|---|---|---|
| examples | `31f271a` | feat(hello-voxel): Phase 5 — remove link-triga-ts.mjs |
| faber | `7ba61c4` | docs: fix CE VJP doc — N = class count (last_dim), not batch size |
| triga | `0b762d0` | docs: commit HV-05C live-proof residual report (hand-1-proof-residual.md) |
| hosts | `9e8d166` | feat(hosts): cap GPU dispatch/buffer to device limits for untrusted packages |

## Recommendation

**H1 is the immediate blocker** for the multi-draw host proof. The host
`webgpu-runtime.js` `createBindGroup` call has a missing/null buffer in a bind
group entry during per-chunk resource setup. Fix the host's
`createChunkGraphicsResources` or `applyChunkResourceReplace` to ensure all
buffer bindings are valid.

D1 (integer division) and D2 (loader hook) need upstream fixes in the Radix
compiler and the loader hook respectively, but the tactical fixes applied in
this unit unblock the structural test path.
