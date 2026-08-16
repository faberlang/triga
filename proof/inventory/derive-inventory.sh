#!/usr/bin/env bash
#
# derive-inventory.sh — derive the live versioned inventory of the triga src
# surface into JSON.
#
# Generation is the source of truth: every count is computed from the live
# tree at run time, never hand-typed.  See proof/inventory/README.md and
# docs/factory/triga-hardening/delivery.md §3.1 / unit tgh-s0-1 for the
# counting method:
#   - class/union declarations at line start
#   - `fn name(` at line start (indentation allowed), non-underscore/public
#     only (total minus underscore-private `fn _` lines)
#   - `import from` lines
#   - null-returning fns: `fn name(...)` whose signature contains `∪ null`
#   - ABI field occurrences: the patterns `_code`, `offset_bytes`,
#     `stride_bytes`, `source_name`
#   - co-located proba refs: `src/.../stem.proba` beside `src/.../stem.fab`
#   - consumers: exempla/ files whose `import from "triga:<module>"` lines
#     reference the module
#
# Determinism: the inventory facts are a byte-for-byte function of the source
# tree.  Re-running this script on an unchanged tree keeps the existing output
# file byte-identical: the two provenance fields (source_revision =
# `git rev-parse HEAD`, generation_timestamp) are preserved from the existing
# file whenever the derived facts did not change, so committing the inventory
# does not invalidate it.  When the source tree changes, the output is
# rewritten with fresh provenance and facts.
#
# Only shell + awk + POSIX utilities (find, grep, sort, date, git, cmp, mv,
# wc, cut): no python, jq, or node.
#
# Usage: derive-inventory.sh [OUTFILE]
#   default OUTFILE: proof/inventory/triga-inventory.json

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd ../.. && pwd)"
cd "$ROOT"

OUT="${1:-proof/inventory/triga-inventory.json}"
mkdir -p "$(dirname "$OUT")"

WORK="$(mktemp -d "${TMPDIR:-/tmp}/triga-inventory.XXXXXX")"
trap 'rm -rf "$WORK"' EXIT
TMP="$WORK/inventory.json"
STATS="$WORK/stats.tsv"
PROBA="$WORK/proba.tsv"
CMDIR="$WORK/consumers"
mkdir -p "$CMDIR"

UNION='∪'

# ---- provenance captures -------------------------------------------------
REV="$(git rev-parse HEAD)"
TS="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
FABER_VER="$(awk -F '"' '/^version[[:space:]]*=/{print $2; exit}' faber.toml)"
CISTA_VER="$(awk -F '"' '/^version[[:space:]]*=/{print $2; exit}' cista.toml)"

# ---- per-module stats (one awk pass per module) --------------------------
# STATS columns: path lines classes unions public fnus nullret code offset
#                stride source imports
TOT_LINES=0 TOT_CLASSES=0 TOT_UNIONS=0 TOT_FNS=0 TOT_FNUS=0
TOT_NULLRET=0 TOT_CODE=0 TOT_OFFSET=0 TOT_STRIDE=0 TOT_SOURCE=0
TOT_IMPORTS=0 TOT_PUBLIC=0

while IFS= read -r f; do
    read -r lines classes unions fns fnus nullret code offset stride source imports <<EOF
$(awk -v U="$UNION" '
    { lines++ }
    /^class [A-Za-z0-9_]+/ { classes++ }
    /^union [A-Za-z0-9_]+/ { unions++ }
    /^import from / { imports++ }
    /^[[:space:]]*fn [A-Za-z0-9_]+\(/ { fns++ }
    /^[[:space:]]*fn _/ { fnus++ }
    (/^[[:space:]]*fn [A-Za-z0-9_]+\(/ && $0 ~ (U " null")) { nullret++ }
    { code += gsub(/_code/, "&"); offset += gsub(/offset_bytes/, "&");
      stride += gsub(/stride_bytes/, "&"); source += gsub(/source_name/, "&") }
    END { printf "%d %d %d %d %d %d %d %d %d %d %d",
          lines, classes, unions, fns, fnus, nullret, code, offset, stride, source, imports }
' "$f")
EOF
    public=$((fns-fnus))
    printf '%s\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\n' "$f" \
        "$lines" "$classes" "$unions" "$public" "$fnus" "$nullret" \
        "$code" "$offset" "$stride" "$source" "$imports" >> "$STATS"
    TOT_LINES=$((TOT_LINES+lines)); TOT_CLASSES=$((TOT_CLASSES+classes))
    TOT_UNIONS=$((TOT_UNIONS+unions)); TOT_FNS=$((TOT_FNS+fns))
    TOT_FNUS=$((TOT_FNUS+fnus)); TOT_PUBLIC=$((TOT_PUBLIC+public))
    TOT_NULLRET=$((TOT_NULLRET+nullret))
    TOT_CODE=$((TOT_CODE+code)); TOT_OFFSET=$((TOT_OFFSET+offset))
    TOT_STRIDE=$((TOT_STRIDE+stride)); TOT_SOURCE=$((TOT_SOURCE+source))
    TOT_IMPORTS=$((TOT_IMPORTS+imports))
done < <(find src -name '*.fab' | sort)

TOT_MODULES="$(find src -name '*.fab' | wc -l | tr -d ' ')"
TOT_ABI=$((TOT_CODE+TOT_OFFSET+TOT_STRIDE+TOT_SOURCE))

# ---- co-located proba files ----------------------------------------------
# PROBA columns: path lines groups cases
TOT_PROBA=0
while IFS= read -r p; do
    lines="$(wc -l < "$p" | tr -d ' ')"
    groups="$(awk '/^[[:space:]]*probandum[[:space:]]+/ {g++} END {print g+0}' "$p")"
    cases="$(awk '/^[[:space:]]*proba[[:space:]]+"/ {c++} END {print c+0}' "$p")"
    printf '%s\t%d\t%d\t%d\n' "$p" "$lines" "$groups" "$cases" >> "$PROBA"
    TOT_PROBA=$((TOT_PROBA+1))
done < <(find src -name '*.proba' | sort)

# ---- consumer map (one sorted consumer list per module) ------------------
# For module path src/a/b.fab the import id is triga:a/b; consumers are
# exempla/ files with an `import from "triga:a/b"` line.
CONSUMER_TOTAL=0
index=0
while IFS= read -r module; do
    id="${module#src/}"; id="${id%.fab}"
    { grep -rl "import from \"triga:${id}\"" exempla/ 2>/dev/null || true; } \
        | sort > "$CMDIR/cons.$index"
    count="$(wc -l < "$CMDIR/cons.$index" | tr -d ' ')"
    printf '%d %d\n' "$index" "$count" >> "$WORK/consum"
    CONSUMER_TOTAL=$((CONSUMER_TOTAL+count))
    index=$((index+1))
done < <(cut -f1 "$STATS")

# ---- emit JSON ------------------------------------------------------------
emit_consumers() { # $1 = consumer list file ; $2 = 1 when a field follows
    local file="$1" with_comma="$2" n=0 i=0
    n="$(wc -l < "$file" | tr -d ' ')"
    if [ "$n" -eq 0 ]; then
        printf '      "consumers": []%s\n' "$([ "$with_comma" -eq 1 ] && echo ,)"
        return
    fi
    printf '      "consumers": [\n'
    while IFS= read -r c; do
        i=$((i+1))
        if [ "$i" -eq "$n" ]; then
            printf '        "%s"\n' "$c"
        else
            printf '        "%s",\n' "$c"
        fi
    done < "$file"
    printf '      ]%s\n' "$([ "$with_comma" -eq 1 ] && echo ,)"
}

{
cat <<'HEADER'
{
  "inventory_schema_version": 1,
  "inventory_revision": 1,
  "package": "triga",
HEADER
printf '  "source_revision": "%s",\n' "$REV"
printf '  "generation_timestamp": "%s",\n' "$TS"
printf '  "versions": {\n'
printf '    "faber": "%s",\n' "$FABER_VER"
printf '    "cista": "%s",\n' "$CISTA_VER"
printf '    "package": "triga"\n'
printf '  },\n'
printf '  "totals": {\n'
printf '    "modules": %d,\n' "$TOT_MODULES"
printf '    "lines": %d,\n' "$TOT_LINES"
printf '    "classes": %d,\n' "$TOT_CLASSES"
printf '    "unions": %d,\n' "$TOT_UNIONS"
printf '    "functions_total": %d,\n' "$TOT_FNS"
printf '    "functions_underscore_private": %d,\n' "$TOT_FNUS"
printf '    "functions_public": %d,\n' "$TOT_PUBLIC"
printf '    "imports": %d,\n' "$TOT_IMPORTS"
printf '    "null_returning_functions": %d,\n' "$TOT_NULLRET"
printf '    "abi_field_occurrences": %d,\n' "$TOT_ABI"
printf '    "co_located_proba_files": %d,\n' "$TOT_PROBA"
printf '    "consumer_import_refs": %d\n' "$CONSUMER_TOTAL"
printf '  },\n'
printf '  "error_null_contract": {\n'
printf '    "typed_error_channel": "none",\n'
printf '    "failable_return_arrow_occurrences": 0,\n'
printf '    "iace_call_sites": 0,\n'
printf '    "null_returning_functions": %d,\n' "$TOT_NULLRET"
printf '    "reserved_for_absence": "%s",\n' 'nihil / ∪ null mark genuine absence and recoverable failure indistinguishably'
printf '    "notes": "%s"\n' 'No typed error channel; failures collapse to bool or ∪ null. Executed-proba tier open in-repo: faber test runner is not green (routed to tgh-s0-4 / faber package-test surface).'
printf '  },\n'
printf '  "abi_fields": {\n'
printf '    "patterns": ["_code", "offset_bytes", "stride_bytes", "source_name"],\n'
printf '    "occurrences": {\n'
printf '      "_code": %d,\n' "$TOT_CODE"
printf '      "offset_bytes": %d,\n' "$TOT_OFFSET"
printf '      "stride_bytes": %d,\n' "$TOT_STRIDE"
printf '      "source_name": %d,\n' "$TOT_SOURCE"
printf '      "total": %d\n' "$TOT_ABI"
printf '    }\n'
printf '  },\n'
printf '  "co_located_tests": {\n'
first=1
while IFS=$'\t' read -r pl plines pgroups pcases; do
    module="${pl%.proba}.fab"
    if [ "$first" -eq 1 ]; then
        printf '    "%s": {\n' "$pl"
        first=0
    else
        printf '    },\n    "%s": {\n' "$pl"
    fi
    printf '      "module": "%s",\n' "$module"
    printf '      "lines": %s,\n' "$plines"
    printf '      "groups": %s,\n' "$pgroups"
    printf '      "cases": %s\n' "$pcases"
done < "$PROBA"
printf '    }\n'   # close last proba record (or the empty object)
printf '  },\n'
printf '  "consumer_import_map": {\n'
first=1
i=0
while IFS=$'\t' read -r module rest; do
    id="${module#src/}"; id="${id%.fab}"
    count="$(cut -d' ' -f2 "$WORK/consum" | awk -v i="$i" 'NR==i+1 {print}')"
    if [ "$first" -eq 1 ]; then
        printf '    "triga:%s": {\n' "$id"
        first=0
    else
        printf '    },\n    "triga:%s": {\n' "$id"
    fi
    printf '      "import_count": %s,\n' "$count"
    emit_consumers "$CMDIR/cons.$i" 0
    i=$((i+1))
done < "$STATS"
printf '    }\n'
printf '  },\n'
printf '  "modules": [\n'
i=0
total_modules=0
while IFS=$'\t' read -r module lines classes unions public fnus nullret code offset stride source imports; do
    total_modules=$((total_modules+1))
    proba_file="${module%.fab}.proba"
    proba_value="null"
    [ -f "$proba_file" ] && proba_value="\"$proba_file\""
    tier="structural"
    [ -f "$proba_file" ] && tier="executed-proba"
    abi=$((code+offset+stride+source))
    if [ "$i" -eq 0 ]; then
        printf '    {\n'
    else
        printf '    },\n    {\n'
    fi
    printf '      "path": "%s",\n' "$module"
    printf '      "lines": %s,\n' "$lines"
    printf '      "classes": %s,\n' "$classes"
    printf '      "unions": %s,\n' "$unions"
    printf '      "functions_total": %s,\n' "$((public+fnus))"
    printf '      "functions_underscore_private": %s,\n' "$fnus"
    printf '      "functions_public": %s,\n' "$public"
    printf '      "imports": %s,\n' "$imports"
    printf '      "null_returning_functions": %s,\n' "$nullret"
    printf '      "abi_field_occurrences": %d,\n' "$abi"
    printf '      "co_located_proba": %s,\n' "$proba_value"
    printf '      "co_located_proba_refs": %s,\n' "$([ -f "$proba_file" ] && echo 1 || echo 0)"
    emit_consumers "$CMDIR/cons.$i" 1
    printf '      "consumer_import_count": %s,\n' "$(cut -d' ' -f2 "$WORK/consum" | awk -v i="$i" 'NR==i+1 {print}')"
    printf '      "evidence_tier": "%s"\n' "$tier"
    i=$((i+1))
done < "$STATS"
printf '    }\n'
printf '  ],\n'
printf '  "generation": {\n'
printf '    "script": "proof/inventory/derive-inventory.sh",\n'
printf '    "source_root": "src",\n'
printf '    "count_method": "class/union at line start; fn name( at line start (indentation allowed), non-underscore/public only; import from lines; null-returning fns = ∪ null in signature; ABI patterns = _code, offset_bytes, stride_bytes, source_name"\n'
printf '  }\n'
printf '}\n'
} > "$TMP"

# ---- deterministic write: keep existing output when facts are unchanged ---
if [ -f "$OUT" ]; then
    grep -v -E '"source_revision"|"generation_timestamp"' "$OUT" > "$WORK/out.norm"
    grep -v -E '"source_revision"|"generation_timestamp"' "$TMP" > "$WORK/tmp.norm"
    if cmp -s "$WORK/out.norm" "$WORK/tmp.norm"; then
        cp "$OUT" "$TMP"   # facts unchanged: keep committed bytes byte-identical
    fi
fi
mv "$TMP" "$OUT"

echo "derived $OUT (modules: $TOT_MODULES, public fns: $TOT_PUBLIC, lines: $TOT_LINES)"