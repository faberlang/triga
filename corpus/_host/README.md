# corpus/_host — superseded (pointer note)

This directory previously held the shared greybox WebGPU host assets that the
corpus demos copied per-build. It was a one-commit fork (2026-07-31 `806aa21`)
of the authoritative browser runtime and has been **extracted into the sibling
host repo** (DS-S2, decision (b) — engine-runtime home).

## Where the shared engine lives now

- Engine JS: `$WORKSPACE/hosts/webgpu-browser/public/src/`
  (`{product,contract,engine,backend,presentation}`)
- Shader artifacts: `$WORKSPACE/hosts/webgpu-browser/public/generated/triga-lit.wgsl`
  + `triga-lit-reflection.json` (placeholder copies of the pre-radix artifacts
  until the radix regeneration lands; the old-format reflection is rejected by
  `loadFaberGraphicsPipeline` until then — see the DS-S2 spec for the gated
  regeneration).
- The demos copy from the hosts repo via `tests/run.sh`
  (`HOST_DIR="$WORKSPACE/hosts/webgpu-browser"`); the page imports the engine
  bootstrap at `../public/src/product/bootstrap.js` (`initEngine`).

Nothing grows here. Delete this directory once provenance of `806aa21` is no
longer needed.
