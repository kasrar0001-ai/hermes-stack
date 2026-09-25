#!/usr/bin/env bash
# Caddy front proxy — public port 7860 (Hugging Face requirement)
set -e
exec /usr/local/bin/caddy run --config /etc/caddy/Caddyfile --adapter caddyfile
