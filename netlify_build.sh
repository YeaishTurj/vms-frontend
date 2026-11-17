#!/usr/bin/env bash
# ==============================================================================
# Netlify Production Build Script for VMS Flutter Web Frontend
# Installs Flutter SDK if missing, runs pub get, analyze, and builds web release.
# ==============================================================================
set -e

echo "=== Starting Netlify Build for VMS Flutter Web Frontend ==="

# 1. Install / locate Flutter SDK
if command -v flutter >/dev/null 2>&1; then
    echo "-> Using existing Flutter SDK: $(flutter --version 2>&1 | head -n 1)"
else
    FLUTTER_DIR="$HOME/flutter"
    echo "-> Flutter SDK not found in PATH. Installing Flutter (stable)..."
    if [ ! -d "$FLUTTER_DIR" ]; then
        git clone https://github.com/flutter/flutter.git --depth 1 -b stable "$FLUTTER_DIR"
    fi
    export PATH="$FLUTTER_DIR/bin:$PATH"
    echo "-> Flutter SDK ready: $(flutter --version 2>&1 | head -n 1)"
fi

# 2. Configure Flutter Web
flutter config --enable-web
flutter precache --web

# 3. Retrieve dependencies
echo "-> Resolving Flutter dependencies..."
flutter pub get

# 4. Run static analysis
echo "-> Running static analysis (flutter analyze)..."
flutter analyze

# 5. Build production Web release
echo "-> Compiling production web release (flutter build web)..."
if [ -n "$API_BASE_URL" ]; then
    echo "-> Injecting production API_BASE_URL: $API_BASE_URL"
    flutter build web --release --dart-define=API_BASE_URL="$API_BASE_URL"
else
    echo "-> No custom API_BASE_URL environment variable set. Compiling with default ApiConfig."
    flutter build web --release
fi

# 6. Verify SPA redirect file in build output
if [ -f "web/_redirects" ]; then
    cp "web/_redirects" "build/web/_redirects"
fi

echo "=== Build Complete! Publish directory: build/web ==="
