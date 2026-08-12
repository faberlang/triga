#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
WORKSPACE="$(cd "$APP_DIR/../../.." && pwd)"
HOST_DIR="$(cd "$WORKSPACE/hosts/webgpu-browser" && pwd)"

for candidate in \
  "${FABER:-}" \
  "$WORKSPACE/faber/target/debug/faber" \
  "${HOME}/.cache/faberlang-target/faber/debug/faber"
do
  if [[ -n "$candidate" && -x "$candidate" ]]; then
    FABER_BIN="$candidate"
    break
  fi
done

if [[ -z "${FABER_BIN:-}" ]]; then
  echo "triga-corpus-terrain: no faber binary found" >&2
  exit 1
fi

# Materialize shared host assets (single source of truth: hosts/webgpu-browser).
# public/src/{product,contract,engine,backend,presentation} is the engine JS
# surface the page imports; triga-lit.wgsl + triga-lit-reflection.json come
# from hosts public/generated and land in the runtime public/ dir (the engine
# fetches them relative to its module) and the build's shader source.
rm -rf "$APP_DIR/public" "$APP_DIR/src/shaders" "$APP_DIR/dist"
mkdir -p "$APP_DIR/public/src" "$APP_DIR/src/shaders/test-data"
cp -R "$HOST_DIR/public/src/product" "$HOST_DIR/public/src/contract" "$HOST_DIR/public/src/engine" "$HOST_DIR/public/src/backend" "$HOST_DIR/public/src/presentation" "$APP_DIR/public/src/"
cp "$HOST_DIR/public/generated/triga-lit.wgsl" "$HOST_DIR/public/generated/triga-lit-reflection.json" "$APP_DIR/public/"
# faber's [product.shaders] contract reads kernel.wgsl/reflection.json from the
# source dir; triga-lit.* are the runtime-fetch names in public/.
cp "$HOST_DIR/public/generated/triga-lit.wgsl" "$APP_DIR/src/shaders/test-data/kernel.wgsl"
cp "$HOST_DIR/public/generated/triga-lit-reflection.json" "$APP_DIR/src/shaders/test-data/reflection.json"

cat > "$APP_DIR/faber.lock" <<LOCK

[[package]]
name = "tela"
version = "0.1.0"
source = "path"
package_root = "$WORKSPACE/tela"
kind = "lib"
target_language = "ts"
target_triple = "browser"
target_manifest = ""
interface_root = "$WORKSPACE/tela/src"
artifact = ""
crate = "tela"
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
  "$APP_DIR/src/terrain.fab" \
  "$APP_DIR/src/camera_controls.fab" \
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
grep -q '"selector": "#triga-corpus-terrain"' "$APP_DIR/dist/controllers.json"
test -f "$APP_DIR/dist/public/src/product/bootstrap.js"
test -f "$APP_DIR/dist/public/src/engine/engine.js"
test -f "$APP_DIR/dist/public/src/backend/webgpu-runtime.js"
test -f "$APP_DIR/dist/public/triga-lit.wgsl"
test -f "$APP_DIR/dist/public/triga-lit-reflection.json"

# The old flat host names are dissolved (moved into public/src/* lanes); assert
# they are absent from the generated dist/public/ copy.
for stale in host-init.js greybox-host.js webgpu-runtime.js kernel.wgsl reflection.json; do
  if [ -e "$APP_DIR/dist/public/$stale" ]; then
    echo "triga-corpus-terrain: stale flat host file $stale present in dist/public" >&2
    exit 1
  fi
done

node -e "
const fs = require('fs');
const bootstrap = fs.readFileSync('$APP_DIR/public/src/product/bootstrap.js', 'utf8');
const scheduler = fs.readFileSync('$APP_DIR/public/src/engine/frame-scheduler.js', 'utf8');
const canvas = fs.readFileSync('$APP_DIR/public/src/presentation/canvas.js', 'utf8');
const overlay = fs.readFileSync('$APP_DIR/public/src/presentation/debug-overlay.js', 'utf8');
const engine = fs.readFileSync('$APP_DIR/public/src/engine/engine.js', 'utf8');
const page = fs.readFileSync('$APP_DIR/pages/index.html', 'utf8');
const checks = [
  bootstrap.includes('initEngine'),
  scheduler.includes('requestAnimationFrame'),
  canvas.includes('.triga-canvas'),
  overlay.includes('.triga-facts'),
  engine.includes('renderGreyboxSceneFrame'),
  page.includes('mountControllers'),
  page.includes('triga-canvas'),
  page.includes('triga-facts'),
];
if (!checks.every(Boolean)) process.exit(1);
"

echo "triga-corpus-terrain checks ok"
