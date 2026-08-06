#!/usr/bin/env bash
set -euo pipefail

APP_DIR="$(cd "$(dirname "$0")" && pwd)"
PORT="${PORT:-8773}"

"$APP_DIR/tests/run.sh"

if [[ ! -f "$APP_DIR/dist/pages/index.html" ]]; then
  echo "triga-corpus-animation-orbit serve: dist/pages/index.html missing" >&2
  exit 1
fi

echo "serving $APP_DIR/dist on http://127.0.0.1:${PORT}/pages/index.html"
cd "$APP_DIR/dist"
exec python3 -m http.server "$PORT"
