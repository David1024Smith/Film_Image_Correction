"""
窗口控制器模块
负责管理界面间的跳转
"""

from PySide6.QtCore import QObject, Signal, Slot
from PySide6.QtQml import QmlElement

QML_IMPORT_NAME = "Revela"
QML_IMPORT_MAJOR_VERSION = 1

@QmlElement
class WindowController(QObject):
    """窗口控制器 - 管理界面跳转"""
    
    # 信号定义
    navigateToParameterControl = Signal()
    navigateToAdjustment = Signal()
    navigateToFileManagement = Signal()
    
    def __init__(self, parent=None):
        super().__init__(parent)
        self._current_window = None
        
    @Slot()
    def goToParameterControl(self):
        """跳转到参数控制界面"""
        print("[WindowController] 跳转到参数控制界面")
        self.navigateToParameterControl.emit()
        
    @Slot()
    def goToAdjustment(self):
        """跳转到调整界面"""
        print("[WindowController] 跳转到调整界面")
        self.navigateToAdjustment.emit()
        
    @Slot()
    def goToFileManagement(self):
        """跳转到文件管理界面"""
        print("[WindowController] 跳转到文件管理界面")
        self.navigateToFileManagement.emit()
        
    def setCurrentWindow(self, window):
        """设置当前窗口"""
        self._current_window = window
        
    def getCurrentWindow(self):
        """获取当前窗口"""
        return self._current_window