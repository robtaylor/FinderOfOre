# /// script
# requires-python = ">=3.10"
# dependencies = ["Pillow"]
# ///
"""Process Holly's Miku character frames into a game spritesheet.

Input: 2 frames of right-facing walk animation at 64x64
Output: 32x48 spritesheet with 4 directions x walk/idle frames
"""

from PIL import Image, ImageOps
from pathlib import Path

PROJECT = Path(__file__).parent.parent
ASSETS = PROJECT / "assets" / "sprites" / "player"
FRAME_W, FRAME_H = 32, 48

# Source images - both are right-facing walk frames
FRAME_0 = Path("/Users/roberttaylor/Library/Messages/Attachments/36/06/FF497407-4770-4521-946A-9D108DA4A962/Untitled 3 1.png")
FRAME_1 = Path("/Users/roberttaylor/Library/Messages/Attachments/75/05/93CFBD02-AED5-41B0-8594-6A83A1CF8E33/Untitled 3 3.png")


def remove_background(img: Image.Image) -> Image.Image:
    """Remove white/near-white background, make transparent."""
    img = img.convert("RGBA")
    pixels = img.load()
    w, h = img.size
    for y in range(h):
        for x in range(w):
            r, g, b, a = pixels[x, y]
            if r > 240 and g > 240 and b > 240:
                pixels[x, y] = (0, 0, 0, 0)
            elif r > 220 and g > 220 and b > 220 and a > 200:
                pixels[x, y] = (0, 0, 0, 0)
    return img


def crop_to_content(img: Image.Image) -> Image.Image:
    """Crop to non-transparent bounding box."""
    bbox = img.getbbox()
    if bbox:
        return img.crop(bbox)
    return img


def fit_to_frame(img: Image.Image, w: int = FRAME_W, h: int = FRAME_H) -> Image.Image:
    """Scale and center image to fit in frame, preserving aspect ratio."""
    img_w, img_h = img.size
    scale = min(w / img_w, h / img_h)
    new_w = int(img_w * scale)
    new_h = int(img_h * scale)
    img = img.resize((new_w, new_h), Image.NEAREST)

    # Center horizontally, align feet to bottom
    canvas = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    x_off = (w - new_w) // 2
    y_off = h - new_h
    canvas.paste(img, (x_off, y_off), img)
    return canvas


def main():
    ASSETS.mkdir(parents=True, exist_ok=True)

    print("Loading Holly's right-walk frames...")
    raw_0 = Image.open(FRAME_0)
    raw_1 = Image.open(FRAME_1)
    print(f"  Frame 0: {raw_0.size}")
    print(f"  Frame 1: {raw_1.size}")

    # Remove background, crop, fit
    print("Processing...")
    clean_0 = remove_background(raw_0)
    clean_1 = remove_background(raw_1)

    cropped_0 = crop_to_content(clean_0)
    cropped_1 = crop_to_content(clean_1)
    print(f"  Frame 0 after crop: {cropped_0.size}")
    print(f"  Frame 1 after crop: {cropped_1.size}")

    right_0 = fit_to_frame(cropped_0)
    right_1 = fit_to_frame(cropped_1)

    # Generate all directions
    print("Generating direction variants...")

    # Right: Holly's frames as-is
    walk_right_0 = right_0
    walk_right_1 = right_1

    # Left: flip horizontally
    walk_left_0 = ImageOps.mirror(right_0)
    walk_left_1 = ImageOps.mirror(right_1)

    # Down/Up: We don't have Holly's art for these yet.
    # Use frame 0 of right-walk as a stand-in for down (front-ish),
    # and flipped version for up. This is temporary until Holly draws them.
    walk_down_0 = right_0
    walk_down_1 = right_1
    walk_up_0 = walk_left_0
    walk_up_1 = walk_left_1

    # Build spritesheet: 4 cols x 4 rows (same layout as before)
    # Rows: down, left, right, up
    # Cols: frame 0, frame 1, frame 0, frame 1 (repeated for 4-frame cycle)
    COLS = 4
    ROWS = 4
    sheet = Image.new("RGBA", (FRAME_W * COLS, FRAME_H * ROWS), (0, 0, 0, 0))

    directions = [
        (walk_down_0, walk_down_1),   # Row 0: Down
        (walk_left_0, walk_left_1),   # Row 1: Left
        (walk_right_0, walk_right_1), # Row 2: Right
        (walk_up_0, walk_up_1),       # Row 3: Up
    ]

    for row, (f0, f1) in enumerate(directions):
        y = row * FRAME_H
        sheet.paste(f0, (0, y))
        sheet.paste(f1, (FRAME_W, y))
        sheet.paste(f0, (FRAME_W * 2, y))
        sheet.paste(f1, (FRAME_W * 3, y))

    output = ASSETS / "miku.png"
    sheet.save(output)
    print(f"\nSpritesheet saved to {output}")
    print(f"  Size: {sheet.size} ({COLS} cols x {ROWS} rows, {FRAME_W}x{FRAME_H} each)")

    # Save individual processed frames for reference
    right_0.save(ASSETS / "miku_right_walk0.png")
    right_1.save(ASSETS / "miku_right_walk1.png")
    walk_left_0.save(ASSETS / "miku_left_walk0.png")
    walk_left_1.save(ASSETS / "miku_left_walk1.png")
    print("Individual frames saved too.")


if __name__ == "__main__":
    main()
