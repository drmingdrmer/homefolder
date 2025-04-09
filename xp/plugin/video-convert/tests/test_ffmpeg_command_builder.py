#!/usr/bin/env python
# coding: utf-8

import sys
import os
import pytest
from unittest.mock import patch, MagicMock

# 添加项目根目录到Python路径，以便测试能够导入模块
# 使用新的包导入结构，不需要修改路径

from videoconv.ffmpeg_command_builder import FFmpegCommandBuilder, FFmpegCommandDirector
from videoconv.ffmpeg_params import FFmpegParams
from videoconv.stream_info import StreamInfo


class TestFFmpegCommandBuilder:
    """FFmpegCommandBuilder类的测试用例"""
    
    def setup_method(self):
        """每个测试方法前的设置"""
        self.params = FFmpegParams(video_bitrate="500k", video_width=1280, fps=30)
        self.builder = FFmpegCommandBuilder(self.params, "input.mp4", "output.mp4")
        
        # 创建模拟的视频流
        self.video_stream = MagicMock(spec=StreamInfo)
        self.video_stream.codec_type = "video"
        self.video_stream.index = 0
        
        # 创建模拟的音频流
        self.audio_stream = MagicMock(spec=StreamInfo)
        self.audio_stream.codec_type = "audio"
        self.audio_stream.index = 1
        self.audio_stream.get_audio_info.return_value = "Audio info"
        
        # 创建模拟的字幕流
        self.subtitle_stream = MagicMock(spec=StreamInfo)
        self.subtitle_stream.codec_type = "subtitle"
        self.subtitle_stream.index = 2
        self.subtitle_stream.get_subtitle_info.return_value = "Subtitle info"
    
    def test_builder_initialization(self):
        """测试构建器初始化"""
        assert self.builder.params == self.params
        assert self.builder.input_file == "input.mp4"
        assert self.builder.output_file == "output.mp4"
        assert self.builder.audio_stream is None
        assert self.builder.subtitle_stream is None
        assert self.builder.external_subtitle_file is None
        assert self.builder.dry_run is False
    
    def test_set_audio_stream(self):
        """测试设置音频流"""
        builder = self.builder.set_audio_stream(self.audio_stream)
        assert builder.audio_stream == self.audio_stream
        assert builder is self.builder  # 测试链式调用返回self
    
    def test_set_subtitle_stream(self):
        """测试设置字幕流"""
        # 先设置外部字幕，然后设置内嵌字幕，应该清除外部字幕
        self.builder.set_external_subtitle("subtitle.srt")
        builder = self.builder.set_subtitle_stream(self.subtitle_stream)
        
        assert builder.subtitle_stream == self.subtitle_stream
        assert builder.external_subtitle_file is None
        assert builder is self.builder  # 测试链式调用返回self
    
    def test_set_external_subtitle(self):
        """测试设置外部字幕"""
        builder = self.builder.set_external_subtitle("subtitle.srt")
        assert builder.external_subtitle_file == "subtitle.srt"
        assert builder is self.builder  # 测试链式调用返回self
    
    def test_set_dry_run(self):
        """测试设置干运行模式"""
        builder = self.builder.set_dry_run(True)
        assert builder.dry_run is True
        assert builder is self.builder  # 测试链式调用返回self
    
    def test_calculate_subtitle_relative_index(self):
        """测试计算字幕相对索引"""
        # 测试正常索引计算
        indices = [2, 4, 7]
        assert self.builder.calculate_subtitle_relative_index(2, indices) == 0
        assert self.builder.calculate_subtitle_relative_index(4, indices) == 1
        assert self.builder.calculate_subtitle_relative_index(7, indices) == 2
        
        # 测试不存在的索引
        assert self.builder.calculate_subtitle_relative_index(999, indices) == 0
        
        # 测试空列表
        assert self.builder.calculate_subtitle_relative_index(2, []) == 0
    
    def test_build_command_basic(self):
        """测试构建基本命令"""
        command = self.builder.build_command()
        
        # 验证基本命令结构
        assert command[0] == "ffmpeg"
        assert command[1] == "-i"
        assert command[2] == "input.mp4"
        
        # 验证视频参数
        assert "-c:v" in command
        assert "libaom-av1" in command
        assert "-b:v" in command
        assert "500k" in command
        assert "-vf" in command
        assert "scale=1280:-2,fps=30" in command[command.index("-vf") + 1]
        
        # 验证音频参数
        assert "-c:a" in command
        assert "aac" in command
        
        # 验证输出文件
        assert command[-1] == "output.mp4"
    
    def test_build_command_with_audio_stream(self):
        """测试构建带音频流的命令"""
        self.builder.set_audio_stream(self.audio_stream)
        command = self.builder.build_command()
        
        # 验证流映射
        assert "-map" in command
        map_index = command.index("-map")
        assert command[map_index + 1] == "0:0"  # 视频流映射
        assert command[map_index + 3] == "0:1"  # 音频流映射
    
    def test_build_command_with_subtitle_stream(self):
        """测试构建带内嵌字幕的命令"""
        self.builder.set_audio_stream(self.audio_stream)
        self.builder.set_subtitle_stream(self.subtitle_stream)
        command = self.builder.build_command([2, 3, 4])
        
        # 验证字幕过滤器
        vf_index = command.index("-vf")
        vf_value = command[vf_index + 1]
        assert "scale=1280:-2,fps=30,subtitles=" in vf_value
        assert ":stream_index=0" in vf_value  # 相对索引应该是0
    
    def test_build_command_with_external_subtitle(self):
        """测试构建带外部字幕的命令"""
        self.builder.set_audio_stream(self.audio_stream)
        self.builder.set_external_subtitle("subtitle.srt")
        command = self.builder.build_command()
        
        # 验证输入文件
        assert command.count("-i") == 2
        assert command[3] == "-i"
        assert command[4] == "subtitle.srt"
        
        # 验证字幕过滤器
        vf_index = command.index("-vf")
        vf_value = command[vf_index + 1]
        assert "scale=1280:-2,fps=30,subtitles=" in vf_value
        assert "subtitle.srt" in vf_value
    
    def test_build_command_with_time_range(self):
        """测试构建带时间范围的命令"""
        # 设置开始和结束时间
        self.params.start_time = "00:01:30"
        self.params.end_time = "00:05:00"
        command = self.builder.build_command()
        
        # 验证时间参数
        assert "-ss" in command
        assert command[command.index("-ss") + 1] == "00:01:30"
        assert "-to" in command
        assert command[command.index("-to") + 1] == "00:05:00"
    
    def test_get_pretty_command(self):
        """测试获取美化后的命令"""
        pretty_cmd = self.builder.get_pretty_command()
        assert isinstance(pretty_cmd, str)
        assert pretty_cmd.startswith("ffmpeg -i input.mp4")
        
        # 设置包含空格的路径，应该被引号包围
        builder = FFmpegCommandBuilder(self.params, "input file.mp4", "output file.mp4")
        pretty_cmd = builder.get_pretty_command()
        assert '"input file.mp4"' in pretty_cmd
        assert '"output file.mp4"' in pretty_cmd
    
    @patch("subprocess.run")
    def test_execute(self, mock_run):
        """测试执行命令"""
        # 设置模拟返回值
        mock_run.return_value = "Command result"
        
        # 测试正常执行
        result = self.builder.execute()
        assert result == "Command result"
        mock_run.assert_called_once()
        
        # 测试干运行模式
        mock_run.reset_mock()
        self.builder.set_dry_run(True)
        result = self.builder.execute()
        assert isinstance(result, list)
        assert result[0] == "ffmpeg"
        mock_run.assert_not_called()


class TestFFmpegCommandDirector:
    """FFmpegCommandDirector类的测试用例"""
    
    def test_create_conversion_command(self):
        """测试创建转换命令"""
        # 创建参数和模拟对象
        params = FFmpegParams(video_bitrate="500k", video_width=1280, fps=30)
        audio_stream = MagicMock(spec=StreamInfo)
        audio_stream.index = 1
        subtitle_stream = MagicMock(spec=StreamInfo)
        subtitle_stream.index = 2
        
        # 测试带音频和字幕的命令
        command = FFmpegCommandDirector.create_conversion_command(
            params=params,
            input_file="input.mp4",
            output_file="output.mp4",
            audio_stream=audio_stream,
            subtitle_stream=subtitle_stream,
            subtitle_indices=[2, 3]
        )
        
        # 验证基本结构
        assert command[0] == "ffmpeg"
        assert command[1] == "-i"
        assert command[2] == "input.mp4"
        assert "-map" in command
        assert command[-1] == "output.mp4"
        
        # 测试带外部字幕的命令
        command = FFmpegCommandDirector.create_conversion_command(
            params=params,
            input_file="input.mp4",
            output_file="output.mp4",
            audio_stream=audio_stream,
            external_subtitle_file="subtitle.srt"
        )
        
        # 验证外部字幕
        assert command.count("-i") == 2
        assert "subtitle.srt" in command


if __name__ == "__main__":
    pytest.main(["-xvs", __file__]) 