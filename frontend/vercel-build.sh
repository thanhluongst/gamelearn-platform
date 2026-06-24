#!/usr/bin/env bash
set -e

FLUTTER_VERSION="3.24.5"
FLUTTER_DIR="/tmp/flutter-${FLUTTER_VERSION}"

echo "==> Setting up git safe directory..."
git config --global --add safe.directory '*' 2>/dev/null || true
export HOME=/tmp/flutter-home
mkdir -p "$HOME"

echo "==> Installing Flutter $FLUTTER_VERSION..."
if [ ! -f "$FLUTTER_DIR/bin/flutter" ]; then
  rm -rf "$FLUTTER_DIR" /tmp/flutter-download.tar.xz
  curl -fsSL \
    "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz" \
    -o /tmp/flutter-download.tar.xz
  # Extract: tarball contains a "flutter/" folder → goes to /tmp/flutter
  tar xf /tmp/flutter-download.tar.xz -C /tmp
  mv /tmp/flutter "$FLUTTER_DIR"
  rm -f /tmp/flutter-download.tar.xz
  echo "Flutter installed at $FLUTTER_DIR"
fi

export PATH="$FLUTTER_DIR/bin:$PATH"
git config --global --add safe.directory "$FLUTTER_DIR" 2>/dev/null || true

echo "Flutter binary: $(which flutter)"
flutter --version --no-version-check 2>/dev/null || echo "(version check skipped)"

flutter config --no-analytics --no-cli-animations 2>/dev/null || true

echo "==> Installing dependencies..."
flutter pub get

echo "==> Building Flutter web..."
flutter build web \
  --release \
  --web-renderer canvaskit

echo "==> Build done! Files:"
ls build/web/ | head -8
