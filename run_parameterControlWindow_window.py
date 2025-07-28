#!/usr/bin/env python3
"""
运行parameterControlWindow的测试脚本
"""

import sys
import os
from pathlib import Path

# 设置Python路径
current_dir = Path(__file__).parent.resolve()
python_dir = current_dir / "python"
if str(python_dir) not in sys.path:
    sys.path.insert(0, str(python_dir))

from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtQuickControls2 import QQuickStyle

def main():
    """主函数"""
    print("启动parameterControlWindow测试")
    
    # 创建应用程序
    app = QGuiApplication(sys.argv)
    
    # 设置QML样式
    QQuickStyle.setStyle("Basic")
    
    # 创建QML引擎
    engine = QQmlApplicationEngine()
    
    # 创建模拟控制器对象
    class MockController:
        def __init__(self, name):
            self.name = name
            self.currentImagePath = "https://image-resource.mastergo.com/146874632348805/146874632348807/af8c680adba3e36cca4fdd5b93f075ed.png"
            self.frameCount = 10
            self.currentFrameIndex = 0
            
        def __getattr__(self, name):
            def mock_method(*args, **kwargs):
                print(f"[{self.name}] 调用方法: {name}, 参数: {args}, {kwargs}")
                return "mock_result"
            return mock_method
    
    # 创建参数控制器模拟对象
    class MockParameterController:
        def __init__(self):
            self.name = "ParameterController"
            # Technical 参数
            self.dmin = 0.0
            self.dmax = 1.0
            self.red = 1.0
            self.green = 0.82
            self.blue = 0.35
            self.grayLevel = 0.42
            self.pureWhite = 0.87
            self.pureBlack = 0.15
            
            # Effects 参数
            self.light = 0
            self.exposure = 0
            self.saturation = 0
            self.warmth = 0
            self.tint = 0
            
            # LUT 设置
            self.lutEnabled = False
            self.selectedLUT = ""
            
            # 宽高比设置
            self.aspectRatio = "Free Form"
            
        def setDmin(self, value):
            self.dmin = value
            print(f"[ParameterController] 设置 Dmin: {value}")
            
        def setDmax(self, value):
            self.dmax = value
            print(f"[ParameterController] 设置 Dmax: {value}")
            
        def setRed(self, value):
            self.red = value
            print(f"[ParameterController] 设置 Red: {value}")
            
        def setGreen(self, value):
            self.green = value
            print(f"[ParameterController] 设置 Green: {value}")
            
        def setBlue(self, value):
            self.blue = value
            print(f"[ParameterController] 设置 Blue: {value}")
            
        def setGrayLevel(self, value):
            self.grayLevel = value
            print(f"[ParameterController] 设置 Gray Level: {value}")
            
        def setPureWhite(self, value):
            self.pureWhite = value
            print(f"[ParameterController] 设置 Pure White: {value}")
            
        def setPureBlack(self, value):
            self.pureBlack = value
            print(f"[ParameterController] 设置 Pure Black: {value}")
            
        def setLight(self, value):
            self.light = value
            print(f"[ParameterController] 设置 Light: {value}")
            
        def setExposure(self, value):
            self.exposure = value
            print(f"[ParameterController] 设置 Exposure: {value}")
            
        def setSaturation(self, value):
            self.saturation = value
            print(f"[ParameterController] 设置 Saturation: {value}")
            
        def setWarmth(self, value):
            self.warmth = value
            print(f"[ParameterController] 设置 Warmth: {value}")
            
        def setTint(self, value):
            self.tint = value
            print(f"[ParameterController] 设置 Tint: {value}")
            
        def setLUTEnabled(self, enabled):
            self.lutEnabled = enabled
            print(f"[ParameterController] LUT 启用状态: {enabled}")
            
        def selectLUT(self, lutName):
            self.selectedLUT = lutName
            print(f"[ParameterController] 选择 LUT: {lutName}")
            
        def setAspectRatio(self, ratio):
            self.aspectRatio = ratio
            print(f"[ParameterController] 设置宽高比: {ratio}")
            
        def resetTechnicalParameters(self):
            self.dmin = 0.0
            self.dmax = 1.0
            self.red = 1.0
            self.green = 0.82
            self.blue = 0.35
            self.grayLevel = 0.42
            self.pureWhite = 0.87
            self.pureBlack = 0.15
            print("[ParameterController] 重置 Technical 参数")
            
        def resetEffectsParameters(self):
            self.light = 0
            self.exposure = 0
            self.saturation = 0
            self.warmth = 0
            self.tint = 0
            print("[ParameterController] 重置 Effects 参数")
            
        def flipVertical(self):
            print("[ParameterController] 垂直翻转")
            
        def flipHorizontal(self):
            print("[ParameterController] 水平翻转")
            
        def rotateRight(self):
            print("[ParameterController] 向右旋转")
            
        def rotateLeft(self):
            print("[ParameterController] 向左旋转")
            
        def zoomIn(self):
            print("[ParameterController] 放大")
            
        def switchToFilm(self):
            print("[ParameterController] 切换到胶片模式")
            
        def switchToFinal(self):
            print("[ParameterController] 切换到成片模式")
            
        def finishEditing(self):
            print("[ParameterController] 完成编辑")
            
        def __getattr__(self, name):
            def mock_method(*args, **kwargs):
                print(f"[{self.name}] 调用方法: {name}, 参数: {args}, {kwargs}")
                return "mock_result"
            return mock_method
    
    # 注册模拟控制器到QML上下文
    engine.rootContext().setContextProperty("mainController", MockController("MainController"))
    engine.rootContext().setContextProperty("imageController", MockController("ImageController"))
    engine.rootContext().setContextProperty("parameterController", MockParameterController())
    engine.rootContext().setContextProperty("analysisController", MockController("AnalysisController"))
    engine.rootContext().setContextProperty("windowController", MockController("WindowController"))
    
    # 加载QML文件
    qml_file = python_dir / "gui" / "qml" / "parameterControlWindow.qml"
    print(f"加载QML文件: {qml_file}")
    
    engine.load(qml_file)
    
    # 检查是否成功加载
    if not engine.rootObjects():
        print("无法加载QML文件")
        return -1
    
    print("parameterControlWindow界面已显示")
    print("可以测试以下功能:")
    print("1. 顶部工具栏按钮 (翻转、旋转、缩放)")
    print("2. 胶片/成片切换")
    print("3. Histogram 显示")
    print("4. LUT 开关和预设选择")
    print("5. Technical 参数调整 (Dmin/Dmax, RGB, Gray, Clip)")
    print("6. Effects 参数调整 (Light, Exposure, Saturation, Warmth, Tint)")
    print("7. 宽高比选择")
    print("8. 各种重置功能")
    print("9. 缩略图切换")
    
    # 运行应用程序
    return app.exec()

if __name__ == "__main__":
    sys.exit(main())