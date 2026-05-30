#!/usr/bin/env python3
"""
Mock HTTP server для тестирования aapanel_api.sh.
Принимает POST запросы, логирует их, возвращает mock JSON.

Использование:
  python3 tests/mock_server.py <port> <log_file>
"""
import json
import sys
import time
from http.server import BaseHTTPRequestHandler, HTTPServer
from urllib.parse import parse_qs, urlparse

received_requests = []


class MockHandler(BaseHTTPRequestHandler):
    def do_POST(self):
        length = int(self.headers.get('Content-Length', 0))
        body = self.rfile.read(length).decode('utf-8')
        params = parse_qs(body)

        req = {
            'path': self.path,
            'content_type': self.headers.get('Content-Type', ''),
            'params': {k: v[0] for k, v in params.items()},
        }
        received_requests.append(req)

        # Сбросить в лог-файл при каждом запросе
        if log_file:
            with open(log_file, 'w') as f:
                json.dump(received_requests, f)

        self.send_response(200)
        self.send_header('Content-Type', 'application/json')
        self.end_headers()
        self.wfile.write(json.dumps({'status': True, 'msg': 'mock ok'}).encode())

    def log_message(self, *args):
        pass  # тихий режим


if __name__ == '__main__':
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 19876
    log_file = sys.argv[2] if len(sys.argv) > 2 else None

    server = HTTPServer(('127.0.0.1', port), MockHandler)
    sys.stdout.write(f'READY:{port}\n')
    sys.stdout.flush()
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
