#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
HOST_DIR="$(cd "$APP_DIR/../_host" && pwd)"
WORKSPACE="$(cd "$APP_DIR/../../.." && pwd)"

for candidate in \
  "${FABER:-}" \
  "${HOME}/.cache/faberlang-target/faber/debug/faber" \
  "$WORKSPACE/faber/target/debug/faber"
do
  if [[ -n "$candidate" && -x "$candidate" ]]; then
    FABER_BIN="$candidate"
    break
  fi
done

if [[ -z "${FABER_BIN:-}" ]]; then
  echo "triga-corpus-geometries: no faber binary found" >&2
  exit 1
fi

# Materialize shared host assets (single source of truth: corpus/_host).
# _host/public is the JS transport only; kernel.wgsl + reflection.json come
# from _host/shaders and land in the runtime public/ dir (the host fetches
# them relative to greybox-host.js) and the build's shader source.
rm -rf "$APP_DIR/public" "$APP_DIR/src/shaders"
cp -R "$HOST_DIR/public" "$APP_DIR/public"
mkdir -p "$APP_DIR/public" "$APP_DIR/src/shaders/test-data"
cp "$HOST_DIR/shaders/kernel.wgsl" "$HOST_DIR/shaders/reflection.json" "$APP_DIR/public/"
cp "$HOST_DIR/shaders/kernel.wgsl" "$HOST_DIR/shaders/reflection.json" "$APP_DIR/src/shaders/test-data/"

cat > "$APP_DIR/faber.lock" <<LOCK

[[package]]
name = "web"
version = "0.1.0"
source = "path"
package_root = "$WORKSPACE/faber-web"
kind = "lib"
target_language = "ts"
target_triple = "browser"
target_manifest = ""
interface_root = "$WORKSPACE/faber-web/src"
artifact = ""
crate = "web"
rustc = ""

[[package]]
name = "triga"
version = "0.1.0"
source = "path"
package_root = "$WORKSPACE/triga"
kind = "lib"
target_language = "ts"
target_triple = "browser"
target_manifest = ""
interface_root = "$WORKSPACE/triga/src"
artifact = ""
crate = "triga"
rustc = ""
LOCK

for source in \
  "$APP_DIR/src/shapes.fab" \
  "$APP_DIR/src/camera.fab" \
  "$APP_DIR/src/scene.fab" \
  "$APP_DIR/src/main.fab"
do
  echo "checking ${source#$APP_DIR/}"
  "$FABER_BIN" check "$source"
done

echo "building browser package"
(
  cd "$APP_DIR"
  "$FABER_BIN" build --package .
)

test -f "$APP_DIR/dist/faber-esm/faber-browser.js"
test -f "$APP_DIR/dist/controllers.json"
grep -q '"selector": "#triga-corpus-geometries"' "$APP_DIR/dist/controllers.json"
test -f "$APP_DIR/dist/public/host-init.js"
test -f "$APP_DIR/dist/public/greybox-host.js"
test -f "$APP_DIR/dist/public/webgpu-runtime.js"
test -f "$APP_DIR/dist/public/kernel.wgsl"
test -f "$APP_DIR/dist/public/reflection.json"

node -e "
const fs = require('fs');
const host = fs.readFileSync('$APP_DIR/public/host-init.js', 'utf8');
const page = fs.readFileSync('$APP_DIR/pages/index.html', 'utf8');
const checks = [
  host.includes('.triga-canvas'),
  host.includes('.triga-facts'),
  host.includes('renderGreyboxSceneFrame'),
  host.includes('requestAnimationFrame'),
  page.includes('mountControllers'),
  page.includes('triga-canvas'),
  page.includes('triga-facts'),
];
if (!checks.every(Boolean)) process.exit(1);
"

echo "triga-corpus-geometries checks ok"
