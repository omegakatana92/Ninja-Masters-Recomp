#!/usr/bin/env python3
"""Generate packaging/appimage/ninjamasters.png (256x256, simple original art)."""
from PIL import Image, ImageDraw, ImageFont
import os

S = 256
img = Image.new("RGB", (S, S), (18, 12, 26))
d = ImageDraw.Draw(img)
# Purple-to-crimson diagonal wash (original art, no game assets).
for y in range(S):
    for band in range(4):
        pass
for y in range(S):
    t = y / (S - 1)
    r = int(40 + 150 * t)
    g = int(10 + 20 * t)
    b = int(55 + 30 * (1 - t))
    d.line([(0, y), (S, y)], fill=(r, g, b))
# A slanted blade shape.
d.polygon([(52, 214), (196, 34), (214, 46), (78, 226)], fill=(220, 224, 232))
d.polygon([(52, 214), (78, 226), (66, 238)], fill=(150, 154, 166))
# Rising sun disc.
d.ellipse([148, 148, 244, 244], fill=(190, 30, 40))
# Monogram.
try:
    font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 74)
except Exception:
    font = ImageFont.load_default()
d.text((22, 22), "NM", font=font, fill=(245, 236, 210))
out = os.path.join(os.path.dirname(os.path.abspath(__file__)), "ninjamasters.png")
img.save(out)
print(out)
