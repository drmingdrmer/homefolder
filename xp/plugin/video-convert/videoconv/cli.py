#!/usr/bin/env python
# coding: utf-8
"""
命令行入口点，用于启动视频转换工具。
"""

import sys
from videoconv.video_conv import main

def entry_point():
    """命令行入口点函数"""
    try:
        main()
    except KeyboardInterrupt:
        print("\nOperation cancelled by user.", file=sys.stderr)
        sys.exit(130)
    except Exception as e:
        print(f"Unexpected error: {str(e)}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    entry_point() 