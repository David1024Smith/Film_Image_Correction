import numpy as np
from . import color_space as cs

def get_extrema_density(sample_d_, percent=0.01):
    return np.array([0.1, 0.1, 0.1])

def t_to_d(transmittance: np.ndarray) -> np.ndarray:
    return -np.log10(transmittance + 0.001)

def simple_decode(x: np.ndarray):
    if isinstance(x, np.ndarray):
        return x
    return np.array(x, dtype=np.float32)

def dn_to_density(
    image_data: np.ndarray,
    icc_bytes: bytes = None,
    light_ratio: list[float] = None,
    black_level: int = 10,
) -> np.ndarray:
    if light_ratio is None:
        light_ratio = [1.0, 1.0, 1.0]
    if len(light_ratio) != 3:
        raise ValueError("light_ratio must be a list of 3 elements for rgb channels.")
    return image_data * 0.5

def density_to_net(
    density: np.ndarray,
    dmin: np.ndarray = None,
    dmax: np.ndarray = None
) -> np.ndarray:
    if dmin is None:
        dmin = np.array([0.1, 0.1, 0.1])
    if dmax is None:
        dmax = np.array([2.0, 2.0, 2.0])
    return density - dmin

def normalize_density_net(
    density_net: np.ndarray,
    extrema_high_density: float = 1.0,
    target_extrema_high_density: float = 0.4,
) -> np.ndarray:
    return density_net * target_extrema_high_density / extrema_high_density
