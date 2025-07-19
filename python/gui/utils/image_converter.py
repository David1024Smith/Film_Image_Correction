"""
图像转换工具模块
提供各种图像格式转换功能
"""

import os
import sys
from pathlib import Path
import tempfile
import shutil

# 添加核心模块路径
current_dir = Path(__file__).parent.parent.parent.resolve()
if str(current_dir) not in sys.path:
    sys.path.insert(0, str(current_dir))

class ImageConverter:
    """图像转换工具类"""
    
    @staticmethod
    def convert_to_png(image_path, output_dir=None):
        """
        将图像转换为PNG格式
        
        Args:
            image_path: 原始图像路径
            output_dir: 输出目录，如果为None则使用临时目录
            
        Returns:
            转换后的PNG图像路径
        """
        try:
            # 检查输入路径
            path = Path(image_path)
            if not path.exists():
                print(f"图像文件不存在: {image_path}")
                return None
                
            # 确定输出目录
            if output_dir is None:
                output_dir = tempfile.gettempdir()
            else:
                output_dir = Path(output_dir)
                if not output_dir.exists():
                    output_dir.mkdir(parents=True)
                    
            # 构建输出文件路径
            output_filename = f"{path.stem}.png"
            output_path = Path(output_dir) / output_filename
            
            # 尝试使用PIL进行转换
            try:
                from PIL import Image
                print(f"使用PIL转换图像: {path} -> {output_path}")
                with Image.open(path) as img:
                    img.save(output_path, "PNG")
                return str(output_path)
            except ImportError:
                print("PIL库不可用，尝试使用QImage")
                
                # 使用Qt进行转换
                from PySide6.QtGui import QImage
                image = QImage()
                if image.load(str(path)):
                    print(f"使用QImage转换图像: {path} -> {output_path}")
                    image.save(str(output_path), "PNG")
                    return str(output_path)
                else:
                    print(f"QImage无法加载图像: {path}")
                    return None
                    
        except Exception as e:
            print(f"转换图像时出错: {e}")
            import traceback
            traceback.print_exc()
            return None
            
    @staticmethod
    def get_cached_png(image_path):
        """
        获取图像的PNG缓存版本，如果不存在则创建
        
        Args:
            image_path: 原始图像路径
            
        Returns:
            PNG图像路径
        """
        try:
            print(f"[ImageConverter] 获取PNG缓存: {image_path}")
            
            # 检查文件格式
            path = Path(image_path)
            if not path.exists():
                print(f"[ImageConverter] 原始文件不存在: {image_path}")
                return None
                
            file_ext = path.suffix.lower()
            print(f"[ImageConverter] 文件格式: {file_ext}")
            
            # 如果已经是PNG格式，直接返回
            if file_ext == '.png':
                print(f"[ImageConverter] 已经是PNG格式，直接返回: {path}")
                return str(path)
                
            # 对于需要转换的格式
            cache_dir = Path(tempfile.gettempdir()) / "revela_image_cache"
            if not cache_dir.exists():
                print(f"[ImageConverter] 创建缓存目录: {cache_dir}")
                cache_dir.mkdir(parents=True)
                
            # 构建缓存文件路径
            cache_filename = f"{path.stem}_{abs(hash(str(path)))}.png"
            cache_path = cache_dir / cache_filename
            print(f"[ImageConverter] 缓存文件路径: {cache_path}")
            
            # 如果缓存文件已存在且有效，直接返回
            if cache_path.exists():
                try:
                    # 验证缓存文件是否有效
                    cache_size = cache_path.stat().st_size
                    if cache_size > 0:
                        print(f"[ImageConverter] 使用有效的缓存PNG图像: {cache_path} (大小: {cache_size} 字节)")
                        return str(cache_path)
                    else:
                        print(f"[ImageConverter] 缓存文件大小为0，删除并重新转换")
                        cache_path.unlink()
                except Exception as cache_check_error:
                    print(f"[ImageConverter] 检查缓存文件时出错: {cache_check_error}")
                    try:
                        cache_path.unlink()
                    except:
                        pass
                
            # 否则进行转换
            print(f"[ImageConverter] 开始转换图像: {image_path} -> {cache_path}")
            result = ImageConverter.convert_to_png(image_path, cache_dir)
            
            if result and Path(result).exists():
                result_size = Path(result).stat().st_size
                print(f"[ImageConverter] 转换成功: {result} (大小: {result_size} 字节)")
            else:
                print(f"[ImageConverter] 转换失败或结果文件不存在")
                
            return result
            
        except Exception as e:
            print(f"[ImageConverter] 获取PNG缓存时出错: {e}")
            import traceback
            traceback.print_exc()
            return None