# syntax=docker/dockerfile:1
# ============================================================
#  Hermes Agent + 9Router + OmniRouter + Caddy — one HF Space
#  Base: official NousResearch hermes-agent image (s6-overlay)
# ============================================================

# ---- Stage 1: grab the ready-built 9Router app -------------
FROM decolua/9router:latest AS ninerouter

# ---- Stage 2: extend the official Hermes image -------------
FROM nousresearch/hermes-agent:latest

USER root

# 9Router (Next.js app served by `node custom-server.js`)
COPY --from=ninerouter /app /opt/9router

# Caddy as the front reverse-proxy on port 7860 (HF requirement)
# Pinned release first (reproducible), official download API as fallback.
RUN set -eux; \
    ( curl -fsSL --retry 3 --retry-all-errors -o /tmp/caddy.tgz \
        "https://github.com/caddyserver/caddy/releases/download/v2.10.0/caddy_2.10.0_linux_amd64.tar.gz" \
      && tar -xzf /tmp/caddy.tgz -C /tmp caddy && mv /tmp/caddy /usr/local/bin/caddy \
    ) || ( curl -fsSL --retry 3 --retry-all-errors -o /tmp/caddy.bin \
        "https://caddyserver.com/api/download?os=linux&arch=amd64" \
      && cp /tmp/caddy.bin /usr/local/bin/caddy ); \
    chmod +x /usr/local/bin/caddy; \
    /usr/local/bin/caddy version; \
    rm -f /tmp/caddy.bin /tmp/caddy.tgz

# OmniRouter (Godde3s) — keyless free models (Qwen/Gemini/OpenCode guest)
# NOTE: /releases/latest/download/ => always the newest published release
RUN set -eux; \
    mkdir -p /opt/omnirouter; \
    curl -fsSL --retry 3 --retry-all-errors -o /tmp/omni.tar.gz \
      "https://github.com/Godde3s/omnirouter/releases/latest/download/dist-omnirouter-linux-amd64.tar.gz"; \
    tar -xzf /tmp/omni.tar.gz -C /opt/omnirouter; \
    chmod +x /opt/omnirouter/*linux-amd64; \
    rm -f /tmp/omni.tar.gz

# huggingface_hub in its own venv -> hourly backup + restore on boot
RUN python3 -m venv /opt/hfpy \
    && /opt/hfpy/bin/pip install --no-cache-dir "huggingface_hub>=0.30"

# ---- Kit files ---------------------------------------------
# Bump CACHE_BUST (or push a commit) to force a rebuild that re-reads kit files
ARG CACHE_BUST=1
COPY Caddyfile /etc/caddy/Caddyfile
COPY hfkit/ /opt/hfkit-kit/
RUN chmod +x /opt/hfkit-kit/*.sh /opt/hfkit-kit/cont-init.d/*.sh \
    && cp /opt/hfkit-kit/cont-init.d/*.sh /etc/cont-init.d/

# Hermes state lives in /opt/data (official image contract)
RUN mkdir -p /opt/data /opt/data/logs

# HF pings the app port; /healthz lets our own keep-alive Action verify
# the full front proxy is alive without spamming the real services.
HEALTHCHECK --interval=60s --timeout=10s --start-period=180s --retries=3 \
    CMD curl -fsS -o /dev/null http://127.0.0.1:7860/healthz || exit 1

# Default: start the supervised Telegram/Discord gateway.
# s6 still supervises the gateway; our services are started by cont-init.
CMD ["gateway", "run"]
