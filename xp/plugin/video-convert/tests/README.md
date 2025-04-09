# video-convert 测试套件

本目录包含 video-convert 项目的单元测试。

## 测试文件概述

- `test_stream_info.py` - 测试 StreamInfo 类的功能
- `test_ffmpeg_params.py` - 测试 FFmpegParams 类和预设参数
- `test_output_utils.py` - 测试输出文件名生成功能
- `test_exceptions.py` - 测试异常处理类

## 运行测试

使用以下命令运行所有测试：

```bash
# 在项目根目录下运行
pytest tests/
```

生成覆盖率报告：

```bash
pytest --cov=bin tests/
pytest --cov=bin --cov-report=html tests/
```

## 添加更多测试

接下来计划添加的测试：

1. VideoConverter 类的测试
   - 模拟 ffprobe 和 ffmpeg 工具
   - 测试音频和字幕流选择
   - 测试转换过程

2. 命令行参数处理测试
   - 测试参数解析和验证
   - 测试错误处理

## 测试数据

测试数据存放在 `fixtures/` 目录下。 