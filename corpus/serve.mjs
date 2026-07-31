// Triga corpus dev server — single entry point for all corpus demos.
//
//   /                          index page listing discovered demos
//   /<slug>/                   redirect target: <slug>/dist/pages/index.html
//   /<slug>/<path>             static file from <slug>/dist/<path>
//
// A directory counts as a demo when it contains dist/pages/index.html
// (build first: ./serve.sh without --no-build, or the demo's tests/run.sh).
// Underscore- and dot-prefixed dirs (e.g. _host) are never served.
//
// Usage: node serve.mjs   (PORT env, default 8780)
import { createServer } from "node:http";
import { readFile, readdir, stat } from "node:fs/promises";
import { fileURLToPath } from "node:url";
import { join, extname, normalize, sep } from "node:path";

const ROOT = fileURLToPath(new URL(".", import.meta.url));
const PORT = Number(process.env.PORT || 8780);

const TYPES = {
  ".html": "text/html; charset=utf-8",
  ".js": "text/javascript; charset=utf-8",
  ".mjs": "text/javascript; charset=utf-8",
  ".css": "text/css; charset=utf-8",
  ".json": "application/json; charset=utf-8",
  ".wgsl": "text/plain; charset=utf-8",
  ".ts": "text/plain; charset=utf-8",
  ".png": "image/png",
  ".svg": "image/svg+xml",
};

async function discoverDemos() {
  const entries = await readdir(ROOT, { withFileTypes: true });
  const demos = [];
  for (const entry of entries) {
    if (!entry.isDirectory()) continue;
    if (entry.name.startsWith("_") || entry.name.startsWith(".")) continue;
    try {
      await stat(join(ROOT, entry.name, "dist", "pages", "index.html"));
    } catch {
      continue;
    }
    let title = entry.name;
    let subtitle = "";
    try {
      const html = await readFile(join(ROOT, entry.name, "pages", "index.html"), "utf8");
      const titleMatch = html.match(/<title>([^<]+)<\/title>/);
      if (titleMatch) title = titleMatch[1].trim();
      const subMatch = html.match(/<div class="corpus-overlay">[\s\S]*?<p>([^<]+)<\/p>/);
      if (subMatch) subtitle = subMatch[1].trim();
    } catch {
      // keep slug as title
    }
    demos.push({ slug: entry.name, title, subtitle });
  }
  demos.sort((a, b) => a.slug.localeCompare(b.slug));
  return demos;
}

function indexPage(demos) {
  const items = demos
    .map(
      (d) => `        <li>
          <a href="/${d.slug}/">${d.title}</a>
          ${d.subtitle ? `<span class="sub">${d.subtitle}</span>` : ""}
          <span class="slug">${d.slug}</span>
        </li>`,
    )
    .join("\n");
  const empty = demos.length === 0
    ? '        <li class="empty">No built demos. Run <code>./serve.sh</code> (builds all) or a demo\'s <code>tests/run.sh</code>.</li>'
    : "";
  return `<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Triga corpus</title>
    <style>
      :root { color: #f4efe1; background: #101419; font-family: Inter, ui-sans-serif, system-ui, sans-serif; }
      body { margin: 0; min-height: 100vh; display: grid; place-items: center; }
      main { width: min(680px, 92vw); padding: 48px 0; }
      h1 { margin: 0 0 4px; font-size: 28px; }
      p.lede { margin: 0 0 28px; color: #d7ceb5; font-size: 14px; }
      ul { list-style: none; margin: 0; padding: 0; display: grid; gap: 10px; }
      li { border: 1px solid #2d3b45; border-radius: 8px; padding: 14px 16px; display: grid; gap: 2px; }
      li a { color: #9ecfff; font-size: 17px; text-decoration: none; font-weight: 600; }
      li a:hover { text-decoration: underline; }
      .sub { color: #d7ceb5; font-size: 13px; }
      .slug { color: #6d7d85; font-size: 12px; font-family: ui-monospace, monospace; }
      .empty { color: #d7ceb5; font-size: 14px; }
      code { color: #9ecfff; }
    </style>
  </head>
  <body>
    <main>
      <h1>Triga corpus</h1>
      <p class="lede">Browser demos recreating three.js examples on the triga / WebGPU path.</p>
      <ul>
${items}
${empty}
      </ul>
    </main>
  </body>
</html>
`;
}

const server = createServer(async (req, res) => {
  try {
    const url = new URL(req.url ?? "/", "http://localhost");
    const pathname = decodeURIComponent(url.pathname);

    if (pathname === "/" || pathname === "/index.html") {
      res.writeHead(200, { "Content-Type": "text/html; charset=utf-8", "Cache-Control": "no-store" });
      res.end(indexPage(await discoverDemos()));
      return;
    }

    const match = pathname.match(/^\/([A-Za-z0-9][A-Za-z0-9-]*)(\/.*)?$/);
    if (!match || match[1].startsWith("_")) {
      res.writeHead(404, { "Content-Type": "text/plain" });
      res.end(`not found: ${pathname}`);
      return;
    }

    const slug = match[1];
    const distRoot = join(ROOT, slug, "dist");
    let rest = match[2] ?? "/";
    if (rest === "/") {
      // Redirect rather than serving inline: relative imports inside the page
      // (../faber-esm, ../public, ../styles) must resolve against the real
      // document URL.
      res.writeHead(302, { Location: `/${slug}/pages/index.html` });
      res.end();
      return;
    }

    const filePath = normalize(join(distRoot, rest));
    if (filePath !== distRoot && !filePath.startsWith(distRoot + sep)) {
      res.writeHead(403, { "Content-Type": "text/plain" });
      res.end("forbidden");
      return;
    }

    try {
      const info = await stat(filePath);
      if (info.isDirectory()) {
        res.writeHead(404, { "Content-Type": "text/plain" });
        res.end(`not found: ${pathname}`);
        return;
      }
      const data = await readFile(filePath);
      res.writeHead(200, {
        "Content-Type": TYPES[extname(filePath)] ?? "application/octet-stream",
        "Cache-Control": "no-store",
      });
      res.end(data);
    } catch {
      res.writeHead(404, { "Content-Type": "text/plain" });
      res.end(`not found: ${pathname}`);
    }
  } catch (err) {
    res.writeHead(500, { "Content-Type": "text/plain" });
    res.end(`server error: ${err.message}`);
  }
});

server.listen(PORT, "127.0.0.1", () => {
  console.log(`triga corpus: http://127.0.0.1:${PORT}/`);
});
