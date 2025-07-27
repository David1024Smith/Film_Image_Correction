"""
图像控制器模块
负责图像显示、预览和缩放功能
"""

from __future__ import annotations

import sys
from pathlib import Path

from PySide6.QtCore import QObject, Signal, Property, Slot
from PySide6.QtQml import QmlElement
from PySide6.QtGui import QPixmap

# 添加核心模块路径
current_dir = Path(__file__).parent.parent.parent.resolve()
if str(current_dir) not in sys.path:
    sys.path.insert(0, str(current_dir))

# 导入图像转换工具
try:
    from gui.utils.image_converter import ImageConverter
    IMAGE_CONVERTER_AVAILABLE = True
except ImportError as e:
    print(f"图像转换工具导入失败: {e}")
    IMAGE_CONVERTER_AVAILABLE = False

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
        print(f"[ImageController] 开始加载图像: {image_path}")
        try:
            if not image_path:
                print("[ImageController] 图像路径为空，重置图像状态")
                self._reset_image()
                return
                
            from pathlib import Path
            path = Path(image_path)
            
            if not path.exists():
                print(f"[ImageController] 图像文件不存在: {image_path}")
                self._reset_image()
                return
                
            # 检查文件格式
            file_ext = path.suffix.lower()
            print(f"[ImageController] 图像文件格式: {file_ext}")
            
            # 对于TIFF格式，转换为PNG以提高兼容性
            display_path = image_path
            if file_ext in ['.tif', '.tiff'] and IMAGE_CONVERTER_AVAILABLE:
                try:
                    print("[ImageController] 检测到TIFF格式，尝试转换为PNG")
                    png_path = ImageConverter.get_cached_png(image_path)
                    if png_path and Path(png_path).exists():
                        print(f"[ImageController] 成功转换为PNG: {png_path}")
                        display_path = png_path
                    else:
                        print("[ImageController] 转换失败，使用原始路径")
                except Exception as conv_error:
                    print(f"[ImageController] 转换图像时出错: {conv_error}")
            
            # 获取图像尺寸
            try:
                pixmap = QPixmap(display_path)
                if not pixmap.isNull():
                    self._image_width = pixmap.width()
                    self._image_height = pixmap.height()
                    print(f"[ImageController] 获取图像尺寸: {self._image_width} x {self._image_height}")
                else:
                    # 使用默认尺寸
                    self._image_width = 1024
                    self._image_height = 768
                    print(f"[ImageController] 使用默认尺寸: {self._image_width} x {self._image_height}")
            except Exception as e:
                self._image_width = 1024
                self._image_height = 768
                print(f"[ImageController] 获取尺寸失败，使用默认: {e}")
            
            # 直接使用文件路径，转换为file:// URL格式
            file_url = Path(display_path).as_uri()
            
            # 更新状态
            self._current_image_path = file_url  # 直接使用文件URL
            self._original_file_path = image_path
            self._image_loaded = True
            
            # 重置缩放
            self._zoom_level = 1.0
            
            print(f"[ImageController] 图像加载完成: {image_path} -> {file_url}")
            print(f"[ImageController] 最终图像尺寸: {self._image_width} x {self._image_height}")
            
            # 发出信号
            print("[ImageController] 发出信号通知界面更新")
            self.currentImageChanged.emit()
            self.imageSizeChanged.emit()
            self.imageLoadedChanged.emit()
            self.zoomLevelChanged.emit()
            
            print("[ImageController] 图像加载流程完成")
            
        except Exception as e:
            print(f"[ImageController] 图像加载失败: {e}")
            import traceback
            traceback.print_exc()
            self._reset_image()
            # 发出错误信号
            try:
                from PySide6.QtCore import QCoreApplication
                app = QCoreApplication.instance()
                if app and hasattr(app, "mainController"):
                    app.mainController.errorOccurred.emit(f"图像加载失败: {e}")
            except Exception as signal_error:
                print(f"[ImageController] 发送错误信号失败: {signal_error}")
            
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
        print(f"[ImageController] 设置帧路径: 索引 {frame_index}, 路径: {file_path}")
        self._current_frame_index = frame_index  # 更新当前帧索引
        
        if file_path:
            print(f"[ImageController] 开始加载帧 {frame_index} 的图像")
            self.loadImage(file_path)
        else:
            print(f"[ImageController] 警告: 帧 {frame_index} 的文件路径为空")
            self._reset_image()
        
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
        
    @Slot(str, result=str)
    def getPreviewImagePath(self, image_path: str) -> str:
        """获取预览图像路径，处理TIFF转换等"""
        if not image_path:
            return ""
            
        try:
            from pathlib import Path
            path = Path(image_path)
            
            if not path.exists():
                return ""
                
            # 检查文件格式
            file_ext = path.suffix.lower()
            
            # 对于TIFF格式，转换为PNG以提高兼容性
            if file_ext in ['.tif', '.tiff'] and IMAGE_CONVERTER_AVAILABLE:
                try:
                    png_path = ImageConverter.get_cached_png(image_path)
                    if png_path and Path(png_path).exists():
                        return Path(png_path).as_uri()
                except Exception as conv_error:
                    print(f"[ImageController] 转换图像时出错: {conv_error}")
            
            # 返回原始路径的file:// URL格式
            return path.as_uri()
            
        except Exception as e:
            print(f"[ImageController] 获取预览路径失败: {e}")
            return ""

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