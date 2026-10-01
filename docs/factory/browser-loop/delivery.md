# Delivery: Closed browser loop — R1 presenter + first mesh

**Status**: active — Units 1–4 landed; Unit 5 blocked on radix texture/sampler emit
**Goal:** [`GOAL.md`](GOAL.md)
**Repos:** `triga` only
**Release:** not-applicable (presenter bootstrap; no product tag)

---

## 1. Interpreted Unit

R1 Unit 2: the visible presenter draw is a Triga `basic.box`. Fixture in this repo. Radix/Faber emit WGSL + reflection. Positions and indices come from `box()`, not the Unit 1 hand cube.

## 2. Normalized Spec

Done when:

- `host/fixtures/box.fab` constructs `basic.box(1,1,1)` and asserts the admitted graphics contract.
- `./scripta/host generate` runs `faber emit -t wgsl-text` and `--reflection` on that fixture.
- Vertex bins are the `box()` position/index lists (24 verts / 36 indices). Color is remapped face normals.
- `./scripta/host check` admits the emitted pipeline (`presenter_vertex` / `presenter_fragment`, 36 indices).
- Presenter does not import `hosts/webgpu-browser`.

Browser GPU pixels are a manual check: a centered box with six face colors, not the Unit 1 rainbow corners.

## 3. Repo-Aware Baseline

Unit 1 presenter under `triga/host/` at the Unit 1 pin (hosts graphics emit + local 8-corner cube). `faber run` of any file that imports `triga:geometry/data` fails (`unsupported MIR lowering: vector method with non-literal width`). That is the `math.proba` residual, not a presenter defect. Bins therefore evaluate `box()` source lists.

## 4. Stage Graph

```text
D1 write delivery
U1 presenter runtime — done
U2 Triga primitive fixture (this spec) — done when check green
U3–U5 per GOAL.md after U2
```

## 5. Implementation Work

| Unit | write_scope | edit | done_when | sanity |
| --- | --- | --- | --- | --- |
| 2 | `triga/host/fixtures/box.fab`, `triga/host/scripta/generate-payloads.py`, `triga/scripta/host`, `triga/host/public/generated/**`, `triga/docs/factory/browser-loop/*`, `triga/host/README.md` | Fixture emit + box bins | `./scripta/host check` exit 0; WGSL entry `presenter_vertex`; positions from `box()` | `rg hosts/webgpu-browser host scripta/host` empty |

## 6. Checkpoints And Gates

- After U2: Node admission green against emitted artifacts. Reload `:8788` to see the box.
- U2 does not bind `PerspectiveCamera` (U3). Transform stays the look-at pin, now aimed at the origin.

## 7. Validation

```bash
./scripta/host check
rg -n 'hosts/webgpu-browser' host scripta/host
# expect: no matches
```

## 8. Companion Skill Plan

`$faber` for the fixture. `$faberlang` for host scripts.

## 9. Open Questions

None for U2. Residual: live `faber run` dump of Geometry waits on the MIR vector-method gap.
