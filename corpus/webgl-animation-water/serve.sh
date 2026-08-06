#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE="$(cd "$SCRIPT_DIR/../../.." && pwd)"
PORT="${PORT:-8774}"
FABER="${FABER:-$WORKSPACE/faber/target/debug/faber}"

"$SCRIPT_DIR/tests/run.sh"
exec python3 -m http.server "$PORT" --directory "$SCRIPT_DIR/dist"
