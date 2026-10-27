# Compatibility report

Game: **Ninja Master's: Haoh-Ninpo-Cho** (MAME set `ninjamas`, NGM-217)
Toolkit: NeoGeoRecomp v0.2.0, upstream commit `af96b2b`, plus the generic
runtime corrections listed in `runtime-changes.md`.

## ROM validation

All files were hashed and compared with MAME 0.242's `ninjamas` set. All
match:

| File | Size | CRC32 | Result |
|---|---:|---|---|
| `217-p1.p1` | 1,048,576 | `3E97ED69` | match |
| `217-p2.sp2` | 2,097,152 | `191FCA88` | match |
| `217-c1.c1` | 4,194,304 | `5FE97BC4` | match |
| `217-c2.c2` | 4,194,304 | `886E0D66` | match |
| `217-c3.c3` | 4,194,304 | `59E8525F` | match |
| `217-c4.c4` | 4,194,304 | `8521ADD2` | match |
| `217-c5.c5` | 4,194,304 | `FB1896E5` | match |
| `217-c6.c6` | 4,194,304 | `1C98C54B` | match |
| `217-c7.c7` | 4,194,304 | `8B0EDE2E` | match |
| `217-c8.c8` | 4,194,304 | `A085BB61` | match |
| `217-s1.s1` | 131,072 | `8FF782F0` | match |
| `217-m1.m1` | 131,072 | `D00FB2AF` | match |
| `217-v1.v1` | 4,194,304 | `1C34E013` | match |
| `217-v2.v2` | 2,097,152 | `22F1C681` | match |

BIOS files from `neogeo.zip`: `sp-s2.sp1` `9036D879`, `sfix.sfix`
`C2EA0CFD`, `000-lo.lo` `5A86CFF2`, `sm1.sm1` `94416D67`.

The cartridge is a plain PCM2 board: standard 1 MB program window at
`$2FFFF0`, no NEO-SMA/NEO-CMC protection, no encryption, no CMC fix-bank.
No title-specific hacks are needed in the runtime.

## What was exercised

| Area | Result |
|---|---|
| BIOS boot | Eyecatcher and memory check render; cart hand-off works |
| Title / attract | Title, how-to-play pages and demo fight render |
| Coin / start | Coin adds a credit, Start consumes it and enters the game |
| Character select | Selection screen and auto-choosing CPU opponent render |
| Match | Both fighters, life/power bars, timer, hits and win sequence |
| Graphics | Sprites, animation, backgrounds, fixed layer, palette banks, rain effect |
| Audio | M1 driver executes, YM2610 FM/SSG/ADPCM audible; continuity checked |
| Input | Keyboard and scripted input; SDL gamepad path is the toolkit's |
| Save data | Not implemented by the toolkit (no memory card) |

## Native execution

Static discovery: **1,202,485 instructions, 7,485 routines, 13,036 dispatch
entries** (pointer scan included). After one profile pass over
`tests/play_long.txt`, the final build has **13,041 dispatch entries** and the
19,000-frame session reports

```
[verify] 11679349 blocks checked, 0 mismatches
[exec] native blocks 11679349, native instructions 383989802,
       interpreted instructions 0 (100.00% native), 0 uncovered entry points
```

That is the measured result for the whole scripted session: every executed
instruction ran in recompiled C, and every block agreed with Musashi.
`tests/coin_start.txt` over 3,000 frames likewise reports 1,498,046 blocks,
0 mismatches and 0 interpreted instructions.

## Audio validation

A 101 s native capture and a MAME 0.242 reference capture of the same
coin/start/play script both show one 3 s quiet window at 22-24 s (the title
to how-to-play transition). Per-second RMS correlation is 0.93. In the
321 s soak the native capture has the same title window plus a 7 s quiet
window at 297-303 s, which the screenshot at frame 17,600 identifies as the
"Ninja Master's Best Time" ranking screen after the match. There is no
music-sized dropout while gameplay is running, so the M1 bank mask and the
audio pump are behaving.

Playback also goes through the generic SDL output repair: the device is opened
with frequency/format/channel changes allowed, the 55,555 Hz YM2610 stream is
converted with `SDL_AudioStream`, and the queue only drops after a genuine
>150 ms stall. This fixes silent output on devices that reject 55,555 Hz and
the click/dropout pattern that `--wav` cannot show. Windowed launches print no
SDL audio warning on the test machine.

## Not verified

* Physical Steam Deck hardware, SteamOS Gaming Mode, Steam Input and a
  physical controller were not available.
* Audio was measured, not auditioned; mix balance was not judged by ear.
* Memory-card save/load is not supported.
* Long multi-credit sessions beyond the 19,000-frame soak were not scripted.


