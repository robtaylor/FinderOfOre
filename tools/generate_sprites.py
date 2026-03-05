# /// script
# requires-python = ">=3.10"
# dependencies = ["Pillow"]
# ///
"""Generate all placeholder pixel art sprites for Finder of Ore.

Tile size: 32x32
Character sprites: 32x48 (4 directions x 4 frames = spritesheet)
Cat sprites: 24x24
Ore sprites: 32x32
"""

from pathlib import Path
from PIL import Image, ImageDraw

ROOT = Path(__file__).parent.parent
ASSETS = ROOT / "assets"


def save(img: Image.Image, *path_parts: str) -> None:
    out = ASSETS / Path(*path_parts)
    out.parent.mkdir(parents=True, exist_ok=True)
    img.save(out)
    print(f"  {out.relative_to(ROOT)}")


# --- Tile generation (32x32) ---

def generate_tiles() -> None:
    print("Generating tiles...")

    # Ground - grass green with subtle texture
    img = Image.new("RGBA", (32, 32), (77, 153, 51, 255))
    draw = ImageDraw.Draw(img)
    # Add grass detail dots
    for x, y in [(5, 7), (15, 3), (25, 10), (8, 20), (20, 25), (28, 15), (3, 28), (18, 14)]:
        draw.point((x, y), fill=(60, 130, 40, 255))
    for x, y in [(10, 12), (22, 8), (6, 24), (26, 28)]:
        draw.point((x, y), fill=(90, 170, 60, 255))
    save(img, "tilesets", "ground.png")

    # Dark grass variant
    img = Image.new("RGBA", (32, 32), (60, 120, 40, 255))
    draw = ImageDraw.Draw(img)
    for x, y in [(5, 7), (15, 3), (25, 10), (8, 20), (20, 25)]:
        draw.point((x, y), fill=(50, 100, 35, 255))
    save(img, "tilesets", "dark_grass.png")

    # Wall - stone with border and texture
    img = Image.new("RGBA", (32, 32), (100, 90, 75, 255))
    draw = ImageDraw.Draw(img)
    # Border
    draw.rectangle([0, 0, 31, 31], outline=(65, 58, 48, 255), width=2)
    # Stone cracks
    draw.line([(8, 2), (10, 12)], fill=(80, 72, 60, 255))
    draw.line([(20, 5), (22, 15)], fill=(80, 72, 60, 255))
    draw.line([(5, 18), (15, 20)], fill=(80, 72, 60, 255))
    draw.line([(18, 22), (28, 25)], fill=(80, 72, 60, 255))
    # Highlights
    draw.point((12, 8), fill=(120, 110, 95, 255))
    draw.point((25, 12), fill=(120, 110, 95, 255))
    save(img, "tilesets", "wall.png")

    # Path - sandy dirt
    img = Image.new("RGBA", (32, 32), (179, 153, 102, 255))
    draw = ImageDraw.Draw(img)
    for x, y in [(5, 5), (12, 18), (25, 8), (8, 28), (20, 22)]:
        draw.point((x, y), fill=(160, 138, 90, 255))
    for x, y in [(15, 10), (28, 20), (3, 15)]:
        draw.point((x, y), fill=(192, 168, 115, 255))
    save(img, "tilesets", "path.png")

    # Water - blue with wave effect
    img = Image.new("RGBA", (32, 32), (51, 102, 204, 255))
    draw = ImageDraw.Draw(img)
    # Wave highlights
    draw.line([(2, 8), (10, 6), (18, 8), (26, 6)], fill=(80, 130, 220, 255))
    draw.line([(4, 18), (12, 16), (20, 18), (28, 16)], fill=(80, 130, 220, 255))
    draw.line([(0, 28), (8, 26), (16, 28), (24, 26), (31, 28)], fill=(80, 130, 220, 255))
    save(img, "tilesets", "water.png")


# --- Character sprites (32x48) ---

def _draw_character(draw: ImageDraw.ImageDraw, x_off: int, y_off: int,
                    body_color: tuple, hair_color: tuple, facing: str,
                    frame: int = 0) -> None:
    """Draw a character at offset position within a spritesheet cell."""
    # Leg animation offset
    leg_shift = 0
    if frame == 1:
        leg_shift = -1
    elif frame == 3:
        leg_shift = 1

    # Skin color
    skin = (240, 200, 170, 255)

    # Body (shirt/dress) - center of sprite
    draw.rectangle([x_off + 8, y_off + 18, x_off + 23, y_off + 34], fill=body_color)

    # Head
    draw.rectangle([x_off + 10, y_off + 4, x_off + 21, y_off + 17], fill=skin)

    # Hair
    if facing == "down":
        draw.rectangle([x_off + 9, y_off + 2, x_off + 22, y_off + 8], fill=hair_color)
        # Eyes
        draw.point((x_off + 13, y_off + 11), fill=(30, 30, 30, 255))
        draw.point((x_off + 18, y_off + 11), fill=(30, 30, 30, 255))
    elif facing == "up":
        draw.rectangle([x_off + 9, y_off + 2, x_off + 22, y_off + 14], fill=hair_color)
    elif facing == "left":
        draw.rectangle([x_off + 9, y_off + 2, x_off + 22, y_off + 8], fill=hair_color)
        draw.rectangle([x_off + 9, y_off + 2, x_off + 12, y_off + 14], fill=hair_color)
        # Eye
        draw.point((x_off + 17, y_off + 11), fill=(30, 30, 30, 255))
    elif facing == "right":
        draw.rectangle([x_off + 9, y_off + 2, x_off + 22, y_off + 8], fill=hair_color)
        draw.rectangle([x_off + 19, y_off + 2, x_off + 22, y_off + 14], fill=hair_color)
        # Eye
        draw.point((x_off + 14, y_off + 11), fill=(30, 30, 30, 255))

    # Legs
    draw.rectangle([x_off + 10 + leg_shift, y_off + 35, x_off + 14 + leg_shift, y_off + 44], fill=(50, 50, 120, 255))
    draw.rectangle([x_off + 17 - leg_shift, y_off + 35, x_off + 21 - leg_shift, y_off + 44], fill=(50, 50, 120, 255))

    # Boots
    draw.rectangle([x_off + 10 + leg_shift, y_off + 42, x_off + 14 + leg_shift, y_off + 46], fill=(80, 50, 30, 255))
    draw.rectangle([x_off + 17 - leg_shift, y_off + 42, x_off + 21 - leg_shift, y_off + 46], fill=(80, 50, 30, 255))


def generate_player() -> None:
    """Generate Miku's 4-direction x 4-frame spritesheet (128x192)."""
    print("Generating player sprites...")
    sheet_w, sheet_h = 32 * 4, 48 * 4  # 4 frames x 4 directions
    img = Image.new("RGBA", (sheet_w, sheet_h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # Miku: teal hair, blue outfit
    body_color = (50, 150, 200, 255)
    hair_color = (0, 190, 190, 255)

    directions = ["down", "left", "right", "up"]
    for dir_idx, facing in enumerate(directions):
        for frame in range(4):
            x_off = frame * 32
            y_off = dir_idx * 48
            _draw_character(draw, x_off, y_off, body_color, hair_color, facing, frame)

    save(img, "sprites", "player", "miku.png")

    # Also save individual frame for non-animated use
    single = img.crop((0, 0, 32, 48))
    save(single, "sprites", "player", "miku_front.png")


def generate_queen() -> None:
    """Generate Queen NPC spritesheet."""
    print("Generating Queen sprite...")
    img = Image.new("RGBA", (32, 48), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    _draw_character(draw, 0, 0, (130, 30, 130, 255), (100, 20, 100, 255), "down", 0)

    # Crown
    draw.rectangle([10, 0, 21, 3], fill=(255, 215, 0, 255))
    draw.point((11, 0), fill=(255, 255, 100, 255))
    draw.point((15, 0), fill=(255, 100, 100, 255))  # Ruby
    draw.point((20, 0), fill=(255, 255, 100, 255))
    # Crown points
    draw.point((10, 0), fill=(0, 0, 0, 0))
    draw.point((13, 0), fill=(0, 0, 0, 0))
    draw.point((18, 0), fill=(0, 0, 0, 0))
    draw.point((21, 0), fill=(0, 0, 0, 0))

    save(img, "sprites", "npcs", "queen.png")


# --- Cat sprites (24x24) ---

def _draw_cat(draw: ImageDraw.ImageDraw, x_off: int, y_off: int,
              color: tuple, facing: str = "down") -> None:
    """Draw a cat sprite."""
    darker = tuple(max(0, c - 30) for c in color[:3]) + (255,)

    # Body
    draw.ellipse([x_off + 4, y_off + 8, x_off + 19, y_off + 20], fill=color)

    # Head
    draw.ellipse([x_off + 6, y_off + 2, x_off + 17, y_off + 12], fill=color)

    # Ears (triangles)
    draw.polygon([(x_off + 7, y_off + 4), (x_off + 5, y_off + 0), (x_off + 10, y_off + 3)], fill=darker)
    draw.polygon([(x_off + 16, y_off + 4), (x_off + 18, y_off + 0), (x_off + 13, y_off + 3)], fill=darker)

    # Tail
    draw.line([(x_off + 18, y_off + 14), (x_off + 22, y_off + 10), (x_off + 22, y_off + 7)], fill=darker, width=2)

    if facing == "down":
        # Eyes
        draw.point((x_off + 9, y_off + 7), fill=(30, 30, 30, 255))
        draw.point((x_off + 14, y_off + 7), fill=(30, 30, 30, 255))
        # Nose
        draw.point((x_off + 11, y_off + 9), fill=(255, 150, 150, 255))

    # Paws
    draw.rectangle([x_off + 5, y_off + 18, x_off + 8, y_off + 22], fill=darker)
    draw.rectangle([x_off + 15, y_off + 18, x_off + 18, y_off + 22], fill=darker)


def generate_cats() -> None:
    """Generate cat species sprites."""
    print("Generating cat sprites...")

    cats = {
        "copper_tabby": (204, 128, 51, 255),
        "iron_persian": (153, 153, 178, 255),
        "gold_siamese": (255, 217, 77, 255),
    }

    for name, color in cats.items():
        img = Image.new("RGBA", (24, 24), (0, 0, 0, 0))
        draw = ImageDraw.Draw(img)
        _draw_cat(draw, 0, 0, color)
        save(img, "sprites", "cats", f"{name}.png")

    # Wild cat exclamation mark sprite
    img = Image.new("RGBA", (16, 16), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    draw.rectangle([6, 1, 9, 10], fill=(255, 255, 50, 255))
    draw.rectangle([6, 12, 9, 14], fill=(255, 255, 50, 255))
    # Outline
    draw.rectangle([5, 0, 10, 11], outline=(0, 0, 0, 255))
    draw.rectangle([5, 11, 10, 15], outline=(0, 0, 0, 255))
    save(img, "sprites", "cats", "exclamation.png")


# --- Ore sprites (32x32) ---

def _draw_ore(draw: ImageDraw.ImageDraw, color: tuple, highlight: tuple) -> None:
    """Draw an ore deposit."""
    darker = tuple(max(0, c - 40) for c in color[:3]) + (255,)

    # Rock base shape (irregular)
    draw.polygon([
        (6, 28), (3, 20), (5, 12), (10, 6), (18, 4),
        (26, 7), (29, 14), (28, 24), (22, 29)
    ], fill=color, outline=darker)

    # Ore veins/sparkles
    draw.rectangle([12, 10, 15, 13], fill=highlight)
    draw.rectangle([20, 14, 22, 16], fill=highlight)
    draw.rectangle([10, 19, 12, 21], fill=highlight)
    draw.point((17, 8), fill=highlight)
    draw.point((24, 20), fill=highlight)

    # Shading on bottom-right
    draw.line([(22, 29), (28, 24)], fill=darker, width=2)
    draw.line([(28, 24), (29, 14)], fill=darker)


def generate_ores() -> None:
    """Generate ore deposit sprites."""
    print("Generating ore sprites...")

    ores = {
        "copper": ((180, 110, 60, 255), (220, 160, 80, 255)),
        "iron": ((140, 140, 155, 255), (200, 200, 220, 255)),
        "gold": ((200, 170, 50, 255), (255, 240, 100, 255)),
    }

    for name, (color, highlight) in ores.items():
        img = Image.new("RGBA", (32, 32), (0, 0, 0, 0))
        draw = ImageDraw.Draw(img)
        _draw_ore(draw, color, highlight)
        save(img, "sprites", "ores", f"{name}.png")


# --- UI sprites ---

def generate_ui() -> None:
    """Generate UI sprites."""
    print("Generating UI sprites...")

    # Ore indicator arrow
    img = Image.new("RGBA", (16, 16), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    draw.polygon([(15, 7), (8, 3), (8, 11)], fill=(255, 230, 50, 255), outline=(200, 180, 30, 255))
    save(img, "sprites", "ui", "ore_arrow.png")

    # Mining progress bar background
    img = Image.new("RGBA", (32, 6), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    draw.rectangle([0, 0, 31, 5], fill=(40, 40, 40, 200), outline=(80, 80, 80, 255))
    save(img, "sprites", "ui", "progress_bg.png")

    # Mining progress bar fill
    img = Image.new("RGBA", (30, 4), (50, 200, 50, 255))
    save(img, "sprites", "ui", "progress_fill.png")


if __name__ == "__main__":
    print("=== Finder of Ore Sprite Generator ===\n")
    generate_tiles()
    generate_player()
    generate_queen()
    generate_cats()
    generate_ores()
    generate_ui()
    print("\nDone! All sprites generated.")
