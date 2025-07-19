"""
图像控制器模块
负责图像显示、预览和缩放功能
"""

from __future__ import annotations

from PySide6.QtCore import QObject, Signal, Property, Slot
from PySide6.QtQml import QmlElement
from PySide6.QtGui import QPixmap

QML_IMPORT_NAME = "Revela"
QML_IMPORT_MAJOR_VERSION = 1


@QmlElement
class ImageController(QObject):
    """图像控制器 - 管理图像显示和预览"""
    
    # 信号定义
    currentImageChanged = Signal()     # 当前图像变化
    zoomLevelChanged = Signal()        # 缩放级别变化
    imageLoadedChanged = Signal()      # 图像加载状态变化
    imageSizeChanged = Signal()        # 图像尺寸变化
    frameIndexChanged = Signal(int)    # 帧索引变化信号
    
    def __init__(self, parent=None):
        super().__init__(parent)
        self._current_image_path = ""       # 图像提供器URL
        self._original_file_path = ""       # 原始文件路径
        self._current_frame_index = -1
        self._zoom_level = 1.0
        self._min_zoom = 0.1
        self._max_zoom = 10.0
        self._image_loaded = False
        self._image_width = 0
        self._image_height = 0
        
        # 图像缓存
        self._image_cache = {}
        
    # 属性定义
    @Property(str, notify=currentImageChanged)
    def currentImagePath(self) -> str:
        return self._current_image_path
        
    @Property(int, notify=currentImageChanged)
    def currentFrameIndex(self) -> int:
        return self._current_frame_index
        
    @Property(float, notify=zoomLevelChanged)
    def zoomLevel(self) -> float:
        return self._zoom_level
        
    @zoomLevel.setter
    def zoomLevel(self, value: float):
        # 限制缩放范围
        value = max(self._min_zoom, min(self._max_zoom, value))
        if self._zoom_level != value:
            self._zoom_level = value
            self.zoomLevelChanged.emit()
            
    @Property(float, constant=True)
    def minZoom(self) -> float:
        return self._min_zoom
        
    @Property(float, constant=True)
    def maxZoom(self) -> float:
        return self._max_zoom
        
    @Property(bool, notify=imageLoadedChanged)
    def imageLoaded(self) -> bool:
        return self._image_loaded
        
    @Property(int, notify=imageSizeChanged)
    def imageWidth(self) -> int:
        return self._image_width
        
    @Property(int, notify=imageSizeChanged)
    def imageHeight(self) -> int:
        return self._image_height
        
    # 插槽方法
    @Slot(str)
    def loadImage(self, image_path: str):
        """加载图像"""
        try:
            if not image_path:
                self._reset_image()
                return
                
            from pathlib import Path
            path = Path(image_path)
            
            if not path.exists():
                raise ValueError(f"图像文件不存在: {image_path}")
                
            # 构建图像提供器URL
            # 格式: image://filmProvider/frame:file_path
            provider_url = f"image://filmProvider/frame:{image_path}"
            
            # 尝试获取图像真实尺寸
            try:
                pixmap = QPixmap(image_path)
                if not pixmap.isNull():
                    self._image_width = pixmap.width()
                    self._image_height = pixmap.height()
                else:
                    # 使用默认尺寸
                    self._image_width = 3000
                    self._image_height = 2000
            except:
                # 使用默认尺寸
                self._image_width = 3000
                self._image_height = 2000
            
            self._current_image_path = provider_url  # 存储提供器URL
            self._original_file_path = image_path    # 存储原始文件路径
            self._image_loaded = True
            
            # 重置缩放
            self._zoom_level = 1.0
            
            print(f"图像加载: {image_path} -> {provider_url}")
            print(f"图像尺寸: {self._image_width} x {self._image_height}")
            
            # 发出信号
            self.currentImageChanged.emit()
            self.imageSizeChanged.emit()
            self.imageLoadedChanged.emit()
            self.zoomLevelChanged.emit()
            
        except Exception as e:
            print(f"图像加载失败: {e}")
            self._reset_image()
            # TODO: 发出错误信号
            
    @Slot(int)
    def loadFrameByIndex(self, frame_index: int):
        """根据帧索引加载图像"""
        try:
            self._current_frame_index = frame_index
            
            # 从项目控制器获取帧路径
            from . import project_controller
            # 这里需要通过应用程序的全局控制器引用获取
            # 暂时使用信号通知主控制器获取路径
            self.frameIndexChanged.emit(frame_index)
            
        except Exception as e:
            print(f"加载帧失败: {e}")
            
    def setFramePath(self, frame_index: int, file_path: str):
        """设置帧路径（由外部调用）"""
        if frame_index == self._current_frame_index and file_path:
            self.loadImage(file_path)
        
    @Slot(float)
    def setZoomLevel(self, zoom: float):
        """设置缩放级别"""
        self.zoomLevel = zoom
        
    @Slot()
    def zoomIn(self):
        """放大"""
        self.zoomLevel = self._zoom_level * 1.2
        
    @Slot()
    def zoomOut(self):
        """缩小"""
        self.zoomLevel = self._zoom_level / 1.2
        
    @Slot()
    def resetZoom(self):
        """重置缩放"""
        self.zoomLevel = 1.0
        
    @Slot()
    def fitToWindow(self):
        """适应窗口大小"""
        # TODO: 计算适合窗口的缩放级别
        self.zoomLevel = 1.0
        
    def _reset_image(self):
        """重置图像状态"""
        self._current_image_path = ""
        self._original_file_path = ""
        self._current_frame_index = -1
        self._image_width = 0
        self._image_height = 0
        self._image_loaded = False
        self._zoom_level = 1.0
        
        self.currentImageChanged.emit()
        self.imageSizeChanged.emit()
        self.imageLoadedChanged.emit()
        self.zoomLevelChanged.emit() 