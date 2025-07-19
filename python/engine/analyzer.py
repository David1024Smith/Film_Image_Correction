#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Revela - Professional Film Processing System

Module for analyzer functionality in the Revela film processing system

File Information:
    File Name: analyzer.py
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



import numpy as np
import gc
from tqdm import tqdm

from core.roll import Roll
from core.calibration import RollCalibrationProfile
from core.memory_manager import MemoryMonitor, force_memory_cleanup

from processing import density as density_proc
from processing import histogram as hist_proc
from processing import alignment as align_proc
from processing import image_loader as loader_proc


class Analyzer:
    """
    负责分析一整卷胶卷，并生成校准配置文件。
    """

    def __init__(self, memory_limit_mb: float = 800):
        """
        初始化分析器
        
        Args:
            memory_limit_mb: 内存使用限制（MB）
        """
        self.memory_monitor = MemoryMonitor(warning_threshold_mb=memory_limit_mb * 0.8)
        self.memory_limit_mb = memory_limit_mb

    def analyze_roll(self, roll: Roll) -> RollCalibrationProfile:
        """
        执行完整的胶卷分析流程。
        这是这个类的主要入口点。
        """
        print(f"开始分析胶卷: {roll.name}...")
        self.memory_monitor.log_usage("分析开始")

        try:
            # 1. 计算Dmin和Dmax
            d_min, d_max = self._find_dmin_dmax(roll)
            print(f"计算完成 Dmin: {d_min}, Dmax: {d_max}")
            
            # 强制清理内存
            force_memory_cleanup(self.memory_limit_mb)

            # 2. 计算整卷的聚合直方图
            hist_values, hist_bins = self._calculate_roll_histogram(roll, d_min, d_max)
            print("计算完成: 聚合直方图")
            
            # 强制清理内存
            force_memory_cleanup(self.memory_limit_mb)

            # 3. 计算高密度点和裁切阈值
            extrema_high_density_net = hist_proc.find_percentile_from_histogram(
                hist_values, hist_bins,
                roll.technical_recipe.extrema_high_density_percentile
            )
            high_density_net = hist_proc.find_percentile_from_histogram(
                hist_values, hist_bins,
                roll.technical_recipe.high_density_percentile
            )
            clip_threshold = (
                extrema_high_density_net - high_density_net
            ) / roll.technical_recipe.interpolation_factor + high_density_net
            print(f"计算完成: 高密度点={extrema_high_density_net:.4f}, 裁切阈值={clip_threshold:.4f}")

            # 4. 计算色彩通道对齐系数 (k值)
            k_values = self._calculate_k_values(roll, d_min, d_max, extrema_high_density_net)
            print(f"计算完成: k值={k_values}")

            # 5. 将所有结果打包成一个校准配置文件对象
            calibration_profile = RollCalibrationProfile(
                d_min=d_min,
                d_max=d_max,
                hist_bins=hist_bins,
                hist_values=hist_values,
                k_values=k_values,
                extrema_high_density_net=extrema_high_density_net,
                clip_threshold=clip_threshold
            )

            # 将校准数据存入Roll对象，以便后续使用
            roll.calibration = calibration_profile
            print("分析完成，校准数据已保存到Roll对象。")

            return calibration_profile
            
        finally:
            # 最终清理
            gc.collect()
            self.memory_monitor.log_usage("分析完成")

    # --- 私有辅助方法 ---
    # 我们将复杂的逻辑分解到这些私有方法中，以保持主方法的清晰

    def _find_dmin_dmax(
        self,
        roll: Roll
    ) -> tuple[np.ndarray, np.ndarray]:
        """计算Dmin和Dmax的第一个大循环。"""
        # 在这里，您将把脚本中那段寻找Dmin/Dmax的代码移入
        # 注意：它现在操作的是`roll.frames`列表和`roll.technical_recipe`

        base_d_candidate = np.array([999, 999, 999])
        leader_d_candidate = np.array([-1, -1, -1])

        for i, frame in enumerate(tqdm(roll.frames, desc="正在计算 Dmin & Dmax", unit="帧")):
            # 图像加载和预处理应该是一个独立的函数
            sample_density = loader_proc.preprocess_thumbnail_density(
                frame.image_path,
                roll.technical_recipe.light_ratio
            )

            density_max = density_proc.get_extrema_density(
                sample_density, percent=roll.technical_recipe.dmax_percentile
            )
            density_min = density_proc.get_extrema_density(
                sample_density, percent=roll.technical_recipe.dmin_percentile
            )

            if np.mean(density_max) > np.mean(leader_d_candidate):
                leader_d_candidate = density_max
            if np.mean(density_min) < np.mean(base_d_candidate):
                base_d_candidate = density_min

            # 清理临时数据
            del sample_density, density_max, density_min
            
            # 每处理10帧执行一次内存检查和清理
            if (i + 1) % 10 == 0:
                self.memory_monitor.check_and_warn(f"Dmin/Dmax计算进度: {i+1}/{len(roll.frames)}")
                if force_memory_cleanup(self.memory_limit_mb):
                    print(f"已处理 {i+1} 帧，执行内存清理")

        return base_d_candidate, leader_d_candidate


    def _calculate_roll_histogram(
        self,
        roll: Roll,
        d_min: np.ndarray,
        d_max: np.ndarray,
    ) -> tuple[np.ndarray, np.ndarray]:
        """计算直方图的第二个大循环。"""

        range_min = -0.1
        range_max = d_max.max() + 0.1

        hist_list = []

        for i, frame in enumerate(tqdm(roll.frames, desc="正在计算聚合直方图", unit="帧")):
            sample_density = loader_proc.preprocess_thumbnail_density(
                frame.image_path,
                roll.technical_recipe.light_ratio
            )

            sample_density_net = density_proc.density_to_net(
                sample_density, dmin=d_min, dmax=d_max
            )

            hist, bin_edges = np.histogram(
                sample_density_net,
                bins=roll.technical_recipe.bins_number,
                range=(range_min, range_max)
            )
            hist_r, _ = np.histogram(
                sample_density_net[..., 0],
                bins=roll.technical_recipe.bins_number,
                range=(range_min, range_max)
            )
            hist_g, _ = np.histogram(
                sample_density_net[..., 1],
                bins=roll.technical_recipe.bins_number,
                range=(range_min, range_max)
            )
            hist_b, _ = np.histogram(
                sample_density_net[..., 2],
                bins=roll.technical_recipe.bins_number,
                range=(range_min, range_max)
            )
            hist_list.append((hist, hist_r, hist_g, hist_b))
            bins = (bin_edges[:-1] + bin_edges[1:]) / 2.0

            # 清理临时数据
            del sample_density, sample_density_net, hist, hist_r, hist_g, hist_b, bin_edges
            
            # 每处理8帧执行一次内存检查
            if (i + 1) % 8 == 0:
                self.memory_monitor.check_and_warn(f"直方图计算进度: {i+1}/{len(roll.frames)}")
                if force_memory_cleanup(self.memory_limit_mb):
                    print(f"已处理 {i+1} 帧，执行内存清理")

        hist_array = np.array(hist_list)
        hist_mean = np.mean(hist_array, axis=0)
        
        # 清理中间数据
        del hist_list, hist_array

        return hist_mean[0], bins


    def _calculate_k_values(
        self,
        roll: Roll,
        d_min: np.ndarray,
        d_max: np.ndarray,
        extrema_high_density_net: float
    ) -> np.ndarray:
        """计算k值的第三个大循环。"""

        k_list = []

        for i, frame in enumerate(tqdm(roll.frames, desc="正在计算通道对齐系数", unit="帧")):
            sample_density = loader_proc.preprocess_thumbnail_density(
                frame.image_path, roll.technical_recipe.light_ratio
            )

            sample_density_net = density_proc.density_to_net(
                sample_density,
                dmin=d_min, dmax=d_max
            )

            if roll.technical_recipe.target_extrema_high_density_mode == "Auto":
                target_extrema_high_density = align_proc.robust_skewness_index(
                    sample_density_net,
                    factor=roll.technical_recipe.target_extrema_high_density_factor
                )
            elif roll.technical_recipe.target_extrema_high_density_mode == "Manual":
                target_extrema_high_density = roll.technical_recipe.input_target_extrema_high_density
            else:
                raise ValueError("target_extrema_high_density_mode is not supported: "
                                 f"{roll.technical_recipe.target_extrema_high_density_mode}")

            sample_density_net_normalized = density_proc.normalize_density_net(
                sample_density_net,
                extrema_high_density=extrema_high_density_net,
                target_extrema_high_density=target_extrema_high_density
            )

            k = align_proc.calculate_k(
                sample_density_net_normalized,
                power=roll.technical_recipe.efficiency_power
            )
            k_list.append(k)

            # 清理临时数据
            del sample_density, sample_density_net, sample_density_net_normalized, k
            
            # 每处理6帧执行一次内存检查
            if (i + 1) % 6 == 0:
                self.memory_monitor.check_and_warn(f"K值计算进度: {i+1}/{len(roll.frames)}")
                if force_memory_cleanup(self.memory_limit_mb):
                    print(f"已处理 {i+1} 帧，执行内存清理")

        k_values_result = np.mean(k_list, axis=0)
        
        # 清理中间数据
        del k_list
        
        return k_values_result

    def analyze_roll_with_memory_optimization(
        self, 
        roll: Roll, 
        batch_size: int = 5
    ) -> RollCalibrationProfile:
        """
        内存优化版本的胶卷分析，适用于大量帧或内存受限的环境。
        
        Args:
            roll: 要分析的胶卷
            batch_size: 批处理大小，一次处理的帧数
            
        Returns:
            校准配置文件
        """
        print(f"开始内存优化分析胶卷: {roll.name}...")
        print(f"总帧数: {len(roll.frames)}, 批处理大小: {batch_size}")
        self.memory_monitor.log_usage("内存优化分析开始")

        try:
            # 使用Roll的内存优化功能
            original_frames = roll.frames.copy()
            
            # 分批处理以降低内存压力
            batch_results = {
                'dmin_candidates': [],
                'dmax_candidates': [],
                'hist_data': [],
                'k_values': []
            }
            
            total_batches = (len(original_frames) + batch_size - 1) // batch_size
            
            for batch_idx in range(total_batches):
                start_idx = batch_idx * batch_size
                end_idx = min(start_idx + batch_size, len(original_frames))
                batch_frames = original_frames[start_idx:end_idx]
                
                print(f"处理批次 {batch_idx + 1}/{total_batches} "
                      f"(帧 {start_idx + 1}-{end_idx})")
                
                # 临时创建只包含当前批次帧的Roll
                batch_roll = Roll(roll.folder_path, roll.film_type)
                batch_roll.frames = batch_frames
                batch_roll.technical_recipe = roll.technical_recipe
                
                # 分析当前批次
                batch_result = self._analyze_batch(batch_roll, batch_results)
                
                # 清理批次数据
                del batch_roll, batch_frames
                gc.collect()
                
                self.memory_monitor.check_and_warn(f"批次 {batch_idx + 1} 完成")
            
            # 整合所有批次结果
            calibration_profile = self._consolidate_batch_results(
                roll, batch_results
            )
            
            return calibration_profile
            
        finally:
            # 恢复原始frames列表
            roll.frames = original_frames
            gc.collect()
            self.memory_monitor.log_usage("内存优化分析完成")

    def _analyze_batch(self, batch_roll: Roll, batch_results: dict) -> dict:
        """分析单个批次的帧"""
        # 这里实现简化的批次分析逻辑
        # 收集Dmin/Dmax候选值
        for frame in batch_roll.frames:
            sample_density = loader_proc.preprocess_thumbnail_density(
                frame.image_path,
                batch_roll.technical_recipe.light_ratio
            )
            
            density_max = density_proc.get_extrema_density(
                sample_density, percent=batch_roll.technical_recipe.dmax_percentile
            )
            density_min = density_proc.get_extrema_density(
                sample_density, percent=batch_roll.technical_recipe.dmin_percentile
            )
            
            batch_results['dmin_candidates'].append(density_min)
            batch_results['dmax_candidates'].append(density_max)
            
            # 清理临时数据
            del sample_density, density_max, density_min
        
        return batch_results

    def _consolidate_batch_results(
        self, 
        roll: Roll, 
        batch_results: dict
    ) -> RollCalibrationProfile:
        """整合所有批次的结果"""
        print("整合批次分析结果...")
        
        # 计算最终的Dmin和Dmax
        all_dmin = np.array(batch_results['dmin_candidates'])
        all_dmax = np.array(batch_results['dmax_candidates'])
        
        d_min = np.min(all_dmin, axis=0)
        d_max = np.max(all_dmax, axis=0)
        
        print(f"整合完成 Dmin: {d_min}, Dmax: {d_max}")
        
        # 计算其他参数（简化版本）
        hist_values, hist_bins = self._calculate_roll_histogram(roll, d_min, d_max)
        
        extrema_high_density_net = hist_proc.find_percentile_from_histogram(
            hist_values, hist_bins,
            roll.technical_recipe.extrema_high_density_percentile
        )
        high_density_net = hist_proc.find_percentile_from_histogram(
            hist_values, hist_bins,
            roll.technical_recipe.high_density_percentile
        )
        clip_threshold = (
            extrema_high_density_net - high_density_net
        ) / roll.technical_recipe.interpolation_factor + high_density_net
        
        k_values = self._calculate_k_values(roll, d_min, d_max, extrema_high_density_net)
        
        # 创建校准配置文件
        calibration_profile = RollCalibrationProfile(
            d_min=d_min,
            d_max=d_max,
            hist_bins=hist_bins,
            hist_values=hist_values,
            k_values=k_values,
            extrema_high_density_net=extrema_high_density_net,
            clip_threshold=clip_threshold
        )
        
        roll.calibration = calibration_profile
        print("内存优化分析完成，校准数据已保存。")
        
        return calibration_profile
