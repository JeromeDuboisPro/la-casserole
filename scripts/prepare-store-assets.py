#!/usr/bin/env python3
"""Turns the raw store images into files the Play Console accepts.

Play rejects a screenshot whose long side is more than twice its short side,
and a feature graphic that carries an alpha channel. Phone captures from a tall
display fail the first rule: 1080x2424 is 2.24:1. They are padded on the sides
with the app's own background rather than cropped, since the controls sit right
at the top and bottom edges and cropping would cut them off.

Reads store/screenshots/, store/feature-1024x500.png and store/icon-512.png;
writes store/upload/.
"""
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "store" / "upload"
MAX_RATIO = 2.0


def flat(im: Image.Image, background: tuple[int, int, int]) -> Image.Image:
    """Drops the alpha channel by compositing over a solid colour."""
    base = Image.new("RGB", im.size, background)
    base.paste(im, mask=im.getchannel("A") if "A" in im.getbands() else None)
    return base


def pad_to_ratio(im: Image.Image) -> Image.Image:
    w, h = im.size
    if h / w <= MAX_RATIO:
        return im
    new_w = -(-h // 2)  # ceil(h / 2), so the ratio is exactly 2:1 or a hair under
    corner = im.getpixel((0, 0))
    canvas = Image.new("RGB", (new_w, h), corner)
    canvas.paste(im, ((new_w - w) // 2, 0))
    return canvas


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    for old in OUT.glob("*"):
        old.unlink()

    for path in sorted((ROOT / "store" / "screenshots").glob("*.png")):
        im = Image.open(path).convert("RGBA")
        im = pad_to_ratio(flat(im, (32, 32, 32)))
        im.save(OUT / path.name, optimize=True)

    feature = Image.open(ROOT / "store" / "feature-1024x500.png").convert("RGBA")
    flat(feature, (20, 20, 20)).save(OUT / "feature-1024x500.png", optimize=True)

    Image.open(ROOT / "store" / "icon-512.png").save(OUT / "icon-512.png", optimize=True)

    for p in sorted(OUT.glob("*.png")):
        im = Image.open(p)
        w, h = im.size
        print(f"{p.name:26s} {w}x{h} {im.mode} ratio {max(w, h) / min(w, h):.2f} {p.stat().st_size // 1024} Ko")


if __name__ == "__main__":
    main()
