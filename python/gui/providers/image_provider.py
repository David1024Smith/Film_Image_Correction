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
            print(f"[ImageLoadWorker] 开始加载图像: {decoded_path}")
            
            # 检查文件是否存在
            path = Path(decoded_path)
            if not path.exists():
                print(f"[ImageLoadWorker] 文件不存在: {decoded_path}")
                self.loadError.emit(image_id, f"文件不存在: {decoded_path}")
                return
            
            print(f"[ImageLoadWorker] 文件存在，大小: {path.stat().st_size} 字节")
            
            try:
                # 尝试使用QPixmap加载图像，然后转换为QImage
                # 这种方法对某些格式的支持更好
                from PySide6.QtGui import QPixmap
                pixmap = QPixmap()
                print(f"[ImageLoadWorker] 尝试使用QPixmap加载图像文件: {str(path)}")
                
                if pixmap.load(str(path)):
                    image = pixmap.toImage()
                    print(f"[ImageLoadWorker] QPixmap加载成功，转换为QImage，尺寸: {image.size()}")
                else:
                    # 如果QPixmap加载失败，尝试直接使用QImage
                    image = QImage()
                    print(f"[ImageLoadWorker] QPixmap加载失败，尝试使用QImage: {str(path)}")
                    if not image.load(str(path)):
                        print(f"[ImageLoadWorker] QImage.load() 也失败: {decoded_path}")
                        self.loadError.emit(image_id, f"无法加载图像: {decoded_path}")
                        return
                    print(f"[ImageLoadWorker] QImage加载成功，尺寸: {image.size()}")
                    
            except Exception as load_error:
                print(f"[ImageLoadWorker] 加载图像时出错: {load_error}")
                import traceback
                traceback.print_exc()
                
                # 最后尝试使用标准QImage加载
                image = QImage()
                print(f"[ImageLoadWorker] 最后尝试标准QImage加载")
                if not image.load(str(path)):
                    print(f"[ImageLoadWorker] 所有加载方法都失败: {decoded_path}")
                    self.loadError.emit(image_id, f"无法加载图像: {decoded_path}")
                    return
                print(f"[ImageLoadWorker] 标准QImage加载成功，尺寸: {image.size()}")
                
            # 检查图像是否有效
            if image.isNull():
                print(f"[ImageLoadWorker] 加载的图像无效: {decoded_path}")
                self.loadError.emit(image_id, f"加载的图像无效: {decoded_path}")
                return
                
            print(f"[ImageLoadWorker] 图像有效性检查通过，原始尺寸: {image.size()}")
                
            # 如果请求了特定尺寸，进行缩放
            if requested_size.isValid() and not requested_size.isEmpty():
                if image.size() != requested_size:
                    from PySide6.QtCore import Qt
                    print(f"[ImageLoadWorker] 缩放图像从 {image.size()} 到 {requested_size}")
                    try:
                        original_size = image.size()
                        image = image.scaled(
                            requested_size, 
                            Qt.KeepAspectRatio,
                            Qt.SmoothTransformation
                        )
                        print(f"[ImageLoadWorker] 缩放成功: {original_size} -> {image.size()}")
                    except Exception as scale_error:
                        print(f"[ImageLoadWorker] 缩放图像时出错: {scale_error}")
                        import traceback
                        traceback.print_exc()
                        # 如果缩放失败，使用原始图像
                    
            print(f"[ImageLoadWorker] 图像处理完成: 尺寸={image.size()}, 格式={image.format()}, 深度={image.depth()}")
            
            # 确保图像格式兼容
            original_format = image.format()
            if image.format() not in [QImage.Format_RGB32, QImage.Format_ARGB32, QImage.Format_ARGB32_Premultiplied]:
                print(f"[ImageLoadWorker] 转换图像格式从 {image.format()} 到 Format_ARGB32")
                try:
                    image = image.convertToFormat(QImage.Format_ARGB32)
                    print(f"[ImageLoadWorker] 格式转换成功: {original_format} -> {image.format()}")
                except Exception as format_error:
                    print(f"[ImageLoadWorker] 格式转换失败: {format_error}")
                    # 继续使用原格式
                
            print(f"[ImageLoadWorker] 准备发送图像加载完成信号")
            self.imageLoaded.emit(image_id, image)
            print(f"[ImageLoadWorker] 图像加载流程完成: {decoded_path}")
            
        except Exception as e:
            print(f"[ImageLoadWorker] 加载图像时发生异常: {str(e)}")
            import traceback
            traceback.print_exc()
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
        try:
            print(f"[ImageProvider] 请求图像: {image_id}, 尺寸: {requested_size}")
            
            # 安全检查
            if not image_id:
                print("[ImageProvider] 警告: 请求的image_id为空")
                error_image = QImage(200, 150, QImage.Format_RGB32)
                error_image.fill(0x808080)  # 灰色错误图像
                return error_image
            
            # 检查缓存
            cache_key = f"{image_id}_{requested_size.width()}x{requested_size.height()}" if requested_size.isValid() else image_id
            print(f"[ImageProvider] 缓存键: {cache_key}")
            
            if cache_key in self._image_cache:
                print(f"[ImageProvider] 从缓存返回图像: {cache_key}")
                try:
                    # 更新访问顺序
                    self._update_cache_access(cache_key)
                    cached_image = self._image_cache[cache_key]
                    if cached_image.isNull():
                        print("[ImageProvider] 警告: 缓存中的图像无效")
                        del self._image_cache[cache_key]
                        raise KeyError("缓存图像无效")
                    print(f"[ImageProvider] 缓存图像有效，尺寸: {cached_image.size()}")
                    return cached_image
                except Exception as cache_error:
                    print(f"[ImageProvider] 从缓存获取图像时出错: {cache_error}")
                    # 如果缓存访问出错，继续尝试重新加载
            
            # 解析image_id获取文件路径
            # image_id格式: "frame:/path/to/image.jpg" 或 "processed:/path/to/image.jpg"
            parts = image_id.split(":", 1)
            print(f"[ImageProvider] 解析image_id: {parts}")
            
            if len(parts) == 2:
                image_type, file_path = parts
                print(f"[ImageProvider] 图像类型: {image_type}, 文件路径: {file_path}")
                
                # 检查文件路径是否为空
                if not file_path or file_path.strip() == "":
                    print("[ImageProvider] 文件路径为空")
                    error_image = QImage(200, 150, QImage.Format_RGB32)
                    error_image.fill(0x808080)  # 灰色错误图像
                    return error_image
                
                # 验证文件是否存在
                from pathlib import Path
                from urllib.parse import unquote
                decoded_path = unquote(file_path)
                print(f"[ImageProvider] 解码后的文件路径: {decoded_path}")
                
                if not Path(decoded_path).exists():
                    print(f"[ImageProvider] 文件不存在: {decoded_path}")
                    error_image = QImage(200, 150, QImage.Format_RGB32)
                    error_image.fill(0xFF4444)  # 红色错误图像
                    return error_image
                
                try:
                    # 异步加载图像
                    print(f"[ImageProvider] 启动异步加载: {cache_key}")
                    self._load_worker.loadImage(cache_key, file_path, requested_size)
                except Exception as load_error:
                    print(f"[ImageProvider] 启动异步加载时出错: {load_error}")
                    import traceback
                    traceback.print_exc()
                
                # 返回占位符图像
                try:
                    print("[ImageProvider] 返回占位符图像")
                    placeholder = QImage(200, 150, QImage.Format_RGB32)
                    placeholder.fill(0x404040)  # 深灰色占位符
                    return placeholder
                except Exception as placeholder_error:
                    print(f"[ImageProvider] 创建占位符图像时出错: {placeholder_error}")
                    # 创建最简单的占位符
                    return QImage(10, 10, QImage.Format_RGB32)
            else:
                # 无效的image_id格式
                print(f"[ImageProvider] 无效的image_id格式: {image_id}")
                error_image = QImage(200, 150, QImage.Format_RGB32)
                error_image.fill(0xFF0000)  # 红色错误图像
                return error_image
                
        except Exception as e:
            print(f"[ImageProvider] requestImage方法发生异常: {e}")
            import traceback
            traceback.print_exc()
            
            # 返回一个安全的错误图像
            try:
                error_image = QImage(200, 150, QImage.Format_RGB32)
                error_image.fill(0xFF00FF)  # 紫色错误图像
                return error_image
            except:
                # 如果连创建错误图像都失败，返回最小的有效图像
                print("[ImageProvider] 创建错误图像也失败，返回最小图像")
                return QImage(1, 1, QImage.Format_RGB32)
            
    def _on_image_loaded(self, cache_key: str, image: QImage):
        """图像加载完成处理"""
        try:
            print(f"图像加载完成并缓存: {cache_key}")
            
            # 检查图像是否有效
            if image.isNull():
                print(f"警告: 加载的图像无效，不添加到缓存")
                return
                
            # 添加到缓存
            self._add_to_cache(cache_key, image)
            
            # 注意：由于QQuickImageProvider的异步特性，
            # 这里加载完成的图像会自动更新到QML中的Image组件
        except Exception as e:
            print(f"处理加载完成的图像时出错: {e}")
            import traceback
            traceback.print_exc()
        
    def _on_load_error(self, cache_key: str, error_message: str):
        """图像加载错误处理"""
        try:
            print(f"图像加载错误 {cache_key}: {error_message}")
            
            # 创建错误图像
            error_image = QImage(200, 150, QImage.Format_RGB32)
            error_image.fill(0xFF4444)  # 浅红色错误图像
            
            self._add_to_cache(cache_key, error_image)
        except Exception as e:
            print(f"处理图像加载错误时出错: {e}")
            import traceback
            traceback.print_exc()
        
    def _add_to_cache(self, cache_key: str, image: QImage):
        """添加图像到缓存"""
        try:
            # 检查图像是否有效
            if image.isNull():
                print(f"警告: 尝试添加无效图像到缓存: {cache_key}")
                return
                
            # 检查缓存大小限制
            if len(self._image_cache) >= self._max_cache_size:
                try:
                    # 移除最久未访问的图像
                    if self._cache_access_order:
                        oldest_key = self._cache_access_order.pop(0)
                        if oldest_key in self._image_cache:
                            del self._image_cache[oldest_key]
                except Exception as cache_error:
                    print(f"清理缓存时出错: {cache_error}")
                    # 如果清理失败，直接清空缓存
                    self._image_cache.clear()
                    self._cache_access_order.clear()
                
            # 添加新图像
            self._image_cache[cache_key] = image
            self._cache_access_order.append(cache_key)
            
        except Exception as e:
            print(f"添加图像到缓存时出错: {e}")
            import traceback
            traceback.print_exc()
        
    def _update_cache_access(self, cache_key: str):
        """更新缓存访问顺序"""
        try:
            if cache_key in self._cache_access_order:
                self._cache_access_order.remove(cache_key)
            self._cache_access_order.append(cache_key)
        except Exception as e:
            print(f"更新缓存访问顺序时出错: {e}")
            # 如果更新失败，不影响主要功能
        
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