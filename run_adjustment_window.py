#!/usr/bin/env python3
"""
运行adjustmentWindow的测试脚本
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
    print("启动adjustmentWindow测试")
    
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
    
    # 注册模拟控制器到QML上下文
    engine.rootContext().setContextProperty("mainController", MockController("MainController"))
    engine.rootContext().setContextProperty("imageController", MockController("ImageController"))
    engine.rootContext().setContextProperty("parameterController", MockController("ParameterController"))
    engine.rootContext().setContextProperty("analysisController", MockController("AnalysisController"))
    engine.rootContext().setContextProperty("windowController", MockController("WindowController"))
    
    # 加载QML文件
    qml_file = python_dir / "gui" / "qml" / "adjustmentWindow.qml"
    print(f"加载QML文件: {qml_file}")
    
    engine.load(qml_file)
    
    # 检查是否成功加载
    if not engine.rootObjects():
        print("无法加载QML文件")
        return -1
    
    print("界面已显示")
    
    # 运行应用程序
    return app.exec()

if __name__ == "__main__":
    sys.exit(main())