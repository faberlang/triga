#!/usr/bin/env bash
set -euo pipefail

CORPUS_DIR="$(cd "$(dirname "$0")" && pwd)"
PORT="${PORT:-8780}"
DO_BUILD=1
PID_FILE="${CORPUS_DIR}/.serve.pid"

usage() {
  cat <<'EOF'
Build all corpus demos and serve them from a single entry point.

Usage:
  ./serve.sh                 # build every demo, then serve http://127.0.0.1:8780/
  ./serve.sh --no-build      # serve existing dist/ output
  ./serve.sh --port 9000
EOF
  exit "${1:-0}"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help) usage 0 ;;
    --port)
      PORT="${2:?--port requires a value}"
      shift 2
      ;;
    --no-build)
      DO_BUILD=0
      shift
      ;;
    *)
      echo "triga corpus serve: unknown arg: $1" >&2
      usage 1
      ;;
  esac
done

if [[ "${DO_BUILD}" -eq 1 ]]; then
  for demo in "${CORPUS_DIR}"/*/; do
    name="$(basename "$demo")"
    case "${name}" in _*|.*) continue ;; esac
    if [[ -x "${demo}tests/run.sh" ]]; then
      echo "== ${name} =="
      "${demo}tests/run.sh"
    fi
  done
fi

if [[ -f "${PID_FILE}" ]]; then
  old="$(cat "${PID_FILE}" 2>/dev/null || true)"
  if [[ -n "${old}" ]] && kill -0 "${old}" 2>/dev/null; then
    kill "${old}" 2>/dev/null || true
    wait "${old}" 2>/dev/null || true
  fi
  rm -f "${PID_FILE}"
fi
if command -v lsof >/dev/null 2>&1; then
  pids="$(lsof -tiTCP:"${PORT}" -sTCP:LISTEN 2>/dev/null || true)"
  if [[ -n "${pids}" ]]; then
    kill ${pids} 2>/dev/null || true
    sleep 0.2
  fi
fi

echo "serving corpus on http://127.0.0.1:${PORT}/"
cd "${CORPUS_DIR}"
PORT="${PORT}" node serve.mjs &
SERVER_PID=$!
echo "${SERVER_PID}" > "${PID_FILE}"
trap 'kill "${SERVER_PID}" 2>/dev/null || true; rm -f "${PID_FILE}"; exit 0' INT TERM
wait "${SERVER_PID}"
rm -f "${PID_FILE}"
