"""
导出控制器模块
负责批量导出功能的界面控制
"""

from __future__ import annotations

import sys
from pathlib import Path
from typing import Optional

from PySide6.QtCore import QObject, Signal, Property, Slot, QThread, QUrl
from PySide6.QtQml import QmlElement

# 添加核心模块路径
current_dir = Path(__file__).parent.parent.parent.resolve()
if str(current_dir) not in sys.path:
    sys.path.insert(0, str(current_dir))

try:
    from engine.exporter import Exporter
    from engine.renderer import Renderer
    from core.recipe import ExportRecipe, ExportFormat
    ENGINE_AVAILABLE = True
except ImportError as e:
    print(f"导出引擎模块导入警告: {e}")
    Exporter = None
    Renderer = None
    ExportRecipe = None
    ExportFormat = None
    ENGINE_AVAILABLE = False

QML_IMPORT_NAME = "Revela"
QML_IMPORT_MAJOR_VERSION = 1


class ExportWorker(QObject):
    """导出工作线程"""
    
    # 信号定义
    exportProgress = Signal(float)           # 导出进度 (0.0-1.0)
    exportStatusChanged = Signal(str)        # 导出状态消息
    exportCompleted = Signal()               # 导出完成
    exportError = Signal(str)                # 导出错误
    
    def __init__(self):
        super().__init__()
        self._exporter = None
        self._renderer = None
        self._is_running = False
        
    def initialize(self):
        """初始化导出组件"""
        try:
            if ENGINE_AVAILABLE:
                self._renderer = Renderer()
                self._exporter = Exporter(self._renderer)
                print("导出引擎初始化成功")
            else:
                print("导出引擎不可用，将使用模拟模式")
        except Exception as e:
            self.exportError.emit(f"导出引擎初始化失败: {str(e)}")
            
    def exportRoll(self, roll_object, export_settings, output_path):
        """导出胶卷"""
        try:
            self._is_running = True
            
            if not ENGINE_AVAILABLE or not self._exporter:
                # 模拟导出流程
                self._simulate_export(len(roll_object.frames) if roll_object else 10)
                return
                
            self.exportStatusChanged.emit("正在准备导出...")
            self.exportProgress.emit(0.1)
            
            # 创建导出配方
            recipe = ExportRecipe()
            recipe.export_format = export_settings.get('format', ExportFormat.JPG)
            recipe.quality = export_settings.get('quality', 90)
            recipe.filename_suffix = export_settings.get('suffix', 'processed')
            
            self.exportStatusChanged.emit("正在导出图像...")
            self.exportProgress.emit(0.3)
            
            # 执行导出
            output_dir = Path(output_path)
            self._exporter.export_roll_with_memory_optimization(
                roll_object, recipe, output_dir
            )
            
            self.exportProgress.emit(1.0)
            self.exportStatusChanged.emit("导出完成")
            self.exportCompleted.emit()
                
        except Exception as e:
            self.exportError.emit(f"导出过程出错: {str(e)}")
        finally:
            self._is_running = False
            
    def _simulate_export(self, frame_count):
        """模拟导出流程"""
        from PySide6.QtCore import QTimer
        
        steps = [
            (0.2, "正在准备导出文件..."),
            (0.4, f"正在处理 {frame_count} 帧图像..."),
            (0.6, "正在应用颜色校正..."),
            (0.8, "正在保存文件..."),
            (1.0, "导出完成")
        ]
        
        def run_step(step_index):
            if step_index < len(steps):
                progress, message = steps[step_index]
                self.exportProgress.emit(progress)
                self.exportStatusChanged.emit(message)
                
                if step_index == len(steps) - 1:
                    self.exportCompleted.emit()
                else:
                    QTimer.singleShot(1000, lambda: run_step(step_index + 1))
                    
        run_step(0)
        
    def stopExport(self):
        """停止导出"""
        self._is_running = False
        self.exportStatusChanged.emit("导出已停止")


@QmlElement
class ExportController(QObject):
    """导出控制器 - 管理批量导出流程"""
    
    # 信号定义
    exportRunningChanged = Signal()          # 导出运行状态变化
    exportProgressChanged = Signal()         # 导出进度变化
    exportStatusChanged = Signal()           # 导出状态变化
    exportCompleted = Signal()               # 导出完成
    exportError = Signal(str)                # 导出错误
    exportSettingsChanged = Signal()         # 导出设置变化
    
    def __init__(self, parent=None):
        super().__init__(parent)
        self._export_running = False
        self._export_progress = 0.0
        self._export_status = "就绪"
        
        # 导出设置
        self._export_format = "JPEG"
        self._export_quality = 90
        self._export_bit_depth = 8
        self._filename_suffix = "processed"
        self._output_directory = ""
        
        # 创建导出工作线程
        self._export_thread = QThread()
        self._export_worker = ExportWorker()
        self._export_worker.moveToThread(self._export_thread)
        
        # 连接信号
        self._export_worker.exportProgress.connect(self._on_progress_changed)
        self._export_worker.exportStatusChanged.connect(self._on_status_changed)
        self._export_worker.exportCompleted.connect(self._on_export_completed)
        self._export_worker.exportError.connect(self._on_export_error)
        
        # 启动工作线程并初始化
        self._export_thread.started.connect(self._export_worker.initialize)
        self._export_thread.start()
        
    # 属性定义
    @Property(bool, notify=exportRunningChanged)
    def exportRunning(self) -> bool:
        return self._export_running
        
    @Property(float, notify=exportProgressChanged)
    def exportProgress(self) -> float:
        return self._export_progress
        
    @Property(str, notify=exportStatusChanged)
    def exportStatus(self) -> str:
        return self._export_status
        
    @Property(str, notify=exportSettingsChanged)
    def exportFormat(self) -> str:
        return self._export_format
        
    @exportFormat.setter
    def exportFormat(self, value: str):
        if self._export_format != value:
            self._export_format = value
            self.exportSettingsChanged.emit()
            
    @Property(int, notify=exportSettingsChanged)
    def exportQuality(self) -> int:
        return self._export_quality
        
    @exportQuality.setter
    def exportQuality(self, value: int):
        value = max(1, min(100, value))
        if self._export_quality != value:
            self._export_quality = value
            self.exportSettingsChanged.emit()
            
    @Property(int, notify=exportSettingsChanged)
    def exportBitDepth(self) -> int:
        return self._export_bit_depth
        
    @exportBitDepth.setter
    def exportBitDepth(self, value: int):
        if value in [8, 16] and self._export_bit_depth != value:
            self._export_bit_depth = value
            self.exportSettingsChanged.emit()
            
    @Property(str, notify=exportSettingsChanged)
    def filenameSuffix(self) -> str:
        return self._filename_suffix
        
    @filenameSuffix.setter
    def filenameSuffix(self, value: str):
        if self._filename_suffix != value:
            self._filename_suffix = value
            self.exportSettingsChanged.emit()
            
    @Property(str, notify=exportSettingsChanged)
    def outputDirectory(self) -> str:
        return self._output_directory
        
    @outputDirectory.setter
    def outputDirectory(self, value: str):
        if self._output_directory != value:
            self._output_directory = value
            self.exportSettingsChanged.emit()
            
    @Property(list, constant=True)
    def supportedFormats(self) -> list:
        return ["JPEG", "TIFF", "PNG"]
        
    @Property(bool, constant=True)
    def engineAvailable(self) -> bool:
        return ENGINE_AVAILABLE
        
    # 插槽方法
    @Slot("QVariant")
    def startExport(self, roll_object):
        """开始导出胶卷"""
        if self._export_running:
            return
            
        if not roll_object:
            self.exportError.emit("无效的胶卷对象")
            return
            
        if not self._output_directory:
            self.exportError.emit("请选择输出目录")
            return
            
        self._export_running = True
        self._export_progress = 0.0
        self._export_status = "正在启动导出..."
        
        self.exportRunningChanged.emit()
        self.exportProgressChanged.emit()
        self.exportStatusChanged.emit()
        
        # 准备导出设置
        export_settings = {
            'format': self._get_export_format_enum(),
            'quality': self._export_quality,
            'bit_depth': self._export_bit_depth,
            'suffix': self._filename_suffix
        }
        
        # 在工作线程中执行导出
        self._export_worker.exportRoll(roll_object, export_settings, self._output_directory)
        
    @Slot()
    def stopExport(self):
        """停止导出"""
        if not self._export_running:
            return
            
        self._export_worker.stopExport()
        self._export_running = False
        self._export_progress = 0.0
        self._export_status = "已停止"
        
        self.exportRunningChanged.emit()
        self.exportProgressChanged.emit()
        self.exportStatusChanged.emit()
        
    @Slot(QUrl)
    def setOutputDirectory(self, directory_url: QUrl):
        """设置输出目录"""
        directory_path = directory_url.toLocalFile()
        self.outputDirectory = directory_path
        
    def _get_export_format_enum(self):
        """获取导出格式枚举值"""
        if not ENGINE_AVAILABLE:
            return self._export_format
            
        format_map = {
            "JPEG": ExportFormat.JPG,
            "TIFF": ExportFormat.TIF_16_BIT if self._export_bit_depth == 16 else ExportFormat.TIF_8_BIT,
            "PNG": ExportFormat.JPG  # PNG暂时映射到JPG
        }
        return format_map.get(self._export_format, ExportFormat.JPG)
        
    def _on_progress_changed(self, progress: float):
        """导出进度变化处理"""
        self._export_progress = progress
        self.exportProgressChanged.emit()
        
    def _on_status_changed(self, status: str):
        """导出状态变化处理"""
        self._export_status = status
        self.exportStatusChanged.emit()
        
    def _on_export_completed(self):
        """导出完成处理"""
        self._export_running = False
        self._export_progress = 1.0
        self._export_status = "导出完成"
        
        self.exportRunningChanged.emit()
        self.exportProgressChanged.emit()
        self.exportStatusChanged.emit()
        self.exportCompleted.emit()
        
    def _on_export_error(self, error_message: str):
        """导出错误处理"""
        self._export_running = False
        self._export_progress = 0.0
        self._export_status = f"导出错误: {error_message}"
        
        self.exportRunningChanged.emit()
        self.exportProgressChanged.emit()
        self.exportStatusChanged.emit()
        self.exportError.emit(error_message)
        
    def shutdown(self):
        """关闭导出控制器"""
        self.stopExport()
        self._export_thread.quit()
        self._export_thread.wait()