"""
主窗口模块
Film Image Correction的主界面窗口
"""

from __future__ import annotations

import sys
from pathlib import Path
from PySide6.QtWidgets import (
    QMainWindow, QWidget, QVBoxLayout, QHBoxLayout,
    QSplitter, QMenuBar, QStatusBar, QToolBar,
    QFileDialog, QMessageBox, QApplication
)
from PySide6.QtCore import Qt, Signal, QThread
from PySide6.QtGui import QAction, QIcon


class MainWindow(QMainWindow):
    """胶片处理系统主窗口"""
    
    # 信号定义
    roll_loaded = Signal(object)  # 胶卷加载完成信号
    processing_started = Signal()  # 处理开始信号
    processing_finished = Signal()  # 处理完成信号
    
    def __init__(self):
        super().__init__()
        self.current_roll = None
        self.setup_ui()
        self.setup_connections()
        
    def setup_ui(self):
        """初始化用户界面"""
        self.setWindowTitle("Film Image Correction - Revela")
        self.setMinimumSize(1200, 800)
        
        # 创建中央部件
        central_widget = QWidget()
        self.setCentralWidget(central_widget)
        
        # 创建主布局
        main_layout = QHBoxLayout(central_widget)
        
        # 创建分割器
        main_splitter = QSplitter(Qt.Horizontal)
        main_layout.addWidget(main_splitter)
        
        # 左侧面板（项目管理）
        self.left_panel = self.create_left_panel()
        main_splitter.addWidget(self.left_panel)
        
        # 中央面板（图像预览）
        self.center_panel = self.create_center_panel()
        main_splitter.addWidget(self.center_panel)
        
        # 右侧面板（参数控制）
        self.right_panel = self.create_right_panel()
        main_splitter.addWidget(self.right_panel)
        
        # 设置分割器比例
        main_splitter.setSizes([300, 600, 300])
        
        # 创建菜单栏
        self.create_menu_bar()
        
        # 创建工具栏
        self.create_tool_bar()
        
        # 创建状态栏
        self.create_status_bar()
        
    def create_left_panel(self) -> QWidget:
        """创建左侧项目管理面板"""
        panel = QWidget()
        layout = QVBoxLayout(panel)
        
        # TODO: 添加项目管理组件
        # - 胶卷文件夹选择
        # - 胶片类型选择
        # - 帧列表显示
        
        return panel
        
    def create_center_panel(self) -> QWidget:
        """创建中央图像预览面板"""
        panel = QWidget()
        layout = QVBoxLayout(panel)
        
        # TODO: 添加图像预览组件
        # - 高性能图像显示
        # - 缩放和平移功能
        # - 颜色空间切换
        
        return panel
        
    def create_right_panel(self) -> QWidget:
        """创建右侧参数控制面板"""
        panel = QWidget()
        layout = QVBoxLayout(panel)
        
        # TODO: 添加参数控制组件
        # - 校准参数显示
        # - 颜色调整控件
        # - 导出设置面板
        
        return panel
        
    def create_menu_bar(self):
        """创建菜单栏"""
        menubar = self.menuBar()
        
        # 文件菜单
        file_menu = menubar.addMenu("文件(&F)")
        
        # 打开胶卷文件夹
        open_roll_action = QAction("打开胶卷文件夹(&O)", self)
        open_roll_action.setShortcut("Ctrl+O")
        open_roll_action.triggered.connect(self.open_roll_folder)
        file_menu.addAction(open_roll_action)
        
        file_menu.addSeparator()
        
        # 退出
        exit_action = QAction("退出(&X)", self)
        exit_action.setShortcut("Ctrl+Q")
        exit_action.triggered.connect(self.close)
        file_menu.addAction(exit_action)
        
        # 编辑菜单
        edit_menu = menubar.addMenu("编辑(&E)")
        
        # 视图菜单
        view_menu = menubar.addMenu("视图(&V)")
        
        # 处理菜单
        process_menu = menubar.addMenu("处理(&P)")
        
        # 分析胶卷
        analyze_action = QAction("分析胶卷(&A)", self)
        analyze_action.triggered.connect(self.analyze_roll)
        process_menu.addAction(analyze_action)
        
        # 批量导出
        export_action = QAction("批量导出(&E)", self)
        export_action.triggered.connect(self.export_frames)
        process_menu.addAction(export_action)
        
        # 帮助菜单
        help_menu = menubar.addMenu("帮助(&H)")
        
        # 关于
        about_action = QAction("关于(&A)", self)
        about_action.triggered.connect(self.show_about)
        help_menu.addAction(about_action)
        
    def create_tool_bar(self):
        """创建工具栏"""
        toolbar = self.addToolBar("主工具栏")
        
        # 打开文件夹按钮
        open_action = QAction("打开文件夹", self)
        open_action.triggered.connect(self.open_roll_folder)
        toolbar.addAction(open_action)
        
        toolbar.addSeparator()
        
        # 分析按钮
        analyze_action = QAction("分析", self)
        analyze_action.triggered.connect(self.analyze_roll)
        toolbar.addAction(analyze_action)
        
        # 导出按钮
        export_action = QAction("导出", self)
        export_action.triggered.connect(self.export_frames)
        toolbar.addAction(export_action)
        
    def create_status_bar(self):
        """创建状态栏"""
        self.status_bar = self.statusBar()
        self.status_bar.showMessage("就绪")
        
    def setup_connections(self):
        """设置信号连接"""
        # TODO: 连接各个组件的信号槽
        pass
        
    def open_roll_folder(self):
        """打开胶卷文件夹"""
        folder_path = QFileDialog.getExistingDirectory(
            self,
            "选择胶卷文件夹",
            "",
            QFileDialog.ShowDirsOnly
        )
        
        if folder_path:
            self.load_roll(folder_path)
            
    def load_roll(self, folder_path: str):
        """加载胶卷数据"""
        try:
            # TODO: 集成core.roll模块
            self.status_bar.showMessage(f"正在加载胶卷: {folder_path}")
            
            # 这里应该创建Roll对象并加载数据
            # from core.roll import Roll
            # self.current_roll = Roll(folder_path=Path(folder_path))
            
            self.status_bar.showMessage(f"胶卷加载完成: {Path(folder_path).name}")
            self.roll_loaded.emit(self.current_roll)
            
        except Exception as e:
            QMessageBox.critical(self, "错误", f"加载胶卷失败:\n{str(e)}")
            self.status_bar.showMessage("加载失败")
            
    def analyze_roll(self):
        """分析胶卷"""
        if not self.current_roll:
            QMessageBox.warning(self, "警告", "请先打开胶卷文件夹")
            return
            
        try:
            # TODO: 集成engine.coordinator进行分析
            self.status_bar.showMessage("正在分析胶卷...")
            self.processing_started.emit()
            
            # 这里应该调用分析引擎
            # coordinator = AnalysisCoordinator(analyzer=analyzer)
            # coordinator.get_calibration_profile(self.current_roll)
            
            self.status_bar.showMessage("分析完成")
            self.processing_finished.emit()
            
        except Exception as e:
            QMessageBox.critical(self, "错误", f"分析失败:\n{str(e)}")
            self.status_bar.showMessage("分析失败")
            
    def export_frames(self):
        """导出帧"""
        if not self.current_roll:
            QMessageBox.warning(self, "警告", "请先打开胶卷文件夹")
            return
            
        # TODO: 显示导出配置对话框
        # TODO: 执行导出操作
        pass
        
    def show_about(self):
        """显示关于对话框"""
        QMessageBox.about(
            self,
            "关于 Film Image Correction",
            """
            <h3>Film Image Correction (Revela)</h3>
            <p>专业的胶片数字化处理系统</p>
            <p>版本: 1.0.0</p>
            <p>基于 PySide6 和 PyOpenColorIO 开发</p>
            """
        )


def main():
    """GUI应用程序入口"""
    app = QApplication(sys.argv)
    
    # 设置应用程序信息
    app.setApplicationName("Film Image Correction")
    app.setApplicationVersion("1.0.0")
    app.setOrganizationName("Revela Team")
    
    # 创建主窗口
    window = MainWindow()
    window.show()
    
    # 运行应用程序
    sys.exit(app.exec())


if __name__ == "__main__":
    main() 