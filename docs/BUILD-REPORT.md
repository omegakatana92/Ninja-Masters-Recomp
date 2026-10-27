# Build and test report

Game: Ninja Master's: Haoh-Ninpo-Cho (MAME `ninjamas`, NGM-217)
Toolkit: NeoGeoRecomp v0.2.0 (`af96b2b`) + generic runtime changes
Host: Windows 11 x64, MSVC 19.51 (VS 18 2026), CMake 4.3, SDL2 2.32.10;
Linux x86_64 under WSL2 Ubuntu 22.04, GCC 11.4.

## ROMs

All 14 game files and the four BIOS files match MAME 0.242 CRC-32 values
(`docs/compatibility.md`). Program byte order verified by the `NEO-GEO`
header and the initial SSP/PC. No encryption, protection or non-standard
mapper.

## Recompilation

Static discovery: 1,202,485 instructions, 7,485 routines, 13,036 dispatch
entries. One profile pass added 5 runtime-only entries; the final build has
13,041 entries.

Generated C: 16 files, two of which contain a ~58k-line data-driven routine.
MSVC is built with `/O1 /Ob0` for generated files; GCC uses `-O0` for them.
The rest of the runtime uses normal Release optimization.

## CPU verification (Windows Release)

3,000 frames, `tests/coin_start.txt`:

```
[verify] 1498046 blocks checked, 0 mismatches
[exec] native blocks 1498046, native instructions 61750721,
       interpreted instructions 0 (100.00% native), 0 uncovered entry points
```

19,000 frames, `tests/play_long.txt`:

```
[verify] 11679349 blocks checked, 0 mismatches
[exec] native blocks 11679349, native instructions 383989802,
       interpreted instructions 0 (100.00% native), 0 uncovered entry points
```

No block disagreed with Musashi. Coverage is measured, not estimated.

## Audio

19,000 frames, native, 321 s WAV. Checker (`scripts/check-audio.py`,
`--from 10 --max-silence 3`) reports a 3 s window at 22-24 s (title to
how-to-play) and a 7 s window at 297-303 s. Frame 17,600 is the "Ninja
Master's Best Time" ranking screen, so the second window is the game's own
post-match screen. A MAME 0.242 capture of the same coin/start/play script
has the same 22-24 s window; per-second RMS correlation is 0.93.

The windowed path uses the generic `window_sdl.c` output repair: it opens the
device with `SDL_AUDIO_ALLOW_*_CHANGE`, converts the 55,555 Hz stream with
`SDL_AudioStream`, and keeps a 60 ms cushion. Windowed runs at 320x224 and
fullscreen exited 0 with no "no sound" warning.

## Windows

Built and launched windowed with SDL2. Keyboard and scripted input work.
Packaged by `scripts/package-windows.ps1` into
`dist/windows/Ninjamasters-Windows-x64/` with `SDL2.dll`,
`vcruntime140*.dll`, licences, and no ROMs.

## Linux / Steam Deck

Built with `scripts/build-linux.sh` (GCC 11.4, generated files at `-O0`);
packaged by `packaging/appimage/build-appimage.sh` into
`dist/steamdeck/Ninjamasters-SteamDeck-x86_64.AppImage` (32188920 bytes,
SHA-256 `eeb216eb7c91e829047551f0fb5860a0cf7855fd521e369b44883c60e6f7ef03`).
The AppImage bundles SDL2, defaults to fullscreen, and searches
`~/.local/share/ninjamasters/roms` and `roms/` beside the AppImage.

Measured on the packaged AppImage (headless, 3,000 frames,
`tests/coin_start.txt`):

```
[verify] 1498036 blocks checked, 0 mismatches
[exec] native blocks 1498036, native instructions 61750720,
       interpreted instructions 1 (100.00% native), 1 uncovered entry point
```

The 6,000-frame play session reports 28 interpreted instructions and 5
uncovered entries; the Linux build was generated before the Windows profile
pass, so those few runtime-only entries fall back to Musashi there. A
300-frame `--fullscreen` launch under Xvfb exited 0. `ldd` shows the bundled
SDL2 plus ordinary system X11/audio libraries; physical Steam Deck/Gaming
Mode was not available.

## Not tested

* Physical Steam Deck LCD/OLED, Gaming Mode, Steam Input and a physical pad.
* Subjective audio mix (waveform analysis only).
* Memory-card save/load (not implemented by the toolkit).




