"""
直方图控制器模块
负责图像直方图的计算和显示
"""

from __future__ import annotations

import sys
from pathlib import Path
from typing import Optional, List

from PySide6.QtCore import QObject, Signal, Property, Slot, QThread
from PySide6.QtQml import QmlElement

# 添加核心模块路径
current_dir = Path(__file__).parent.parent.parent.resolve()
if str(current_dir) not in sys.path:
    sys.path.insert(0, str(current_dir))

try:
    from processing.histogram import calculate_histogram, calculate_rgb_histogram
    HISTOGRAM_AVAILABLE = True
except ImportError as e:
    print(f"直方图模块导入警告: {e}")
    HISTOGRAM_AVAILABLE = False

QML_IMPORT_NAME = "Revela"
QML_IMPORT_MAJOR_VERSION = 1


class HistogramWorker(QObject):
    """直方图计算工作线程"""
    
    # 信号定义
    histogramCalculated = Signal(list, list, list, list)  # R, G, B, Luminance histograms
    histogramError = Signal(str)
    
    def __init__(self):
        super().__init__()
        
    def calculateHistogram(self, image_path: str):
        """计算图像直方图"""
        try:
            if not HISTOGRAM_AVAILABLE:
                # 模拟直方图数据
                self._simulate_histogram()
                return
                
            # 实际计算直方图
            from processing.image_loader import load_image_data
            
            # 加载图像数据
            image_data = load_image_data(image_path)
            if image_data is None:
                self.histogramError.emit("无法加载图像数据")
                return
                
            # 计算RGB直方图
            r_hist, g_hist, b_hist = calculate_rgb_histogram(image_data)
            
            # 计算亮度直方图
            luminance_hist = calculate_histogram(image_data)
            
            # 转换为列表格式
            r_hist_list = r_hist.tolist() if hasattr(r_hist, 'tolist') else list(r_hist)
            g_hist_list = g_hist.tolist() if hasattr(g_hist, 'tolist') else list(g_hist)
            b_hist_list = b_hist.tolist() if hasattr(b_hist, 'tolist') else list(b_hist)
            lum_hist_list = luminance_hist.tolist() if hasattr(luminance_hist, 'tolist') else list(luminance_hist)
            
            self.histogramCalculated.emit(r_hist_list, g_hist_list, b_hist_list, lum_hist_list)
            
        except Exception as e:
            self.histogramError.emit(f"计算直方图时出错: {str(e)}")
            
    def _simulate_histogram(self):
        """模拟直方图数据"""
        import random
        import math
        
        # 生成模拟的直方图数据
        bins = 256
        
        def generate_channel_histogram():
            # 生成类似正态分布的直方图数据
            hist = []
            for i in range(bins):
                # 使用多个高斯分布的组合
                value = 0
                value += 100 * math.exp(-((i - 64) ** 2) / (2 * 30 ** 2))   # 阴影
                value += 150 * math.exp(-((i - 128) ** 2) / (2 * 40 ** 2))  # 中间调
                value += 80 * math.exp(-((i - 200) ** 2) / (2 * 25 ** 2))   # 高光
                value += random.uniform(-10, 10)  # 添加噪声
                hist.append(max(0, value))
            return hist
            
        r_hist = generate_channel_histogram()
        g_hist = generate_channel_histogram()
        b_hist = generate_channel_histogram()
        
        # 亮度直方图是RGB的加权平均
        lum_hist = []
        for i in range(bins):
            lum_value = 0.299 * r_hist[i] + 0.587 * g_hist[i] + 0.114 * b_hist[i]
            lum_hist.append(lum_value)
            
        self.histogramCalculated.emit(r_hist, g_hist, b_hist, lum_hist)


@QmlElement
class HistogramController(QObject):
    """直方图控制器 - 管理图像直方图显示"""
    
    # 信号定义
    histogramDataChanged = Signal()          # 直方图数据变化
    histogramModeChanged = Signal()          # 显示模式变化
    histogramCalculating = Signal(bool)      # 计算状态变化
    
    def __init__(self, parent=None):
        super().__init__(parent)
        
        # 直方图数据
        self._r_histogram = []
        self._g_histogram = []
        self._b_histogram = []
        self._luminance_histogram = []
        
        # 显示设置
        self._show_rgb = True
        self._show_luminance = True
        self._histogram_mode = "RGB"  # "RGB", "Luminance", "All"
        self._is_calculating = False
        
        # 创建计算工作线程
        self._histogram_thread = QThread()
        self._histogram_worker = HistogramWorker()
        self._histogram_worker.moveToThread(self._histogram_thread)
        
        # 连接信号
        self._histogram_worker.histogramCalculated.connect(self._on_histogram_calculated)
        self._histogram_worker.histogramError.connect(self._on_histogram_error)
        
        self._histogram_thread.start()
        
    # 属性定义
    @Property(list, notify=histogramDataChanged)
    def rHistogram(self) -> List[float]:
        return self._r_histogram
        
    @Property(list, notify=histogramDataChanged)
    def gHistogram(self) -> List[float]:
        return self._g_histogram
        
    @Property(list, notify=histogramDataChanged)
    def bHistogram(self) -> List[float]:
        return self._b_histogram
        
    @Property(list, notify=histogramDataChanged)
    def luminanceHistogram(self) -> List[float]:
        return self._luminance_histogram
        
    @Property(str, notify=histogramModeChanged)
    def histogramMode(self) -> str:
        return self._histogram_mode
        
    @histogramMode.setter
    def histogramMode(self, value: str):
        if self._histogram_mode != value:
            self._histogram_mode = value
            self.histogramModeChanged.emit()
            
    @Property(bool, notify=histogramModeChanged)
    def showRGB(self) -> bool:
        return self._show_rgb
        
    @showRGB.setter
    def showRGB(self, value: bool):
        if self._show_rgb != value:
            self._show_rgb = value
            self.histogramModeChanged.emit()
            
    @Property(bool, notify=histogramModeChanged)
    def showLuminance(self) -> bool:
        return self._show_luminance
        
    @showLuminance.setter
    def showLuminance(self, value: bool):
        if self._show_luminance != value:
            self._show_luminance = value
            self.histogramModeChanged.emit()
            
    @Property(bool, notify=histogramCalculating)
    def isCalculating(self) -> bool:
        return self._is_calculating
        
    @Property(bool, constant=True)
    def histogramAvailable(self) -> bool:
        return HISTOGRAM_AVAILABLE
        
    @Property(list, constant=True)
    def supportedModes(self) -> List[str]:
        return ["RGB", "Luminance", "All"]
        
    # 插槽方法
    @Slot(str)
    def calculateHistogram(self, image_path: str):
        """计算指定图像的直方图"""
        if self._is_calculating:
            return
            
        if not image_path:
            return
            
        self._is_calculating = True
        self.histogramCalculating.emit(True)
        
        # 在工作线程中计算直方图
        self._histogram_worker.calculateHistogram(image_path)
        
    @Slot()
    def clearHistogram(self):
        """清除直方图数据"""
        self._r_histogram = []
        self._g_histogram = []
        self._b_histogram = []
        self._luminance_histogram = []
        self.histogramDataChanged.emit()
        
    @Slot(result=float)
    def getMaxHistogramValue(self) -> float:
        """获取直方图的最大值，用于归一化显示"""
        max_values = []
        
        if self._r_histogram:
            max_values.append(max(self._r_histogram))
        if self._g_histogram:
            max_values.append(max(self._g_histogram))
        if self._b_histogram:
            max_values.append(max(self._b_histogram))
        if self._luminance_histogram:
            max_values.append(max(self._luminance_histogram))
            
        return max(max_values) if max_values else 1.0
        
    def _on_histogram_calculated(self, r_hist, g_hist, b_hist, lum_hist):
        """直方图计算完成处理"""
        self._r_histogram = r_hist
        self._g_histogram = g_hist
        self._b_histogram = b_hist
        self._luminance_histogram = lum_hist
        
        self._is_calculating = False
        self.histogramCalculating.emit(False)
        self.histogramDataChanged.emit()
        
    def _on_histogram_error(self, error_message: str):
        """直方图计算错误处理"""
        print(f"直方图计算错误: {error_message}")
        self._is_calculating = False
        self.histogramCalculating.emit(False)
        
    def shutdown(self):
        """关闭直方图控制器"""
        self._histogram_thread.quit()
        self._histogram_thread.wait()