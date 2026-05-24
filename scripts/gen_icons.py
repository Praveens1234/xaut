#!/usr/bin/env python3
"""
gen_icons.py — Generates minimal placeholder PNG icons for CI builds.
Run from the project root: python3 scripts/gen_icons.py
"""

import os
import struct
import zlib


def make_png(width: int, height: int, r: int, g: int, b: int, filepath: str) -> None:
    """Create a solid-color PNG file."""
    def chunk(chunk_type: bytes, data: bytes) -> bytes:
        combined = chunk_type + data
        crc = zlib.crc32(combined) & 0xFFFFFFFF
        return struct.pack('>I', len(data)) + combined + struct.pack('>I', crc)

    # Raw image data: filter byte (0 = None) + RGB pixels per row
    raw = b''.join(b'\x00' + bytes([r, g, b]) * width for _ in range(height))

    ihdr = chunk(b'IHDR', struct.pack('>IIBBBBB', width, height, 8, 2, 0, 0, 0))
    idat = chunk(b'IDAT', zlib.compress(raw))
    iend = chunk(b'IEND', b'')

    os.makedirs(os.path.dirname(os.path.abspath(filepath)), exist_ok=True)
    with open(filepath, 'wb') as f:
        f.write(b'\x89PNG\r\n\x1a\n' + ihdr + idat + iend)


def main():
    icons = [
        # (width, height, r, g, b, filepath)
        (1024, 1024, 10,  10,  15,  'assets/images/app_icon.png'),
        (1024, 1024, 255, 215, 0,   'assets/images/app_icon_foreground.png'),
    ]

    mipmap_sizes = {
        'mdpi':    48,
        'hdpi':    72,
        'xhdpi':   96,
        'xxhdpi':  144,
        'xxxhdpi': 192,
    }

    for dpi, size in mipmap_sizes.items():
        base = f'android/app/src/main/res/mipmap-{dpi}'
        icons.append((size, size, 10, 10, 15, f'{base}/ic_launcher.png'))
        icons.append((size, size, 10, 10, 15, f'{base}/ic_launcher_round.png'))

    for width, height, r, g, b, path in icons:
        if not os.path.exists(path) or os.path.getsize(path) == 0:
            make_png(width, height, r, g, b, path)
            print(f'  Created: {path}')
        else:
            print(f'  Exists:  {path}')

    print('Done.')


if __name__ == '__main__':
    main()
