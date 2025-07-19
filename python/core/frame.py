#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Revela - Professional Film Processing System

Frame class for individual film frame processing and metadata management

File Information:
    File Name: frame.py
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
    - numpy
    - opencv-python

Copyright (c) 2025 Flemyng. All rights reserved.
This file is part of the Revela project.

For more information, please refer to the project documentation.
"""



from pathlib import Path
import numpy as np
from .recipe import TechnicalRecipe, CreativeRecipe

class Frame:
    """代表胶片中的一帧图像。"""

    def __init__(self, image_path: Path):
        self.image_path: Path = image_path

        self.technical_recipe: TechnicalRecipe = TechnicalRecipe()
        self.creative_recipe: CreativeRecipe = CreativeRecipe()

        self.thumbnail_data: np.ndarray | None = None
        self.full_quality_data: np.ndarray | None = None
        self.icc_bytes: bytes | None = None
        self.processed_image: np.ndarray | None = None

    @property
    def filename(self) -> str:
        """一个辅助属性，方便地获取文件名。"""
        return self.image_path.name

    def __repr__(self) -> str:
        """一个友好的字符串表示，用于打印和调试。"""
        return f"Frame(path='{self.filename}')"

    def clear_large_data(self) -> None:
        """清除大型图像数据以释放内存。"""
        if self.full_quality_data is not None:
            del self.full_quality_data
            self.full_quality_data = None
        
        if self.processed_image is not None:
            del self.processed_image
            self.processed_image = None

    def clear_all_data(self) -> None:
        """清除所有图像数据以释放内存。"""
        self.clear_large_data()
        
        if self.thumbnail_data is not None:
            del self.thumbnail_data
            self.thumbnail_data = None
        
        if self.icc_bytes is not None:
            del self.icc_bytes
            self.icc_bytes = None

    def get_memory_usage(self) -> dict[str, float]:
        """获取当前内存使用情况（以MB为单位）。"""
        memory_usage = {}
        
        if self.thumbnail_data is not None:
            memory_usage['thumbnail'] = self.thumbnail_data.nbytes / (1024 * 1024)
        
        if self.full_quality_data is not None:
            memory_usage['full_quality'] = self.full_quality_data.nbytes / (1024 * 1024)
        
        if self.processed_image is not None:
            memory_usage['processed'] = self.processed_image.nbytes / (1024 * 1024)
        
        if self.icc_bytes is not None:
            memory_usage['icc'] = len(self.icc_bytes) / (1024 * 1024)
        
        memory_usage['total'] = sum(memory_usage.values())
        return memory_usage

    def __del__(self):
        """析构函数，确保内存被释放。"""
        self.clear_all_data()
