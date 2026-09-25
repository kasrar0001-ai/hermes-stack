#!/usr/bin/env bash
# Hourly backup of /opt/data -> private HF dataset repo
set -u

INTERVAL="${BACKUP_INTERVAL:-3600}"
sleep "${BACKUP_FIRST_DELAY:-300}"

while true; do
    if [ -n "${BACKUP_REPO:-}" ] && [ -n "${HF_TOKEN:-}" ]; then
        if /opt/hfpy/bin/python /opt/hfkit-kit/backup.py; then
            echo "[$(date -u +%F\ %T)] backup uploaded."
        else
            echo "[$(date -u +%F\ %T)] backup FAILED (rc=$?)."
        fi
    fi
    sleep "$INTERVAL"
done
