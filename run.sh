#!/usr/bin/env bash
# ============================================================================
# Vehicle Management System (VMS) — Automated Launcher
# Automatically determines whether to run via host Flutter or Docker.
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "============================================================"
echo " Starting Vehicle Management System (VMS) Frontend Shell"
echo "============================================================"

if command -v flutter >/dev/null 2>&1; then
    echo "-> Found Flutter SDK on host. Launching in Chrome..."
    flutter pub get
    flutter run -d chrome
elif command -v docker >/dev/null 2>&1; then
    echo "-> Flutter SDK not found on host. Launching via Docker container on port 8080..."
    docker compose up --build -d
    echo "-> VMS Frontend is running at: http://localhost:8080"
    if command -v google-chrome-stable >/dev/null 2>&1; then
        echo "-> Opening Google Chrome..."
        google-chrome-stable http://localhost:8080 >/dev/null 2>&1 &
    fi
else
    echo "[!] Error: Neither Flutter nor Docker is ready to run this service."
    exit 1
fi
