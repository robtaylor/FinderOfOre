# /// script
# requires-python = ">=3.10"
# dependencies = ["Pillow"]
# ///
"""Process all of Holly's new sprite animations at once.

1. Mining animation (5 frames) -> player mining SpriteFrames
2. Updated cat animation (2 frames) -> cat SpriteFrames + color variants
3. Queen animation (6 frames) -> queen SpriteFrames
"""

from PIL import Image, ImageOps
from pathlib import Path
import colorsys

PROJECT = Path(__file__).parent.parent
DOWNLOADS = Path("/Users/roberttaylor/Downloads")


def remove_background(img: Image.Image, threshold: int = 240) -> Image.Image:
    """Remove white/near-white background."""
    img = img.convert("RGBA")
    pixels = img.load()
    w, h = img.size
    for y in range(h):
        for x in range(w):
            r, g, b, a = pixels[x, y]
            if r > threshold and g > threshold and b > threshold:
                pixels[x, y] = (0, 0, 0, 0)
    return img


def crop_to_content(img: Image.Image) -> Image.Image:
    bbox = img.getbbox()
    return img.crop(bbox) if bbox else img


def fit_to_frame(img: Image.Image, w: int, h: int) -> Image.Image:
    """Scale to fit frame, center horizontally, align feet to bottom."""
    img_w, img_h = img.size
    scale = min(w / img_w, h / img_h)
    new_w = max(1, int(img_w * scale))
    new_h = max(1, int(img_h * scale))
    img = img.resize((new_w, new_h), Image.NEAREST)
    canvas = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    x_off = (w - new_w) // 2
    y_off = h - new_h
    canvas.paste(img, (x_off, y_off), img)
    return canvas


def hue_shift(img: Image.Image, hue_delta: float, sat_mult: float = 1.0,
              val_mult: float = 1.0) -> Image.Image:
    """Shift hue of non-transparent pixels."""
    img = img.copy()
    pixels = img.load()
    w, h = img.size
    for y in range(h):
        for x in range(w):
            r, g, b, a = pixels[x, y]
            if a < 10:
                continue
            h_val, s, v = colorsys.rgb_to_hsv(r / 255.0, g / 255.0, b / 255.0)
            h_val = (h_val + hue_delta) % 1.0
            s = min(1.0, s * sat_mult)
            v = min(1.0, v * val_mult)
            r2, g2, b2 = colorsys.hsv_to_rgb(h_val, s, v)
            pixels[x, y] = (int(r2 * 255), int(g2 * 255), int(b2 * 255), a)
    return img


def process_mining():
    """Process 5 mining frames into individual PNGs for SpriteFrames."""
    print("\n=== MINING ANIMATION ===")
    out_dir = PROJECT / "assets" / "sprites" / "player"
    out_dir.mkdir(parents=True, exist_ok=True)

    frames = []
    for i in range(1, 6):
        img = Image.open(DOWNLOADS / f"mining - {i}.png")
        img = remove_background(img)
        img = crop_to_content(img)
        img = fit_to_frame(img, 48, 48)  # Mining is wider due to pickaxe swing
        frames.append(img)
        img.save(out_dir / f"mining_frame{i-1}.png")
        print(f"  Frame {i}: saved")

    print(f"  Saved 5 mining frames to {out_dir}/mining_frame*.png")
    return frames


def process_cats():
    """Process 2 new cat frames + generate color variants."""
    print("\n=== CAT ANIMATION ===")
    cat_dir = PROJECT / "assets" / "sprites" / "cats"
    cat_dir.mkdir(parents=True, exist_ok=True)

    frames = []
    for i in range(1, 3):
        img = Image.open(DOWNLOADS / f"cat-new - {i}.png")
        img = remove_background(img)
        img = crop_to_content(img)
        img = fit_to_frame(img, 32, 32)
        frames.append(img)

    # Base cat (copper tabby) - right-facing frames
    for i, frame in enumerate(frames):
        frame.save(cat_dir / f"cat1-frame{i}.png")
        # Left-facing
        flipped = ImageOps.mirror(frame)
        flipped.save(cat_dir / f"cat1-frame{i}-left.png")

    print("  Copper tabby: saved")

    # Iron Persian - silver/grey shift
    for i, frame in enumerate(frames):
        shifted = hue_shift(frame, hue_delta=0.55, sat_mult=0.3, val_mult=1.1)
        shifted.save(cat_dir / f"iron_persian-frame{i}.png")
        flipped = ImageOps.mirror(shifted)
        flipped.save(cat_dir / f"iron_persian-frame{i}-left.png")
    print("  Iron Persian: saved")

    # Gold Siamese - golden shift
    for i, frame in enumerate(frames):
        shifted = hue_shift(frame, hue_delta=0.08, sat_mult=1.2, val_mult=1.15)
        shifted.save(cat_dir / f"gold_siamese-frame{i}.png")
        flipped = ImageOps.mirror(shifted)
        flipped.save(cat_dir / f"gold_siamese-frame{i}-left.png")
    print("  Gold Siamese: saved")


def process_queen():
    """Process 6 queen animation frames."""
    print("\n=== QUEEN ANIMATION ===")
    out_dir = PROJECT / "assets" / "sprites" / "npcs"
    out_dir.mkdir(parents=True, exist_ok=True)

    frames = []
    for i in range(1, 7):
        img = Image.open(DOWNLOADS / f"queen-anim - {i}.png")
        img = remove_background(img)
        img = crop_to_content(img)
        img = fit_to_frame(img, 32, 48)
        frames.append(img)
        img.save(out_dir / f"queen_frame{i-1}.png")
        print(f"  Frame {i}: saved")

    print(f"  Saved 6 queen frames to {out_dir}/queen_frame*.png")
    return frames


def main():
    process_mining()
    process_cats()
    process_queen()
    print("\nAll sprites processed!")


if __name__ == "__main__":
    main()
