# Testing

All commands assume the ROM directory is `roms-src` (unzipped `ninjamas` and
`neogeo` files). The original archives are never modified.

## 1. ROM validation

```bash
python3 /path/to/check-crc.py roms-src    # or use MAME -listroms
mame -listroms ninjamas
```

Expected names and CRCs are in `compatibility.md`. Verified against MAME 0.242.

## 2. Interpreted boot

```powershell
.\build-windows\Release\Ninjamasters.exe --headless --interp --rom-path .\roms-src `
    --frames 2200 --screenshot 600:bios.png --screenshot 1200:title.png `
    --screenshot 1800:attract.png --screenshot 2199:attract2.png
```

The BIOS eyecatcher is at frame 600; the title appears near 1000. This tests
the board model without any recompiled code.

## 3. Native build

```powershell
cmake -S . -B build-windows -G "Visual Studio 18 2026" -A x64 `
    -DNINJAMAS_ROM_DIR="$PWD\roms-src" -DSDL2_DIR="C:\path\to\SDL2\cmake"
cmake --build build-windows --config Release --parallel 8
```

The generator prints the discovery totals and writes `build-windows/generated`.

Ninja Master's produces two ~58,000-line dispatch functions.  MSVC's
optimizer is superlinear on those, so the Windows build compiles the generated
files at `/Od` (about one minute per file; the executable is ~174 MB).  GCC
at `-O1` on the same functions exceeds a Steam Deck-class memory budget, so
the Linux build uses `-O0` for the generated files.  The 68000 helpers and
the rest of the runtime keep normal Release optimization, and measured game
speed is still several times real-time (6,000 frames in ~19 s).

## 4. CPU verification

```powershell
.\build-windows\Release\Ninjamasters.exe --headless --verify --rom-path .\roms-src `
    --frames 3000 --input .\tests\coin_start.txt
```

Measured: `[verify] 1498046 blocks checked, 0 mismatches`, 100.00% native,
0 interpreted. The 19,000-frame session reports
`[verify] 11679316 blocks checked, 0 mismatches` and
`native instructions 383989802, interpreted instructions 0 (100.00% native),
0 uncovered entry points`.

## 5. Coverage / profile pass

```powershell
cmake --build build-windows --config Release --target profile
cmake --build build-windows --config Release
```

`profile` runs a 6,000-frame no-input attract session and the 19,000-frame
`tests/play_long.txt` session, merges runtime-only entries into
`build-windows/entries.txt`, and the next build regenerates the C with them.
The entry list is derived from the game and is never committed.

## 6. Gameplay

```powershell
.\build-windows\Release\Ninjamasters.exe --headless --rom-path .\roms-src `
    --frames 6000 --input .\tests\play_long.txt `
    --screenshot 3100:select.png --screenshot 3500:round.png `
    --screenshot 5000:match.png --screenshot 5999:match2.png
```

The script inserts a coin at frame 1300, starts at 1500, confirms the
character at 3200/3600, then moves and attacks. The screenshots show the
character-select screen, "ROUND 1", the match and the CPU opponent losing
health.

## 7. Audio

```powershell
.\build-windows\Release\Ninjamasters.exe --headless --rom-path .\roms-src `
    --frames 6000 --input .\tests\play_long.txt --wav capture.wav
python .\scripts\check-audio.py capture.wav --from 10 --max-silence 3
```

Measured native capture: window 10-101 s, median RMS 1607.6, one 3.0 s quiet
window at 22-24 s (title transition). MAME 0.242, same script: median RMS
1549.6, the same 22-24 s window. Per-second RMS correlation 0.93. No
music-sized stall.

`--interp` produces the same continuity, so the result is not a native-only
timing artifact.

## 8. Windows launch

```powershell
.\build-windows\Release\Ninjamasters.exe --rom-path .\roms-src
```

Windowed launch, keyboard input, SDL2 audio and fullscreen (`--fullscreen`)
are exercised. The packaged folder is produced by
`scripts/package-windows.ps1`.

## 9. Linux / Steam Deck

```bash
./scripts/build-linux.sh "$PWD/roms-src"
./packaging/appimage/build-appimage.sh "$PWD/roms-src"
./dist/steamdeck/Ninjamasters-SteamDeck-x86_64.AppImage --headless \
    --rom-path "$PWD/roms-src" --frames 6000 --input tests/play_long.txt
```

Also launched windowed and fullscreen under Xvfb. `ldd` is used to confirm
that only SDL2 is bundled from the host libraries. Physical Deck hardware was
not available.

## Known gaps in this test set

* No physical Steam Deck, Gaming Mode or physical controller test.
* No memory-card save/load (the toolkit does not implement it).
* Audio was measured, not auditioned.

