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
    print("[Main] GUI应用程序已启动")
    
    try:
        # 创建应用程序
        app = QGuiApplication(sys.argv)
        
        # 设置应用程序异常处理
        def handle_exception(exc_type, exc_value, exc_traceback):
            if issubclass(exc_type, KeyboardInterrupt):
                sys.__excepthook__(exc_type, exc_value, exc_traceback)
                return
            
            print(f"[Main] 未捕获的异常: {exc_type.__name__}: {exc_value}")
            import traceback
            traceback.print_exception(exc_type, exc_value, exc_traceback)
            
        sys.excepthook = handle_exception
    
        # 设置QML样式以避免警告
        QQuickStyle.setStyle("Basic")
    
        # 创建QML引擎
        engine = QQmlApplicationEngine()
    
        # 导入控制器
        from gui.controllers.export_controller import ExportController
        from gui.controllers.preset_controller import PresetController
        from gui.controllers.window_controller import WindowController
        
        # 创建控制器实例
        main_controller = MainController()
        project_controller = ProjectController()
        image_controller = ImageController()
        parameter_controller = ParameterController()
        analysis_controller = AnalysisController()
        export_controller = ExportController()
        preset_controller = PresetController()
        window_controller = WindowController()
    
        # 注册控制器到QML上下文
        engine.rootContext().setContextProperty("mainController", main_controller)
        engine.rootContext().setContextProperty("projectController", project_controller)
        engine.rootContext().setContextProperty("imageController", image_controller)
        engine.rootContext().setContextProperty("parameterController", parameter_controller)
        engine.rootContext().setContextProperty("analysisController", analysis_controller)
        engine.rootContext().setContextProperty("exportController", export_controller)
        engine.rootContext().setContextProperty("presetController", preset_controller)
        engine.rootContext().setContextProperty("windowController", window_controller)
    
        # 不再需要复杂的图像提供器，直接使用文件路径
    
        # 连接控制器之间的信号
        # 连接 image_controller 的 frameIndexChanged 信号到 project_controller 获取帧路径
        image_controller.frameIndexChanged.connect(
            lambda index: image_controller.setFramePath(index, project_controller.getFramePath(index))
        )
        # analysis_controller.calibrationCompleted.connect(parameter_controller.updateFromCalibration)
    
        # 加载主QML文件 - 直接启动文件管理窗口
        qml_file = current_dir / "gui" / "qml" / "fileManagementWindow.qml"
        print(f"[Main] 加载QML文件: {qml_file}")
        engine.load(qml_file)
        
        # 检查是否成功加载
        if not engine.rootObjects():
            print("[Main] 无法加载QML文件")
            return -1
        
        print("[Main] 主界面已显示")
    
        # 运行应用程序
        print("[Main] 开始运行应用程序事件循环")
        exit_code = app.exec()
        
        # 清理资源
        print("[Main] 开始清理资源")
        try:
            export_controller.shutdown()
            analysis_controller.shutdown()
        except Exception as cleanup_error:
            print(f"[Main] 清理资源时出错: {cleanup_error}")
            
        print(f"[Main] 应用程序退出，退出码: {exit_code}")
        return exit_code
        
    except Exception as e:
        print(f"[Main] 主函数发生异常: {e}")
        import traceback
        traceback.print_exc()
        return -1

if __name__ == "__main__":
    sys.exit(main()) 