# Film_Image_Correction (Revela)
一个专业的胶片数字化处理系统，提供完整的胶片扫描图像校正、分析和导出功能，集成了现代化的图形用户界面。

## 项目概括
本项目是一个基于Python的专业胶片数字化处理平台，采用模块化架构设计。系统支持多种胶片类型的校准分析，提供精确的颜色管理和批量导出功能，适用于专业摄影师、影像工作室和胶片爱好者。

## 技术选型
- **主要编程语言**: Python 3.10+
- **GUI框架**: PySide6 (Qt6) - 现代化跨平台界面
- **颜色管理**: PyOpenColorIO (OCIO) - 专业级颜色管理
- **图像处理**: NumPy, OpenCV, Pillow - 高性能图像算法
- **配置管理**: TOML - 人性化配置文件格式
- **测试框架**: Pytest, pytest-qt - 完整的测试覆盖
- **版本控制**: Git
- **支持平台**: Windows, macOS, Linux

## 项目结构 / 模块划分
```
Film_Image_Correction/
├── python/                     # 核心Python代码
│   ├── core/                   # 核心数据模型
│   │   ├── calibration.py      # 校准数据管理
│   │   ├── frame.py            # 胶片帧对象
│   │   ├── recipe.py           # 导出配方管理
│   │   ├── roll.py             # 胶卷对象管理
│   │   └── memory_*.py         # 内存管理工具
│   ├── engine/                 # 处理引擎
│   │   ├── analyzer.py         # 图像分析引擎
│   │   ├── coordinator.py      # 分析协调器
│   │   ├── renderer.py         # 渲染引擎
│   │   └── exporter.py         # 导出引擎
│   ├── processing/             # 图像处理算法
│   │   ├── alignment.py        # 图像对齐
│   │   ├── color_space.py      # 颜色空间转换
│   │   ├── density.py          # 密度分析
│   │   ├── histogram.py        # 直方图分析
│   │   └── tone.py             # 色调映射
│   ├── gui/                    # 图形用户界面 (新增)
│   │   ├── components/         # UI组件
│   │   ├── windows/            # 窗口模块
│   │   └── utils/              # GUI工具类
│   ├── tests/                  # 测试代码
│   ├── main.py                 # 命令行入口
│   └── config.toml             # 配置文件
├── data/                       # 数据文件目录
│   ├── ocio_config/            # OCIO颜色配置
│   └── icc_files/              # ICC配置文件
└── requirements.txt            # 项目依赖
```

## 核心功能 / 模块详解
- **Roll Management** (`core.roll`): 胶卷文件夹管理和帧扫描
- **Calibration Analysis** (`engine.analyzer`): 自动校准分析和Dmin/K值计算
- **Color Management** (`processing.color_space`): 基于OCIO的专业颜色管理
- **Batch Export** (`engine.exporter`): 多格式批量导出功能
- **GUI Interface** (`gui.*`): PySide6现代化图形界面
- **Memory Management** (`core.memory_*`): 大文件处理的内存优化

## 数据模型
- **Roll**: { folder_path, film_type, frames[], calibration }
- **Frame**: { file_path, metadata, processing_state }
- **Calibration**: { d_min, k_values, color_profile }
- **ExportRecipe**: { format, quality, icc_profile, output_settings }

## 工作流程
1. **项目创建**: 选择胶卷文件夹和胶片类型
2. **自动分析**: 系统分析扫描图像，计算校准参数
3. **参数调整**: 用户可视化调整校准和颜色参数
4. **预览确认**: 实时预览处理效果
5. **批量导出**: 按配置批量处理和导出

## 技术实现细节

### QML GUI架构
- **应用程序框架**: QGuiApplication + QQmlApplicationEngine
- **界面架构**: 三面板分离式设计（项目管理 + 图像预览 + 参数控制）
- **数据绑定**: Qt Property系统实现Python ↔ QML双向数据绑定
- **组件化设计**: 模块化QML组件，便于维护和扩展

### Python控制器系统
- **MainController**: 全局状态管理、错误处理、状态栏控制
- **ProjectController**: 胶卷项目管理、文件加载、胶片类型选择、实际core.roll集成
- **ImageController**: 图像显示、缩放控制、预览功能、QQuickImageProvider集成
- **ParameterController**: 校准参数显示、颜色调整、导出配置
- **AnalysisController**: 分析工作流程、多线程处理、engine.analyzer集成

### 关键技术特性
- **QML组件注册**: @QmlElement装饰器自动注册Python类型
- **信号槽通信**: 松耦合的事件驱动架构
- **后端模块集成**: 完整集成core.roll和engine.analyzer模块
- **高性能图像显示**: QQuickImageProvider + 异步加载 + LRU缓存
- **多线程分析**: QThread工作线程，避免界面冻结
- **响应式UI**: 现代化Material Design风格界面
- **错误处理**: 统一的错误对话框和状态反馈机制

## 开发状态跟踪
| 模块/功能                | 状态       | 负责人 | 计划完成日期 | 实际完成日期 | 备注                    |
|-------------------------|-----------|--------|-------------|-------------|------------------------|
| 核心数据模型 (core)       | 已完成     | AI     | -           | 已完成       | Roll, Frame, Recipe等   |
| 处理引擎 (engine)        | 已完成     | AI     | -           | 已完成       | 分析、渲染、导出引擎    |
| 图像处理算法 (processing) | 已完成     | AI     | -           | 已完成       | 颜色、密度、对齐等算法  |
| 命令行接口 (main.py)     | 已完成     | AI     | -           | 已完成       | 后端功能验证完成        |
| GUI架构设计              | 已完成     | AI     | 2025-07-19  | 2025-07-19  | QML架构设计完成         |
| 主窗口界面               | 已完成     | AI     | 2025-07-19  | 2025-07-19  | QML主界面完成           |
| 项目管理组件             | 已完成     | AI     | 2025-07-19  | 2025-07-19  | ProjectPanel.qml       |
| 图像预览组件             | 已完成     | AI     | 2025-07-19  | 2025-07-19  | ImageViewer.qml        |
| 参数控制面板             | 已完成     | AI     | 2025-07-19  | 2025-07-19  | ParameterPanel.qml     |
| 导出配置界面             | 已完成     | AI     | 2025-07-19  | 2025-07-19  | 集成在参数面板中        |
| 后端模块集成             | 已完成     | AI     | 2025-07-19  | 2025-07-19  | core.roll + engine.*   |
| 图像提供器               | 已完成     | AI     | 2025-07-19  | 2025-07-19  | QQuickImageProvider    |
| 分析工作流程             | 已完成     | AI     | 2025-07-19  | 2025-07-19  | AnalysisController     |
| 性能优化                 | 已完成     | AI     | 2025-07-19  | 2025-07-19  | 多线程 + 图像缓存       |

## 环境安装说明

### 基础依赖安装
```bash
pip install -r requirements.txt
```


### 验证安装
运行后端测试：
```bash
cd python
python main.py
```

## 代码检查与问题记录

### 已修复的问题 (2025-07-19)

1. **Frame对象属性错误** ✅
   - 问题: `'Frame' object has no attribute 'file_path'`
   - 解决: 修正为正确的 `image_path` 属性
   - 位置: `python/gui/controllers/project_controller.py`

2. **QML信号重复错误** ✅  
   - 问题: `Duplicate signal name: invalid override of property change signal`
   - 解决: 重命名自定义信号 `valueChanged` → `parameterValueChanged`
   - 位置: `python/gui/qml/components/ParameterSlider.qml`

3. **缺失依赖包** ✅
   - 问题: `No module named 'tqdm'`
   - 解决: 添加 tqdm 和 psutil 到 requirements.txt
   - 影响: engine.analyzer 模块正常工作

4. **QML组件加载问题** ✅
   - 问题: `ProjectPanel is not a type`
   - 解决: 使用 Loader 组件相对路径加载
   - 位置: `python/gui/qml/main.qml`

5. **图像路径URL编码问题** ✅
   - 问题: `文件不存在: D:%5Cg200%5Cframe_001.tif` (URL编码路径)
   - 解决: 在ImageLoadWorker中添加urllib.parse.unquote解码
   - 位置: `python/gui/providers/image_provider.py`

6. **QML参数注入警告** ✅
   - 问题: `Parameter "wheel" is not declared. Injection of parameters into signal handlers is deprecated`
   - 解决: 改用function(wheel)形式声明参数
   - 位置: `python/gui/qml/components/ImageViewer.qml`

7. **QML样式自定义警告** ✅
   - 问题: `The current style does not support customization`
   - 解决: 设置QQuickStyle为"Basic"样式
   - 位置: `python/gui_main.py`

8. **QImage.scaled()参数错误** ✅
   - 问题: `unsupported keyword 'transformMode'`
   - 解决: 使用正确的Qt枚举参数
   - 位置: `python/gui/providers/image_provider.py`

9. **信号连接错误** ✅
   - 问题: `'ProjectController' object has no attribute 'frameSelected'`
   - 解决: 移除错误的信号连接，信号处理改为在QML中进行
   - 位置: `python/gui_main.py`

10. **缺失colour-science依赖** ✅
    - 问题: `No module named 'colour'`
    - 解决: 安装colour-science包到requirements.txt
    - 影响: engine模块的颜色处理功能

### 性能优化记录
- ✅ 图像提供器LRU缓存 (最大50张图像)
- ✅ 多线程分析处理 (避免界面冻结)
- ✅ 异步图像加载机制
- ✅ 内存自动清理和监控
- ✅ URL解码优化 (支持Windows路径)
- ✅ QML样式优化 (减少警告信息)

## 使用说明

### 启动方式
- **命令行模式**: `python main.py` (后端功能测试)
- **图形界面模式**: `python gui_main.py` (推荐使用)

### GUI操作流程
1. **启动应用**: 运行`python gui_main.py`
2. **选择胶片类型**: 在项目管理面板选择合适的胶片类型
3. **加载胶卷**: 点击"选择胶卷文件夹"加载图像文件
4. **预览图像**: 在左侧帧列表中点击任意帧进行预览
5. **调整参数**: 使用右侧参数面板进行颜色调整
6. **分析校准**: 点击"开始分析"进行自动校准分析
7. **批量导出**: 配置导出设置后执行批量处理

### 快捷键支持
- `Ctrl+O`: 打开胶卷文件夹
- `Ctrl+Q`: 退出应用程序
- `Ctrl+滚轮`: 图像缩放
- 双击图像: 重置缩放
