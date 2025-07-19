"""
预设控制器模块
负责参数预设的保存、加载和管理
"""

from __future__ import annotations

import json
import sys
from pathlib import Path
from typing import Dict, List, Optional

from PySide6.QtCore import QObject, Signal, Property, Slot
from PySide6.QtQml import QmlElement

QML_IMPORT_NAME = "Revela"
QML_IMPORT_MAJOR_VERSION = 1


@QmlElement
class PresetController(QObject):
    """预设控制器 - 管理参数预设"""
    
    # 信号定义
    presetsChanged = Signal()            # 预设列表变化
    presetSaved = Signal(str)           # 预设保存成功
    presetLoaded = Signal(str)          # 预设加载成功
    presetError = Signal(str)           # 预设操作错误
    
    def __init__(self, parent=None):
        super().__init__(parent)
        
        # 预设存储路径
        self._presets_dir = Path.home() / ".revela" / "presets"
        self._presets_dir.mkdir(parents=True, exist_ok=True)
        
        # 预设数据
        self._presets = {}
        self._preset_names = []
        
        # 加载现有预设
        self._load_all_presets()
        
    # 属性定义
    @Property(list, notify=presetsChanged)
    def presetNames(self) -> List[str]:
        return self._preset_names
        
    @Property(int, notify=presetsChanged)
    def presetCount(self) -> int:
        return len(self._preset_names)
        
    # 插槽方法
    @Slot(str, "QVariant")
    def savePreset(self, preset_name: str, parameters: dict):
        """保存参数预设"""
        try:
            if not preset_name.strip():
                self.presetError.emit("预设名称不能为空")
                return
                
            # 清理预设名称
            clean_name = preset_name.strip()
            
            # 准备预设数据
            preset_data = {
                "name": clean_name,
                "created_time": self._get_current_time(),
                "parameters": parameters
            }
            
            # 保存到文件
            preset_file = self._presets_dir / f"{clean_name}.json"
            with open(preset_file, 'w', encoding='utf-8') as f:
                json.dump(preset_data, f, indent=2, ensure_ascii=False)
                
            # 更新内存中的预设
            self._presets[clean_name] = preset_data
            if clean_name not in self._preset_names:
                self._preset_names.append(clean_name)
                self._preset_names.sort()
                
            self.presetsChanged.emit()
            self.presetSaved.emit(clean_name)
            
        except Exception as e:
            self.presetError.emit(f"保存预设失败: {str(e)}")
            
    @Slot(str, result="QVariant")
    def loadPreset(self, preset_name: str) -> dict:
        """加载参数预设"""
        try:
            if preset_name not in self._presets:
                self.presetError.emit(f"预设 '{preset_name}' 不存在")
                return {}
                
            preset_data = self._presets[preset_name]
            parameters = preset_data.get("parameters", {})
            
            self.presetLoaded.emit(preset_name)
            return parameters
            
        except Exception as e:
            self.presetError.emit(f"加载预设失败: {str(e)}")
            return {}
            
    @Slot(str)
    def deletePreset(self, preset_name: str):
        """删除预设"""
        try:
            if preset_name not in self._presets:
                self.presetError.emit(f"预设 '{preset_name}' 不存在")
                return
                
            # 删除文件
            preset_file = self._presets_dir / f"{preset_name}.json"
            if preset_file.exists():
                preset_file.unlink()
                
            # 从内存中移除
            del self._presets[preset_name]
            self._preset_names.remove(preset_name)
            
            self.presetsChanged.emit()
            
        except Exception as e:
            self.presetError.emit(f"删除预设失败: {str(e)}")
            
    @Slot(str, result="QVariant")
    def getPresetInfo(self, preset_name: str) -> dict:
        """获取预设信息"""
        if preset_name in self._presets:
            preset_data = self._presets[preset_name]
            return {
                "name": preset_data.get("name", ""),
                "created_time": preset_data.get("created_time", ""),
                "parameter_count": len(preset_data.get("parameters", {}))
            }
        return {}
        
    @Slot()
    def refreshPresets(self):
        """刷新预设列表"""
        self._load_all_presets()
        
    @Slot(str, str)
    def renamePreset(self, old_name: str, new_name: str):
        """重命名预设"""
        try:
            if old_name not in self._presets:
                self.presetError.emit(f"预设 '{old_name}' 不存在")
                return
                
            if not new_name.strip():
                self.presetError.emit("新预设名称不能为空")
                return
                
            clean_new_name = new_name.strip()
            
            if clean_new_name in self._presets:
                self.presetError.emit(f"预设 '{clean_new_name}' 已存在")
                return
                
            # 获取原预设数据
            preset_data = self._presets[old_name].copy()
            preset_data["name"] = clean_new_name
            
            # 保存新文件
            new_preset_file = self._presets_dir / f"{clean_new_name}.json"
            with open(new_preset_file, 'w', encoding='utf-8') as f:
                json.dump(preset_data, f, indent=2, ensure_ascii=False)
                
            # 删除旧文件
            old_preset_file = self._presets_dir / f"{old_name}.json"
            if old_preset_file.exists():
                old_preset_file.unlink()
                
            # 更新内存数据
            self._presets[clean_new_name] = preset_data
            del self._presets[old_name]
            
            self._preset_names.remove(old_name)
            self._preset_names.append(clean_new_name)
            self._preset_names.sort()
            
            self.presetsChanged.emit()
            
        except Exception as e:
            self.presetError.emit(f"重命名预设失败: {str(e)}")
            
    def _load_all_presets(self):
        """加载所有预设"""
        try:
            self._presets.clear()
            self._preset_names.clear()
            
            # 扫描预设目录
            for preset_file in self._presets_dir.glob("*.json"):
                try:
                    with open(preset_file, 'r', encoding='utf-8') as f:
                        preset_data = json.load(f)
                        
                    preset_name = preset_data.get("name", preset_file.stem)
                    self._presets[preset_name] = preset_data
                    self._preset_names.append(preset_name)
                    
                except Exception as e:
                    print(f"加载预设文件 {preset_file} 失败: {e}")
                    
            self._preset_names.sort()
            self.presetsChanged.emit()
            
        except Exception as e:
            print(f"加载预设目录失败: {e}")
            
    def _get_current_time(self) -> str:
        """获取当前时间字符串"""
        from datetime import datetime
        return datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        
    @Slot(result=str)
    def getPresetsDirectory(self) -> str:
        """获取预设目录路径"""
        return str(self._presets_dir)
        
    @Slot(result=list)
    def getDefaultPresets(self) -> List[dict]:
        """获取默认预设列表"""
        return [
            {
                "name": "标准胶片",
                "parameters": {
                    "exposure": 0.0,
                    "contrast": 1.0,
                    "saturation": 1.0,
                    "highlights": 0.0,
                    "shadows": 0.0,
                    "vibrance": 0.0,
                    "temperature": 0.0,
                    "tint": 0.0
                }
            },
            {
                "name": "高对比度",
                "parameters": {
                    "exposure": 0.2,
                    "contrast": 1.3,
                    "saturation": 1.1,
                    "highlights": -20.0,
                    "shadows": 15.0,
                    "vibrance": 10.0,
                    "temperature": 0.0,
                    "tint": 0.0
                }
            },
            {
                "name": "柔和色调",
                "parameters": {
                    "exposure": -0.1,
                    "contrast": 0.9,
                    "saturation": 0.9,
                    "highlights": 10.0,
                    "shadows": -10.0,
                    "vibrance": -5.0,
                    "temperature": 100.0,
                    "tint": 2.0
                }
            }
        ]