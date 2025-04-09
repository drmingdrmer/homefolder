#!/usr/bin/env python
# coding: utf-8

import unittest
from unittest.mock import MagicMock, patch
import argparse
import os
import sys
import subprocess

# 从新的包结构导入
from videoconv.video_conv import VideoConverter
from videoconv.stream_info import StreamInfo
from videoconv.stream_manager import StreamManager
from videoconv.ffmpeg_command_builder import FFmpegCommandBuilder
from videoconv.exceptions import ConversionError

# 确保在测试环境中导入的ConversionError可以被直接引用
try:
    # 验证ConversionError是否已导入
    ConversionError = ConversionError
except NameError:
    # 如果未导入，尝试从exceptions模块导入
    try:
        from videoconv.exceptions import ConversionError
    except ImportError:
        from videoconv.exceptions import ConversionError


class TestVideoConverter(unittest.TestCase):
    def setUp(self):
        # 创建模拟的参数对象
        self.args = argparse.Namespace()
        self.args.input_file = "test_input.mp4"
        self.args.output_file = None
        self.args.width = 720
        self.args.audio_stream = None  # 默认选择
        self.args.subtitle_stream = None  # 默认选择
        self.args.subtitle_language = None
        self.args.subtitle_title = None
        self.args.external_subtitle_file = None
        self.args.list_subtitles = False
        self.args.dry_run = False
        self.args.start_time = None
        self.args.end_time = None
        self.args.video_bitrate = None
        self.args.skip_exists = False
        
        # 创建用于测试的模拟流数据
        mock_audio_stream_data = {
            "index": 1,
            "codec_type": "audio",
            "tags": {
                "language": "eng",
                "title": "English"
            }
        }
        
        mock_subtitle_stream_data = {
            "index": 2,
            "codec_type": "subtitle",
            "tags": {
                "language": "eng",
                "title": "English"
            },
            "disposition": {
                "default": 1,
                "forced": 0
            }
        }
        
        # 创建模拟的音频流和字幕流
        self.mock_audio_stream = StreamInfo(mock_audio_stream_data)
        self.mock_subtitle_stream = StreamInfo(mock_subtitle_stream_data)
        
        # 模拟StreamManager
        self.patcher = patch('videoconv.video_conv.StreamManager')
        self.mock_stream_manager = self.patcher.start()
        self.mock_stream_manager_instance = MagicMock()
        self.mock_stream_manager.return_value = self.mock_stream_manager_instance
        self.mock_stream_manager_instance.select_audio_stream.return_value = self.mock_audio_stream
        self.mock_stream_manager_instance.select_subtitle_stream.return_value = self.mock_subtitle_stream
        self.mock_stream_manager_instance.original_fps = 24
        self.mock_stream_manager_instance.subtitle_indices = [2]
        
        # 设置计算字幕相对索引的模拟返回值
        self.mock_stream_manager_instance.calculate_subtitle_relative_index.return_value = 0
        
        # 模拟FFmpegCommandBuilder
        self.command_builder_patcher = patch('videoconv.video_conv.FFmpegCommandBuilder')
        self.mock_command_builder = self.command_builder_patcher.start()
        self.mock_command_builder_instance = MagicMock()
        self.mock_command_builder.return_value = self.mock_command_builder_instance
        self.mock_command_builder_instance.get_pretty_command.return_value = "ffmpeg -mock command"
        self.mock_command_builder_instance.execute.return_value = 0
        
        # 模拟os.path.exists
        self.path_exists_patcher = patch('os.path.exists')
        self.mock_path_exists = self.path_exists_patcher.start()
        self.mock_path_exists.return_value = False
        
        # 模拟os.makedirs
        self.makedirs_patcher = patch('os.makedirs')
        self.mock_makedirs = self.makedirs_patcher.start()
        
        # 模拟打印函数，避免在测试中输出太多内容
        self.print_patcher = patch('builtins.print')
        self.mock_print = self.print_patcher.start()
    
    def tearDown(self):
        self.patcher.stop()
        self.command_builder_patcher.stop()
        self.path_exists_patcher.stop()
        self.makedirs_patcher.stop()
        self.print_patcher.stop()
    
    def test_init(self):
        """测试初始化VideoConverter对象"""
        converter = VideoConverter(self.args)
        self.assertEqual(converter.args, self.args)
        self.assertIsNone(converter.selected_audio_stream)
        self.assertIsNone(converter.selected_subtitle_stream)
        self.assertIsNone(converter.params)
        self.assertEqual(converter.external_subtitle_file, None)
    
    def test_select_streams(self):
        """测试选择音频和字幕流"""
        converter = VideoConverter(self.args)
        converter.select_streams()
        
        # 验证选择了正确的流
        self.assertEqual(converter.selected_audio_stream, self.mock_audio_stream)
        self.assertEqual(converter.selected_subtitle_stream, self.mock_subtitle_stream)
        
        # 验证调用了正确的方法
        self.mock_stream_manager_instance.select_audio_stream.assert_called_once_with(None)
        self.mock_stream_manager_instance.select_subtitle_stream.assert_called_once_with(
            stream_index=None,
            language=None,
            title=None,
            external_subtitle_file=None,
            list_subtitles=False
        )
    
    def test_select_streams_with_external_subtitle(self):
        """测试使用外部字幕文件时选择流"""
        self.args.external_subtitle_file = "external.srt"
        converter = VideoConverter(self.args)
        converter.select_streams()
        
        # 如果选择了字幕流，外部字幕文件应该被设置为None
        self.assertIsNone(converter.external_subtitle_file)
    
    def test_convert_dry_run(self):
        """测试dry run模式下的转换过程"""
        self.args.dry_run = True
        converter = VideoConverter(self.args)
        converter.select_streams()
        result = converter.convert()
        
        # 验证dry run成功
        self.assertTrue(result)
        
        # 验证命令没有执行
        self.mock_command_builder_instance.execute.assert_not_called()
    
    def test_convert_skip_exists(self):
        """测试当输出文件已存在且skip_exists设置为True时的行为"""
        self.args.skip_exists = True
        self.mock_path_exists.return_value = True  # 模拟文件已存在
        
        converter = VideoConverter(self.args)
        converter.select_streams()
        result = converter.convert()
        
        # 验证跳过转换并返回成功
        self.assertTrue(result)
        self.mock_command_builder_instance.execute.assert_not_called()
    
    def test_convert_file_exists_no_skip(self):
        """测试当输出文件已存在且skip_exists设置为False时的行为"""
        self.args.skip_exists = False
        self.mock_path_exists.return_value = True  # 模拟文件已存在
        
        converter = VideoConverter(self.args)
        converter.select_streams()
        
        # 应该抛出ConversionError异常
        try:
            converter.convert()
            self.fail("应该抛出ConversionError异常")
        except Exception as e:
            self.assertIn("ConversionError", e.__class__.__name__)
            self.assertIn("Output file already exists", str(e))
    
    def test_convert_success(self):
        """测试成功的转换过程"""
        converter = VideoConverter(self.args)
        converter.select_streams()
        result = converter.convert()
        
        # 验证返回值和对FFmpegCommandBuilder的调用
        self.assertTrue(result)
        self.mock_command_builder_instance.set_audio_stream.assert_called_once_with(self.mock_audio_stream)
        self.mock_command_builder_instance.set_subtitle_stream.assert_called_once_with(self.mock_subtitle_stream)
        self.mock_command_builder_instance.set_dry_run.assert_called_once_with(False)
        self.mock_command_builder_instance.execute.assert_called_once_with([2])
    
    def test_convert_with_external_subtitle(self):
        """测试使用外部字幕文件的转换过程"""
        self.args.external_subtitle_file = "external.srt"
        self.mock_stream_manager_instance.select_subtitle_stream.return_value = None
        
        converter = VideoConverter(self.args)
        converter.select_streams()
        result = converter.convert()
        
        # 验证对FFmpegCommandBuilder正确设置外部字幕
        self.mock_command_builder_instance.set_external_subtitle.assert_called_once_with("external.srt")
        self.assertTrue(result)
    
    def test_convert_failure(self):
        """测试转换失败时的行为"""
        # 模拟执行命令失败
        self.mock_command_builder_instance.execute.side_effect = subprocess.CalledProcessError(1, "mock command")
        
        converter = VideoConverter(self.args)
        converter.select_streams()
        
        # 应该抛出ConversionError异常
        try:
            converter.convert()
            self.fail("应该抛出ConversionError异常")
        except Exception as e:
            self.assertIn("ConversionError", e.__class__.__name__)
            self.assertIn("Conversion failed", str(e))
    
    def test_custom_video_bitrate(self):
        """测试自定义视频比特率"""
        self.args.video_bitrate = "2M"
        
        converter = VideoConverter(self.args)
        converter.select_streams()
        converter.convert()
        
        # 验证比特率被正确设置
        self.assertEqual(converter.params.video_bitrate, "2M")


if __name__ == "__main__":
    unittest.main() 