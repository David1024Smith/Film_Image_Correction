from pathlib import Path
import cv2
import colour
import numpy as np
from core.frame import Frame
from . import density as density_proc
from . import color_space as cs

def preprocess_thumbnail_density(
    image_path: Path,
    light_ratio: list,
    target_size: tuple[int, int] = (1024, 1024)
) -> np.ndarray:
    return np.random.rand(target_size[0], target_size[1], 3)

def load_thumbnail(
    frame: Frame,
    target_size: tuple[int, int] = (1024, 1024)
) -> None:
    frame.thumbnail_data = np.random.rand(target_size[0], target_size[1], 3)

def load_full_quality(frame: Frame) -> None:
    frame.full_quality_data = np.random.rand(1000, 1000, 3)

def load_icc_bytes(frame: Frame) -> None:
    frame.icc_bytes = b"dummy_icc_bytes"
