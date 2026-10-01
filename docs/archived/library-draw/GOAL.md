# GOAL: Library structures on the presenter

**Status**: done — I1/S1/L1 closed 2026-10-01 (operator visual: two checkerboard boxes; inward faces darker under DirectionalLight)
**Created**: 2026-10-01
**Campaign:** —
**Source:** operator 2026-10-01 after browser-loop R4: continue Triga as a library without fighting display infra
**Repos:** `triga` (fixture + presenter + inventory)
**Related:** [`../../archived/browser-loop/GOAL.md`](../../archived/browser-loop/GOAL.md); [`../../library-surface-inventory.md`](../../library-surface-inventory.md)

---

## Invariant

The thin Triga presenter draws values that come from Triga library types (`SceneStore` packets, `DirectionalLight`, shared `box` geometry). Display plumbing is stable enough that library work is the bottleneck.

## Problem

R1–R4 closed one textured mesh. `SceneStore`, lights, and most materials remained typed or proba-only. Further library work was blocked on “will this show up?”

## Proposal

1. Inventory (`docs/library-surface-inventory.md`) — honesty pass.
2. One fixture: `SceneStore` with two translated mesh children; presenter multi-draw from `VisibleMeshes`-shaped transform packets.
3. Same fixture: `DirectionalLight` whose direction the fragment lambert uses with mesh normals and the existing albedo sample.

### Non-goals

- Phong/PBR evaluation records → shader.
- glTF / corpus DOM blob path.
- Lifting the MIR Geometry dump residual.
- Moving `hosts/webgpu-browser`.

## Requirements register

| ID | Requirement | Status |
| --- | --- | --- |
| I1 | Inventory typed / proba / drawn | done |
| S1 | Two SceneStore meshes visible on one canvas | done |
| L1 | Directional light changes shading on those meshes | done |

## Validation

```bash
./scripta/host check
./scripta/host serve   # two checkerboard boxes, lit; operator visual
```

## Ledger

| Unit | Status | Notes |
| --- | --- | --- |
| I1 inventory | done | `docs/library-surface-inventory.md` |
| S1 SceneStore multi-draw | done | operator visual: two side-by-side boxes |
| L1 directional lambert | done | operator visual: inward faces darker |
