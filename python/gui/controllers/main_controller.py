"""
主控制器模块
负责应用程序的全局状态管理和控制器协调
"""

from __future__ import annotations

from PySide6.QtCore import QObject, Signal, Property, Slot
from PySide6.QtQml import QmlElement

QML_IMPORT_NAME = "Revela"
QML_IMPORT_MAJOR_VERSION = 1


@QmlElement
class MainController(QObject):
    """主控制器 - 管理应用程序全局状态"""
    
    # 信号定义
    statusChanged = Signal(str)  # 状态栏消息变化
    busyChanged = Signal(bool)   # 忙碌状态变化
    errorOccurred = Signal(str)  # 错误发生
    
    def __init__(self, parent=None):
        super().__init__(parent)
        self._status = "就绪"
        self._busy = False
        
        # 其他控制器引用
        self.project_controller = None
        self.image_controller = None
        self.parameter_controller = None
        
    # 属性定义
    @Property(str, notify=statusChanged)
    def status(self) -> str:
        return self._status
        
    @status.setter
    def status(self, value: str):
        if self._status != value:
            self._status = value
            self.statusChanged.emit(value)
            
    @Property(bool, notify=busyChanged)
    def busy(self) -> bool:
        return self._busy
        
    @busy.setter
    def busy(self, value: bool):
        if self._busy != value:
            self._busy = value
            self.busyChanged.emit(value)
            
    # 插槽方法
    @Slot()
    def initialize(self):
        """初始化应用程序"""
        try:
            self.status = "正在初始化..."
            self.busy = True
            
            # TODO: 初始化各个控制器
            # TODO: 加载配置文件
            # TODO: 设置默认值
            
            self.status = "就绪"
            self.busy = False
            
        except Exception as e:
            self.busy = False
            self.status = "初始化失败"
            self.errorOccurred.emit(f"初始化失败: {str(e)}")
            
    @Slot()
    def shutdown(self):
        """应用程序关闭清理"""
        try:
            self.status = "正在关闭..."
            
            # TODO: 保存配置
            # TODO: 清理资源
            
        except Exception as e:
            self.errorOccurred.emit(f"关闭时发生错误: {str(e)}")
            
    @Slot(str)
    def setStatus(self, message: str):
        """设置状态消息"""
        self.status = message
        
    @Slot(bool)
    def setBusy(self, busy: bool):
        """设置忙碌状态"""
        self.busy = busy 