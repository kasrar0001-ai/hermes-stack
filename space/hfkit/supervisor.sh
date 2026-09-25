#!/usr/bin/env bash
# Restart-on-exit supervisor for the four extra services.
set -u

truncate_log() {
    # keep logs under ~5 MB
    if [ -f "/opt/data/logs/$1.log" ] && [ "$(stat -c%s "/opt/data/logs/$1.log" 2>/dev/null || echo 0)" -gt 5000000 ]; then
        tail -c 1000000 "/opt/data/logs/$1.log" > "/opt/data/logs/$1.log.tmp" 2>/dev/null || true
        mv "/opt/data/logs/$1.log.tmp" "/opt/data/logs/$1.log" 2>/dev/null || true
    fi
}

start_svc() {
    local name="$1"
    (
        local fails=0 delay=5
        while true; do
            truncate_log "$name"
            echo "[$(date -u +%F\ %T)] starting $name ..."
            /opt/hfkit-kit/svc-"$name".sh
            rc=$?
            # exponential backoff 5s -> 10s -> 20s -> 40s -> 60s (cap)
            # so a broken service never hammers the CPU (HF flags crash loops)
            if [ "$rc" -eq 0 ]; then fails=0; delay=5; else fails=$((fails+1)); fi
            [ "$fails" -gt 1 ] && delay=$(( delay < 60 ? delay*2 : 60 ))
            echo "[$(date -u +%F\ %T)] $name exited (rc=$rc) — restart in ${delay}s"
            sleep "$delay"
        done
    ) >>/opt/data/logs/"$name".log 2>&1 &
    disown 2>/dev/null || true
}

start_svc 9router
start_svc caddy
start_svc backup

if [ "${OMNI_ENABLED:-true}" = "true" ]; then
    start_svc omnirouter
else
    echo "[supervisor] OMNI_ENABLED != true — omnirouter skipped."
fi

echo "[supervisor] all services launched."
exit 0
