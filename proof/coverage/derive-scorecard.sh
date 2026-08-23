#!/usr/bin/env bash
#
# Derive the Stage 0 coverage scorecard from the committed live inventory.
#
# The inventory is the authority for the module set and all source counts.
# Observed source revision/digest are write-time provenance: a mismatch mark
# means the inventory snapshot is not the current HEAD census.
# Exempla references are limited to the files documented by exempla/README.md,
# matching the file-set rule in scripta/check-exempla-inventory.
#
# Usage: proof/coverage/derive-scorecard.sh [OUTFILE]

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd ../.. && pwd)"

exec python3 - "$ROOT" "$@" <<'PY'
from __future__ import annotations

import hashlib
import json
from pathlib import Path
import re
import subprocess
import sys

root = Path(sys.argv[1])
out_arg = Path(sys.argv[2]) if len(sys.argv) > 2 else Path("proof/coverage-scorecard.json")
out = out_arg if out_arg.is_absolute() else root / out_arg
inventory_path = root / "proof" / "inventory" / "triga-inventory.json"
readme_path = root / "exempla" / "README.md"

def git_head(root: Path) -> str | None:
    try:
        completed = subprocess.run(
            ["git", "rev-parse", "HEAD"],
            cwd=root,
            capture_output=True,
            text=True,
            check=False,
        )
    except OSError:
        return None
    value = completed.stdout.strip()
    if completed.returncode == 0 and re.fullmatch(r"[0-9a-f]{40}", value):
        return value
    return None


def source_digest(root: Path) -> str:
    digest = hashlib.sha256()
    src = root / "src"
    paths = sorted(src.rglob("*.fab"), key=lambda path: path.relative_to(root).as_posix())
    for path in paths:
        digest.update(path.relative_to(root).as_posix().encode("utf-8"))
        digest.update(b"\0")
        digest.update(path.read_bytes())
        digest.update(b"\n")
    return "sha256:" + digest.hexdigest()


with inventory_path.open(encoding="utf-8") as source:
    inventory = json.load(source)

# This is the same top-level documented-file rule used by the live exempla
# checker. Nested browser fixtures are deliberately outside this package set.
documented_names = sorted(
    match.group(1)
    for match in re.finditer(r"^  ([^\s]+\.fab)[^\s]*", readme_path.read_text(encoding="utf-8"), re.MULTILINE)
)
actual_names = sorted(path.name for path in (root / "exempla").glob("*.fab"))
if documented_names != actual_names:
    raise SystemExit(
        "exempla README/file inventory mismatch: "
        f"documented={documented_names!r} actual={actual_names!r}"
    )

documented_files = [f"exempla/{name}" for name in documented_names]
module_records = inventory["modules"]
module_ids = {
    record["path"]: f"triga:{record['path'][len('src/'):-len('.fab')]}"
    for record in module_records
}

# The README/checker pair covers the 15 top-level instructional exempla. The
# committed inventory also records the nested conformance exempla, so include
# every live exemplum when resolving coverage references.
all_exempla = sorted(
    path.relative_to(root).as_posix()
    for path in (root / "exempla").rglob("*.fab")
)
coverage: dict[str, list[str]] = {module_id: [] for module_id in module_ids.values()}
import_pattern = re.compile(r'import from "triga:([^"]+)"')
for relative in all_exempla:
    path = root / relative
    for line in path.read_text(encoding="utf-8").splitlines():
        for match in import_pattern.finditer(line):
            module_id = match.group(1)
            if f"triga:{module_id}" not in coverage:
                raise SystemExit(f"{relative}: import references non-live module triga:{module_id}")
            if relative not in coverage[f"triga:{module_id}"]:
                coverage[f"triga:{module_id}"].append(relative)
for module_id, refs in coverage.items():
    refs.sort()
    inventory_refs = sorted(inventory["consumer_import_map"].get(module_id, {}).get("consumers", []))
    if refs != inventory_refs:
        raise SystemExit(
            f"{module_id}: live exempla imports differ from committed inventory consumer map"
        )

stale_claims = [
    {
        "id": "module-map-size",
        "claim": "The approximate post-S1 line counts in the module-map Size section are stale live coverage data.",
        "stale_source": "docs/module-map.md#size-after-s1-splits",
        "replacement": "proof/coverage-scorecard.json modules[*].lines",
    },
    {
        "id": "module-map-target-count",
        "claim": "The module-map Target map's 61 non-facade leaves / 75 import paths describe a frozen future target horizon, not the 26-module live package.",
        "stale_source": "docs/module-map.md#target-map-frozen-at-s0-2026-08-01",
        "replacement": "proof/inventory/triga-inventory.json modules and proof/coverage-scorecard.json",
    },
    {
        "id": "test-decomposition-report",
        "claim": "The test-decomposition report is pre-split evidence; its source paths, line numbers, and symbol coverage claims are not live coverage authority.",
        "stale_source": "docs/factory/test-decomposition-report.md",
        "replacement": "proof/coverage-scorecard.json modules[*]",
    },
]
stale_ids = [claim["id"] for claim in stale_claims]

tiers = [
    "structural",
    "executed-proba",
    "target",
    "browser-numeric-pixel",
    "stress",
    "clean-install",
]

test_records = inventory.get("co_located_tests", {})
rows = []
for record in module_records:
    path = record["path"]
    module_id = module_ids[path]
    proba = record.get("co_located_proba")
    proba_refs = [proba] if isinstance(proba, str) else []
    proba_record = test_records.get(proba) if isinstance(proba, str) else None
    rows.append(
        {
            "path": path,
            "lines": record["lines"],
            "symbol_counts": {
                "classes": record["classes"],
                "unions": record["unions"],
                "functions_total": record["functions_total"],
                "functions_underscore_private": record["functions_underscore_private"],
                "functions_public": record["functions_public"],
                "total": record["classes"] + record["unions"] + record["functions_total"],
                "public": record["classes"] + record["unions"] + record["functions_public"],
            },
            "co_located_proba_refs": proba_refs,
            "co_located_proba": proba_record,
            "exempla_coverage_refs": coverage[module_id],
            "evidence_tier": record["evidence_tier"],
            "stale_claims": stale_ids,
        }
    )

observed_revision = git_head(root)
snapshot_revision = inventory["source_revision"]
scorecard = {
    "coverage_schema_version": 1,
    "coverage_revision": 3,
    "package": "triga",
    "stage0_unit": "tgh-s0-3",
    "inventory": {
        "path": "proof/inventory/triga-inventory.json",
        "inventory_schema_version": inventory["inventory_schema_version"],
        "inventory_revision": inventory["inventory_revision"],
        "source_revision": snapshot_revision,
        "module_count": inventory["totals"]["modules"],
        "observed_source_revision": observed_revision or snapshot_revision,
        "observed_source_digest": source_digest(root),
        "inventory_mismatch": bool(observed_revision) and observed_revision != snapshot_revision,
    },
    "exempla_inventory": {
        "readme": "exempla/README.md",
        "checker": "scripta/check-exempla-inventory",
        "documented_files": documented_files,
    },
    "evidence_tier_enum": tiers,
    "stale_claims": stale_claims,
    "modules": rows,
}

out.parent.mkdir(parents=True, exist_ok=True)
out.write_text(json.dumps(scorecard, indent=2) + "\n", encoding="utf-8")
print(f"derived {out} (modules: {len(rows)}, documented exempla: {len(documented_files)})")
PY
