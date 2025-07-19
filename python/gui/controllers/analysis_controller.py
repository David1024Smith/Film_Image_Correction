"""
分析控制器模块
负责胶卷分析工作流程，集成engine.analyzer等分析模块
"""

from __future__ import annotations

import sys
from pathlib import Path
from typing import Optional

from PySide6.QtCore import QObject, Signal, Property, Slot, QThread
from PySide6.QtQml import QmlElement

# 添加核心模块路径
current_dir = Path(__file__).parent.parent.parent.resolve()
if str(current_dir) not in sys.path:
    sys.path.insert(0, str(current_dir))

try:
    from engine.analyzer import Analyzer
    from engine.coordinator import AnalysisCoordinator
    ENGINE_AVAILABLE = True
except ImportError as e:
    print(f"引擎模块导入警告: {e}")
    Analyzer = None
    AnalysisCoordinator = None
    ENGINE_AVAILABLE = False

QML_IMPORT_NAME = "Revela"
QML_IMPORT_MAJOR_VERSION = 1


class AnalysisWorker(QObject):
    """分析工作线程"""
    
    # 信号定义
    analysisProgress = Signal(float)           # 分析进度 (0.0-1.0)
    analysisStatusChanged = Signal(str)        # 分析状态消息
    analysisCompleted = Signal(object)         # 分析完成，返回校准数据
    analysisError = Signal(str)                # 分析错误
    
    def __init__(self):
        super().__init__()
        self._analyzer = None
        self._coordinator = None
        self._is_running = False
        
    def initialize(self):
        """初始化分析组件"""
        try:
            if ENGINE_AVAILABLE:
                self._analyzer = Analyzer()
                self._coordinator = AnalysisCoordinator(analyzer=self._analyzer)
                print("分析引擎初始化成功")
            else:
                print("分析引擎不可用，将使用模拟模式")
        except Exception as e:
            self.analysisError.emit(f"分析引擎初始化失败: {str(e)}")
            
    def analyzeRoll(self, roll_object):
        """分析胶卷"""
        try:
            self._is_running = True
            
            if not ENGINE_AVAILABLE or not self._coordinator:
                # 模拟分析流程
                self._simulate_analysis()
                return
                
            self.analysisStatusChanged.emit("正在初始化分析...")
            self.analysisProgress.emit(0.1)
            
            # 实际分析流程
            self.analysisStatusChanged.emit("正在分析胶卷特性...")
            self.analysisProgress.emit(0.3)
            
            # 调用协调器进行分析
            self._coordinator.get_calibration_profile(roll_object)
            
            self.analysisProgress.emit(0.7)
            self.analysisStatusChanged.emit("正在计算校准参数...")
            
            # 获取校准结果
            calibration = roll_object.calibration
            
            if calibration:
                self.analysisProgress.emit(1.0)
                self.analysisStatusChanged.emit("分析完成")
                self.analysisCompleted.emit(calibration)
            else:
                self.analysisError.emit("未能获取有效的校准数据")
                
        except Exception as e:
            self.analysisError.emit(f"分析过程出错: {str(e)}")
        finally:
            self._is_running = False
            
    def _simulate_analysis(self):
        """模拟分析流程"""
        import time
        from PySide6.QtCore import QTimer
        
        steps = [
            (0.2, "正在扫描胶片帧..."),
            (0.4, "正在分析密度曲线..."),
            (0.6, "正在计算D-min值..."),
            (0.8, "正在计算K值..."),
            (1.0, "分析完成")
        ]
        
        def run_step(step_index):
            if step_index < len(steps):
                progress, message = steps[step_index]
                self.analysisProgress.emit(progress)
                self.analysisStatusChanged.emit(message)
                
                if step_index == len(steps) - 1:
                    # 创建模拟校准数据
                    calibration_data = type('MockCalibration', (), {
                        'd_min': 0.125,
                        'k_values': [0.847, 0.923, 0.756]
                    })()
                    self.analysisCompleted.emit(calibration_data)
                else:
                    QTimer.singleShot(800, lambda: run_step(step_index + 1))
                    
        run_step(0)
        
    def stopAnalysis(self):
        """停止分析"""
        self._is_running = False
        self.analysisStatusChanged.emit("分析已停止")


@QmlElement
class AnalysisController(QObject):
    """分析控制器 - 管理胶卷分析流程"""
    
    # 信号定义
    analysisRunningChanged = Signal()          # 分析运行状态变化
    analysisProgressChanged = Signal()         # 分析进度变化
    analysisStatusChanged = Signal()           # 分析状态变化
    analysisCompleted = Signal(object)         # 分析完成
    analysisError = Signal(str)                # 分析错误
    
    def __init__(self, parent=None):
        super().__init__(parent)
        self._analysis_running = False
        self._analysis_progress = 0.0
        self._analysis_status = "就绪"
        
        # 创建分析工作线程
        self._analysis_thread = QThread()
        self._analysis_worker = AnalysisWorker()
        self._analysis_worker.moveToThread(self._analysis_thread)
        
        # 连接信号
        self._analysis_worker.analysisProgress.connect(self._on_progress_changed)
        self._analysis_worker.analysisStatusChanged.connect(self._on_status_changed)
        self._analysis_worker.analysisCompleted.connect(self._on_analysis_completed)
        self._analysis_worker.analysisError.connect(self._on_analysis_error)
        
        # 启动工作线程并初始化
        self._analysis_thread.started.connect(self._analysis_worker.initialize)
        self._analysis_thread.start()
        
    # 属性定义
    @Property(bool, notify=analysisRunningChanged)
    def analysisRunning(self) -> bool:
        return self._analysis_running
        
    @Property(float, notify=analysisProgressChanged)
    def analysisProgress(self) -> float:
        return self._analysis_progress
        
    @Property(str, notify=analysisStatusChanged)
    def analysisStatus(self) -> str:
        return self._analysis_status
        
    @Property(bool, constant=True)
    def engineAvailable(self) -> bool:
        return ENGINE_AVAILABLE
        
    # 插槽方法
    @Slot("QVariant")
    def startAnalysis(self, roll_object):
        """开始分析胶卷"""
        if self._analysis_running:
            return
            
        if not roll_object:
            self.analysisError.emit("无效的胶卷对象")
            return
            
        self._analysis_running = True
        self._analysis_progress = 0.0
        self._analysis_status = "正在启动分析..."
        
        self.analysisRunningChanged.emit()
        self.analysisProgressChanged.emit()
        self.analysisStatusChanged.emit()
        
        # 在工作线程中执行分析
        self._analysis_worker.analyzeRoll(roll_object)
        
    @Slot()
    def stopAnalysis(self):
        """停止分析"""
        if not self._analysis_running:
            return
            
        self._analysis_worker.stopAnalysis()
        self._analysis_running = False
        self._analysis_progress = 0.0
        self._analysis_status = "已停止"
        
        self.analysisRunningChanged.emit()
        self.analysisProgressChanged.emit()
        self.analysisStatusChanged.emit()
        
    def _on_progress_changed(self, progress: float):
        """分析进度变化处理"""
        self._analysis_progress = progress
        self.analysisProgressChanged.emit()
        
    def _on_status_changed(self, status: str):
        """分析状态变化处理"""
        self._analysis_status = status
        self.analysisStatusChanged.emit()
        
    def _on_analysis_completed(self, calibration_data):
        """分析完成处理"""
        self._analysis_running = False
        self._analysis_progress = 1.0
        self._analysis_status = "分析完成"
        
        self.analysisRunningChanged.emit()
        self.analysisProgressChanged.emit()
        self.analysisStatusChanged.emit()
        self.analysisCompleted.emit(calibration_data)
        
    def _on_analysis_error(self, error_message: str):
        """分析错误处理"""
        self._analysis_running = False
        self._analysis_progress = 0.0
        self._analysis_status = f"分析错误: {error_message}"
        
        self.analysisRunningChanged.emit()
        self.analysisProgressChanged.emit()
        self.analysisStatusChanged.emit()
        self.analysisError.emit(error_message)
        
    def shutdown(self):
        """关闭分析控制器"""
        self.stopAnalysis()
        self._analysis_thread.quit()
        self._analysis_thread.wait() 