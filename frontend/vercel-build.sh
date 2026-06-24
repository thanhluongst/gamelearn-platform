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

echo "==> Generating placeholder icons if missing..."
mkdir -p web/icons
python3 - <<'PYEOF'
import struct, zlib, os

def make_png(size, r, g, b):
    def chunk(t, d):
        c = zlib.crc32(t + d) & 0xffffffff
        return struct.pack('>I', len(d)) + t + d + struct.pack('>I', c)
    raw = b''
    for _ in range(size):
        raw += b'\x00' + bytes([r, g, b] * size)
    sig = b'\x89PNG\r\n\x1a\n'
    ihdr = chunk(b'IHDR', struct.pack('>IIBBBBB', size, size, 8, 2, 0, 0, 0))
    idat = chunk(b'IDAT', zlib.compress(raw))
    iend = chunk(b'IEND', b'')
    return sig + ihdr + idat + iend

files = {
    'web/favicon.png': 16,
    'web/icons/Icon-192.png': 32,
    'web/icons/Icon-512.png': 32,
    'web/icons/Icon-maskable-192.png': 32,
    'web/icons/Icon-maskable-512.png': 32,
}
for path, size in files.items():
    if not os.path.exists(path):
        with open(path, 'wb') as f:
            f.write(make_png(size, 1, 117, 194))
        print(f"Created placeholder: {path}")
PYEOF

echo "==> Installing dependencies..."
flutter pub get

echo "==> Building Flutter web..."
flutter build web \
  --release \
  --web-renderer canvaskit

echo "==> Build done! Files:"
ls build/web/ | head -8
