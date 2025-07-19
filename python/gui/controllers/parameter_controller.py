"""
参数控制器模块
负责校准参数显示和颜色调整控制
"""

from __future__ import annotations

from PySide6.QtCore import QObject, Signal, Property, Slot
from PySide6.QtQml import QmlElement

QML_IMPORT_NAME = "Revela"
QML_IMPORT_MAJOR_VERSION = 1


@QmlElement
class ParameterController(QObject):
    """参数控制器 - 管理校准参数和颜色调整"""
    
    # 信号定义
    calibrationDataChanged = Signal()    # 校准数据变化
    colorParametersChanged = Signal()    # 颜色参数变化
    analysisCompleteChanged = Signal()   # 分析完成状态变化
    parametersModified = Signal()        # 参数被修改
    
    def __init__(self, parent=None):
        super().__init__(parent)
        
        # 校准参数
        self._d_min = 0.0
        self._k_values = []
        self._analysis_complete = False
        
        # 颜色调整参数
        self._exposure = 0.0
        self._contrast = 1.0
        self._saturation = 1.0
        self._highlights = 0.0
        self._shadows = 0.0
        self._vibrance = 0.0
        self._temperature = 0.0
        self._tint = 0.0
        
        # 参数范围
        self._parameter_ranges = {
            "exposure": (-3.0, 3.0),
            "contrast": (0.1, 2.0),
            "saturation": (0.0, 2.0),
            "highlights": (-100.0, 100.0),
            "shadows": (-100.0, 100.0),
            "vibrance": (-100.0, 100.0),
            "temperature": (-2000.0, 2000.0),
            "tint": (-50.0, 50.0)
        }
        
    # 校准参数属性
    @Property(float, notify=calibrationDataChanged)
    def dMin(self) -> float:
        return self._d_min
        
    @Property(list, notify=calibrationDataChanged)
    def kValues(self) -> list:
        return self._k_values
        
    @Property(bool, notify=analysisCompleteChanged)
    def analysisComplete(self) -> bool:
        return self._analysis_complete
        
    # 颜色调整参数属性
    @Property(float, notify=colorParametersChanged)
    def exposure(self) -> float:
        return self._exposure
        
    @exposure.setter
    def exposure(self, value: float):
        min_val, max_val = self._parameter_ranges["exposure"]
        value = max(min_val, min(max_val, value))
        if self._exposure != value:
            self._exposure = value
            self.colorParametersChanged.emit()
            self.parametersModified.emit()
            
    @Property(float, notify=colorParametersChanged)
    def contrast(self) -> float:
        return self._contrast
        
    @contrast.setter
    def contrast(self, value: float):
        min_val, max_val = self._parameter_ranges["contrast"]
        value = max(min_val, min(max_val, value))
        if self._contrast != value:
            self._contrast = value
            self.colorParametersChanged.emit()
            self.parametersModified.emit()
            
    @Property(float, notify=colorParametersChanged)
    def saturation(self) -> float:
        return self._saturation
        
    @saturation.setter
    def saturation(self, value: float):
        min_val, max_val = self._parameter_ranges["saturation"]
        value = max(min_val, min(max_val, value))
        if self._saturation != value:
            self._saturation = value
            self.colorParametersChanged.emit()
            self.parametersModified.emit()
            
    @Property(float, notify=colorParametersChanged)
    def highlights(self) -> float:
        return self._highlights
        
    @highlights.setter
    def highlights(self, value: float):
        min_val, max_val = self._parameter_ranges["highlights"]
        value = max(min_val, min(max_val, value))
        if self._highlights != value:
            self._highlights = value
            self.colorParametersChanged.emit()
            self.parametersModified.emit()
            
    @Property(float, notify=colorParametersChanged)
    def shadows(self) -> float:
        return self._shadows
        
    @shadows.setter
    def shadows(self, value: float):
        min_val, max_val = self._parameter_ranges["shadows"]
        value = max(min_val, min(max_val, value))
        if self._shadows != value:
            self._shadows = value
            self.colorParametersChanged.emit()
            self.parametersModified.emit()
            
    @Property(float, notify=colorParametersChanged)
    def vibrance(self) -> float:
        return self._vibrance
        
    @vibrance.setter
    def vibrance(self, value: float):
        min_val, max_val = self._parameter_ranges["vibrance"]
        value = max(min_val, min(max_val, value))
        if self._vibrance != value:
            self._vibrance = value
            self.colorParametersChanged.emit()
            self.parametersModified.emit()
            
    @Property(float, notify=colorParametersChanged)
    def temperature(self) -> float:
        return self._temperature
        
    @temperature.setter
    def temperature(self, value: float):
        min_val, max_val = self._parameter_ranges["temperature"]
        value = max(min_val, min(max_val, value))
        if self._temperature != value:
            self._temperature = value
            self.colorParametersChanged.emit()
            self.parametersModified.emit()
            
    @Property(float, notify=colorParametersChanged)
    def tint(self) -> float:
        return self._tint
        
    @tint.setter
    def tint(self, value: float):
        min_val, max_val = self._parameter_ranges["tint"]
        value = max(min_val, min(max_val, value))
        if self._tint != value:
            self._tint = value
            self.colorParametersChanged.emit()
            self.parametersModified.emit()
            
    # 插槽方法
    @Slot("QVariant")
    def updateCalibrationData(self, calibration_data):
        """更新校准数据"""
        try:
            if calibration_data:
                # TODO: 从实际的calibration对象获取数据
                self._d_min = getattr(calibration_data, 'd_min', 0.0)
                self._k_values = getattr(calibration_data, 'k_values', [])
                self._analysis_complete = True
            else:
                self._d_min = 0.0
                self._k_values = []
                self._analysis_complete = False
                
            self.calibrationDataChanged.emit()
            self.analysisCompleteChanged.emit()
            
        except Exception as e:
            # TODO: 发出错误信号
            pass
            
    @Slot()
    def resetColorParameters(self):
        """重置颜色参数到默认值"""
        self._exposure = 0.0
        self._contrast = 1.0
        self._saturation = 1.0
        self._highlights = 0.0
        self._shadows = 0.0
        self._vibrance = 0.0
        self._temperature = 0.0
        self._tint = 0.0
        
        self.colorParametersChanged.emit()
        
    @Slot(str, float)
    def setParameter(self, parameter_name: str, value: float):
        """设置指定参数的值"""
        if hasattr(self, parameter_name):
            setattr(self, parameter_name, value)
            
    @Slot(str, result=list)
    def getParameterRange(self, parameter_name: str) -> list:
        """获取参数的取值范围"""
        if parameter_name in self._parameter_ranges:
            min_val, max_val = self._parameter_ranges[parameter_name]
            return [min_val, max_val]
        return [0.0, 1.0]
        
    @Slot(result="QVariant")
    def getColorParametersDict(self):
        """获取所有颜色参数的字典"""
        return {
            "exposure": self._exposure,
            "contrast": self._contrast,
            "saturation": self._saturation,
            "highlights": self._highlights,
            "shadows": self._shadows,
            "vibrance": self._vibrance,
            "temperature": self._temperature,
            "tint": self._tint
        } 