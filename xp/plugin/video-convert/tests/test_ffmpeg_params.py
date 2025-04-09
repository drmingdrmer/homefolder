#!/usr/bin/env python
# coding: utf-8

import sys
import os
import pytest

# 添加项目根目录到Python路径，以便测试能够导入模块
# 使用新的包导入结构，不需要修改路径

from videoconv.ffmpeg_params import FFmpegParams, PRESET_PARAMS


class TestFFmpegParams:
    """FFmpegParams类的测试用例"""

    def test_default_initialization(self):
        """测试默认参数初始化"""
        params = FFmpegParams()
        
        # 验证默认值
        assert params.video_bitrate == "149k"
        assert params.video_width == 854
        assert params.fps == 24
        assert params.audio_stream is None
        assert params.subtitle_stream is None
        assert params.start_time is None
        assert params.end_time is None
        assert params.input_file is None
        assert params.external_subtitle_file is None

    def test_custom_initialization(self):
        """测试自定义参数初始化"""
        params = FFmpegParams(
            video_bitrate="500k",
            video_width=1280,
            fps=30,
            audio_stream=1,
            subtitle_stream=2,
            start_time="00:01:30",
            end_time="00:05:00",
            external_subtitle_file="subtitles.srt"
        )
        
        # 验证自定义值
        assert params.video_bitrate == "500k"
        assert params.video_width == 1280
        assert params.fps == 30
        assert params.audio_stream == 1
        assert params.subtitle_stream == 2
        assert params.start_time == "00:01:30"
        assert params.end_time == "00:05:00"
        assert params.external_subtitle_file == "subtitles.srt"
        assert params.input_file is None  # 这个属性没有在初始化参数中设置

    def test_get_scale_filter(self):
        """测试缩放滤镜生成"""
        # 测试默认参数
        params = FFmpegParams()
        assert params.get_scale_filter() == "scale=854:-2,fps=24"
        
        # 测试自定义参数
        params = FFmpegParams(video_width=720, fps=30)
        assert params.get_scale_filter() == "scale=720:-2,fps=30"
        
        # 测试极端值
        params = FFmpegParams(video_width=1, fps=1)
        assert params.get_scale_filter() == "scale=1:-2,fps=1"

    def test_attribute_modification(self):
        """测试属性修改"""
        params = FFmpegParams()
        
        # 修改属性
        params.video_bitrate = "300k"
        params.video_width = 960
        params.fps = 25
        params.input_file = "test.mp4"
        
        # 验证修改后的值
        assert params.video_bitrate == "300k"
        assert params.video_width == 960
        assert params.fps == 25
        assert params.input_file == "test.mp4"
        
        # 验证缩放滤镜也已更新
        assert params.get_scale_filter() == "scale=960:-2,fps=25"


class TestPresetParams:
    """PRESET_PARAMS字典的测试用例"""

    def test_preset_keys(self):
        """测试预设参数的键值"""
        expected_keys = {480, 640, 720, 854, 1280, 1920}
        assert set(PRESET_PARAMS.keys()) == expected_keys

    def test_preset_480p(self):
        """测试480p预设参数"""
        preset = PRESET_PARAMS[480]
        assert preset.video_bitrate == "80k"
        assert preset.video_width == 480
        assert preset.fps == 24

    def test_preset_720p(self):
        """测试720p预设参数"""
        preset = PRESET_PARAMS[720]
        assert preset.video_bitrate == "150k"
        assert preset.video_width == 720
        assert preset.fps == 24

    def test_preset_1080p(self):
        """测试1080p预设参数"""
        preset = PRESET_PARAMS[1920]
        assert preset.video_bitrate == "1000k"
        assert preset.video_width == 1920
        assert preset.fps == 24

    def test_all_presets_have_correct_width(self):
        """测试所有预设参数的宽度是否与键值匹配"""
        for width, preset in PRESET_PARAMS.items():
            assert preset.video_width == width


if __name__ == "__main__":
    pytest.main(["-xvs", __file__]) 