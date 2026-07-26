# Residual: HV-05C live proof blocked — build chain regressions

**From**: hand-1  
**Date**: 2026-07-26  
**Task**: ae2cf0bd → `task 2950eeec`  
**Status**: RED — unable to complete. New residual reported.

## Evidence

### 1. `faber build --package .` exits with tsc errors (faber rebuild at 03:38)

The faber binary was rebuilt (newer version), changing behavior:
- Previous (03:29): produced ESM output despite tsc errors, exit 0
- Current (03:38): no ESM output, exit 1

TS errors include `TS2307: Cannot find module 'triga:triga'` and `TS1128: Declaration or statement expected` in `faber-web.d.ts` (extra `}}` brace).

**Fix applied**: edited `faber-web.d.ts` to remove the extra closing brace (lines 82, 91: `}}` → `}`). This allowed `link-triga-ts.mjs` to run.

### 2. `link-triga-ts.mjs` produces duplicate `export const` namespace blocks

`wrapLocalModule()` re-wraps an already-wrapped TS file, adding a second `export const voxel/meshing/application` block. This causes ES module `SyntaxError: Identifier 'voxel' has already been declared`.

**Fix applied**: manually removed the second namespace block from `voxel.js`, `meshing.js`, `application.js` in `dist/faber-esm/` using Python script.

### 3. `emit-package-geometry.mjs` fails: `status not package-ready: package-pending`

Root cause: `link-triga-ts.mjs` rewrites `web:dom` imports to `./web-dom.js`:

```javascript
// In link-triga-ts.mjs, rewriteTrigaImports:
code = code.replace(
    /import\s*\{\s*dom\s*\}\s*from\s*["']web:dom["']\s*;?/g,
    'import { dom } from "./web-dom.js"',
);
```

The generated `web-dom.js` (from `faber-web/src/dom.fab`) has stub functions that only `console.log()`:

```javascript
// dist/faber-esm/web-dom.js
export function text_set(element, value) {
    console.log(__faberDisplay(element, "unknown"));
    console.log(__faberDisplay(value, "textus"));
    // does NOT actually set element.textContent
}
export function attr_set(element, name, value) {
    console.log(__faberDisplay(element, "unknown"));
    console.log(__faberDisplay(name, "textus"));
    console.log(__faberDisplay(value, "textus"));
    // does NOT actually set element attributes
}
```

The runtime-bridge (`browser-app/tests/runtime-bridge.mjs`) has real implementations but is only reachable via the Node.js loader hook (`--import register-hooks.mjs`) when importing from the bare specifier `web:dom`. Since the import was rewritten to `./web-dom.js`, the loader hook is bypassed.

**Result**: DOM operations are no-ops → controller runs but status field never gets `"package-ready"` → `emit-package-geometry.mjs` fails before writing geometry bins → no bins for host proof.

## All issues discovered

| # | File | Issue | Scope |
|---|---|---|---|
| R1 | `dist/faber-ts/faber-web.d.ts` | Extra `}}` closing brace | faber emitter |
| R2 | `link-triga-ts.mjs` `wrapLocalModule()` | Duplicates namespace export on re-wrap | `link-triga-ts.mjs` |
| R3 | `link-triga-ts.mjs` `rewriteTrigaImports()` | Rewrites `web:dom` import → bypasses loader hook → DOM stubs used | `link-triga-ts.mjs` |
| R4 | `faber-web/src/dom.fab` → generated `web-dom.js` | DOM functions only console.log; no actual DOM mutation | faber-web emit |

## Recommendation

**R3 is the immediate blocker.** Fix: stop rewriting `web:dom` → `./web-dom.js` in `link-triga-ts.mjs`'s `rewriteTrigaImports()`. With `web:dom` kept as bare specifier:
- tsc resolves via `faber-web.d.ts` ambient declaration
- Node.js runtime resolves via loader hook → `runtime-bridge.mjs` with real DOM operations

**R2** (duplicate namespace) must also be fixed for `link-triga-ts.mjs` to produce valid output — `wrapLocalModule()` should strip the existing namespace before adding its own, or use raw `emitTs` output instead of the already-wrapped TS file.

**Write scope limits**: `examples/hello-voxel/scripta/hv04c-host-proof-app.js` only (proof-script bug) — none of the above files are in scope. Residual report only.
