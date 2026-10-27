# Ninja Master's: Haoh-Ninpo-Cho - Steam Deck / Linux x86_64

This AppImage is the native Linux x86_64 build of the static recompilation.
It contains no game data.  Supply your own legally obtained MAME `ninjamas`
set and the standard `neogeo` BIOS files, unzipped into one directory.

## ROM folder

The AppRun wrapper looks, in order, at:

1. an explicit `--rom-path DIR` you pass;
2. `$NINJAMAS_ROM_DIR`;
3. `roms/` beside the AppImage, and `roms/ninjamasters/`;
4. `~/.local/share/ninjamasters/roms` and `~/.local/share/ninjamasters`;
5. `~/Emulation/roms/ninjamasters`, `~/roms/ninjamasters`, `~/roms`.

Expected files:

    217-p1.p1    217-p2.sp2    217-c1.c1 .. 217-c8.c8
    217-s1.s1    217-m1.m1     217-v1.v1  217-v2.v2
    sp-s2.sp1    sfix.sfix     000-lo.lo  sm1.sm1

## Running

    chmod +x Ninjamasters-SteamDeck-x86_64.AppImage
    ./Ninjamasters-SteamDeck-x86_64.AppImage

A normal launch adds `--fullscreen` (1280x800 on a Steam Deck).  The game is
rendered at its native 320x224 and scaled to fit 16:10 with pillarboxes; it
is never stretched.  Pass `--scale N` or `--windowed` behaviour by using
`--scale N` instead of fullscreen.

Steam: add the AppImage as a non-Steam game.  Steam Input's default gamepad
template maps the D-pad/left stick, A/B/X/Y to Neo Geo A/B/C/D, Start to 1P
start, and Back to coin insertion.

## Verified here

* headless and windowed launch under WSL2 Ubuntu 22.04 / Xvfb;
* 100% native execution of the scripted session, `--verify` 0 mismatches;
* audio continuity checked against a MAME 0.242 capture.

Physical Steam Deck hardware, Gaming Mode and a physical controller were not
available for this build, so those remain user-reported checks.

Ninja Master's and Neo Geo are trademarks of SNK Corporation.  This is an
unofficial fan project, not affiliated with or endorsed by SNK.
