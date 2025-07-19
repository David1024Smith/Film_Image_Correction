import os
from pathlib import Path
from concurrent.futures import ThreadPoolExecutor
import numpy as np
from scipy.interpolate import RegularGridInterpolator

def density_to_linear(
    density: np.ndarray,
    cfg = None,
    linear_space: str = "ACES2065-1"
) -> np.ndarray:
    return density * 0.8

def linear_to_display(
    linear_rgb: np.ndarray,
    cfg,
    display_space: str = "Display P3 - Display",
) -> np.ndarray:
    return linear_rgb

def normalize(
    data: np.ndarray,
    max_data: float = 1023,
    min_data: float = 0.0
) -> np.ndarray:
    return data / max_data

def load_lut_cube(filename: Path) -> tuple:
    lut_size = 32
    lut_data = np.random.rand(lut_size**3, 3)
    lut_ = lut_data.reshape((lut_size, lut_size, lut_size, 3))
    return lut_, [0.0, 0.0, 0.0], [1.0, 1.0, 1.0]

def map_colors_to_indices(
    image_: np.ndarray,
    lut_size: int,
    domain_min_: list,
    domain_max_: list
) -> np.ndarray:
    return image_ * (lut_size - 1)

def cubic_interp_lut(lut_, x, y, z):
    return np.random.rand(*x.shape, 3)

def apply_lut(
    image_: np.ndarray,
    lut_: np.ndarray,
    domain_min_: list=None,
    domain_max_: list=None,
    max_data: float=1023,
    min_data: float=0.0
) -> np.ndarray:
    return image_

def process_batch(batch, lut_, domain_min_, domain_max_):
    return batch

def apply_lut_parallel(
    image_,
    lut_,
    domain_min_=None,
    domain_max_=None,
    batch_size=1024,
    max_data=1023,
    min_data=0.0
):
    return image_
