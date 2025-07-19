#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Revela - Professional Film Processing System

Module for exporter functionality in the Revela film processing system

File Information:
    File Name: exporter.py
    Author: Flemyng
    Email: flemyng1999@gmail.com
    Created: 2025-07-18 17:02:34
    Last Modified: 2025-07-18 17:02:34
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


from pathlib import Path
import gc
from tqdm import tqdm

from core.roll import Roll
from core.frame import Frame
from core.recipe import ExportRecipe, ExportFormat
import processing.image_export as file_writers

from .renderer import Renderer

# import processing.image_loader as loader # 用于加载ICC配置文件


class Exporter:
    """
    负责协调整个导出流程。
    """
    def __init__(self, renderer: Renderer):
        # Exporter需要一个Renderer来确保图像是最高质量的。
        # 这是“依赖注入”——我们把需要的工具递给它，而不是让它自己创建。
        self.renderer = renderer

    def export_frames(
        self,
        frames: list[Frame],
        roll: Roll,
        recipe: ExportRecipe,
        output_dir: Path
    ):
        """
        导出指定的一系列帧。
        
        Args:
            frames: 需要导出的Frame对象列表。
            roll: 当前的Roll对象，用于获取校准数据。
            recipe: 包含所有导出设置的ExportRecipe对象。
            output_dir: 导出的目标目录。
        """
        print(f"开始导出 {len(frames)} 帧到目录: {output_dir}")
        output_dir.mkdir(exist_ok=True, parents=True)

        for i, frame in enumerate(tqdm(frames, desc="正在导出图像", unit="帧")):
            try:
                # 显示内存使用情况
                memory_usage = frame.get_memory_usage()
                if memory_usage['total'] > 0:
                    print(f"处理帧 {i+1}/{len(frames)}: {frame.filename} (内存: {memory_usage['total']:.1f}MB)")
                
                # 1. 渲染全质量图像
                # 我们调用render_full_quality来确保使用原始高分辨率文件进行处理。
                # 这是与实时预览的核心区别。
                final_image_data = self.renderer.render_full_quality(
                    frame,
                    roll.calibration,
                    recipe.icc_bytes
                )

                # 2. 构建输出文件名
                # 这是一个简单的命名，未来可以根据ExportRecipe中的设置变得更复杂
                base_name = frame.image_path.stem
                output_name = f"{base_name}_{recipe.filename_suffix}"

                # 3. 根据配方选择正确的写入工具并执行
                if recipe.export_format == ExportFormat.JPG:
                    save_path = output_dir / f"{output_name}.jpg"
                    file_writers.save_as_jpg(
                        final_image_data, save_path,
                        quality=recipe.quality, icc_profile=recipe.icc_bytes
                    )
                elif recipe.export_format == ExportFormat.TIF_8_BIT:
                    save_path = output_dir / f"{output_name}.tif"
                    file_writers.save_as_tif(
                        final_image_data, save_path,
                        bit_depth=8, icc_profile=recipe.icc_bytes
                    )
                elif recipe.export_format == ExportFormat.TIF_16_BIT:
                    save_path = output_dir / f"{output_name}.tif"
                    file_writers.save_as_tif(
                        final_image_data, save_path,
                        bit_depth=16, icc_profile=recipe.icc_bytes
                    )
                
                # 4. 保存完成后立即清理当前帧的大型数据
                frame.clear_large_data()
                
                # 5. 每处理几帧就执行一次垃圾回收
                if (i + 1) % 5 == 0:
                    gc.collect()
                    print(f"已处理 {i+1} 帧，执行内存清理")
                    
            except Exception as e:
                print(f"导出帧 {frame.filename} 时出错: {e}")
                # 即使出错也要清理内存
                frame.clear_large_data()
                raise

    def export_roll_with_memory_optimization(
        self,
        roll: Roll,
        recipe: ExportRecipe,
        output_dir: Path,
        memory_limit_mb: float = 1000
    ):
        """
        导出整卷胶卷，采用内存优化策略。
        
        Args:
            roll: 要导出的Roll对象
            recipe: 导出配方
            output_dir: 输出目录
            memory_limit_mb: 内存限制（MB）
        """
        print(f"开始内存优化导出胶卷: {roll.name}")
        print(f"总帧数: {len(roll.frames)}, 内存限制: {memory_limit_mb}MB")
        
        output_dir.mkdir(exist_ok=True, parents=True)
        
        for i, frame in enumerate(tqdm(roll.frames, desc="导出胶卷", unit="帧")):
            # 优化内存：只保留当前帧及其邻近帧的数据
            roll.optimize_memory_for_batch_processing(
                current_frame_index=i,
                keep_previous=0,  # 导出时不需要保留之前的帧
                keep_next=1       # 预载下一帧
            )
            
            try:
                # 检查内存使用
                total_memory = roll.get_total_memory_usage()
                if total_memory['total'] > memory_limit_mb * 0.8:  # 80% 阈值
                    print(f"内存使用过高 ({total_memory['total']:.1f}MB)，强制清理...")
                    roll.clear_all_frame_data()
                    gc.collect()
                
                # 渲染和保存
                final_image_data = self.renderer.render_full_quality(
                    frame,
                    roll.calibration,
                    recipe.icc_bytes
                )
                
                # 构建输出路径
                base_name = frame.image_path.stem
                output_name = f"{base_name}_{recipe.filename_suffix}"
                
                # 保存文件
                if recipe.export_format == ExportFormat.JPG:
                    save_path = output_dir / f"{output_name}.jpg"
                    file_writers.save_as_jpg(
                        final_image_data, save_path,
                        quality=recipe.quality, icc_profile=recipe.icc_bytes
                    )
                elif recipe.export_format == ExportFormat.TIF_8_BIT:
                    save_path = output_dir / f"{output_name}.tif"
                    file_writers.save_as_tif(
                        final_image_data, save_path,
                        bit_depth=8, icc_profile=recipe.icc_bytes
                    )
                elif recipe.export_format == ExportFormat.TIF_16_BIT:
                    save_path = output_dir / f"{output_name}.tif"
                    file_writers.save_as_tif(
                        final_image_data, save_path,
                        bit_depth=16, icc_profile=recipe.icc_bytes
                    )
                
                print(f"已导出: {save_path.name}")
                
            except Exception as e:
                print(f"导出帧 {frame.filename} 失败: {e}")
                continue
            
            finally:
                # 确保清理当前帧数据
                frame.clear_all_data()
        
        # 最终清理
        roll.clear_all_frame_data()
        gc.collect()
        print(f"胶卷导出完成: {roll.name}")
