#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Revela - Memory Management Utilities

Simple memory management utilities for the Revela film processing system.

File Information:
    File Name: memory_manager.py
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
from contextlib import contextmanager
from typing import Iterator


def get_memory_usage_mb() -> float:
    """获取当前进程的内存使用量（MB）"""
    process = psutil.Process(os.getpid())
    return process.memory_info().rss / 1024 / 1024


@contextmanager
def memory_cleanup_context(auto_gc: bool = True) -> Iterator[None]:
    """内存清理上下文管理器
    
    Args:
        auto_gc: 是否在退出时自动执行垃圾回收
    """
    initial_memory = get_memory_usage_mb()
    print(f"开始处理，初始内存: {initial_memory:.1f}MB")
    
    try:
        yield
    finally:
        if auto_gc:
            gc.collect()
            final_memory = get_memory_usage_mb()
            freed_memory = initial_memory - final_memory
            if freed_memory > 0:
                print(f"内存清理完成，释放: {freed_memory:.1f}MB")
            else:
                print(f"处理完成，当前内存: {final_memory:.1f}MB")


def force_memory_cleanup(threshold_mb: float = 1000) -> bool:
    """强制内存清理
    
    Args:
        threshold_mb: 内存阈值，超过此值时执行清理
        
    Returns:
        bool: 是否执行了清理
    """
    current_memory = get_memory_usage_mb()
    if current_memory > threshold_mb:
        print(f"内存使用 {current_memory:.1f}MB 超过阈值 {threshold_mb}MB，执行强制清理...")
        gc.collect()
        new_memory = get_memory_usage_mb()
        print(f"清理后内存: {new_memory:.1f}MB")
        return True
    return False


class MemoryMonitor:
    """简单的内存监控器"""
    
    def __init__(self, warning_threshold_mb: float = 800):
        self.warning_threshold_mb = warning_threshold_mb
        self.process = psutil.Process(os.getpid())
    
    def check_and_warn(self, context: str = "") -> float:
        """检查内存使用并发出警告"""
        memory_mb = self.process.memory_info().rss / 1024 / 1024
        
        if memory_mb > self.warning_threshold_mb:
            message = f"⚠️  内存使用警告: {memory_mb:.1f}MB"
            if context:
                message += f" ({context})"
            print(message)
        
        return memory_mb
    
    def log_usage(self, context: str = "") -> None:
        """记录内存使用情况"""
        memory_mb = self.process.memory_info().rss / 1024 / 1024
        message = f"内存使用: {memory_mb:.1f}MB"
        if context:
            message = f"{context} - {message}"
        print(message)
