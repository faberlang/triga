# Triga factory work

## Open campaigns

| Campaign | Status | Next stage |
| --- | --- | --- |
| [Hello Voxel](hello-voxel/CAMPAIGN.md) | In factory. Triga-owned contract gate is packaged; Radix red fixtures still pending | Goal 00 - baseline and contract lock, HV-00B Radix red fixtures |
| [Triga Three.js 80](triga-threejs-80/CAMPAIGN.md) | Active — Stage 1 foundation cleared; Stage 2 generated-Rust scene identity acceptance and direct scene-store Radix check green | Stage 4 — [graphics MIR and shader-stage handoff](triga-threejs-80/stage4-readiness-map-2026-07-14.md) |
| [Triga Three.js 90](triga-threejs-90/CAMPAIGN.md) | Parked successor; routing only | None — wait for the Three.js 80 Stage 12 audit |

## Hello Voxel Triga Gate

Run this before handing work to Radix, Faber, or browser-host factory stages:

```bash
./scripta/check-hello-voxel-contract
```

This gate is intentionally scoped to Triga-owned evidence. It does not prove
fragment lowering, direct WebGPU drawing, browser lifecycle, interaction, or
runtime clean-break completion.
