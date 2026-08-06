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
  echo "triga-corpus-animation-orbit: no faber binary found" >&2
  exit 1
fi

rm -rf "$APP_DIR/public" "$APP_DIR/src/shaders" "$APP_DIR/dist"
mkdir -p "$APP_DIR/public/src" "$APP_DIR/src/shaders/test-data"
cp -R "$HOST_DIR/public/src/product" "$HOST_DIR/public/src/contract" "$HOST_DIR/public/src/engine" "$HOST_DIR/public/src/backend" "$HOST_DIR/public/src/presentation" "$APP_DIR/public/src/"
# The shared engine fetches the runtime names `triga-lit.*`, while the current
# host generator publishes the admitted graphics contract as `graphics.*`.
# Keep this adapter inside the Triga corpus package until the host-owned names
# and the 36-byte interleaved scene layout are reconciled.
cp "$APP_DIR/assets/orbit.wgsl" "$APP_DIR/public/triga-lit.wgsl"
cp "$APP_DIR/assets/orbit.wgsl" "$APP_DIR/src/shaders/test-data/kernel.wgsl"
node "$SCRIPT_DIR/adapt-graphics-reflection.mjs" \
  "$HOST_DIR/public/generated/graphics-reflection.json" \
  "$APP_DIR/public/triga-lit-reflection.json"
cp "$APP_DIR/public/triga-lit-reflection.json" "$APP_DIR/src/shaders/test-data/reflection.json"

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

echo "checking src/main.fab"
"$FABER_BIN" check "$APP_DIR/src/main.fab"

echo "building browser package"
(
  cd "$APP_DIR"
  "$FABER_BIN" build --package .
)

test -f "$APP_DIR/dist/faber-esm/faber-browser.js"
test -f "$APP_DIR/dist/controllers.json"
grep -q '"selector": "#triga-corpus-animation-orbit"' "$APP_DIR/dist/controllers.json"
test -f "$APP_DIR/dist/public/src/product/bootstrap.js"
test -f "$APP_DIR/dist/public/src/engine/engine.js"
test -f "$APP_DIR/dist/public/src/backend/webgpu-runtime.js"
test -f "$APP_DIR/dist/public/triga-lit.wgsl"
test -f "$APP_DIR/dist/public/triga-lit-reflection.json"
grep -q 'fn triga_orbit_vertex' "$APP_DIR/dist/public/triga-lit.wgsl"

node -e "
const fs = require('fs');
const reflection = JSON.parse(fs.readFileSync('$APP_DIR/dist/public/triga-lit-reflection.json', 'utf8'));
if (reflection.schema_version !== 1 || reflection.target !== 'wgsl-text') process.exit(1);
const vertex = reflection.kernels.find((kernel) => kernel.shader_stage === 'vertex');
const fragment = reflection.kernels.find((kernel) => kernel.shader_stage === 'fragment');
if (!vertex || !fragment) process.exit(1);
if (vertex.entry_name !== 'triga_orbit_vertex' || fragment.entry_name !== 'triga_orbit_fragment') process.exit(1);
if (vertex.vertex_input_count !== 1 || vertex.vertex_inputs[0].stride_bytes !== 36) process.exit(1);
if (vertex.launch.webgpu_adapter.vertex_buffer_layout_descriptor_count !== 1) process.exit(1);
"

node -e "
const fs = require('fs');
const main = fs.readFileSync('$APP_DIR/src/main.fab', 'utf8');
const page = fs.readFileSync('$APP_DIR/pages/index.html', 'utf8');
const scheduler = fs.readFileSync('$APP_DIR/public/src/engine/frame-scheduler.js', 'utf8');
const checks = [
  main.includes('dom.on_frame'),
  main.includes('data-animation-seconds'),
  main.includes('data-transform-payload'),
  main.includes('math.euler(elapsed_seconds * 0.55, elapsed_seconds * 0.9, 0.0)'),
  page.includes('mountControllers'),
  scheduler.includes('requestAnimationFrame'),
];
if (!checks.every(Boolean)) process.exit(1);
"

echo "triga-corpus-animation-orbit checks ok"
