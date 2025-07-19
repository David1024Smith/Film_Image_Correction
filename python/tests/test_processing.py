#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Revela - Professional Film Processing System

Module for test_processing functionality in the Revela film processing system

File Information:
    File Name: test_processing.py
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

Copyright (c) 2025 Flemyng. All rights reserved.
This file is part of the Revela project.

For more information, please refer to the project documentation.
"""


import sys
import unittest
from pathlib import Path

import numpy as np

# 添加父目录到Python路径，确保能找到processing模块
current_dir = Path(__file__).parent
python_dir = current_dir.parent
if str(python_dir) not in sys.path:
    sys.path.insert(0, str(python_dir))

from processing.density import t_to_d # 导入您想测试的函数


class TestProcessingDensity(unittest.TestCase):
    """测试透射率到密度的转换函数。"""
    def test_t_to_d_conversion(self):
        """测试透射率到密度的转换是否正确。"""
        transmittance = np.array([1.0, 0.1, 0.01])
        expected_density = np.array([0.0, 1.0, 2.0])

        actual_density = t_to_d(transmittance)

        # 使用numpy的测试工具来比较浮点数数组
        np.testing.assert_array_almost_equal(actual_density, expected_density)

    def test_t_to_d_with_zero(self):
        """测试当输入接近零时，函数是否能健壮地处理。"""
        transmittance = np.array([0.0])
        # log10(1/0)是无穷大，但我们的函数应该通过裁切避免错误
        # 期望一个非常大的数，而不是程序崩溃
        density = t_to_d(transmittance)
        self.assertTrue(np.all(density > 9)) # 1e-10的对数是10
