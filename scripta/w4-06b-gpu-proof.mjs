#!/usr/bin/env node

/**
 * W4-06b Unit 2 — Headless Chrome GPU Proof Script
 *
 * Exercises real WebGPU matmul+add execution via headless Chrome with
 * SwiftShader.  Uses hand-authored inline WGSL mirroring the
 * tiny-linear-device exemplar — the faber compiler does not emit WGSL
 * device code.  Serves a proof page, launches headless Chrome via
 * Puppeteer, captures the console proof result, compares against the
 * stepper reference, and reports pass/fail.
 *
 * Usage:
 *   node triga/scripta/w4-06b-gpu-proof.mjs
 *
 * Dependencies:
 *   - Node.js >= 18
 *   - puppeteer (npm, installed via triga/package.json)
 *   - A browser cache with Chrome for Testing >= 120
 *     (puppeteer installs this automatically)
 *   - WebGPU support via --enable-unsafe-swiftshader (no GPU required)
 *
 * Exit codes:
 *   0 — proof passed (matmul+add result matches stepper reference)
 *   1 — proof failed (result mismatch or runtime error)
 *   2 — environment error (missing dependencies, Chrome unavailable)
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
const PORT = 8787;
const BASE_URL = `http://127.0.0.1:${PORT}`;
const TIMEOUT_MS = 60_000;

// ── Files to serve ────────────────────────────────────────────────────────
// The proof page loads app-matmul.mjs, which imports artifact-admission.js
// (contract) and webgpu-runtime.js (backend) from the same origin.

const STATIC_ROUTES = [
  "/",
  "/index.html",
  "/matmul-proof.html",
  "/src/app-matmul.mjs",
  "/src/contract/artifact-admission.js",
  "/src/backend/webgpu-runtime.js",
];

// ── Helpers ───────────────────────────────────────────────────────────────

function mimeType(ext) {
  switch (ext) {
    case ".html": return "text/html; charset=utf-8";
    case ".mjs":
    case ".js":   return "application/javascript; charset=utf-8";
    case ".json": return "application/json";
    case ".wgsl": return "text/plain; charset=utf-8";
    case ".wasm": return "application/wasm";
    default:      return "application/octet-stream";
  }
}

function serveFile(res, filePath) {
  const ext = path.extname(filePath);
  const data = fs.readFileSync(filePath);
  res.writeHead(200, { "Content-Type": mimeType(ext) });
  res.end(data);
}

function notFound(res) {
  res.writeHead(404);
  res.end("Not found");
}

/**
 * Start a minimal HTTP server serving the webgpu-browser public directory.
 * Returns { server, url }.
 */
function startServer() {
  return new Promise((resolve, reject) => {
    const server = http.createServer((req, res) => {
      const norm = req.url === "/" ? "/index.html" : req.url;
      const filePath = path.join(PUBLIC_DIR, norm);

      // Prevent path traversal
      if (!filePath.startsWith(PUBLIC_DIR)) {
        notFound(res);
        return;
      }

      try {
        if (fs.statSync(filePath).isFile()) {
          serveFile(res, filePath);
        } else {
          notFound(res);
        }
      } catch {
        notFound(res);
      }
    });

    server.listen(PORT, "127.0.0.1", () => {
      resolve({ server, url: BASE_URL });
    });
    server.on("error", reject);
  });
}

/**
 * Capture the FABER_MATMUL_PROOF console message from a headless page.
 * Returns the parsed proof object or null on timeout.
 */
async function captureProof(page) {
  return new Promise((resolve, reject) => {
    const timeout = setTimeout(() => {
      resolve(null);
    }, TIMEOUT_MS);

    page.on("console", (msg) => {
      const text = msg.text();
      const prefix = "FABER_MATMUL_PROOF:";
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
  console.log("W4-06b GPU Proof: starting");

  // 1. Verify dependencies
  const chromePath = await puppeteer.executablePath();
  if (!chromePath || !fs.existsSync(String(chromePath))) {
    console.error("W4-06b GPU Proof FAILED: Chrome not found at", chromePath);
    console.error("Run: npx puppeteer browsers install chrome");
    process.exit(2);
  }
  console.log("Chrome:", chromePath);

  // 2. Start HTTP server
  console.log("Starting HTTP server on", BASE_URL, "...");
  const { server } = await startServer();
  console.log("Server ready");

  // 3. Launch headless Chrome with SwiftShader WebGPU
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
      `--window-size=640,480`,
    ],
  });

  let exitCode = 2;
  try {
    const page = await browser.newPage();

    // Suppress noisy console (we only care about FABER_MATMUL_PROOF)
    page.on("console", () => {});

    // 4. Capture proof
    console.log("Navigating to matmul proof page ...");
    const proofPromise = captureProof(page);
    await page.goto(`${BASE_URL}/matmul-proof.html`, {
      waitUntil: "networkidle0",
      timeout: TIMEOUT_MS,
    });

    // 5. Wait for proof result
    const proof = await proofPromise;

    // 6. Assert and report
    if (!proof) {
      console.error("W4-06b GPU Proof FAILED: timeout waiting for proof result");
      exitCode = 1;
    } else if (proof.ok !== true) {
      console.error("W4-06b GPU Proof FAILED:", proof.error || proof.kind);
      console.error("Proof:", JSON.stringify(proof, null, 2));
      exitCode = 1;
    } else {
      console.log("W4-06b GPU Proof PASSED");
      console.log("  ok:", proof.ok);
      console.log("  status:", proof.status);
      console.log("  entry:", proof.entryName);
      console.log("  values:", JSON.stringify(Array.from(proof.values)));
      console.log("  expected matches:", JSON.stringify(proof.expected));
      exitCode = 0;
    }
  } catch (err) {
    console.error("W4-06b GPU Proof FAILED with exception:", err.message);
    exitCode = 1;
  } finally {
    await browser.close();
    server.close();
  }

  console.log(`W4-06b GPU Proof: exiting with code ${exitCode}`);
  process.exit(exitCode);
}

main().catch((err) => {
  console.error("W4-06b GPU Proof FATAL:", err.message);
  process.exit(2);
});
