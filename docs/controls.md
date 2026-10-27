# Controls

## Keyboard

| Key | Neo Geo |
|---|---|
| Arrow keys | joystick |
| Z | A (light attack) |
| X | B (heavy attack) |
| C | C |
| V | D |
| 5 | coin 1 |
| 6 | coin 2 |
| 1 | start 1P |
| 2 | start 2P |
| 3 | select |
| 9 | service |
| F2 | test switch |
| Esc | quit |
| Alt+Enter | toggle fullscreen (SDL) |

## Gamepad (SDL GameController)

The first connected pad is player 1, the second player 2; pads may be
connected while the game runs.

| Pad | Neo Geo |
|---|---|
| D-pad / left stick | move |
| A (south) | A |
| B (east) | B |
| X (west) | C |
| Y (north) | D |
| Start | start |
| Back | coin |
| Left shoulder | select |

Steam Deck: the built-in controls are an SDL GameController, so the default
Steam Input template works without remapping.  If Steam Input is set to
"Keyboard and Mouse", set it back to a gamepad template so SDL sees the pad.

Unknown pads can be described with SDL's mapping format:

```bash
export SDL_GAMECONTROLLERCONFIG="03000000...,My Pad,a:b0,b:b1,..."
```

## Notes

The MVS BIOS requires a credit before Start does anything.  Insert a coin
(keyboard 5 / pad Back / on-screen Steam keyboard) then press Start.
