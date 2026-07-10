# Goal 05: Backend Portability

**Status**: parked surface brief
**Campaign**: [`../CAMPAIGN.md`](../CAMPAIGN.md)
**Reserved increment**: 1.0 point
**Likely owners**: `radix`, selected graphics hosts/runtimes, `triga`, `examples`
**Depends on**: successor Stage 0 and stable programmable/render-resource contracts
**Lowers to**: `delivery` → `factory` only after campaign activation

## Purpose

Prove that the Triga and MIR graphics model describes graphics semantics rather
than one WebGPU host by running representative unchanged workloads through a
second backend.

## Surface Area

- Evidence-based selection between WebGL2 browser breadth, native `wgpu`
  systems pressure, or another backend justified by the activation audit.
- Shared Triga scene, material, resource, render-graph, and workload inputs
  without public backend forks.
- Target-neutral MIR/reflection facts with explicit target-specific capability
  negotiation, rejection, and diagnostics.
- Comparable structural/numeric/image results within declared target limits.
- Resource lifecycle, synchronization, shader translation/emission, and host
  integration through canonical ownership seams.

## Boundary

The goal requires one second backend, not a general backend matrix. Lowest-
common-denominator APIs, silent degradation, and target conditionals embedded
throughout public Triga types are outside this brief.
