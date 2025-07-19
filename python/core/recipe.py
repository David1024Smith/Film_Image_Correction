#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Revela - Professional Film Processing System

Processing recipe definitions for different film types and development styles

File Information:
    File Name: recipe.py
    Author: Flemyng
    Email: flemyng1999@gmail.com
    Created: 2025-07-18 12:44:01
    Last Modified: 2025-07-18 12:44:01
    Version: 1.0.0
    Python Version: 3.12+
    License: GPL-3.0 license

Project Information:
    Project: Revela
    Repository: https://github.com/Flemyng1999/Revela
    Documentation: https://github.com/Flemyng1999/Revela/docs

Dependencies:
    Required packages:
    - yaml
    - typing

Copyright (c) 2025 Flemyng. All rights reserved.
This file is part of the Revela project.

For more information, please refer to the project documentation.
"""


from __future__ import annotations

from enum import Enum
from pathlib import Path
from dataclasses import dataclass, field

import numpy as np


# 这个类包含了所有用于分析整卷胶卷的技术参数。
# 这些是 “科学” 设定。
@dataclass
class TechnicalRecipe:
    """定义用于胶卷分析的技术参数。"""
    reference_mode: str = "Auto"  # Dmin Dmax获取方式: "Auto" 或 "Manual"
    align_mode: str = "Auto"      # 对齐方式: "Auto" 或 "Manual"

    dmin_percentile: float = 3.0
    dmax_percentile: float = 99.9

    extrema_high_density_percentile: float = 99.9999
    extrema_high_density_multiplier: float = 1.0
    threshold_percentile: float = 98.0
    threshold_multiplier: float = 1.0
    high_density_percentile: float = 99.0
    interpolation_factor: float = 2.0
    bins_number: int = 1024

    target_extrema_high_density_mode: str = "Auto"
    target_extrema_high_density_factor: float = 1.0
    input_target_extrema_high_density: float = 0.2
    extrema_high_density_threshold: float = 0.45

    efficiency_power: float = 1.0
    light_ratio: list[float] = field(
        default_factory=lambda: [1.0, 1.0, 1.0]
    )

    # 手动模式下的输入值
    manual_d_min: np.ndarray = field(
        default_factory=lambda: np.array([0.1838453, 0.49051684, 0.86234473])
    )
    manual_d_max: np.ndarray = field(
        default_factory=lambda: np.array([1.4, 2.6, 2.8])
    )
    manual_k: np.ndarray = field(
        default_factory=lambda: np.array([1.0, 0.94, 0.88])
    )

# 这个类包含了用户可能进行的创意性调整。
# 它会随着您添加更多编辑工具而成长。
@dataclass
class CreativeRecipe:
    """定义应用于图像的创意性调整。"""
    tone_mapping: str = "Standard"  # "None", "Standard", "Enhanced"
    display_mode: str = "Displays" # "Displays", "LUT"
    display_space: str = "Display P3 - Display"
    lut_name: str = "Kodak 2383 (D65)"
    flip_up_and_down: bool = True
    jpg_quality: int = 90

    # exposure_adjustment: float = 0.0
    # contrast: float = 1.0
    # saturation: float = 1.0


class ExportFormat(Enum):
    """定义支持的导出格式。"""
    JPG = "jpg"
    PNG = "png"
    TIF_8_BIT = "tif8"
    TIF_16_BIT = "tif16"


@dataclass
class ExportRecipe:
    """定义一次导出任务的所有参数。"""
    export_format: ExportFormat = ExportFormat.JPG
    quality: int = 90  # 仅用于JPG格式 (1-100)

    output_directory: Path | None = None
    filename_suffix: str = "exported"
    icc_bytes: bytes | None = None   # 输出色彩配置
