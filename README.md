# Ninja Master's: Haoh-Ninpo-Cho — Neo Geo static recompilation

A native Windows x64 and Linux x86_64 (Steam Deck AppImage) recompilation of
SNK's **Ninja Master's: Haoh-Ninpo-Cho** (MAME set `ninjamas`, NGM-217, 1996),
built with [sp00nznet's neogeorecomp](https://github.com/sp00nznet/neogeorecomp).

The game's Motorola 68000 program is translated ahead of time into C and runs
against a model of the MVS board: video, palette, I/O, the Z80 sound CPU and
the YM2610. It is not an emulator wrapper. Addresses that have no
recompiled entry fall back to Musashi, which is also the correctness oracle.

## Deliverables

| Target | File |
|---|---|
| Windows x64 | `dist/windows/Ninjamasters-Windows-x64/Ninjamasters.exe` |
| Steam Deck / Linux x86_64 | `dist/steamdeck/Ninjamasters-SteamDeck-x86_64.AppImage` |

Neither package contains ROM data.

## Status

| Item | Result |
|---|---|
| ROM set | MAME 0.242 `ninjamas`, every file CRC-verified; standard uncompressed PCM2 cart, no encryption or protection |
| Boot | MVS BIOS eyecatcher, cart check, title, attract and how-to-play all render; screenshots are from the real player |
| Gameplay | Coin, start, tutorial, character select and a scripted match tested; CPU opponent and both life bars update |
| Graphics | Sprites, backgrounds, palettes, fix layer, rain/raster effects |
| Audio | Real Z80 M1 driver + YM2610; continuity matches a MAME 0.242 reference capture (including the same 3 s title transition); SDL output converts 55,555 Hz through `SDL_AudioStream`, so it works on hosts that reject the native rate |
| Native coverage | **100.00%** of the 19,000-frame scripted soak after one profile pass: 11,679,349 blocks, 383,989,802 instructions, 0 interpreted, 0 uncovered |
| `--verify` | 11,679,349 blocks checked, **0 mismatches** |
| Windows | Release x64 built and launched windowed/fullscreen (MSVC 19.51, SDL2 2.32.10), exit 0 |
| Steam Deck | `Ninjamasters-SteamDeck-x86_64.AppImage` built, 32,188,920 bytes, SHA-256 `eeb216eb...`; headless verified (1,498,036 blocks, 0 mismatches) and fullscreen launch under WSL2/Xvfb. Physical Deck/Gaming Mode not available |

## Requirements

* The MAME `ninjamas` ROM set and the standard `neogeo` BIOS set, legally
  obtained. Expected files:

     217-p1.p1   217-p2.sp2   217-c1.c1 .. 217-c8.c8
     217-s1.s1   217-m1.m1    217-v1.v1   217-v2.v2
     sp-s2.sp1   sfix.sfix    000-lo.lo   sm1.sm1

* To build: CMake 3.21+, a C/C++ compiler (MSVC 2022+ on Windows, gcc on
  Linux), SDL2 development files, and the neogeorecomp toolkit (vendored in
  `neogeorecomp/`).
* The ROMs are read from disk at build time to generate the C and at run time
  for graphics and sound. They are never committed.

## Build (Windows)

```powershell
cmake -S . -B build-windows -G "Visual Studio 18 2026" -A x64 `
  -DNINJAMAS_ROM_DIR="$PWD\roms-src" -DSDL2_DIR="C:\path\to\SDL2\cmake"
cmake --build build-windows --config Release --parallel 8
.\build-windows\Release\Ninjamasters.exe --rom-path .\roms-src
```

Package the Windows folder:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\package-windows.ps1
```

## Build (Linux / Steam Deck)

```bash
sudo apt install build-essential cmake libsdl2-dev python3
./scripts/build-linux.sh "$PWD/roms-src"
./packaging/appimage/build-appimage.sh "$PWD/roms-src"
```

The AppImage is written to `dist/steamdeck/Ninjamasters-SteamDeck-x86_64.AppImage`.
See `packaging/appimage/README.txt` for ROM discovery and Steam Input notes.

## Controls

Keyboard: arrows; **Z X C V** = A B C D; **5** = coin; **1** = start;
**3** = select; **9** = service; **F2** = test; **Esc** = quit.

Gamepad: D-pad/left stick; **A B X Y** = Neo Geo A B C D; **Start** = start;
**Back** = coin; **left shoulder** = select. SDL's controller database covers
Xbox-compatible pads; unknown pads can be described with
`SDL_GAMECONTROLLERCONFIG`.

## Verification commands

```powershell
# interpreted bring-up
.\build-windows\Release\Ninjamasters.exe --headless --interp --rom-path .\roms-src --frames 2200

# native + Musashi comparison
.\build-windows\Release\Ninjamasters.exe --headless --verify --rom-path .\roms-src `
    --frames 19000 --input .\tests\play_long.txt

# native coverage / profile pass
cmake --build build-windows --config Release --target profile
cmake --build build-windows --config Release
```

Audio continuity:

```bash
python3 scripts/check-audio.py capture.wav --from 10 --max-silence 3
```

The same checker flags the 22-24 s title transition in both this build and
MAME 0.242, so it is game behaviour, not a driver stall.

## ROM layout

| File | Size | Role |
|---|---:|---|
| `217-p1.p1` | 1 MB | fixed program bank |
| `217-p2.sp2` | 2 MB | banked program data (standard 1 MB window at `$2FFFF0`) |
| `217-c1..c8` | 4 MB each | 32 MB sprite graphics, paired bitplanes |
| `217-s1.s1` | 128 KB | fixed layer |
| `217-m1.m1` | 128 KB | Z80 sound driver |
| `217-v1/v2` | 4 MB + 2 MB | ADPCM samples |
| `sp-s2.sp1`, `sfix.sfix`, `000-lo.lo`, `sm1.sm1` | — | MVS BIOS |

The P ROMs are byte-swapped at rest. After swapping, the initial SSP is
`$0010F300`, the initial PC is `$00001000`, and the header at `$100` reads
`NEO-GEO`. Every CRC matches MAME 0.242's `ninjamas` definition.

## Repository layout

```
CMakeLists.txt              build: recompiler generator + player
src/game.c, game.h          verified ng_game_t ROM layout
src/main.c                  player entry point
src/recomp_main.c           generator entry point
tests/                      scripted input
scripts/                    Linux build, Windows packaging, audio checker
packaging/appimage/         AppImage build script, icon, desktop file
docs/                       compatibility, testing, controls, runtime notes
neogeorecomp/               upstream toolkit (MIT), vendored
```

## Licensing

The original code in this repository (game host, build scripts, packaging,
documentation) is offered under the **PolyForm Noncommercial License 1.0.0**
(see `LICENSE` and `LICENSE-STATUS.md`). This is the Noncommercial variant
requested for the project; it does not permit commercial redistribution.

The vendored `neogeorecomp/` toolkit is MIT, and Musashi, superzazu/z80 and
ymfm keep their own licences. Those files are **not** relicensed. See
`THIRD_PARTY_NOTICES.md` and `neogeorecomp/LICENSES/`.

No ROMs, BIOS images, decrypted data, generated C or entry lists are
distributed. Ninja Master's and Neo Geo are trademarks of SNK Corporation;
this is an unofficial fan project, not affiliated with or endorsed by SNK.




