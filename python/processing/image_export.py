from __future__ import annotations
from pathlib import Path
import tifffile as tiff
import numpy as np
from PIL import Image

def to_uint8(image_float: np.ndarray) -> np.ndarray:
    return np.clip(image_float * 255, 0, 255).astype(np.uint8)

def to_uint16(image_float: np.ndarray) -> np.ndarray:
    return np.clip(image_float * 65535, 0, 65535).astype(np.uint16)

def save_as_jpg(image_data: np.ndarray, save_path: Path, quality: int, icc_profile: bytes | None):
    if image_data.dtype != np.uint8:
        image_data = to_uint8(image_data)
    pil_image = Image.fromarray(image_data, 'RGB')
    pil_image.save(save_path, format='JPEG', quality=quality)

def save_as_tif(
    image_data: np.ndarray,
    save_path: Path,
    bit_depth: int,
    icc_profile: bytes | None,
    compression: str = 'zlib'
):
    if bit_depth == 8:
        if image_data.dtype != np.uint8:
            image_data = to_uint8(image_data)
    elif bit_depth == 16:
        if image_data.dtype != np.uint16:
            image_data = to_uint16(image_data)
    tiff.imwrite(save_path, image_data)
