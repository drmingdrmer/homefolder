#!/usr/bin/env python
# coding: utf-8

import sys
import os
import pytest
from unittest.mock import patch, MagicMock

# 添加项目根目录到Python路径，以便测试能够导入模块
# 使用新的包导入结构，不需要修改路径

from videoconv.output_utils import get_output_name
from videoconv.ffmpeg_params import FFmpegParams


class TestOutputUtils:
    """output_utils模块的测试用例"""

    def test_output_name_with_default_dir(self):
        """测试使用默认输出目录的情况"""
        params = FFmpegParams(video_width=720, video_bitrate="150k")
        with patch('os.makedirs') as mock_makedirs:
            output_name = get_output_name(params, "output-dir", "input.mp4")
            
            # 验证目录创建
            mock_makedirs.assert_called_once_with("output-dir", exist_ok=True)
            
            # 验证输出文件名
            assert output_name == "output-dir/input-720x-150k.mp4"

    def test_output_name_with_path_prefix(self):
        """测试输入文件带有路径前缀的情况"""
        params = FFmpegParams(video_width=720, video_bitrate="150k")
        with patch('os.makedirs'):
            # 测试普通路径
            output_name = get_output_name(params, "output-dir", "path/to/input.mp4")
            assert output_name == "output-dir/path/to/input-720x-150k.mp4"
            
            # 测试带有 "./" 的路径
            output_name = get_output_name(params, "output-dir", "path/./to/input.mp4")
            assert output_name == "output-dir/to/input-720x-150k.mp4"

    def test_output_name_with_wildcard(self):
        """测试使用通配符的情况"""
        params = FFmpegParams(video_width=1280, video_bitrate="480k")
        output_name = get_output_name(params, "output-dir", "input.mp4", output_arg="converted_*.mp4")
        assert output_name == "converted_input-1280x-480k.mp4"
        
        # 测试带有路径的通配符
        output_name = get_output_name(params, "output-dir", "path/to/input.mp4", output_arg="output/*.mp4")
        assert output_name == "output/path/to/input-1280x-480k.mp4"

    def test_dot_in_src_and_output_name_with_wildcard(self):
        """测试使用通配符的情况"""
        params = FFmpegParams(video_width=1280, video_bitrate="480k")
        output_name = get_output_name(params, "output-dir", "a/b/./c/input.mp4", output_arg="e/f/xxx_*.mp4")
        assert output_name == "e/f/xxx_c/input-1280x-480k.mp4"
        
        # 测试带有路径的通配符
        output_name = get_output_name(params, "output-dir", "a/b/./c/input.mp4", output_arg="e/f/*.mp4")
        assert output_name == "e/f/c/input-1280x-480k.mp4"

    def test_output_name_with_slash_suffix(self):
        """测试输出参数以斜杠结尾的情况"""
        params = FFmpegParams(video_width=854, video_bitrate="220k")
        with patch('os.makedirs') as mock_makedirs:
            output_name = get_output_name(params, "output-dir", "input.mp4", output_arg="custom/")
            
            # 验证目录创建
            mock_makedirs.assert_called_once_with("custom/", exist_ok=True)
            
            # 验证输出文件名
            assert output_name == "custom/input-854x-220k.mp4"

    def test_explicit_output_path(self):
        """测试明确指定输出路径的情况"""
        params = FFmpegParams()
        output_name = get_output_name(params, "output-dir", "input.mp4", output_arg="explicit_output.mp4")
        assert output_name == "explicit_output.mp4"

    def test_output_name_with_time_range(self):
        """测试带有时间范围的情况"""
        # 只有开始时间
        params = FFmpegParams(video_width=720, video_bitrate="150k", start_time="00:01:30")
        with patch('os.makedirs'):
            output_name = get_output_name(params, "output-dir", "input.mp4")
            assert output_name == "output-dir/input-720x-150k-from_00_01_30.mp4"
        
        # 只有结束时间
        params = FFmpegParams(video_width=720, video_bitrate="150k", end_time="00:05:00")
        with patch('os.makedirs'):
            output_name = get_output_name(params, "output-dir", "input.mp4")
            assert output_name == "output-dir/input-720x-150k-to_00_05_00.mp4"
        
        # 同时有开始和结束时间
        params = FFmpegParams(video_width=720, video_bitrate="150k", start_time="00:01:30", end_time="00:05:00")
        with patch('os.makedirs'):
            output_name = get_output_name(params, "output-dir", "input.mp4")
            assert output_name == "output-dir/input-720x-150k-from_00_01_30-to_00_05_00.mp4"
        
        # 使用秒数格式
        params = FFmpegParams(video_width=720, video_bitrate="150k", start_time="90", end_time="300")
        with patch('os.makedirs'):
            output_name = get_output_name(params, "output-dir", "input.mp4")
            assert output_name == "output-dir/input-720x-150k-from_90-to_300.mp4"

    def test_combined_output_params(self):
        """测试组合多个输出参数的情况"""
        params = FFmpegParams(
            video_width=1280,
            video_bitrate="480k",
            start_time="00:01:30",
            end_time="00:05:00",
            external_subtitle_file="subtitles.srt",  # This does not affect the output name
        )
        with patch('os.makedirs'):
            output_name = get_output_name(params, "output-dir", "input.mp4")
            assert output_name == "output-dir/input-1280x-480k-from_00_01_30-to_00_05_00.mp4"


if __name__ == "__main__":
    pytest.main(["-xvs", __file__]) 