#!/usr/bin/env bash
# cont-init 01 — restore the latest backup from the private HF dataset repo
# (runs BEFORE s6 services start; only when /opt/data is fresh/empty)
set -u

mkdir -p /opt/data

# already restored / already configured? nothing to do
if [ -f /opt/data/.restored-ok ] || [ -f /opt/data/config.yaml ]; then
    touch /opt/data/.restored-ok
    exit 0
fi

if [ -z "${BACKUP_REPO:-}" ] || [ -z "${HF_TOKEN:-}" ]; then
    echo "[restore] BACKUP_REPO or HF_TOKEN not set — starting fresh (no restore)."
    touch /opt/data/.restored-ok
    exit 0
fi

echo "[restore] downloading latest.tar.gz from dataset ${BACKUP_REPO} ..."
if /opt/hfpy/bin/python /opt/hfkit-kit/restore.py; then
    echo "[restore] OK"
    touch /opt/data/.restored-ok
else
    echo "[restore] no usable backup found — starting fresh."
    touch /opt/data/.restored-ok
fi

# make everything writable for the runtime 'hermes' user
HERMES_UID="$(id -u hermes 2>/dev/null || echo 1000)"
HERMES_GID="$(id -g hermes 2>/dev/null || echo 1000)"
chown -R "${HERMES_UID}:${HERMES_GID}" /opt/data 2>/dev/null || true
exit 0
