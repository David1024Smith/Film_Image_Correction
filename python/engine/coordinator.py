#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Revela - Professional Film Processing System

Module for coordinator functionality in the Revela film processing system

File Information:
    File Name: coordinator.py
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


from core.roll import Roll
from core.calibration import RollCalibrationProfile
from processing import cache_utils as cache

from .analyzer import Analyzer


class AnalysisCoordinator:
    """
    协调分析和缓存的智能调度员。
    这是UI层应该与之交互的主要接口。
    """
    def __init__(self, analyzer: Analyzer):
        # 它依赖于一个Analyzer实例，但它不创建它（依赖注入）
        self.analyzer = analyzer

    def get_calibration_profile(self, roll: Roll) -> RollCalibrationProfile:
        """
        获取胶卷的校准配置文件。
        它会首先尝试从缓存加载，如果失败，则调用Analyzer进行计算。
        """
        # 1. 定义缓存目录
        cache_dir = roll.folder_path / '.cache'
        cache_dir.mkdir(exist_ok=True)

        # 2. 根据当前的技术配方生成唯一的缓存键
        recipe_key = cache.generate_recipe_key(roll.technical_recipe)
        cache_file_path = cache_dir / f"{recipe_key}.profile.csv"

        # 3. 尝试从缓存加载
        cached_profile = cache.load_profile_from_csv(cache_file_path)
        if cached_profile:
            print("缓存命中！直接使用已有的分析结果。")
            # 将加载的校准数据存入Roll对象
            roll.calibration = cached_profile
            return cached_profile

        # 4. 如果缓存不存在（缓存未命中），则执行完整的分析
        print("缓存未命中。开始执行新的分析...")
        new_profile = self.analyzer.analyze_roll(roll)

        # 5. 将新的分析结果保存到缓存，以备将来使用
        cache.save_profile_to_csv(new_profile, cache_file_path)

        return new_profile
