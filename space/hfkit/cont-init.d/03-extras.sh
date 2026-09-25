#!/usr/bin/env bash
# cont-init 03 — launch the extra services supervisor in the background.
# The hermes gateway itself is supervised by s6 (official image behavior);
# everything else (9router / omnirouter / caddy / backup) is managed here.
set -u

mkdir -p /opt/data/logs

nohup setsid /opt/hfkit-kit/supervisor.sh </dev/null >>/opt/data/logs/supervisor.log 2>&1 &
disown 2>/dev/null || true

echo "[extras] supervisor started."
exit 0
