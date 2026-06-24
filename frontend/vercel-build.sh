#!/usr/bin/env bash
set -e

FLUTTER_VERSION="3.24.5"
FLUTTER_DIR="/tmp/flutter-sdk"

echo "==> Setting up environment..."
# Fix git safe directory for root user on Vercel
git config --global --add safe.directory '*' 2>/dev/null || true

# Create proper home for root
export HOME=/tmp/home-flutter
mkdir -p "$HOME"

echo "==> Installing Flutter $FLUTTER_VERSION..."
if [ ! -f "$FLUTTER_DIR/bin/flutter" ]; then
  rm -rf "$FLUTTER_DIR"
  curl -fsSL \
    "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz" \
    -o /tmp/flutter.tar.xz
  mkdir -p "$FLUTTER_DIR"
  tar xf /tmp/flutter.tar.xz -C /tmp
  mv /tmp/flutter "$FLUTTER_DIR" 2>/dev/null || true
  rm -f /tmp/flutter.tar.xz
fi

export PATH="$FLUTTER_DIR/bin:$PATH"

# Fix git safe.directory for the extracted Flutter SDK
git config --global --add safe.directory "$FLUTTER_DIR" 2>/dev/null || true

echo "==> Flutter version check..."
# Force Flutter to think it's not running from a git repo for version
flutter config --no-analytics --no-cli-animations 2>/dev/null || true

echo "==> Installing dependencies..."
flutter pub get

echo "==> Building Flutter web..."
flutter build web \
  --release \
  --web-renderer canvaskit

echo "==> Build complete! Output: build/web"
ls -la build/web/ | head -10
