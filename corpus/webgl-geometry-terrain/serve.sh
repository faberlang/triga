#!/usr/bin/env bash
set -euo pipefail

APP_DIR="$(cd "$(dirname "$0")" && pwd)"
PORT="${PORT:-8772}"
PID_FILE="${APP_DIR}/.serve.pid"

stop_existing() {
  if [[ -f "${PID_FILE}" ]]; then
    local old
    old="$(cat "${PID_FILE}" 2>/dev/null || true)"
    if [[ -n "${old}" ]] && kill -0 "${old}" 2>/dev/null; then
      kill "${old}" 2>/dev/null || true
      wait "${old}" 2>/dev/null || true
    fi
    rm -f "${PID_FILE}"
  fi
  if command -v lsof >/dev/null 2>&1; then
    local pids
    pids="$(lsof -tiTCP:"${PORT}" -sTCP:LISTEN 2>/dev/null || true)"
    if [[ -n "${pids}" ]]; then
      kill ${pids} 2>/dev/null || true
      sleep 0.2
    fi
  fi
}

# tests/run.sh owns asset sync, lockfile, checks, and the build.
"${APP_DIR}/tests/run.sh"

if [[ ! -f "${APP_DIR}/dist/pages/index.html" ]]; then
  echo "triga-corpus-terrain serve: dist/pages/index.html missing" >&2
  exit 1
fi

stop_existing
echo "serving ${APP_DIR}/dist on http://127.0.0.1:${PORT}/pages/index.html"
cd "${APP_DIR}/dist"
python3 -m http.server "${PORT}" &
SERVER_PID=$!
echo "${SERVER_PID}" > "${PID_FILE}"
trap 'kill "${SERVER_PID}" 2>/dev/null || true; rm -f "${PID_FILE}"; exit 0' INT TERM
wait "${SERVER_PID}"
rm -f "${PID_FILE}"
