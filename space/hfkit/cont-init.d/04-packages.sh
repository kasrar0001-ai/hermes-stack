#!/usr/bin/env bash
# cont-init 04 — "real server" mode: install extra packages & run custom boot code.
#
# Everything here is OPTIONAL. Configure via Space Variables/Secrets:
#   EXTRA_APT_PACKAGES="jq ffmpeg"        -> apt-get install at every boot
#   EXTRA_PIP_PACKAGES="requests yt-dlp"  -> pip install into every venv found
#   EXTRA_NPM_PACKAGES="typescript"       -> npm install -g
#   STARTUP_SCRIPT="echo hi"              -> bash snippet run after packages
# Plus a persistent file /opt/data/hfkit-boot.sh you can create from the
# agent chat / dashboard — it survives restarts (it lives in /opt/data and
# is included in the hourly backup) and is replayed at every boot.
#
# Failures never block the boot: every step is logged + time-boxed.
set -u
LOG=/opt/data/logs/packages.log
mkdir -p /opt/data/logs /opt/data
exec >>"$LOG" 2>&1

echo "[$(date -u +%F\ %T)] [packages] boot pass start"
APT="${EXTRA_APT_PACKAGES:-}"
PIP="${EXTRA_PIP_PACKAGES:-}"
NPM="${EXTRA_NPM_PACKAGES:-}"
STARTUP="${STARTUP_SCRIPT:-}"
[ -f /opt/data/hfkit-boot.sh ] && echo "[packages] persistent hfkit-boot.sh found"

# nothing to do? exit fast (keeps restarts snappy)
if [ -z "$APT" ] && [ -z "$PIP" ] && [ -z "$NPM" ] && [ -z "$STARTUP" ] && [ ! -f /opt/data/hfkit-boot.sh ]; then
    echo "[packages] nothing configured — done"
    exit 0
fi

# ---- apt ------------------------------------------------------------
if [ -n "$APT" ]; then
    echo "[packages] apt install: $APT"
    timeout 420 apt-get update -qq || true
    # shellcheck disable=SC2086
    timeout 600 apt-get install -y --no-install-recommends $APT || echo "[packages] apt FAILED (non-fatal)"
fi

# ---- pip (into the hfkit venv + any hermes venv we can find) --------
if [ -n "$PIP" ]; then
    for PY in /opt/hfpy/bin/pip /app/.venv/bin/pip /opt/hermes/.venv/bin/pip; do
        if [ -x "$PY" ]; then
            echo "[packages] pip ($PY): $PIP"
            # shellcheck disable=SC2086
            timeout 600 "$PY" install --no-cache-dir $PIP || echo "[packages] pip $PY FAILED (non-fatal)"
        fi
    done
fi

# ---- npm ------------------------------------------------------------
if [ -n "$NPM" ] && command -v npm >/dev/null 2>&1; then
    echo "[packages] npm -g: $NPM"
    # shellcheck disable=SC2086
    timeout 600 npm install -g --no-audit --no-fund $NPM || echo "[packages] npm FAILED (non-fatal)"
fi

# ---- persistent user boot file --------------------------------------
if [ -f /opt/data/hfkit-boot.sh ]; then
    echo "[packages] replaying /opt/data/hfkit-boot.sh"
    chmod +x /opt/data/hfkit-boot.sh 2>/dev/null || true
    timeout 900 bash /opt/data/hfkit-boot.sh || echo "[packages] hfkit-boot.sh FAILED (non-fatal)"
fi

# ---- one-shot startup snippet from a Variable/Secret ----------------
if [ -n "$STARTUP" ]; then
    echo "[packages] running STARTUP_SCRIPT"
    echo "$STARTUP" | timeout 900 bash || echo "[packages] STARTUP_SCRIPT FAILED (non-fatal)"
fi

echo "[$(date -u +%F\ %T)] [packages] boot pass done"
exit 0
