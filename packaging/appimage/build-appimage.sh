#!/usr/bin/env bash
# Build the native Linux x86_64 player and package it as a Steam Deck AppImage.
#
# Prerequisites: gcc, g++, cmake 3.21+, make, libsdl2-dev, wget.
# The user's ROMs are never bundled: the AppImage contains only the player.
#
# Usage: ./packaging/appimage/build-appimage.sh [ROM_DIR]
# Default ROM_DIR=$ROOT/roms-src, output dist/steamdeck/...
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
ROMS="${1:-$ROOT/roms-src}"
BUILD="$ROOT/build-linux"
APPDIR="$BUILD/AppDir"
OUT="$ROOT/dist/steamdeck/Ninjamasters-SteamDeck-x86_64.AppImage"
NAME="Ninjamasters"

echo "== configure/build (Release) =="
cmake -S "$ROOT" -B "$BUILD" -DCMAKE_BUILD_TYPE=Release \
      -DNINJAMAS_ROM_DIR="$ROMS" -DNEOGEORECOMP_BUILD_TESTS=OFF
cmake --build "$BUILD" --parallel "$(nproc)"

echo "== assemble AppDir =="
rm -rf "$APPDIR"
mkdir -p "$APPDIR/usr/bin" "$APPDIR/usr/lib" \
         "$APPDIR/usr/share/applications" \
         "$APPDIR/usr/share/icons/hicolor/256x256/apps" \
         "$APPDIR/usr/share/doc/ninjamasters"
cp "$BUILD/$NAME" "$APPDIR/usr/bin/$NAME"
strip --strip-unneeded "$APPDIR/usr/bin/$NAME" 2>/dev/null || true

# Bundle the SDL2 the build linked against; SteamOS's system copy may differ.
SDL=$(ldd "$BUILD/$NAME" | awk '/libSDL2-2\.0\.so\.0/{print $3; exit}')
if [ -n "$SDL" ]; then cp "$SDL" "$APPDIR/usr/lib/"; fi

cp "$ROOT/packaging/appimage/ninjamasters.png" "$APPDIR/ninjamasters.png"
cp "$ROOT/packaging/appimage/ninjamasters.png" \
   "$APPDIR/usr/share/icons/hicolor/256x256/apps/ninjamasters.png"
cp "$ROOT/packaging/appimage/ninjamasters.desktop" "$APPDIR/ninjamasters.desktop"
cp "$ROOT/packaging/appimage/ninjamasters.desktop" \
   "$APPDIR/usr/share/applications/ninjamasters.desktop"
cp "$ROOT/packaging/appimage/README.txt" "$APPDIR/usr/share/doc/ninjamasters/README.txt"
cp "$ROOT/LICENSE" "$APPDIR/usr/share/doc/ninjamasters/LICENSE.txt"
cp "$ROOT/LICENSE-STATUS.md" "$APPDIR/usr/share/doc/ninjamasters/LICENSE-STATUS.txt" 2>/dev/null || true
cp "$ROOT/THIRD_PARTY_NOTICES.md" "$APPDIR/usr/share/doc/ninjamasters/THIRD_PARTY_NOTICES.txt"
mkdir -p "$APPDIR/usr/share/doc/ninjamasters/LICENSES"
cp "$ROOT/neogeorecomp/LICENSE" "$APPDIR/usr/share/doc/ninjamasters/LICENSES/neogeorecomp.txt"
cp "$ROOT/neogeorecomp/NOTICE" "$APPDIR/usr/share/doc/ninjamasters/LICENSES/neogeorecomp-NOTICE.txt"
cp "$ROOT/neogeorecomp/LICENSES/"*.txt "$APPDIR/usr/share/doc/ninjamasters/LICENSES/"
cp "$ROOT/packaging/windows/SDL2.txt" "$APPDIR/usr/share/doc/ninjamasters/LICENSES/SDL2.txt"

cat > "$APPDIR/AppRun" <<'EOF'
#!/bin/sh
HERE=$(dirname "$(readlink -f "$0")")
export LD_LIBRARY_PATH="$HERE/usr/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"

has_rom=0
for a in "$@"; do
    [ "$a" = "--rom-path" ] && has_rom=1
done

if [ "$has_rom" = 0 ]; then
    cand=""
    if [ -n "${NINJAMAS_ROM_DIR:-}" ]; then
        cand="$NINJAMAS_ROM_DIR"
    elif [ -n "${APPIMAGE:-}" ]; then
        for d in "$(dirname "$APPIMAGE")/roms" \
                 "$(dirname "$APPIMAGE")/roms/ninjamasters" \
                 "$HOME/.local/share/ninjamasters/roms" \
                 "$HOME/.local/share/ninjamasters" \
                 "$HOME/Emulation/roms/ninjamasters" \
                 "$HOME/roms/ninjamasters" "$HOME/roms"; do
            if [ -d "$d" ]; then cand="$d"; break; fi
        done
    fi
    if [ -n "$cand" ]; then
        set -- --rom-path "$cand" "$@"
    fi
fi

# Steam Deck / Gaming Mode wants a fullscreen game.  Keep --headless and an
# explicit --scale or --fullscreen from being overridden.
add_fs=1
for a in "$@"; do
    case "$a" in --headless|--fullscreen|--scale) add_fs=0;; esac
done
[ "$add_fs" = 1 ] && set -- --fullscreen "$@"

exec "$HERE/usr/bin/Ninjamasters" "$@"
EOF
chmod +x "$APPDIR/AppRun"

echo "== appimagetool =="
mkdir -p "$ROOT/dist/steamdeck"
TOOL="${APPIMAGETOOL:-$HOME/appimagetool-x86_64.AppImage}"
if [ ! -x "$TOOL" ]; then
    TOOL="$BUILD/appimagetool.AppImage"
    wget -q -O "$TOOL" \
      https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-x86_64.AppImage
    chmod +x "$TOOL"
fi
ARCH=x86_64 "$TOOL" --appimage-extract-and-run --no-appstream "$APPDIR" "$OUT"
chmod +x "$OUT"
echo "wrote $OUT"
