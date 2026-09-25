#!/usr/bin/env bash
# 9Router (decolua) — Next.js app copied from the official image into /opt/9router
set -e

mkdir -p /opt/data/9router
cd /opt/9router

export PORT=20128
export HOSTNAME=127.0.0.1
export DATA_DIR=/opt/data/9router
export NODE_ENV=production
export NEXT_TELEMETRY_DISABLED=1

# API key enforcement on /v1/* (you create the key in the dashboard)
export REQUIRE_API_KEY="${REQUIRE_API_KEY:-true}"
# HTTPS in front (HF edge) -> Secure auth cookie
export AUTH_COOKIE_SECURE=true
# first-login dashboard password (change via Secret ROUTER_INITIAL_PASSWORD)
export INITIAL_PASSWORD="${ROUTER_INITIAL_PASSWORD:-123456}"

exec node custom-server.js
