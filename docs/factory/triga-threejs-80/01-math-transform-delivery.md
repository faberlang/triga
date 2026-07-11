# Stage 1 Delivery: Math And Transform Foundation

## Interpreted Unit

Establish a coherent Triga math representation and prove a CPU transform chain,
while routing compiler-owned register and GPU parity work upstream.

## Normalized Spec

- Triga records are backend-agnostic domain/storage values.
- Compiler `vector` and `matrix` values are fixed-width register values.
- Use column-major 4×4 matrices, column vectors, right-handed coordinates,
  radians, and an explicit epsilon policy.
- Implement the smallest coherent Vector3 and Matrix4 family needed for a
  composition/inverse round trip; do not add compatibility wrappers.
- Zero-length normalization returns the zero vector. Singular inversion returns
  `nihil` through an optional result.

## Repo-Aware Baseline

Triga has record declarations but no operations. Radix supports vector
elementwise operations, dot, cross, and partial host matrix behavior; its live
systems-shaped-values design records matrix device/register semantics as
unfinished. The packet may write only Triga.

## Stage Graph

1. Document representation, layout, coordinate, and failure policies.
2. Implement Vector3 arithmetic and Matrix4 transform operations in Triga.
3. Add a transform-chain exemplar covering composition, inverse, singular, and
   zero-normalization policy.
4. Validate Triga and file exact MIR parity residuals upstream.

## Implementation Work

- Extend `src/triga.fab` with pure constructors and operations.
- Add `exempla/triga-transforms.fab` as the CPU representation proof.
- Extend compilation validation to include instructional exempla.
- Update the campaign only when the integrated Stage 1 gate is honest.

## Checkpoints And Gates

The Triga CPU/HIR checkpoint is green on main `c3f2972`: the provider-imported
transform workload typechecks, emits Rust, builds with the `faber-runtime`
dependency, and runs its assertions. Stage 1 remains open until GPU residual
`ea89665` proves the selected shared subset on the required MIR/GPU path.

**Batching / Split Decision:** discovery then batch. This phase establishes the
record representation in one batch. MIR semantics are a named ownership split
to hunter-1.

**Release decision:** defer-release until the cross-backend Stage 1 gate closes.

## Validation

```bash
./scripta/check-source
./scripta/check-compile
```

## Companion Skill Plan

Use Faber live grammar and exempla, factory execution, and per-file polish.
File MIR needs through Vivi with the operation subset and acceptance evidence.

## Open Questions

- Which matrix operations Radix will admit to typed MIR for the first shared
  subset is owned by the MIR campaign and blocks integrated Stage 1 closure.

## Revision: Extended CPU Batch

The Triga-owned batch now also covers Vector3 distance/interpolation/projection,
quaternion multiplication/normalization/interpolation, quaternion-based matrix
composition, affine determinant, transpose, color interpolation, and essential
Box/Sphere/Plane/Ray queries. A source-module split is deferred until provider
interfaces can prove imports across the canonical `triga:triga` seam.

## Revision: Provider Execution And Euler

The provider proof now covers quaternion normalization/interpolation/composition,
Euler XYZ conversion/composition/interpolation with fail-closed unsupported
orders, color interpolation, Box3/Sphere containment, plane distance, ray point,
affine determinant/inverse, and transpose. The admitted proof sequence is:

```bash
FABER_LIBRARY_HOME=<faberlang-root> radix check exempla/triga-transforms.fab
FABER_LIBRARY_HOME=<faberlang-root> radix emit -t rust exempla/triga-transforms.fab
# Build emitted Rust with the local faber-runtime package, then run assertions.
```

This is CPU/generated-Rust evidence, not GPU product evidence. It closes the
former HIR/provider blockers but does not close Stage 1 while `ea89665` remains
open.
