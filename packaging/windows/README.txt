# Ninja Master's: Haoh-Ninpo-Cho - Windows x64

This is a native Windows x64 build of the Neo Geo MVS game **Ninja Master's:
Haoh-Ninpo-Cho** (`ninjamas`, NGM-217, 1996).  The game's Motorola 68000
program is statically recompiled to C and runs against a model of the MVS
board; the Z80 sound driver and YM2610 are emulated.  It is not a ROM
emulator front end.

## What you need

This package contains **no game data**.  Supply your own legally obtained
MAME `ninjamas` set and the `neogeo` BIOS set, unzipped into a folder:

    217-p1.p1    217-p2.sp2    217-c1.c1 .. 217-c8.c8
    217-s1.s1    217-m1.m1     217-v1.v1  217-v2.v2
    sp-s2.sp1    sfix.sfix     000-lo.lo  sm1.sm1

The BIOS files (last line) come from the standard `neogeo.zip` set.  The
game and BIOS files may all be placed in the same folder.

## Run

1. Put the files above in a folder, e.g. `roms` next to `Ninjamasters.exe`.
2. Double-click `Ninjamasters.exe`.
   * It looks for `roms` next to the executable automatically.
   * To use another folder, run from a Command Prompt:
     `Ninjamasters.exe --rom-path "C:\path\to\roms"`

## Controls (keyboard)

| Key | Action |
|---|---|
| Arrow keys | Move |
| Z / X / C / V | Neo Geo A / B / C / D |
| 5 | Insert coin |
| 1 | Start (player 1) |
| 2 | Start (player 2) |
| 3 | Select |
| 9 | Service credit |
| F2 | Test mode |
| Esc | Quit |

An Xbox-compatible controller works alongside the keyboard: D-pad or left
stick to move, A/B/X/Y for Neo Geo A/B/C/D, Start for 1P start, Back for
coin, left shoulder for select.  See `docs/controls.md`.

## Command line

The player takes the toolkit's standard options:

    --rom-path DIR        game ROM files (default: roms)
    --bios-path DIR       system ROM files (default: the ROM path)
    --bios FILE           system ROM (default: sp-s2.sp1)
    --fullscreen          start fullscreen
    --scale N             window scale (default 3)
    --headless            no window; run as fast as possible
    --input FILE          scripted input
    --screenshot N:FILE   save a PNG
    --wav FILE            write audio to a WAV file
    --mute                disable sound
    --interp              run everything in Musashi
    --verify              compare every native block with Musashi

## Files

    Ninjamasters.exe    the native player
    SDL2.dll            SDL2 2.32.10 (zlib licence)
    vcruntime140*.dll   MSVC runtime, when included
    README.txt          this file
    LICENSES\           project and third-party licences

## Notes

* The executable is built for Windows 10/11 x64.
* No ROMs, BIOS files, generated C, or save data are included.
* Ninja Master's and Neo Geo are trademarks of SNK Corporation.  This is an
  unofficial fan project, not affiliated with or endorsed by SNK.
