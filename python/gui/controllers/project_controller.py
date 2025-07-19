"""
项目控制器模块
负责胶卷项目的加载、管理和文件操作
"""

from __future__ import annotations

import sys
from pathlib import Path
from typing import Optional

from PySide6.QtCore import QObject, Signal, Property, Slot, QUrl
from PySide6.QtQml import QmlElement

# 添加核心模块路径
current_dir = Path(__file__).parent.parent.parent.resolve()
if str(current_dir) not in sys.path:
    sys.path.insert(0, str(current_dir))

try:
    from core.roll import Roll
    CORE_AVAILABLE = True
except ImportError as e:
    print(f"核心模块导入警告: {e}")
    Roll = None
    CORE_AVAILABLE = False

QML_IMPORT_NAME = "Revela"
QML_IMPORT_MAJOR_VERSION = 1


@QmlElement
class ProjectController(QObject):
    """项目控制器 - 管理胶卷项目和文件"""
    
    # 信号定义
    rollLoadedChanged = Signal()           # 胶卷加载状态变化
    rollPathChanged = Signal()             # 胶卷路径变化
    filmTypeChanged = Signal()             # 胶片类型变化
    frameCountChanged = Signal()           # 帧数量变化
    loadingProgressChanged = Signal()      # 加载进度变化
    errorOccurred = Signal(str)            # 错误发生
    
    def __init__(self, parent=None):
        super().__init__(parent)
        self._current_roll: Optional[Roll] = None
        self._roll_path = ""
        self._film_type = "未选择"
        self._frame_count = 0
        self._loading_progress = 0.0
        self._roll_loaded = False
        
        # 支持的胶片类型
        self._supported_film_types = [
            "5207-2",
            "5218", 
            "5219",
            "Portra 400",
            "Portra 800",
            "Ektar 100",
            "ColorPlus 200",
            "UltraMax 400"
        ]
        
    # 属性定义
    @Property(bool, notify=rollLoadedChanged)
    def rollLoaded(self) -> bool:
        return self._roll_loaded
        
    @Property(str, notify=rollPathChanged)
    def rollPath(self) -> str:
        return self._roll_path
        
    @Property(str, notify=filmTypeChanged)
    def filmType(self) -> str:
        return self._film_type
        
    @filmType.setter
    def filmType(self, value: str):
        if self._film_type != value:
            self._film_type = value
            self.filmTypeChanged.emit()
            
    @Property(int, notify=frameCountChanged)
    def frameCount(self) -> int:
        return self._frame_count
        
    @Property(float, notify=loadingProgressChanged)
    def loadingProgress(self) -> float:
        return self._loading_progress
        
    @Property(list, constant=True)
    def supportedFilmTypes(self) -> list:
        return self._supported_film_types
        
    # 插槽方法
    @Slot(QUrl)
    def loadRollFromFolder(self, folder_url: QUrl):
        """从文件夹URL加载胶卷"""
        try:
            folder_path = folder_url.toLocalFile()
            self.loadRoll(folder_path)
        except Exception as e:
            self.errorOccurred.emit(f"从文件夹加载失败: {str(e)}")
            
    @Slot(str)
    def loadRoll(self, folder_path: str):
        """加载胶卷"""
        try:
            if not folder_path:
                self.errorOccurred.emit("请选择有效的文件夹路径")
                return
                
            path = Path(folder_path)
            if not path.exists() or not path.is_dir():
                self.errorOccurred.emit("选择的路径不存在或不是文件夹")
                return
                
            self._loading_progress = 0.2
            self.loadingProgressChanged.emit()
            
            # 检查胶片类型是否已设置
            if self._film_type == "未选择":
                self.errorOccurred.emit("请先选择胶片类型")
                return
                
            self._loading_progress = 0.4
            self.loadingProgressChanged.emit()
            
            # 创建Roll对象
            if CORE_AVAILABLE and Roll is not None:
                print(f"正在加载胶卷: {path}, 胶片类型: {self._film_type}")
                self._current_roll = Roll(folder_path=path, film_type=self._film_type)
                self._frame_count = len(self._current_roll.frames)
                print(f"成功加载胶卷，包含 {self._frame_count} 帧")
            else:
                # 模拟数据模式
                print("运行在模拟数据模式")
                self._scan_folder_for_images(path)
                
            self._loading_progress = 0.8
            self.loadingProgressChanged.emit()
                
            self._roll_path = str(path)
            self._roll_loaded = True
            self._loading_progress = 1.0
            
            # 发出信号
            self.rollPathChanged.emit()
            self.frameCountChanged.emit()
            self.loadingProgressChanged.emit()
            self.rollLoadedChanged.emit()
            
        except Exception as e:
            self._roll_loaded = False
            self._loading_progress = 0.0
            self.rollLoadedChanged.emit()
            self.loadingProgressChanged.emit()
            self.errorOccurred.emit(f"加载胶卷失败: {str(e)}")
            
    def _scan_folder_for_images(self, folder_path: Path):
        """扫描文件夹中的图像文件（模拟模式）"""
        image_extensions = {'.jpg', '.jpeg', '.png', '.tiff', '.tif', '.bmp', '.raw', '.dng'}
        image_files = []
        
        for ext in image_extensions:
            image_files.extend(folder_path.glob(f"*{ext}"))
            image_files.extend(folder_path.glob(f"*{ext.upper()}"))
            
        self._frame_count = len(image_files)
        self._image_files = sorted(image_files)  # 保存图像文件列表
        print(f"在文件夹中找到 {self._frame_count} 个图像文件")
            
    @Slot()
    def unloadRoll(self):
        """卸载当前胶卷"""
        self._current_roll = None
        self._roll_path = ""
        self._frame_count = 0
        self._roll_loaded = False
        self._loading_progress = 0.0
        
        self.rollPathChanged.emit()
        self.frameCountChanged.emit()
        self.rollLoadedChanged.emit()
        self.loadingProgressChanged.emit()
        
    @Slot(str)
    def setFilmType(self, film_type: str):
        """设置胶片类型"""
        self.filmType = film_type
        
    @Slot(result=str)
    def getRollName(self) -> str:
        """获取胶卷名称"""
        if self._roll_path:
            return Path(self._roll_path).name
        return "未加载胶卷"
        
    @Slot(result="QVariant")
    def getCurrentRoll(self):
        """获取当前胶卷对象（用于其他控制器）"""
        return self._current_roll
        
    @Slot(int, result=str)
    def getFramePath(self, frame_index: int) -> str:
        """获取指定帧的文件路径"""
        try:
            if not self._roll_loaded:
                print(f"尝试获取帧路径，但胶卷未加载，帧索引: {frame_index}")
                return ""
                
            if CORE_AVAILABLE and self._current_roll:
                if 0 <= frame_index < len(self._current_roll.frames):
                    path = str(self._current_roll.frames[frame_index].image_path)
                    print(f"获取帧路径成功 (核心模式): 帧索引 {frame_index}, 路径: {path}")
                    return path
                else:
                    print(f"帧索引超出范围 (核心模式): {frame_index}, 总帧数: {len(self._current_roll.frames)}")
            else:
                # 模拟模式
                if hasattr(self, '_image_files') and 0 <= frame_index < len(self._image_files):
                    path = str(self._image_files[frame_index])
                    print(f"获取帧路径成功 (模拟模式): 帧索引 {frame_index}, 路径: {path}")
                    return path
                else:
                    if hasattr(self, '_image_files'):
                        print(f"帧索引超出范围 (模拟模式): {frame_index}, 总帧数: {len(self._image_files)}")
                    else:
                        print("模拟模式下未找到图像文件列表")
                    
            return ""
        except Exception as e:
            print(f"获取帧路径失败: {e}")
            return ""
            
    @Slot(result=bool)
    def coreModuleAvailable(self) -> bool:
        """检查核心模块是否可用"""
        return CORE_AVAILABLE 