#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Revela - Professional Film Processing System

Core Roll class for managing film roll data structures and metadata

File Information:
    File Name: roll.py
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
    - dataclasses
    - pathlib
    - typing

Copyright (c) 2025 Flemyng. All rights reserved.
This file is part of the Revela project.

For more information, please refer to the project documentation.
"""


from pathlib import Path
from .recipe import TechnicalRecipe
from .frame import Frame
from .calibration import RollCalibrationProfile


class Roll:
    """代表一整卷胶卷。"""

    def __init__(self, folder_path: Path, film_type: str):
        self.folder_path: Path = folder_path
        self.film_type: str = film_type
        # 整卷胶卷共享一套技术配方
        self.technical_recipe: TechnicalRecipe = TechnicalRecipe()

        # 查找所有.tif文件，并为它们创建Frame对象
        self.frames: list[Frame] = sorted(
            [Frame(p) for p in folder_path.glob("*.tif")],
            key=lambda f: f.image_path
        )

        # 这个属性将持有分析的结果。它一开始是None。
        self.calibration: RollCalibrationProfile | None = None

    @property
    def name(self) -> str:
        """一个辅助属性，用于生成胶卷名称，例如 '2025_06_28_5207-2'。"""
        # 注意：这里的.parent.name 假设了您的目录结构
        date_folder_name = self.folder_path.parent.name
        return f"{date_folder_name}_{self.film_type}"

    def __repr__(self) -> str:
        return f"Roll(name='{self.name}', frames={len(self.frames)})"

    def clear_all_frame_data(self) -> None:
        """清除所有帧的大型图像数据以释放内存。"""
        for frame in self.frames:
            frame.clear_large_data()

    def clear_frame_data_except(self, keep_indices: list[int]) -> None:
        """清除除指定索引外的所有帧的大型图像数据。
        
        Args:
            keep_indices: 要保留数据的帧的索引列表
        """
        for i, frame in enumerate(self.frames):
            if i not in keep_indices:
                frame.clear_large_data()

    def clear_frame_completely(self, frame_index: int) -> None:
        """完全清除指定帧的所有数据。
        
        Args:
            frame_index: 要清除的帧的索引
        """
        if 0 <= frame_index < len(self.frames):
            self.frames[frame_index].clear_all_data()

    def get_total_memory_usage(self) -> dict[str, float]:
        """获取整个胶卷的内存使用情况（以MB为单位）。"""
        total_usage = {
            'thumbnail': 0.0,
            'full_quality': 0.0,
            'processed': 0.0,
            'icc': 0.0,
            'total': 0.0
        }
        
        for frame in self.frames:
            frame_usage = frame.get_memory_usage()
            for key in total_usage:
                if key in frame_usage:
                    total_usage[key] += frame_usage[key]
        
        total_usage['total'] = sum(v for k, v in total_usage.items() if k != 'total')
        return total_usage

    def get_memory_summary(self) -> str:
        """获取内存使用摘要的字符串表示。"""
        usage = self.get_total_memory_usage()
        frames_with_data = sum(1 for frame in self.frames 
                              if frame.full_quality_data is not None or 
                                 frame.processed_image is not None)
        
        return (f"Roll '{self.name}': {usage['total']:.1f}MB total "
                f"({frames_with_data}/{len(self.frames)} frames loaded)")

    def optimize_memory_for_batch_processing(self, current_frame_index: int, 
                                           keep_previous: int = 1, 
                                           keep_next: int = 1) -> None:
        """为批处理优化内存使用，只保留当前帧及其邻近帧的数据。
        
        Args:
            current_frame_index: 当前正在处理的帧索引
            keep_previous: 保留当前帧之前的帧数量
            keep_next: 保留当前帧之后的帧数量
        """
        keep_indices = []
        start_idx = max(0, current_frame_index - keep_previous)
        end_idx = min(len(self.frames), current_frame_index + keep_next + 1)
        
        keep_indices.extend(range(start_idx, end_idx))
        self.clear_frame_data_except(keep_indices)

    def __del__(self):
        """析构函数，确保清理所有帧数据。"""
        self.clear_all_frame_data()
