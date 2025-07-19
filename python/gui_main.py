#!/usr/bin/env python3
"""
Film Image Correction GUI应用程序主入口
使用QML + PySide6的现代GUI架构
"""

import sys
import os
from pathlib import Path

# 设置Python路径
current_dir = Path(__file__).parent.resolve()
if str(current_dir) not in sys.path:
    sys.path.insert(0, str(current_dir))

# PySide6和QML导入
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine, qmlRegisterType
from PySide6.QtQuickControls2 import QQuickStyle

# 导入控制器和组件
from gui.controllers.main_controller import MainController
from gui.controllers.project_controller import ProjectController
from gui.controllers.image_controller import ImageController
from gui.controllers.parameter_controller import ParameterController
from gui.controllers.analysis_controller import AnalysisController
from gui.providers.image_provider import FilmImageProvider

def main():
    """主函数"""
    print("GUI应用程序已启动")
    
    # 创建应用程序
    app = QGuiApplication(sys.argv)
    
    # 设置QML样式以避免警告
    QQuickStyle.setStyle("Basic")
    
    # 创建QML引擎
    engine = QQmlApplicationEngine()
    
    # 创建控制器实例
    main_controller = MainController()
    project_controller = ProjectController()
    image_controller = ImageController()
    parameter_controller = ParameterController()
    analysis_controller = AnalysisController()
    
    # 注册控制器到QML上下文
    engine.rootContext().setContextProperty("mainController", main_controller)
    engine.rootContext().setContextProperty("projectController", project_controller)
    engine.rootContext().setContextProperty("imageController", image_controller)
    engine.rootContext().setContextProperty("parameterController", parameter_controller)
    engine.rootContext().setContextProperty("analysisController", analysis_controller)
    
    # 创建并注册图像提供器
    image_provider = FilmImageProvider()
    engine.addImageProvider("filmProvider", image_provider)
    engine.addImageProvider("filmprovider", image_provider)  # 小写版本以防URL大小写问题
    
    # 连接控制器之间的信号
    # project_controller 与 image_controller 的连接将在QML中处理
    # analysis_controller.calibrationCompleted.connect(parameter_controller.updateFromCalibration)
    
    # 加载主QML文件
    qml_file = current_dir / "gui" / "qml" / "main.qml"
    engine.load(qml_file)
    
    # 检查是否成功加载
    if not engine.rootObjects():
        print("无法加载QML文件")
        return -1
    
    print("主界面已显示")
    
    # 运行应用程序
    exit_code = app.exec()
    
    # 清理资源
    image_provider.clear_cache()
    print(f"应用程序退出，退出码: {exit_code}")
    
    return exit_code

if __name__ == "__main__":
    sys.exit(main()) 