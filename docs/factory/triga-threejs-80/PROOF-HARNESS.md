# Triga Three.js 80 Proof Harness

Stage 0 records capability evidence without treating declarations or compiler
acceptance as rendered graphics. Run the baseline report with:

```bash
./scripta/check-capabilities
./scripta/check-capabilities --json
```

## Claim Levels

| Level | Claim |
| --- | --- |
| `source` | Faber source parses and typechecks. |
| `rust` | Generated Rust executes the workload contract. |
| `mir_wgsl` | MIR/WGSL artifacts validate the required GPU semantics. |
| `host_compute` | A host executes a compute workload and verifies its result. |
| `host_graphics` | A graphics host renders and verifies numeric, structural, or pixel output. |

Evidence at a lower level never satisfies a proof requiring a higher level.
Only `passed` proofs earn points; `unsupported`, `available`, and `failed` earn
zero. The ledger retains unsupported states so ordinary CI stays green while
the score remains honest.

## Capstone Protocol

The five manifests under `proof/capstones/` reserve stable workload locations
in the public `examples` repo and define their result contracts. Assets must be
small, redistributable, checksum-pinned, and stored with the owning workload;
generated artifacts must identify their source inputs and generator version.

Numeric and structural comparisons must be deterministic. Pixel comparisons
must pin viewport, device-independent dimensions, color space, camera, scene
seed, and an explicit tolerance. Approved screenshots may supplement but never
replace a machine comparison.

A browser runner must report these independently:

1. browser/WebGPU availability;
2. artifact freshness;
3. compilation or pipeline failure;
4. execution result and comparison result.

An unavailable browser is not a passed or failed graphics proof. The Stage 0
report therefore exposes it separately and leaves every capstone unsupported.

## Ownership And Validation

| Surface | Validation owner |
| --- | --- |
| Triga ledger, manifests, and source checks | `triga` |
| Language, HIR, MIR, WGSL, and reflection | `radix` |
| Package/import orchestration | `faber` |
| Generated application runtime | `faber-runtime` |
| Public workloads, assets, expected results | `examples` |
| Direct WebGPU execution | browser host owned by `radix` until superseded |

Triga CI runs the capability checker plus `check-source` and `check-compile`.
Later stages may add browser execution, but must not collapse its availability
or artifact-freshness status into the capability score.
