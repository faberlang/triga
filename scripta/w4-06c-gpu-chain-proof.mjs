#!/usr/bin/env node

/**
 * W4-06c — Headless Chrome GPU Chain Dispatch Proof
 *
 * Reads a G-SPINE-10 KernelChainDescriptor JSON, serves a dynamic proof page
 * that imports webgpu-runtime.js and dispatches the chain through
 * dispatchChainFromDescriptor (S3, hosts 735df10), reads back the output, and
 * asserts a bit-identical match against the expected stepper values within
 * f32 tolerance.
 *
 * The chain descriptor is compiler-emitted (radix-mir-wgsl emit_chain_descriptor,
 * G-SPINE-10 S1/S2). Each chain entry carries its own WGSL source string, so
 * the proof page does not need a separate --wgsl argument.
 *
 * Usage:
 *   node triga/scripta/w4-06c-gpu-chain-proof.mjs \
 *     --descriptor ./chain-descriptor.json \
 *     --input '{"0":[1,1,1,2,2,2,3,3,3,4,4,4],"1":[1,2,3,4,5,6],"3":[0.1,0.2,0.1,0.2,0.1,0.2,0.1,0.2]}' \
 *     --expected '[9.1,12.2,18.1,24.2,27.1,36.2,36.1,48.2]' \
 *     [--tolerance 0.00001]
 *
 * Dependencies:
 *   - Node.js >= 18
 *   - puppeteer (npm, installed via triga/package.json)
 *   - Chrome for Testing >= 120 with WebGPU via --enable-unsafe-swiftshader
 *
 * Exit codes:
 *   0 — proof passed (chain dispatch output matches expected values)
 *   1 — proof failed (result mismatch or runtime error)
 *   2 — environment error (missing arguments/dependencies, Chrome unavailable)
 */

import http from "node:http";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import puppeteer from "puppeteer";

// ── Constants ─────────────────────────────────────────────────────────────

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const PROJECT_ROOT = path.resolve(__dirname, "../..");
const HOSTS_ROOT = path.resolve(PROJECT_ROOT, "hosts/webgpu-browser");
const PUBLIC_DIR = path.resolve(HOSTS_ROOT, "public");
const PORT = 8789;
const BASE_URL = `http://127.0.0.1:${PORT}`;
const TIMEOUT_MS = 60_000;
const DEFAULT_TOLERANCE = 0.00001;

// ── Argument parsing ──────────────────────────────────────────────────────

function parseArgs() {
  const args = process.argv.slice(2);
  const opts = {};

  for (let i = 0; i < args.length; i++) {
    switch (args[i]) {
      case "--descriptor":
        opts.descriptorPath = args[++i];
        break;
      case "--input":
        opts.inputJson = args[++i];
        break;
      case "--expected":
        opts.expectedJson = args[++i];
        break;
      case "--tolerance":
        opts.tolerance = Number(args[++i]);
        break;
      case "--help":
      case "-h":
        printUsage();
        process.exit(0);
      default:
        console.error(`unknown option: ${args[i]}`);
        printUsage();
        process.exit(2);
    }
  }

  if (!opts.descriptorPath) {
    console.error("error: --descriptor <path> is required");
    printUsage();
    process.exit(2);
  }
  if (!opts.expectedJson) {
    console.error("error: --expected <json> is required");
    printUsage();
    process.exit(2);
  }
  if (opts.tolerance !== undefined && !Number.isFinite(opts.tolerance)) {
    console.error("error: --tolerance must be a finite number");
    process.exit(2);
  }

  return opts;
}

function printUsage() {
  console.log(`
Usage: node w4-06c-gpu-chain-proof.mjs [options]

Options:
  --descriptor <path>      Path to KernelChainDescriptor JSON (required)
  --input <json>           Input data as JSON object mapping resource key to
                           value array, e.g. '{"0":[1,2,3],"1":[4,5,6]}'
  --expected <json>        Expected output values as JSON array (required)
  --tolerance <float>      f32 comparison tolerance (default 0.00001)
  --help, -h               Show this help
`);
}

// ── Server ────────────────────────────────────────────────────────────────

function mimeType(ext) {
  switch (ext) {
    case ".html": return "text/html; charset=utf-8";
    case ".mjs":
    case ".js":   return "application/javascript; charset=utf-8";
    case ".json": return "application/json";
    case ".wgsl": return "text/plain; charset=utf-8";
    default:      return "application/octet-stream";
  }
}

function startServer() {
  return new Promise((resolve, reject) => {
    const server = http.createServer((req, res) => {
      const norm = req.url === "/" ? "/index.html" : req.url;

      // Serve the dynamic proof page at /chain-proof.html.
      if (req.url === "/chain-proof.html") {
        serveProofPage(res);
        return;
      }

      const filePath = path.join(PUBLIC_DIR, norm);
      if (!filePath.startsWith(PUBLIC_DIR)) {
        res.writeHead(404);
        res.end("Not found");
        return;
      }
      try {
        if (fs.statSync(filePath).isFile()) {
          const ext = path.extname(filePath);
          const data = fs.readFileSync(filePath);
          res.writeHead(200, { "Content-Type": mimeType(ext) });
          res.end(data);
        } else {
          res.writeHead(404);
          res.end("Not found");
        }
      } catch {
        res.writeHead(404);
        res.end("Not found");
      }
    });

    server.listen(PORT, "127.0.0.1", () => {
      resolve({ server, url: BASE_URL });
    });
    server.on("error", reject);
  });
}

// ── Proof page generation ─────────────────────────────────────────────────

let _chainDescriptor = null;
let _inputData = null;
let _expectedValues = null;
let _tolerance = DEFAULT_TOLERANCE;

function setProofData(descriptor, input, expected, tolerance) {
  _chainDescriptor = descriptor;
  _inputData = input;
  _expectedValues = expected;
  _tolerance = tolerance;
}

function serveProofPage(res) {
  const descriptorJson = JSON.stringify(_chainDescriptor);
  const inputDataJson = _inputData
    ? JSON.stringify([..._inputData.entries()])
    : "null";
  const expectedJson = JSON.stringify(_expectedValues);
  const toleranceJson = JSON.stringify(_tolerance);

  const html = `<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Chain Dispatch Proof</title>
</head>
<body>
<h1>Chain Dispatch Proof</h1>
<pre id="proof-output">pending</pre>
<script type="module">
import {
  acquireWebGpuDevice,
  dispatchChainFromDescriptor,
} from "./src/webgpu-runtime.js";
import { FaberKernelContractError } from "./src/faber-kernel.js";

// ── Embedded chain descriptor + input data ────────────────────────────
const CHAIN_DESCRIPTOR = ${descriptorJson};
const INPUT_DATA = ${inputDataJson};
const EXPECTED_VALUES = ${expectedJson};
const TOLERANCE = ${toleranceJson};

window.faberChainProof = { ok: false, status: "starting" };

main().catch((error) => {
  const proof = proofFailure(error);
  window.faberChainProof = proof;
  console.log("FABER_CHAIN_PROOF:", JSON.stringify(proof));
});

async function main() {
  const { device } = await acquireWebGpuDevice();

  // Build resources.buffers from the input data map. Keying follows the
  // descriptor's storage-buffer @binding namespace (dispatchChainFromDescriptor
  // resolves resources by bufDecl.binding).
  const buffers = new Map();
  const STORAGE = GPUBufferUsage.STORAGE | GPUBufferUsage.COPY_DST | GPUBufferUsage.COPY_SRC;
  for (const [key, values] of (INPUT_DATA || new Map())) {
    const data = new Float32Array(values);
    const buffer = device.createBuffer({
      size: data.byteLength,
      usage: STORAGE,
    });
    device.queue.writeBuffer(buffer, 0, data);
    buffers.set(Number(key), { buffer });
  }
  const resources = { buffers };

  // Dispatch the chain through the S3 descriptor shim. runKernelChain reads
  // back every kernel's outputBindings in chain order.
  const { results } = await dispatchChainFromDescriptor(device, resources, CHAIN_DESCRIPTOR);

  // The final kernel's readback is the chain result.
  const finalValues = Array.from(results[results.length - 1].values);

  // ── Compare against expected values within f32 tolerance ────────────
  let ok = true;
  const failures = [];
  for (let i = 0; i < EXPECTED_VALUES.length; i++) {
    const diff = Math.abs(finalValues[i] - EXPECTED_VALUES[i]);
    if (diff > TOLERANCE) {
      ok = false;
      failures.push(
        \`[$\{i}]: expected \${EXPECTED_VALUES[i]}, got \${finalValues[i]} (diff \${diff})\`,
      );
    }
  }

  if (!ok) {
    throw new FaberKernelContractError(
      "readback",
      "chain dispatch result mismatch:\\n  " + failures.join("\\n  "),
      "product",
    );
  }

  window.faberChainProof = {
    ok: true,
    status: "ready",
    kind: "ok",
    kernelCount: CHAIN_DESCRIPTOR.chain.length,
    values: finalValues,
    expected: EXPECTED_VALUES,
    tolerance: TOLERANCE,
  };

  console.log("FABER_CHAIN_PROOF:", JSON.stringify(window.faberChainProof));
}

function proofFailure(error) {
  const kind =
    error instanceof FaberKernelContractError
      ? error.kind
      : typeof error?.kind === "string"
        ? error.kind
        : "product";
  return {
    ok: false,
    status: "error",
    kind,
    path: error?.path ?? null,
    error: error?.message ?? String(error),
  };
}
</script>
</body>
</html>`;

  const buf = Buffer.from(html, "utf-8");
  res.writeHead(200, {
    "Content-Type": "text/html; charset=utf-8",
    "Content-Length": buf.length,
  });
  res.end(buf);
}

// ── Proof capture ────────────────────────────────────────────────────────

async function captureProof(page) {
  return new Promise((resolve, reject) => {
    const timeout = setTimeout(() => {
      resolve(null);
    }, TIMEOUT_MS);

    page.on("console", (msg) => {
      const text = msg.text();
      const prefix = "FABER_CHAIN_PROOF:";
      if (text.startsWith(prefix)) {
        clearTimeout(timeout);
        try {
          resolve(JSON.parse(text.slice(prefix.length)));
        } catch {
          resolve(null);
        }
      }
    });

    page.on("pageerror", (err) => {
      clearTimeout(timeout);
      reject(err);
    });
  });
}

// ── Main ──────────────────────────────────────────────────────────────────

async function main() {
  const opts = parseArgs();
  console.log("W4-06c Chain Proof: starting");

  // 1. Read the chain descriptor JSON.
  const descriptorPath = path.resolve(opts.descriptorPath);
  let descriptor;
  try {
    descriptor = JSON.parse(fs.readFileSync(descriptorPath, "utf-8"));
  } catch (e) {
    console.error("error: cannot read/invalid descriptor JSON:", e.message);
    process.exit(2);
  }
  if (!descriptor || !Array.isArray(descriptor.chain) || descriptor.chain.length === 0) {
    console.error("error: descriptor.chain must be a non-empty array");
    process.exit(2);
  }
  console.log(`Descriptor: ${descriptorPath} (kernels: ${descriptor.chain.length})`);

  // 2. Parse input data (kept as plain arrays so JSON round-trips through
  //    the embedded page payload; the page rebuilds Float32Array views).
  let inputData = null;
  if (opts.inputJson) {
    try {
      const parsed = JSON.parse(opts.inputJson);
      inputData = new Map();
      for (const [key, values] of Object.entries(parsed)) {
        inputData.set(Number(key), values);
      }
    } catch (e) {
      console.error("error: invalid input JSON:", e.message);
      process.exit(2);
    }
  }

  // 3. Parse expected values.
  let expectedValues;
  try {
    expectedValues = JSON.parse(opts.expectedJson);
  } catch (e) {
    console.error("error: invalid expected JSON:", e.message);
    process.exit(2);
  }

  // 4. Inject proof data.
  setProofData(descriptor, inputData, expectedValues, opts.tolerance ?? DEFAULT_TOLERANCE);

  // 5. Verify dependencies.
  const chromePath = await puppeteer.executablePath();
  if (!chromePath || !fs.existsSync(String(chromePath))) {
    console.error("W4-06c Chain Proof FAILED: Chrome not found at", chromePath);
    console.error("Run: npx puppeteer browsers install chrome");
    process.exit(2);
  }
  console.log("Chrome:", chromePath);

  // 6. Start HTTP server.
  console.log("Starting HTTP server on", BASE_URL, "...");
  const { server } = await startServer();
  console.log("Server ready");

  // 7. Launch headless Chrome with SwiftShader WebGPU.
  console.log("Launching headless Chrome ...");
  const browser = await puppeteer.launch({
    executablePath: chromePath,
    headless: "new",
    args: [
      "--headless=new",
      "--no-sandbox",
      "--enable-unsafe-swiftshader",
      "--enable-webgpu",
      "--enable-features=Vulkan,UseSkiaRenderer,WebGPU",
      "--window-size=640,480",
    ],
  });

  let exitCode = 2;
  try {
    const page = await browser.newPage();
    // Suppress noisy console (we only care about FABER_CHAIN_PROOF).
    page.on("console", () => {});

    // 8. Capture proof.
    console.log("Navigating to chain proof page ...");
    const proofPromise = captureProof(page);
    await page.goto(`${BASE_URL}/chain-proof.html`, {
      waitUntil: "networkidle0",
      timeout: TIMEOUT_MS,
    });

    // 9. Wait for proof result.
    const proof = await proofPromise;

    // 10. Assert and report.
    if (!proof) {
      console.error("W4-06c Chain Proof FAILED: timeout waiting for proof result");
      exitCode = 1;
    } else if (proof.ok !== true) {
      console.error("W4-06c Chain Proof FAILED:", proof.error || proof.kind);
      console.error("Proof:", JSON.stringify(proof, null, 2));
      exitCode = 1;
    } else {
      console.log("W4-06c Chain Proof PASSED");
      console.log("  ok:", proof.ok);
      console.log("  kernels:", proof.kernelCount);
      console.log("  values:", JSON.stringify(proof.values));
      console.log("  expected:", JSON.stringify(proof.expected));
      console.log("  tolerance:", proof.tolerance);
      exitCode = 0;
    }
  } catch (err) {
    console.error("W4-06c Chain Proof FAILED with exception:", err.message);
    exitCode = 1;
  } finally {
    await browser.close();
    server.close();
  }

  console.log(`W4-06c Chain Proof: exiting with code ${exitCode}`);
  process.exit(exitCode);
}

main().catch((err) => {
  console.error("W4-06c Chain Proof FATAL:", err.message);
  process.exit(2);
});
