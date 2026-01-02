#!/usr/bin/env python3
"""Generate app icon for LiveRadio with radio tower and signal waves."""

from PIL import Image, ImageDraw
import math
import os

def create_icon(size):
    """Create a radio tower icon with signal waves."""
    # Dark background
    img = Image.new('RGBA', (size, size), (20, 20, 26, 255))
    draw = ImageDraw.Draw(img)

    center_x = size // 2
    center_y = size // 2

    # Orange color for the icon elements
    orange = (255, 149, 0, 255)
    orange_dim = (255, 149, 0, 180)
    orange_faint = (255, 149, 0, 100)

    # Scale factor based on size
    scale = size / 1024

    # Draw signal waves (arcs emanating from top of tower)
    tower_top_y = int(center_y - 180 * scale)

    # Draw 3 signal wave arcs on each side
    for i, (radius, alpha) in enumerate([(280, 100), (380, 70), (480, 40)]):
        r = int(radius * scale)
        wave_color = (255, 149, 0, alpha)
        line_width = max(int(18 * scale), 2)

        # Left arc
        bbox = [center_x - r, tower_top_y - r, center_x + r, tower_top_y + r]
        draw.arc(bbox, start=200, end=250, fill=wave_color, width=line_width)

        # Right arc
        draw.arc(bbox, start=290, end=340, fill=wave_color, width=line_width)

    # Draw the radio tower
    tower_width_top = int(30 * scale)
    tower_width_bottom = int(160 * scale)
    tower_height = int(400 * scale)
    tower_bottom_y = int(center_y + 200 * scale)

    # Tower body (trapezoid)
    tower_points = [
        (center_x - tower_width_top, tower_top_y),
        (center_x + tower_width_top, tower_top_y),
        (center_x + tower_width_bottom, tower_bottom_y),
        (center_x - tower_width_bottom, tower_bottom_y),
    ]
    draw.polygon(tower_points, fill=orange)

    # Antenna on top
    antenna_height = int(80 * scale)
    antenna_width = max(int(8 * scale), 2)
    draw.rectangle([
        center_x - antenna_width // 2,
        tower_top_y - antenna_height,
        center_x + antenna_width // 2,
        tower_top_y
    ], fill=orange)

    # Antenna tip (circle)
    tip_radius = int(16 * scale)
    draw.ellipse([
        center_x - tip_radius,
        tower_top_y - antenna_height - tip_radius,
        center_x + tip_radius,
        tower_top_y - antenna_height + tip_radius
    ], fill=orange)

    # Tower cross-beams
    num_beams = 5
    for i in range(num_beams):
        t = (i + 1) / (num_beams + 1)
        y = int(tower_top_y + t * tower_height)
        width_at_y = tower_width_top + t * (tower_width_bottom - tower_width_top)
        beam_thickness = max(int(10 * scale), 1)

        # Horizontal beam
        draw.rectangle([
            int(center_x - width_at_y),
            y - beam_thickness // 2,
            int(center_x + width_at_y),
            y + beam_thickness // 2
        ], fill=(30, 30, 36, 255))

        # Diagonal beams (X pattern)
        if i < num_beams - 1:
            next_t = (i + 2) / (num_beams + 1)
            next_y = int(tower_top_y + next_t * tower_height)
            next_width = tower_width_top + next_t * (tower_width_bottom - tower_width_top)

            line_width = max(int(6 * scale), 1)
            # Left diagonal
            draw.line([
                (int(center_x - width_at_y), y),
                (int(center_x - next_width), next_y)
            ], fill=(30, 30, 36, 255), width=line_width)
            draw.line([
                (int(center_x - width_at_y), y),
                (int(center_x), next_y)
            ], fill=(30, 30, 36, 255), width=line_width)

            # Right diagonal
            draw.line([
                (int(center_x + width_at_y), y),
                (int(center_x + next_width), next_y)
            ], fill=(30, 30, 36, 255), width=line_width)
            draw.line([
                (int(center_x + width_at_y), y),
                (int(center_x), next_y)
            ], fill=(30, 30, 36, 255), width=line_width)

    return img


def main():
    # Icon sizes needed for iOS
    sizes = [
        (20, 1), (20, 2), (20, 3),
        (29, 1), (29, 2), (29, 3),
        (40, 1), (40, 2), (40, 3),
        (60, 2), (60, 3),
        (76, 1), (76, 2),
        (83.5, 2),
        (1024, 1),
    ]

    output_dir = "/Users/joseph/Code/LiveRadio/LiveRadio/Assets.xcassets/AppIcon.appiconset"
    os.makedirs(output_dir, exist_ok=True)

    # Generate icons
    images = []
    for base_size, scale in sizes:
        actual_size = int(base_size * scale)
        icon = create_icon(actual_size)

        if base_size == 83.5:
            filename = f"icon-{base_size}@{scale}x.png"
        elif scale == 1:
            filename = f"icon-{int(base_size)}.png"
        else:
            filename = f"icon-{int(base_size)}@{scale}x.png"

        filepath = os.path.join(output_dir, filename)
        icon.save(filepath, "PNG")
        print(f"Created {filename} ({actual_size}x{actual_size})")
        images.append((base_size, scale, filename))

    # Generate Contents.json
    contents = {
        "images": [],
        "info": {"author": "xcode", "version": 1}
    }

    idiom_map = {
        (20, 2): ("iphone", "20x20", "2x"),
        (20, 3): ("iphone", "20x20", "3x"),
        (29, 2): ("iphone", "29x29", "2x"),
        (29, 3): ("iphone", "29x29", "3x"),
        (40, 2): ("iphone", "40x40", "2x"),
        (40, 3): ("iphone", "40x40", "3x"),
        (60, 2): ("iphone", "60x60", "2x"),
        (60, 3): ("iphone", "60x60", "3x"),
        (20, 1): ("ipad", "20x20", "1x"),
        (20, 2): ("ipad", "20x20", "2x"),
        (29, 1): ("ipad", "29x29", "1x"),
        (29, 2): ("ipad", "29x29", "2x"),
        (40, 1): ("ipad", "40x40", "1x"),
        (40, 2): ("ipad", "40x40", "2x"),
        (76, 1): ("ipad", "76x76", "1x"),
        (76, 2): ("ipad", "76x76", "2x"),
        (83.5, 2): ("ipad", "83.5x83.5", "2x"),
        (1024, 1): ("ios-marketing", "1024x1024", "1x"),
    }

    for base_size, scale, filename in images:
        key = (base_size, scale)
        if key in idiom_map:
            idiom, size_str, scale_str = idiom_map[key]
            contents["images"].append({
                "filename": filename,
                "idiom": idiom,
                "scale": scale_str,
                "size": size_str
            })

    import json
    contents_path = os.path.join(output_dir, "Contents.json")
    with open(contents_path, "w") as f:
        json.dump(contents, f, indent=2)
    print(f"Created Contents.json")


if __name__ == "__main__":
    main()
