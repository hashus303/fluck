"""Fluck web build'ini HTTPS üzerinden LAN'a servis eder.
iOS Safari'de GPS ve kamera için güvenli bağlam (HTTPS) gerekir.
Çalıştır: python serve_https.py   ->  https://<LAN-IP>:8443
"""
import http.server
import os
import ssl

ROOT = os.path.dirname(os.path.abspath(__file__))
WEB_DIR = os.path.join(ROOT, "build", "web")
CERT = os.path.join(ROOT, "certs", "cert.pem")
KEY = os.path.join(ROOT, "certs", "key.pem")
PORT = 8443


class Handler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=WEB_DIR, **kwargs)

    def end_headers(self):
        # Servis çalışanı/önbellek kapalı kalsın (her zaman taze build).
        self.send_header("Cache-Control", "no-store")
        super().end_headers()


ctx = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
ctx.load_cert_chain(certfile=CERT, keyfile=KEY)

httpd = http.server.ThreadingHTTPServer(("0.0.0.0", PORT), Handler)
httpd.socket = ctx.wrap_socket(httpd.socket, server_side=True)
print(f"Serving {WEB_DIR} at https://0.0.0.0:{PORT}")
httpd.serve_forever()
