#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Revela - Professional Film Processing System

Module for renderer functionality in the Revela film processing system

File Information:
    File Name: renderer.py
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


from __future__ import annotations
from pathlib import Path

import numpy as np

from core.frame import Frame
from core.calibration import RollCalibrationProfile
from core.memory_manager import memory_cleanup_context, MemoryMonitor

from processing import image_loader as loader_proc
from processing import density as density_proc
from processing import alignment as align_proc
from processing import conversion as conversion_proc
from processing import tone as tone_proc
from processing import color_space as colorspace_proc


lut_dir = Path(__file__).parent.parent.parent / "data" / "lut"


class Renderer:
    """
    负责将单个Frame根据校准数据渲染成最终图像。
    
    提供两种渲染模式：
    - render_preview: 用于实时预览，使用缩略图数据，速度快
    - render_full_quality: 用于最终导出，使用全尺寸原始数据，质量高
    """

    def __init__(self, ocio_config):
        # Renderer可能需要一些配置，比如OCIO配置，在创建时传入
        self.ocio_config = ocio_config
        self.memory_monitor = MemoryMonitor(warning_threshold_mb=500)

    def render_preview(
        self, frame: Frame,
        calibration: RollCalibrationProfile,
        preview_target_size: tuple[int, int]
    ) -> np.ndarray:
        """
        渲染预览图像。

        :param frame: 要渲染的帧
        :param calibration: 胶卷的校准配置
        :param preview_target_size: 预览图像的目标大小
        """
        print(f"开始渲染预览帧: {frame.filename}...")
        self.memory_monitor.log_usage("预览渲染开始")

        # 0) 加载预览图像并计算光学密度
        loader_proc.load_thumbnail(frame, preview_target_size)
        if frame.thumbnail_data is None:
            raise ValueError("Frame thumbnail data has not been loaded.")

        # 读取ICC配置文件
        if frame.icc_bytes is None:
            loader_proc.load_icc_bytes(frame)
            if frame.icc_bytes is None:
                raise ValueError("Frame ICC bytes have not been loaded.")

        image_density = density_proc.dn_to_density(
            frame.thumbnail_data,
            icc_bytes=frame.icc_bytes,
            light_ratio=frame.technical_recipe.light_ratio,
        )

        # 1) 计算相对密度 (Dnet) 并归一化
        image_density_net = density_proc.density_to_net(
            image_density,
            dmin=calibration.d_min,
            dmax=calibration.d_max
        )

        if frame.technical_recipe.target_extrema_high_density_mode == "Auto":
            target_extrema_high_density = align_proc.robust_skewness_index(
                image_density_net,
                factor=frame.technical_recipe.target_extrema_high_density_factor
            )
        elif frame.technical_recipe.target_extrema_high_density_mode == "Manual":
            target_extrema_high_density = frame.technical_recipe.input_target_extrema_high_density
        else:
            raise ValueError("target_extrema_high_density_mode is not supported: "
                                f"{frame.technical_recipe.target_extrema_high_density_mode}")

        image_density_net_normalized = density_proc.normalize_density_net(
            image_density_net,
            extrema_high_density=calibration.extrema_high_density_net,
            target_extrema_high_density=target_extrema_high_density
        )

        # 2) 对齐通道并裁切
        image_density_net_aligned = align_proc.align_three_channels(
            image_density_net_normalized,
            k=calibration.k_values
        )
        image_density_net_clipped = np.clip(
            image_density_net_aligned,
            None,
            (
                calibration.clip_threshold / calibration.extrema_high_density_net
            ) * target_extrema_high_density
        )

        # 3) 转换为线性RGB
        image_linear = conversion_proc.density_to_linear(
            image_density_net_clipped,
            self.ocio_config,
            "ACES2065-1"
        )

        # 应用Rolloff (如果需要)
        if target_extrema_high_density > frame.technical_recipe.extrema_high_density_threshold:
            # 应用 Rolloff
            image_linear_rolloff = tone_proc.rolloff(
                image_linear,
                frame.technical_recipe.extrema_high_density_percentile,
                frame.technical_recipe.extrema_high_density_multiplier,
                frame.technical_recipe.threshold_percentile,
                frame.technical_recipe.threshold_multiplier,
            )
            image_linear_rolloff *= image_linear.max() / image_linear_rolloff.max()
            image_linear = image_linear_rolloff

        # 4) 转换到输出
        if frame.creative_recipe.display_mode == "LUT":
            lut_cube = conversion_proc.load_lut_cube(
                lut_dir / frame.creative_recipe.lut_name,
            )
            # 使用LUT转换
            image_sdr = conversion_proc.apply_lut(
                image_linear,
                lut_cube,
                max_data=image_linear.max(),
            )
        elif frame.creative_recipe.display_mode == "Displays":
            # 使用SDR转换
            image_sdr = conversion_proc.linear_to_display(
                image_linear,
                self.ocio_config,
                display_space=frame.creative_recipe.display_space
            )
        else:
            raise ValueError(f"Unsupported display mode: {frame.creative_recipe.display_mode}")

        # 5) 色调映射
        image_output = tone_proc.tune_function(
            image_sdr,
            function_type=frame.creative_recipe.tone_mapping
        )
        image_output = image_output / image_output.max()

        if frame.creative_recipe.flip_up_and_down:
            image_output = np.flipud(image_output)

        frame.processed_image = image_output
        print(f"预览渲染完成: {frame.filename}")
        
        # 清理大型数据以节省内存（保留预览结果）
        if frame.full_quality_data is not None:
            del frame.full_quality_data
            frame.full_quality_data = None
        
        return image_output

    def render_full_quality(
        self, frame: Frame,
        calibration: RollCalibrationProfile,
        target_icc_bytes: bytes | None = None
    ) -> np.ndarray:
        """
        渲染全尺寸高质量图像，用于最终导出。

        :param frame: 要渲染的帧
        :param calibration: 胶卷的校准配置
        :param target_icc_bytes: 目标色彩空间的ICC配置文件字节数据
        """
        print(f"开始渲染全尺寸图像: {frame.filename}...")
        self.memory_monitor.log_usage("全质量渲染开始")

        # 0) 加载全尺寸图像并计算光学密度
        loader_proc.load_full_quality(frame)
        if frame.full_quality_data is None:
            raise ValueError("Frame full quality data has not been loaded.")

        # 读取ICC配置文件
        if frame.icc_bytes is None:
            loader_proc.load_icc_bytes(frame)
            if frame.icc_bytes is None:
                raise ValueError("Frame ICC bytes have not been loaded.")

        image_density = density_proc.dn_to_density(
            frame.full_quality_data,
            icc_bytes=frame.icc_bytes,
            light_ratio=frame.technical_recipe.light_ratio,
        )

        # 1) 计算相对密度 (Dnet) 并归一化
        image_density_net = density_proc.density_to_net(
            image_density,
            dmin=calibration.d_min,
            dmax=calibration.d_max
        )

        if frame.technical_recipe.target_extrema_high_density_mode == "Auto":
            target_extrema_high_density = align_proc.robust_skewness_index(
                image_density_net,
                factor=frame.technical_recipe.target_extrema_high_density_factor
            )
        elif frame.technical_recipe.target_extrema_high_density_mode == "Manual":
            target_extrema_high_density = frame.technical_recipe.input_target_extrema_high_density
        else:
            raise ValueError("target_extrema_high_density_mode is not supported: "
                                f"{frame.technical_recipe.target_extrema_high_density_mode}")

        image_density_net_normalized = density_proc.normalize_density_net(
            image_density_net,
            extrema_high_density=calibration.extrema_high_density_net,
            target_extrema_high_density=target_extrema_high_density
        )

        # 2) 对齐通道并裁切
        image_density_net_aligned = align_proc.align_three_channels(
            image_density_net_normalized,
            k=calibration.k_values
        )
        image_density_net_clipped = np.clip(
            image_density_net_aligned,
            None,
            (
                calibration.clip_threshold / calibration.extrema_high_density_net
            ) * target_extrema_high_density
        )

        # 3) 转换为线性RGB
        image_linear = conversion_proc.density_to_linear(
            image_density_net_clipped,
            self.ocio_config,
            "ACES2065-1"
        )

        # 应用Rolloff (如果需要)
        if target_extrema_high_density > frame.technical_recipe.extrema_high_density_threshold:
            # 应用 Rolloff
            image_linear_rolloff = tone_proc.rolloff(
                image_linear,
                frame.technical_recipe.extrema_high_density_percentile,
                frame.technical_recipe.extrema_high_density_multiplier,
                frame.technical_recipe.threshold_percentile,
                frame.technical_recipe.threshold_multiplier,
            )
            image_linear_rolloff *= image_linear.max() / image_linear_rolloff.max()
            image_linear = image_linear_rolloff

        # 4) 转换到输出
        if frame.creative_recipe.display_mode == "LUT":
            lut_cube = conversion_proc.load_lut_cube(
                lut_dir / frame.creative_recipe.lut_name,
            )
            # 使用LUT转换
            image_sdr = conversion_proc.apply_lut(
                image_linear,
                lut_cube,
                max_data=image_linear.max(),
            )
        elif frame.creative_recipe.display_mode == "Displays":
            # 使用SDR转换
            image_sdr = conversion_proc.linear_to_display(
                image_linear,
                self.ocio_config,
                display_space=frame.creative_recipe.display_space
            )
        else:
            raise ValueError(f"Unsupported display mode: {frame.creative_recipe.display_mode}")

        # 5) 色调映射
        image_output = tone_proc.tune_function(
            image_sdr,
            function_type=frame.creative_recipe.tone_mapping
        )
        image_output = image_output / image_output.max()

        # 6) 色彩空间转换
        if frame.creative_recipe.display_mode == "Displays":
            if frame.creative_recipe.display_space == "Display P3 - Display":
                image_output_transformed = colorspace_proc.color_space_transform(
                    image_output,
                    input_colorspace='Display P3',
                    output_colorspace=target_icc_bytes
                )
                print(f"导出色彩空间: {frame.creative_recipe.display_space}")
            else:
                print(f"使用自定义色彩空间: {frame.creative_recipe.display_space}")
        elif frame.creative_recipe.display_mode == "LUT":
            image_output_transformed = colorspace_proc.color_space_transform(
                image_output,
                input_colorspace='ITU-R BT.709',
                output_colorspace=target_icc_bytes
            )
            print(f"导出色彩空间: {frame.creative_recipe.display_space}")
        else:
            raise ValueError(f"Unsupported display mode: {frame.creative_recipe.display_mode}")

        if frame.creative_recipe.flip_up_and_down:
            image_output_transformed = np.flipud(image_output_transformed)

        frame.processed_image = image_output_transformed
        print(f"全尺寸渲染完成: {frame.filename}")
        
        # 渲染完成后立即清理原始数据以节省内存
        if frame.full_quality_data is not None:
            del frame.full_quality_data
            frame.full_quality_data = None
        
        return image_output_transformed
