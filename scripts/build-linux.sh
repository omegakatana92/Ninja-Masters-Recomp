#!/usr/bin/env bash
# Build the native Linux x86_64 player (Release) from the user's own ROMs.
# Usage: scripts/build-linux.sh [ROM_DIR] [BUILD_DIR]
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ROMS="${1:-$ROOT/roms-src}"
BUILD="${2:-$ROOT/build-linux}"
cmake -S "$ROOT" -B "$BUILD" -DCMAKE_BUILD_TYPE=Release \
      -DNINJAMAS_ROM_DIR="$ROMS" -DNEOGEORECOMP_BUILD_TESTS=OFF
cmake --build "$BUILD" --parallel "${JOBS:-4}"
echo "built $BUILD/Ninjamasters"

