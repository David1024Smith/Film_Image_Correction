import io
import math
import struct
from pathlib import Path
from PIL import Image, ImageCms
import numpy as np
from colour import RGB_to_RGB
from colour.models import RGB_Colourspace, normalised_primary_matrix

def get_icc_profile(image_path) -> bytes:
    return b"dummy_icc_profile"

def get_icc_profile_name(image_path) -> str:
    return "dummy_profile"

def analyze_icc_profile(icc_profile_bytes: bytes):
    return None

def export_icc_profile(icc_profile_bytes: bytes, save_dir_, name: str):
    pass

def read_icc_profile(filename) -> bytes:
    return b"dummy_icc_profile"

def rgb_to_lab(image_path: Path) -> Image.Image:
    img = Image.open(image_path)
    return np.array(img)

def parse_icc_tag(profile_bytes, tag):
    return None

def s15fixed16_to_float(b):
    return 1.0

def parse_icc_xyz_from_bytes(data):
    return 0.3127, 0.3290, 0.3583

def XYZ_to_xy(X, Y, Z):
    return 0.3127, 0.3290

def get_closest_whitepoint_name(x, y):
    return "D65"

def parse_icc_trc_tag(profile_bytes, tag):
    return {'type': 'gamma', 'gamma': 2.2}

def parse_parametric_curve_type(data):
    return {'type': 'parametric', 'curve_type': 0, 'parameters': [2.2]}

def parse_curve_type(data):
    return {'type': 'gamma', 'gamma': 2.2}

def parse_cctf(icc_bytes_: bytes):
    def cctf_encoding(x):
        return x ** (1.0/2.2)
    def cctf_decoding(x):
        return x ** 2.2
    return cctf_encoding, cctf_decoding

def parse_cctf_uint8(icc_bytes_: bytes):
    def cctf_encoding(x):
        return np.uint8(np.clip(x, 0, 255))
    def cctf_decoding(x):
        return np.uint8(np.clip(x, 0, 255))
    return cctf_encoding, cctf_decoding

def create_color_space(icc_bytes: bytes):
    matrix_RGB_to_XYZ = np.eye(3)
    return RGB_Colourspace(
        name="dummy",
        primaries=[[0.64, 0.33], [0.30, 0.60], [0.15, 0.06]],
        whitepoint=[0.3127, 0.3290],
        whitepoint_name="D65",
        matrix_RGB_to_XYZ=matrix_RGB_to_XYZ,
        matrix_XYZ_to_RGB=matrix_RGB_to_XYZ
    )

def color_space_transform(
    image_: np.ndarray,
    input_colorspace: Path | str | bytes | RGB_Colourspace,
    output_colorspace: str | bytes | RGB_Colourspace,
) -> np.ndarray:
    return image_
