#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Revela - Memory Management Utilities

Context managers and utilities for efficient memory management
during film processing operations.

File Information:
    File Name: memory_utils.py
    Author: Flemyng
    Email: flemyng1999@gmail.com
    Created: 2025-07-18
    Version: 1.0.0
    Python Version: 3.12+
    License: GPL-3.0 license
"""

import gc
import psutil
import os
import logging
from contextlib import contextmanager
from typing import Iterator, Optional, Protocol
from pathlib import Path


class MemoryManageable(Protocol):
    """协议定义，用于支持内存管理的对象"""
    
    def clear_large_data(self) -> None:
        """清除大型数据"""
        ...
    
    def clear_all_data(self) -> None:
        """清除所有数据"""
        ...
    
    def get_memory_usage(self) -> dict[str, float]:
        """获取内存使用情况"""
        ...


class MemoryMonitor:
    """内存使用监控器"""
    
    def __init__(self):
        self.process = psutil.Process(os.getpid())
        self.logger = logging.getLogger(__name__)
    
    def get_memory_mb(self) -> float:
        """获取当前进程内存使用量（MB）"""
        return self.process.memory_info().rss / 1024 / 1024
    
    def get_memory_percent(self) -> float:
        """获取内存使用百分比"""
        return self.process.memory_percent()
    
    def log_memory_usage(self, context: str = "") -> None:
        """记录当前内存使用情况"""
        memory_mb = self.get_memory_mb()
        memory_percent = self.get_memory_percent()
        
        message = f"Memory usage: {memory_mb:.1f}MB ({memory_percent:.1f}%)"
        if context:
            message = f"{context} - {message}"
        
        self.logger.info(message)


@contextmanager
def memory_managed_processing(
    obj: MemoryManageable,
    auto_cleanup: bool = True,
    memory_limit_mb: Optional[float] = None
) -> Iterator[MemoryManageable]:
    """内存管理的上下文管理器
    
    Args:
        obj: 支持内存管理的对象
        auto_cleanup: 是否在退出时自动清理
        memory_limit_mb: 内存限制，超过时强制垃圾回收
    """
    monitor = MemoryMonitor()
    initial_memory = monitor.get_memory_mb()
    
    try:
        # 检查内存限制
        if memory_limit_mb and initial_memory > memory_limit_mb:
            gc.collect()
            monitor.log_memory_usage("Pre-processing cleanup")
        
        yield obj
        
    finally:
        if auto_cleanup:
            obj.clear_large_data()
            gc.collect()
            
            final_memory = monitor.get_memory_mb()
            freed_memory = initial_memory - final_memory
            
            if freed_memory > 0:
                monitor.logger.info(f"Freed {freed_memory:.1f}MB of memory")


@contextmanager
def batch_memory_manager(
    memory_limit_mb: float = 1000,
    gc_threshold_mb: float = 500
) -> Iterator[MemoryMonitor]:
    """批处理内存管理器
    
    Args:
        memory_limit_mb: 硬性内存限制
        gc_threshold_mb: 触发垃圾回收的阈值
    """
    monitor = MemoryMonitor()
    monitor.log_memory_usage("Batch processing started")
    
    try:
        yield monitor
    finally:
        # 强制最终清理
        gc.collect()
        monitor.log_memory_usage("Batch processing completed")


class MemoryEfficientRollProcessor:
    """内存高效的胶卷处理器"""
    
    def __init__(
        self,
        memory_limit_mb: float = 1000,
        frames_to_keep: int = 3,
        enable_monitoring: bool = True
    ):
        self.memory_limit_mb = memory_limit_mb
        self.frames_to_keep = frames_to_keep
        self.monitor = MemoryMonitor() if enable_monitoring else None
        self.logger = logging.getLogger(__name__)
    
    def process_roll(self, roll) -> Iterator[dict]:
        """处理整卷胶卷，自动管理内存
        
        Args:
            roll: Roll对象
            
        Yields:
            dict: 每帧的处理结果
        """
        total_frames = len(roll.frames)
        
        with batch_memory_manager(self.memory_limit_mb) as monitor:
            for i, frame in enumerate(roll.frames):
                # 内存优化：只保留邻近帧
                if hasattr(roll, 'optimize_memory_for_batch_processing'):
                    keep_range = self.frames_to_keep // 2
                    roll.optimize_memory_for_batch_processing(
                        current_frame_index=i,
                        keep_previous=keep_range,
                        keep_next=keep_range
                    )
                
                # 检查内存使用
                current_memory = monitor.get_memory_mb()
                if current_memory > self.memory_limit_mb * 0.8:  # 80%阈值
                    self.logger.warning(
                        f"Memory usage high ({current_memory:.1f}MB), "
                        "clearing unused data..."
                    )
                    if hasattr(roll, 'clear_all_frame_data'):
                        roll.clear_all_frame_data()
                    gc.collect()
                
                try:
                    # 处理帧
                    with memory_managed_processing(frame) as managed_frame:
                        # 这里是实际的图像处理逻辑
                        # managed_frame.full_quality_data = load_image(...)
                        # managed_frame.processed_image = process_image(...)
                        
                        yield {
                            'frame_index': i,
                            'total_frames': total_frames,
                            'success': True,
                            'memory_usage': managed_frame.get_memory_usage() if hasattr(managed_frame, 'get_memory_usage') else {},
                            'system_memory_mb': monitor.get_memory_mb()
                        }
                
                except Exception as e:
                    self.logger.error(f"Failed to process frame {i}: {e}")
                    yield {
                        'frame_index': i,
                        'total_frames': total_frames,
                        'success': False,
                        'error': str(e),
                        'system_memory_mb': monitor.get_memory_mb()
                    }


def setup_memory_logging(level: int = logging.INFO) -> None:
    """设置内存管理相关的日志"""
    logging.basicConfig(
        level=level,
        format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
        handlers=[
            logging.StreamHandler(),
            logging.FileHandler('memory_management.log')
        ]
    )


# 装饰器版本的内存管理
def memory_managed(auto_cleanup: bool = True, memory_limit_mb: Optional[float] = None):
    """内存管理装饰器"""
    def decorator(func):
        def wrapper(*args, **kwargs):
            monitor = MemoryMonitor()
            initial_memory = monitor.get_memory_mb()
            
            try:
                if memory_limit_mb and initial_memory > memory_limit_mb:
                    gc.collect()
                
                result = func(*args, **kwargs)
                return result
            
            finally:
                if auto_cleanup:
                    gc.collect()
                    
                final_memory = monitor.get_memory_mb()
                freed_memory = initial_memory - final_memory
                
                if freed_memory > 0:
                    monitor.logger.info(
                        f"Function {func.__name__} freed {freed_memory:.1f}MB"
                    )
        
        return wrapper
    return decorator
