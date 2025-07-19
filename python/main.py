from __future__ import annotations

import sys
import os
import gc
import atexit
from pathlib import Path

current_dir = Path(__file__).parent.resolve()
if str(current_dir) not in sys.path:
    sys.path.insert(0, str(current_dir))

os.environ['PYTHONPATH'] = str(current_dir)

try:
    import PyOpenColorIO as ocio
    from core.roll import Roll
    from core.recipe import ExportRecipe, ExportFormat
    from engine.analyzer import Analyzer
    from engine.renderer import Renderer
    from engine.coordinator import AnalysisCoordinator
    from engine.exporter import Exporter
    from processing import color_space as colorspace_proc

except ImportError as e:
    print(f"导入错误: {e}")
    print(f"当前Python路径: {sys.path}")
    print(f"当前工作目录: {os.getcwd()}")
    print("请检查所有依赖模块是否正确安装和配置")
    sys.exit(1)


def main():
    print("--- 应用程序后端执行测试 ---")

    print("正在初始化服务...")
    analyzer = Analyzer()

    data_dir = Path(__file__).resolve().parent.parent / 'data'
    ocio_config_path = data_dir / 'ocio_config' / 'studio-config-v3.0.0_aces-v2.0_ocio-v2.4.ocio'
    ocio_config = ocio.Config.CreateFromFile(str(ocio_config_path))
    renderer = Renderer(ocio_config=ocio_config)

    coordinator = AnalysisCoordinator(analyzer=analyzer)
    print("服务初始化完成。")

    exporter = Exporter(renderer=renderer)

    film_dir = Path('/Users/flemyng/Desktop/Film/Preprocess/2025_06_28/5207-2')
    film_type = "5207-2"
    print(f"\n准备处理胶卷: {film_dir}")

    my_roll = Roll(folder_path=film_dir, film_type=film_type)
    print(f"已创建Roll对象: {my_roll.name}, 包含 {len(my_roll.frames)} 帧。")

    print("\n开始分析流程...")
    coordinator.get_calibration_profile(my_roll)

    if my_roll.calibration:
        print("分析成功完成！")
        print(f"  - 计算出的Dmin: {my_roll.calibration.d_min}")
        print(f"  - 计算出的k值: {my_roll.calibration.k_values}")
    else:
        print("分析失败。")
        return

    print("\n开始导出流程...")

    icc_path = Path("/Users/flemyng/Documents/GitHub/Revela/data/icc_files") / "Display_P3.icc"
    output_icc_bytes = colorspace_proc.read_icc_profile(icc_path)
    export_recipe = ExportRecipe(
        export_format=ExportFormat.JPG,
        quality=90,
        filename_suffix="exported",
        icc_bytes=output_icc_bytes
    )

    output_directory = my_roll.folder_path / "@Exports"

    exporter.export_frames(my_roll.frames, my_roll, export_recipe, output_directory)

    print("\n--- 后端执行测试完成 ---")


def cleanup_resources():
    gc.collect()


if __name__ == "__main__":
    atexit.register(cleanup_resources)

    try:
        main()
    finally:
        cleanup_resources()
