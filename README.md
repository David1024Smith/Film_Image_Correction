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

为了保持代码整洁，删除以下旧的界面文件:
- `python/gui/qml/main.qml` (旧主界面)
- `python/gui/qml/components/ProjectPanel.qml`
- `python/gui/qml/components/ParameterPanel.qml`
- `python/gui/qml/components/LiveImageViewer.qml`
- `python/gui/qml/components/ParameterSlider.qml`

### 2. 界面跳转循环实现
```
文件管理 → 参数控制 → 调整 → 文件管理

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


## 🎯 与HTML设计的一致性
- ✅ 动态网格布局（默认4x4）
- ✅ 缩放控件（滑块 + 按钮 + 数值显示）
- ✅ 8-32范围，默认16
- ✅ 16px间距（gap-4）
- ✅ #262626背景色（bg-neutral-800）
- ✅ 8px圆角（rounded-button）
- ✅ "Image"占位文本
- ✅ #6B7280占位文本颜色（text-neutral-500）
- ✅ hover效果（bg-black bg-opacity-40）
- ✅ 平滑过渡动画
- ✅ 黄色滑块手柄（#FFD60A）

## 🔧 技术实现要点
1. 使用动态的`Repeater`模型，根据`imageCount`调整网格数量
2. 智能计算列数：根据图片数量选择最佳列数（3-6列）
3. 使用`Flow`布局替代`GridLayout`，更好适应不同屏幕尺寸
4. 动态计算网格单元格大小，最小120px，充分利用可用空间
5. 响应式字体和按钮大小，根据格子大小自动调整
6. 通过条件判断控制图像显示和占位文本显示
7. 只有在有图像且加载成功时才启用hover效果
8. 使用`imageController.getPreviewImagePath()`处理TIFF等格式转换
9. 通过信号机制实现前后端通信
10. 实时响应缩放控件的变化，无需重启
### 🎯 布局优化
- **充分利用空间**: 网格占据右侧大部分区域，不再挤在左上角
- **智能尺寸**: 网格单元格最小120px，根据可用空间动态调整
- **响应式设计**: 使用Flow布局，更好适应不同屏幕尺寸

### 🔄 动态缩放
- **默认体验**: 启动时显示4x4网格（16个格子）
- **灵活调整**: 用户可以通过缩放控件调整显示8-32个格子
- **智能列数**: 根据图片数量自动选择最佳列数（3-6列）
- **实时响应**: 调整后立即生效，无需重启

### 🎨 视觉体验
- **不再拥挤**: 网格单元格大小合适，视觉舒适
- **保持一致**: 无论显示多少图片，布局都保持美观
- **响应式元素**: 字体、按钮大小根据格子大小自动调整



### 2. 响应式组件
- **成像比例选择**: 3:2, 3:4, 16:9 按钮网格
- **裁剪模式**: 向内裁剪(带百分比设置) / 自动框选 单选按钮
- **阈值调节**: 5个可折叠的滑块控制器
- **图片预览**: 主图显示区 + 缩略图滚动条

### 3. 前后端分离架构
- QML界面通过信号槽与Python控制器通信
- 所有业务逻辑都在Python后端处理
- 界面状态通过Qt属性系统同步

## Python控制器接口

### ImageController
```python
# 图片相关操作
imageController.currentImagePath      # 当前图片路径
imageController.frameCount           # 帧数量
imageController.currentFrameIndex    # 当前帧索引
imageController.getFramePath(index)  # 获取指定帧路径
imageController.setCurrentFrame(index) # 设置当前帧
```

### ParameterController
```python
# 参数设置
parameterController.setAspectRatio(width, height)    # 设置成像比例
parameterController.setCropMode(mode)                # 设置裁剪模式
parameterController.setInwardCropPercent(percent)    # 设置向内裁剪百分比
parameterController.setAreaRatioMin(value)           # 设置区域占比下限
parameterController.setAreaRatioMax(value)           # 设置区域占比上限
parameterController.setThresholdMax(value)           # 设置阈值上限
parameterController.setPerforationThreshold(value)   # 设置齿孔阈值
parameterController.setFilmClampThreshold(value)     # 设置片夹阈值
```
### AnalysisController
```python
# 分析功能
analysisController.startFrameDetection()  # 开始胶片成像区框选
analysisController.removeColorCast()      # 去色罩处理
```

### WindowController
```python
# 窗口控制
windowController.closeWindow()  # 关闭窗口
```

## 运行方式

### 1. 测试运行
```bash
python run_adjustment_window.py
```

### 2. 集成到主程序
```python
# 在gui_main.py中已经配置好了路径
qml_file = current_dir / "gui" / "qml" / "adjustmentWindow.qml"
engine.load(qml_file)
```
