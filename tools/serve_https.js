#!/usr/bin/env node
/**
 * Fluck web build'ini HTTPS üzerinden LAN'a servis eder (Python alternatifi).
 * iOS Safari'de GPS ve kamera için güvenli bağlam (HTTPS) gerekir.
 *
 * Çalıştır:  node tools/serve_https.js   ->  https://<LAN-IP>:8443
 *
 * Not: certs/ altındaki self-signed sertifikayı kullanır; Safari "güvenli
 * değil" uyarısı gösterir → "Ayrıntılar → siteyi ziyaret et" ile geçilir.
 */
const fs = require('fs');
const path = require('path');
const https = require('https');
const http = require('http');

const ROOT = path.resolve(__dirname, '..');
const WEB_DIR = path.join(ROOT, 'build', 'web');
const CERT = path.join(ROOT, 'certs', 'cert.pem');
const KEY = path.join(ROOT, 'certs', 'key.pem');
// HTTP=1 → masaüstü doğrulaması için localhost'ta düz HTTP (secure context).
const USE_HTTP = process.env.HTTP === '1';
const PORT = USE_HTTP ? 8080 : 8443;

const MIME = {
  '.html': 'text/html; charset=utf-8',
  '.js': 'text/javascript',
  '.mjs': 'text/javascript',
  '.json': 'application/json',
  '.wasm': 'application/wasm',
  '.css': 'text/css',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.jpeg': 'image/jpeg',
  '.svg': 'image/svg+xml',
  '.ico': 'image/x-icon',
  '.ttf': 'font/ttf',
  '.otf': 'font/otf',
  '.woff': 'font/woff',
  '.woff2': 'font/woff2',
  '.bin': 'application/octet-stream',
  '.map': 'application/json',
};

function send(res, status, body, type) {
  res.writeHead(status, {
    'Content-Type': type || 'text/plain',
    'Cache-Control': 'no-store',
    'Access-Control-Allow-Origin': '*',
  });
  res.end(body);
}

const handler = (req, res) => {
    let urlPath = decodeURIComponent(req.url.split('?')[0]);
    if (urlPath === '/') urlPath = '/index.html';
    // Dizin dışına çıkışı engelle
    const filePath = path.join(WEB_DIR, path.normalize(urlPath));
    if (!filePath.startsWith(WEB_DIR)) return send(res, 403, 'forbidden');

    fs.readFile(filePath, (err, data) => {
      if (err) {
        // SPA geri düşüşü: uzantısız yollar index.html'e
        if (!path.extname(urlPath)) {
          return fs.readFile(path.join(WEB_DIR, 'index.html'), (e2, idx) =>
            e2 ? send(res, 404, 'not found') : send(res, 200, idx, MIME['.html']));
        }
        return send(res, 404, 'not found');
      }
      send(res, 200, data, MIME[path.extname(filePath).toLowerCase()] || 'application/octet-stream');
    });
};

if (!fs.existsSync(WEB_DIR)) {
  console.error(`Web build yok: ${WEB_DIR}\nÖnce: flutter build web --release --dart-define=MAPTILER_KEY=...`);
  process.exit(1);
}

if (USE_HTTP) {
  http.createServer(handler).listen(PORT, '127.0.0.1', () =>
    console.log(`(HTTP doğrulama) http://127.0.0.1:${PORT}`));
} else {
  https
    .createServer({ cert: fs.readFileSync(CERT), key: fs.readFileSync(KEY) }, handler)
    .listen(PORT, '0.0.0.0', () =>
      console.log(`Serving ${WEB_DIR}\n  https://<LAN-IP>:${PORT}  (bu makine: https://192.168.1.130:${PORT})`));
}
