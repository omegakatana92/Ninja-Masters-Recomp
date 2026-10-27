# Generic runtime changes in the vendored toolkit

These changes live in `neogeorecomp/`, are not specific to Ninja Master's,
and are offered under the toolkit's MIT license. They were carried over from
the reference Garou/KOF/Metal Slug work because they fix generic MVS
behaviour that this game also depends on.

## 1. Z80 M1 bank-window mask

`src/audio.c: z_read()`

MAME's `init_audio()` loads the M1 at audio-region offset `$10000` and
`ROM_RELOAD`s it, so the file offset of a banked window is the masked bank
value with no extra base:

```c
uint32_t reg_mask = size ? (((uint32_t)size - 1u) & 0x3FFFFu) : 0;
off = (s_bank[window] & reg_mask) + (a & window_mask);
```

The earlier `(size - 0x10000 - 1) & 0x3FFFF` mask drops a bit for 256 KB
M1s and shifts the wrong 64 KB block into the window. `ninjamas` uses a
128 KB M1, where the old mask also wrapped banks beyond `$10000`; the new
mask is the MAME-correct `$1FFFF`.

## 2. Keep the Z80 running between polls

`src/audio.c: audio_take_samples()`

Calls `audio_sync()` before generating samples. The 68k does not poll the
sound latches during some menus and effects; without this the YM2610 timers
and the driver's sequencer can be starved, which shows up as a stopped BGM
stream while one-shot ADPCM effects still fire.

## 3. Banked-code fallback

`src/exec.c: slot()`

When the cartridge points the `$200000` window at a non-zero bank, the same
68k address refers to different bytes. The generated dispatch table only
describes the first bank. For `$200000-$2FFFFF` with `ng_bank_base != 0`,
the dispatcher returns `NULL`, so Musashi interprets the code rather than
running stale native code. Without this, banked routines can execute the
wrong instructions. This is a correctness fallback, not a replacement for
recompilation: the fixed bank and BIOS still run natively.

## 4. SDL audio output conversion

`src/window_sdl.c`

The device was opened for exactly 55,555 Hz S16 stereo with
`allowed_changes = 0`.  Devices that do not accept that rate failed to open
(the game ran silently), and on devices that did, the frame queue's
drop-above-120 ms / insert-silence-below-30 ms policy produced clicks and
17 ms holes under normal scheduling jitter.  `--wav` bypassed this path, so
waveform captures looked clean while real playback did not.

The fixed code opens with `SDL_AUDIO_ALLOW_FREQUENCY_CHANGE |
SDL_AUDIO_ALLOW_FORMAT_CHANGE | SDL_AUDIO_ALLOW_CHANNELS_CHANGE`, converts
the YM2610's 55,555 Hz output through `SDL_AudioStream` to the device format,
starts after a 60 ms cushion, and never inserts silence or drops a frame
except after a genuine >150 ms stall (pause/debugger).  This adds 60 ms of
output latency by design.

## 5. Sprite allocation padding

`src/video.c`

Allocates the decoded sprite region at the next power of two (zero-filled),
because tile numbers are masked to that power and the address lines above
the fitted ROMs are not connected.  This matters for non-power-of-two C ROM
sets; Ninja Master's 32 MB set is a power of two, so this is a correctness
guard rather than a title-specific fix.

## 6. Coverage counters

`src/exec.c` counts native instructions separately from interpreted ones, so
the final `[exec]` line can report a measured native percentage instead of an
estimate.

## Not changed for this title

No title-specific address, patch, or speed hack was added. Ninja Master's
uses the plain PCM2 board and needs none of the NEO-SMA/NEO-CMC42 fix-ups
that the encrypted late titles use.
