# Stage 0 Delivery: Capability Baseline And Proof Harness

## Interpreted Unit

Freeze the campaign scorecard as machine-readable Triga-owned data and provide
an honest reporting harness before graphics implementation begins.

## Normalized Spec

- Preserve the campaign's 11 domain weights, mandatory floors, and 80-point
  closeout threshold.
- Map every point to a named proof, owner repository, and evidence state.
- Represent the five mandatory capstone families with versioned manifests and
  unsupported baselines.
- Report score, floors, artifact freshness, and browser availability as
  separate results.
- Do not implement graphics capabilities or weaken unsupported baselines.

## Repo-Aware Baseline

Triga currently has one type-construction exemplar and two source checks. It
has no graphics-stage MIR model or direct-render host. Stage 0 therefore owns
only data, fixture manifests, documentation, and a local report command.

## Stage Graph

1. Define the versioned score ledger and proof-level evidence taxonomy.
2. Add the five capstone manifests with explicit unsupported results.
3. Add a deterministic report/check command and document its protocol.
4. Validate source, compilation, ledger invariants, and baseline reporting.

## Implementation Work

- `proof/capabilities.json`: scorecard, proof mapping, and evidence states.
- `proof/capstones/*.json`: capstone inputs, required claim level, and current
  unsupported state.
- `scripta/check-capabilities`: schema/invariant/freshness validation and human
  report, with optional JSON output.
- `docs/factory/triga-threejs-80/PROOF-HARNESS.md`: claim levels, assets,
  browser protocol, ownership, and commands.

## Checkpoints And Gates

The phase passes when weights total 100, every weighted point has a proof and
owner, all floors are preserved, five manifests validate, unsupported work
scores zero, stale artifacts fail, and browser unavailability is reported
without masquerading as a graphics failure.

**Batching / Split Decision:** one discovery-first batch. Upstream HIR or MIR
work is a named ownership boundary and becomes Vivi needs, not Stage 0 edits.

**Release decision:** defer-release. This is campaign infrastructure and does
not add a usable graphics capability.

## Validation

```bash
./scripta/check-capabilities
./scripta/check-capabilities --json
./scripta/check-source
./scripta/check-compile
```

## Companion Skill Plan

Use factory for execution and polish for the changed primary harness source.
Use Faber repository evidence for claim levels and route compiler blockers to
their canonical owners.

## Open Questions

None blocking. Browser execution remains unavailable until the direct WebGPU
host stage; the baseline records that state explicitly.
