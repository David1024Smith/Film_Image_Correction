#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Revela - Professional Film Processing System

Color calibration and ICC profile management for accurate color reproduction

File Information:
    File Name: calibration.py
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
    - colour-science
    - numpy

Copyright (c) 2025 Flemyng. All rights reserved.
This file is part of the Revela project.

For more information, please refer to the project documentation.
"""


from dataclasses import dataclass
import numpy as np

@dataclass
class RollCalibrationProfile:
    """存储一整卷胶卷的分析计算结果。"""
    d_min: np.ndarray
    d_max: np.ndarray

    hist_bins: np.ndarray
    hist_values: np.ndarray

    k_values: np.ndarray

    extrema_high_density_net: float
    clip_threshold: float
