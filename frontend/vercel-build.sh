#!/usr/bin/env bash
set -e

FLUTTER_VERSION="3.24.5"
FLUTTER_DIR="/tmp/flutter"

echo "==> Installing Flutter $FLUTTER_VERSION..."
if [ ! -d "$FLUTTER_DIR" ]; then
  curl -fsSL \
    "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz" \
    | tar xJ -C /tmp
fi

export PATH="$FLUTTER_DIR/bin:$PATH"

flutter config --no-analytics --no-cli-animations
flutter pub get

echo "==> Building Flutter web..."
flutter build web \
  --release \
  --web-renderer canvaskit \
  --dart-define=FLUTTER_WEB_USE_SKIA=true

echo "==> Build complete!"
