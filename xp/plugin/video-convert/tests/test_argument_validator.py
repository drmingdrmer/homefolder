#!/usr/bin/env python
# coding: utf-8

import sys
import os
import pytest
import argparse
from unittest.mock import patch, MagicMock

# 添加项目根目录到Python路径，以便测试能够导入模块
# 使用新的包导入结构，不需要修改路径

from videoconv.argument_validator import ArgumentValidator
from videoconv.exceptions import ConversionError


class TestArgumentValidator:
    """ArgumentValidator类的测试用例"""
    
    def setup_method(self):
        """每个测试方法前的准备工作"""
        # 创建临时测试文件
        self.temp_file = "temp_test_file.txt"
        self.temp_subtitle = "temp_test_subtitle.srt"
        
        with open(self.temp_file, "w") as f:
            f.write("Test content")
        
        with open(self.temp_subtitle, "w") as f:
            f.write("Test subtitle")
    
    def teardown_method(self):
        """每个测试方法后的清理工作"""
        # 删除临时测试文件
        for file in [self.temp_file, self.temp_subtitle]:
            if os.path.exists(file):
                os.remove(file)
    
    def test_validate_width_valid(self):
        """测试有效的宽度值"""
        # 假设宽度480在预设中
        width = ArgumentValidator.validate_width(480)
        assert width == 480
    
    def test_validate_width_invalid(self):
        """测试无效的宽度值"""
        with pytest.raises(ConversionError) as exc_info:
            ArgumentValidator.validate_width(999)
        
        assert "Width 999 not found in presets" in str(exc_info.value)
    
    def test_validate_input_file_valid(self):
        """测试有效的输入文件"""
        validated = ArgumentValidator.validate_input_file(self.temp_file)
        assert validated == self.temp_file
    
    def test_validate_input_file_not_found(self):
        """测试不存在的输入文件"""
        with pytest.raises(ConversionError) as exc_info:
            ArgumentValidator.validate_input_file("nonexistent_file.mp4")
        
        assert "Input file not found" in str(exc_info.value)
    
    def test_validate_input_file_empty(self):
        """测试空的输入文件路径"""
        with pytest.raises(ConversionError) as exc_info:
            ArgumentValidator.validate_input_file("")
        
        assert "Input file path cannot be empty" in str(exc_info.value)
    
    def test_validate_output_file_none(self):
        """测试None输出文件路径"""
        output = ArgumentValidator.validate_output_file(None, self.temp_file)
        assert output is None
    
    @patch('os.path.isdir')
    def test_validate_output_file_directory(self, mock_isdir):
        """测试目录输出路径"""
        mock_isdir.return_value = True
        
        # 测试不以/结尾的目录路径
        output = ArgumentValidator.validate_output_file("output_dir", self.temp_file)
        assert output == "output_dir/"
        
        # 测试已以/结尾的目录路径
        output = ArgumentValidator.validate_output_file("output_dir/", self.temp_file)
        assert output == "output_dir/"
    
    def test_validate_output_file_normal(self):
        """测试普通输出文件路径"""
        output = ArgumentValidator.validate_output_file("output.mp4", self.temp_file)
        assert output == "output.mp4"
    
    def test_validate_external_subtitle_valid(self):
        """测试有效的外部字幕文件"""
        subtitle = ArgumentValidator.validate_external_subtitle(self.temp_subtitle)
        assert subtitle == os.path.abspath(self.temp_subtitle)
    
    def test_validate_external_subtitle_none(self):
        """测试None外部字幕文件"""
        subtitle = ArgumentValidator.validate_external_subtitle(None)
        assert subtitle is None
    
    def test_validate_external_subtitle_not_found(self):
        """测试不存在的外部字幕文件"""
        with pytest.raises(ConversionError) as exc_info:
            ArgumentValidator.validate_external_subtitle("nonexistent_subtitle.srt")
        
        assert "External subtitle file not found" in str(exc_info.value)
    
    def test_validate_time_format_valid(self):
        """测试有效的时间格式"""
        # 测试HH:MM:SS格式
        time = ArgumentValidator.validate_time_format("01:30:45")
        assert time == "01:30:45"
        
        # 测试秒数格式
        time = ArgumentValidator.validate_time_format("90")
        assert time == "90"
        
        # 测试None
        time = ArgumentValidator.validate_time_format(None)
        assert time is None
    
    def test_validate_time_format_invalid(self):
        """测试无效的时间格式"""
        # 测试无效格式
        with pytest.raises(ConversionError) as exc_info:
            ArgumentValidator.validate_time_format("1:30")
        
        assert "Invalid time format" in str(exc_info.value)
        
        # 测试无效值
        with pytest.raises(ConversionError):
            ArgumentValidator.validate_time_format("01:70:45")  # 分钟超过60
    
    def test_validate_video_bitrate_valid(self):
        """测试有效的视频比特率"""
        # 测试k后缀
        bitrate = ArgumentValidator.validate_video_bitrate("500k")
        assert bitrate == "500k"
        
        # 测试M后缀
        bitrate = ArgumentValidator.validate_video_bitrate("1.5M")
        assert bitrate == "1.5M"
        
        # 测试纯数字
        bitrate = ArgumentValidator.validate_video_bitrate("1000000")
        assert bitrate == "1000000"
        
        # 测试None
        bitrate = ArgumentValidator.validate_video_bitrate(None)
        assert bitrate is None
    
    def test_validate_video_bitrate_invalid(self):
        """测试无效的视频比特率"""
        with pytest.raises(ConversionError) as exc_info:
            ArgumentValidator.validate_video_bitrate("invalid_bitrate")
        
        assert "Invalid video bitrate format" in str(exc_info.value)
    
    def test_convert_to_seconds(self):
        """测试时间转换为秒数"""
        # 测试HH:MM:SS格式
        seconds = ArgumentValidator._convert_to_seconds("01:30:45")
        assert seconds == 5445  # 1*3600 + 30*60 + 45
        
        # 测试秒数格式
        seconds = ArgumentValidator._convert_to_seconds("90")
        assert seconds == 90
    
    def test_validate_args_valid(self):
        """测试有效的参数验证"""
        # 创建模拟参数对象
        args = argparse.Namespace(
            width=720,
            input_file=self.temp_file,
            output_file="output.mp4",
            external_subtitle_file=self.temp_subtitle,
            start_time="00:01:30",
            end_time="00:05:00",
            video_bitrate="500k",
            audio_stream=1,
            subtitle_stream=2,
            subtitle_language="eng",
            subtitle_title=None,
            list_subtitles=False,
            dry_run=True,
            skip_exists=False
        )
        
        # 验证参数
        with patch.object(ArgumentValidator, 'validate_width', return_value=720), \
             patch.object(ArgumentValidator, 'validate_input_file', return_value=self.temp_file), \
             patch.object(ArgumentValidator, 'validate_output_file', return_value="output.mp4"), \
             patch.object(ArgumentValidator, 'validate_external_subtitle', return_value=self.temp_subtitle), \
             patch.object(ArgumentValidator, 'validate_time_format', side_effect=lambda x, _: x), \
             patch.object(ArgumentValidator, 'validate_video_bitrate', return_value="500k"), \
             patch.object(ArgumentValidator, '_convert_to_seconds', side_effect=lambda x: 90 if x == "00:01:30" else 300):
            
            validated_args = ArgumentValidator.validate_args(args)
            
            # 检查所有参数是否正确传递
            assert validated_args.width == 720
            assert validated_args.input_file == self.temp_file
            assert validated_args.output_file == "output.mp4"
            assert validated_args.external_subtitle_file == self.temp_subtitle
            assert validated_args.start_time == "00:01:30"
            assert validated_args.end_time == "00:05:00"
            assert validated_args.video_bitrate == "500k"
            assert validated_args.audio_stream == 1
            assert validated_args.subtitle_stream == 2
            assert validated_args.subtitle_language == "eng"
            assert validated_args.subtitle_title is None
            assert validated_args.list_subtitles is False
            assert validated_args.dry_run is True
            assert validated_args.skip_exists is False
    
    def test_validate_args_invalid_time_range(self):
        """测试无效的时间范围"""
        # 创建模拟参数对象，开始时间晚于结束时间
        args = argparse.Namespace(
            width=720,
            input_file=self.temp_file,
            output_file="output.mp4",
            external_subtitle_file=None,
            start_time="00:05:00",
            end_time="00:01:30",
            video_bitrate=None,
            audio_stream=None,
            subtitle_stream=None,
            subtitle_language=None,
            subtitle_title=None,
            list_subtitles=False,
            dry_run=False,
            skip_exists=False
        )
        
        # 应该抛出异常
        with patch.object(ArgumentValidator, 'validate_width', return_value=720), \
             patch.object(ArgumentValidator, 'validate_input_file', return_value=self.temp_file), \
             patch.object(ArgumentValidator, 'validate_output_file', return_value="output.mp4"), \
             patch.object(ArgumentValidator, 'validate_external_subtitle', return_value=None), \
             patch.object(ArgumentValidator, 'validate_time_format', side_effect=lambda x, _: x), \
             patch.object(ArgumentValidator, 'validate_video_bitrate', return_value=None), \
             patch.object(ArgumentValidator, '_convert_to_seconds', side_effect=lambda x: 300 if x == "00:05:00" else 90):
            
            with pytest.raises(ConversionError) as exc_info:
                ArgumentValidator.validate_args(args)
            
            assert "Start time (00:05:00) must be earlier than end time (00:01:30)" in str(exc_info.value)


if __name__ == "__main__":
    pytest.main(["-xvs", __file__]) 