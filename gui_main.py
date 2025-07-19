#!/usr/bin/env python3
"""
Film Image Correction GUI应用程序启动入口点
"""

import sys
import os
from pathlib import Path

# 添加python目录到路径
current_dir = Path(__file__).parent.resolve()
python_dir = current_dir / "python"
if str(python_dir) not in sys.path:
    sys.path.insert(0, str(python_dir))

# 导入并运行主程序
try:
    # 切换到python目录
    os.chdir(python_dir)
    
    # 导入主程序
    from gui_main import main
    
    # 运行主程序
    sys.exit(main())
    
except ImportError as e:
    print(f"导入错误: {e}")
    print(f"当前Python路径: {sys.path}")
    print(f"当前工作目录: {os.getcwd()}")
    sys.exit(1)
except Exception as e:
    print(f"启动GUI应用程序时发生错误: {e}")
    import traceback
    traceback.print_exc()
    sys.exit(1) 