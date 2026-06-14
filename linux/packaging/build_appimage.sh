#!/usr/bin/env bash
# build_appimage.sh — builds a Linux AppImage for Polypodium.
#
# Prerequisites:
#   - Flutter SDK in PATH with Linux desktop enabled
#   - appimagetool in PATH (https://github.com/AppImage/AppImageKit/releases)
#   - libnotify and GTK3 dev libs installed
#
# Usage: ./linux/packaging/build_appimage.sh [--release | --profile]
#
# Version override (optional — defaults to pubspec.yaml values):
#   BUILD_NAME=1.2.3 BUILD_NUMBER=5 ./linux/packaging/build_appimage.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
BUILD_TYPE="${1:---release}"

APP_ID="com.polypodium.polypodium"
APP_NAME="Polypodium"
# Flutter uses "x64" in the build path; AppImage tools expect "x86_64".
FLUTTER_ARCH="x64"
APPIMAGE_ARCH="x86_64"

echo "==> Building Flutter Linux bundle ($BUILD_TYPE)..."
cd "$PROJECT_ROOT"

FLUTTER_BUILD_ARGS=("build" "linux" "$BUILD_TYPE")
[[ -n "${BUILD_NAME:-}" ]]   && FLUTTER_BUILD_ARGS+=("--build-name=$BUILD_NAME")
[[ -n "${BUILD_NUMBER:-}" ]] && FLUTTER_BUILD_ARGS+=("--build-number=$BUILD_NUMBER")
flutter "${FLUTTER_BUILD_ARGS[@]}"

BUILD_MODE="release"
[[ "$BUILD_TYPE" == "--profile" ]] && BUILD_MODE="profile"
FLUTTER_BUNDLE="$PROJECT_ROOT/build/linux/$FLUTTER_ARCH/$BUILD_MODE/bundle"

APPDIR="$PROJECT_ROOT/build/AppDir"
rm -rf "$APPDIR"

echo "==> Assembling AppDir..."

# The Flutter binary is built with RPATH=$ORIGIN/lib, so lib/ and data/ must
# sit next to the binary. We mirror the Flutter bundle layout inside usr/bin/.
BIN_DIR="$APPDIR/usr/bin"
install -d "$BIN_DIR"

# Binary
install -m755 "$FLUTTER_BUNDLE/polypodium" "$BIN_DIR/polypodium"

# Libraries (RPATH $ORIGIN/lib → usr/bin/lib/)
cp -a "$FLUTTER_BUNDLE/lib" "$BIN_DIR/lib"

# Flutter data — icudtl.dat, flutter_assets/, app.so snapshot, etc.
cp -a "$FLUTTER_BUNDLE/data" "$BIN_DIR/data"

# Desktop entry
install -Dm644 "$SCRIPT_DIR/$APP_ID.desktop" \
  "$APPDIR/usr/share/applications/$APP_ID.desktop"

# Icon
install -Dm644 "$PROJECT_ROOT/assets/images/logo.png" \
  "$APPDIR/usr/share/icons/hicolor/512x512/apps/$APP_ID.png"
install -Dm644 "$PROJECT_ROOT/assets/images/logo.png" \
  "$APPDIR/$APP_ID.png"

# AppRun — no LD_LIBRARY_PATH needed; RPATH handles lib discovery
cat > "$APPDIR/AppRun" <<'APPRUN'
#!/bin/sh
HERE="$(dirname "$(readlink -f "$0")")"
exec "$HERE/usr/bin/polypodium" "$@"
APPRUN
chmod +x "$APPDIR/AppRun"

# Top-level .desktop required by appimagetool
cp "$SCRIPT_DIR/$APP_ID.desktop" "$APPDIR/$APP_ID.desktop"

echo "==> Running appimagetool..."
OUTPUT="$PROJECT_ROOT/build/${APP_NAME}-${APPIMAGE_ARCH}.AppImage"
rm -f "$OUTPUT"

# Locate appimagetool: honour PATH first, then common user locations.
APPIMAGETOOL=""
if command -v appimagetool &>/dev/null; then
  APPIMAGETOOL="appimagetool"
else
  for candidate in \
      "$HOME/.local/bin/appimagetool" \
      "$HOME/.local/bin/appimagetool-x86_64.AppImage" \
      "$HOME/.local/share/applications/appimagetool-x86_64.AppImage" \
      "/opt/appimagetool/appimagetool-x86_64.AppImage"; do
    if [[ -x "$candidate" ]]; then
      APPIMAGETOOL="$candidate"
      break
    fi
  done
fi

if [[ -z "$APPIMAGETOOL" ]]; then
  echo "ERROR: appimagetool not found. Download it from:"
  echo "  https://github.com/AppImage/AppImageKit/releases"
  echo "and place it at ~/.local/bin/appimagetool-x86_64.AppImage (chmod +x)"
  exit 1
fi

ARCH="$APPIMAGE_ARCH" "$APPIMAGETOOL" "$APPDIR" "$OUTPUT"

echo ""
echo "AppImage ready: $OUTPUT"
