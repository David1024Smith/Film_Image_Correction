"""
图像提供器模块
实现QQuickImageProvider为QML提供高性能图像显示
"""

from __future__ import annotations

import sys
from pathlib import Path
from typing import Dict, Optional
from PySide6.QtGui import QPixmap, QImage
from PySide6.QtCore import QSize, QThread, Signal, QObject
from PySide6.QtQml import qmlRegisterType
from PySide6.QtQuick import QQuickImageProvider

# 添加核心模块路径
current_dir = Path(__file__).parent.parent.parent.resolve()
if str(current_dir) not in sys.path:
    sys.path.insert(0, str(current_dir))


class ImageLoadWorker(QObject):
    """图像加载工作线程"""
    
    imageLoaded = Signal(str, QImage)  # 图像加载完成信号
    loadError = Signal(str, str)       # 加载错误信号
    
    def __init__(self):
        super().__init__()
        self._pending_requests = {}
        
    def loadImage(self, image_id: str, file_path: str, requested_size: QSize):
        """加载图像"""
        try:
            # URL解码文件路径
            from urllib.parse import unquote
            decoded_path = unquote(file_path)
            print(f"加载图像: {decoded_path}")
            
            # 检查文件是否存在
            path = Path(decoded_path)
            if not path.exists():
                self.loadError.emit(image_id, f"文件不存在: {decoded_path}")
                return
                
            # 加载图像
            image = QImage()
            if not image.load(str(path)):
                self.loadError.emit(image_id, f"无法加载图像: {decoded_path}")
                return
                
            # 如果请求了特定尺寸，进行缩放
            if requested_size.isValid() and not requested_size.isEmpty():
                if image.size() != requested_size:
                    from PySide6.QtCore import Qt
                    image = image.scaled(
                        requested_size, 
                        Qt.KeepAspectRatio,
                        Qt.SmoothTransformation
                    )
                    
            print(f"图像加载成功: {image.size()}")
            self.imageLoaded.emit(image_id, image)
            
        except Exception as e:
            self.loadError.emit(image_id, f"加载图像时发生错误: {str(e)}")


class FilmImageProvider(QQuickImageProvider):
    """胶片图像提供器"""
    
    def __init__(self):
        super().__init__(QQuickImageProvider.Image, QQuickImageProvider.ForceAsynchronousImageLoading)
        self._image_cache: Dict[str, QImage] = {}
        self._max_cache_size = 50  # 最大缓存图像数量
        self._cache_access_order = []  # LRU缓存访问顺序
        
        # 创建图像加载工作线程
        self._load_thread = QThread()
        self._load_worker = ImageLoadWorker()
        self._load_worker.moveToThread(self._load_thread)
        
        # 连接信号
        self._load_worker.imageLoaded.connect(self._on_image_loaded)
        self._load_worker.loadError.connect(self._on_load_error)
        
        self._load_thread.start()
        
    def requestImage(self, image_id: str, size: QSize, requested_size: QSize) -> QImage:
        """QML请求图像时调用"""
        print(f"请求图像: {image_id}, 尺寸: {requested_size}")
        
        # 检查缓存
        cache_key = f"{image_id}_{requested_size.width()}x{requested_size.height()}" if requested_size.isValid() else image_id
        
        if cache_key in self._image_cache:
            print(f"从缓存返回图像: {cache_key}")
            # 更新访问顺序
            self._update_cache_access(cache_key)
            return self._image_cache[cache_key]
            
        # 解析image_id获取文件路径
        # image_id格式: "frame:/path/to/image.jpg" 或 "processed:/path/to/image.jpg"
        parts = image_id.split(":", 1)
        if len(parts) == 2:
            image_type, file_path = parts
            
            # 异步加载图像
            self._load_worker.loadImage(cache_key, file_path, requested_size)
            
            # 返回占位符图像
            placeholder = QImage(200, 150, QImage.Format_RGB32)
            placeholder.fill(0x404040)  # 深灰色占位符
            return placeholder
        else:
            # 无效的image_id格式
            error_image = QImage(200, 150, QImage.Format_RGB32)
            error_image.fill(0xFF0000)  # 红色错误图像
            return error_image
            
    def _on_image_loaded(self, cache_key: str, image: QImage):
        """图像加载完成处理"""
        print(f"图像加载完成并缓存: {cache_key}")
        
        # 添加到缓存
        self._add_to_cache(cache_key, image)
        
        # 注意：由于QQuickImageProvider的异步特性，
        # 这里加载完成的图像会自动更新到QML中的Image组件
        
    def _on_load_error(self, cache_key: str, error_message: str):
        """图像加载错误处理"""
        print(f"图像加载错误 {cache_key}: {error_message}")
        
        # 创建错误图像
        error_image = QImage(200, 150, QImage.Format_RGB32)
        error_image.fill(0xFF4444)  # 浅红色错误图像
        
        self._add_to_cache(cache_key, error_image)
        
    def _add_to_cache(self, cache_key: str, image: QImage):
        """添加图像到缓存"""
        # 检查缓存大小限制
        if len(self._image_cache) >= self._max_cache_size:
            # 移除最久未访问的图像
            oldest_key = self._cache_access_order.pop(0)
            if oldest_key in self._image_cache:
                del self._image_cache[oldest_key]
                
        # 添加新图像
        self._image_cache[cache_key] = image
        self._cache_access_order.append(cache_key)
        
    def _update_cache_access(self, cache_key: str):
        """更新缓存访问顺序"""
        if cache_key in self._cache_access_order:
            self._cache_access_order.remove(cache_key)
        self._cache_access_order.append(cache_key)
        
    def clear_cache(self):
        """清空图像缓存"""
        self._image_cache.clear()
        self._cache_access_order.clear()
        print("图像缓存已清空")
        
    def get_cache_info(self) -> dict:
        """获取缓存信息"""
        return {
            "size": len(self._image_cache),
            "max_size": self._max_cache_size,
            "keys": list(self._image_cache.keys())
        }
        
    def shutdown(self):
        """关闭图像提供器"""
        self._load_thread.quit()
        self._load_thread.wait()
        self.clear_cache() 