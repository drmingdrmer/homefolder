#!/usr/bin/env python
# coding: utf-8

import os

# 导入自己包内的模块
from videoconv.ffmpeg_params import FFmpegParams
from videoconv.stream_info import StreamInfo

class FFmpegCommandBuilder:
    """
    构建 FFmpeg 命令行的类
    
    该类负责根据提供的参数构建完整的 FFmpeg 命令行。
    可以处理各种输入/输出选项、视频/音频编码参数、字幕添加等。
    """
    
    def __init__(self, params: FFmpegParams, input_file: str, output_file: str):
        """
        初始化命令构建器
        
        Args:
            params: FFmpeg 参数对象
            input_file: 输入文件路径
            output_file: 输出文件路径
        """
        self.params = params
        self.input_file = input_file
        self.output_file = output_file
        self.audio_stream = None
        self.subtitle_stream = None
        self.external_subtitle_file = None
        self.dry_run = False
    
    def set_audio_stream(self, stream: StreamInfo):
        """设置音频流"""
        self.audio_stream = stream
        return self
    
    def set_subtitle_stream(self, stream: StreamInfo):
        """设置字幕流"""
        self.subtitle_stream = stream
        self.external_subtitle_file = None  # 使用内嵌字幕时清除外部字幕文件
        return self
    
    def set_external_subtitle(self, subtitle_file: str):
        """设置外部字幕文件"""
        self.external_subtitle_file = subtitle_file
        return self
    
    def set_dry_run(self, dry_run: bool):
        """设置是否为干运行模式"""
        self.dry_run = dry_run
        return self
    
    def calculate_subtitle_relative_index(self, absolute_index: int, all_subtitle_indices: list) -> int:
        """
        计算字幕的相对索引
        
        Args:
            absolute_index: 字幕的绝对索引
            all_subtitle_indices: 所有字幕流的索引列表
            
        Returns:
            相对索引 (用于 FFmpeg 的 subtitles 过滤器)
        """
        sorted_indices = sorted(all_subtitle_indices)
        
        for i, index in enumerate(sorted_indices):
            if index == absolute_index:
                return i
        
        return 0
    
    def build_command(self, subtitle_indices=None):
        """
        构建完整的 FFmpeg 命令
        
        Args:
            subtitle_indices: 所有字幕流的索引列表，用于计算相对索引
            
        Returns:
            完整的 FFmpeg 命令行参数列表
        """
        command = ["ffmpeg", "-i", self.input_file]
        
        # 添加外部字幕文件作为输入
        if self.external_subtitle_file:
            command.extend(["-i", self.external_subtitle_file])
        
        # 添加时间参数
        if self.params.start_time:
            command.extend(["-ss", self.params.start_time])
        
        if self.params.end_time:
            command.extend(["-to", self.params.end_time])
        
        # 流映射
        if self.audio_stream:
            command.extend(["-map", "0:0"])  # 映射视频流
            command.extend(["-map", f"0:{self.audio_stream.index}"])  # 映射音频流
        
        # 构建字幕过滤器
        subtitle_filter = ""
        if self.subtitle_stream and subtitle_indices:
            # 处理内嵌字幕
            relative_index = self.calculate_subtitle_relative_index(
                self.subtitle_stream.index, subtitle_indices
            )
            subtitle_filter = f",subtitles='{os.path.abspath(self.input_file)}':stream_index={relative_index}"
        elif self.external_subtitle_file:
            # 处理外部字幕
            subtitle_filter = f",subtitles='{os.path.abspath(self.external_subtitle_file)}'"
        
        # 视频参数
        command.extend([
            "-c:v",             "libaom-av1",
            "-b:v",             self.params.video_bitrate,
            "-vf",              self.params.get_scale_filter() + subtitle_filter,
            "-pix_fmt",         "yuv420p",
            "-color_primaries", "bt709",
            "-color_trc",       "bt709",
            "-colorspace",      "bt709",
        ])
        
        # 音频参数
        command.extend([
            "-c:a",             "aac",
            "-b:a",             "116k",
            "-ar",              "48000",
            "-ac",              "2",
        ])
        
        # 编码器设置
        command.extend([
            "-preset",          "slower",
            "-cpu-used",        "3",
            "-threads",         "0",
        ])
        
        # 输出文件
        command.append(self.output_file)
        
        return command
    
    def get_pretty_command(self):
        """
        获取格式化的命令字符串，用于显示
        """
        command = self.build_command()
        return " ".join([f'"{arg}"' if ' ' in arg else arg for arg in command])
    
    def execute(self, subtitle_indices=None):
        """
        构建并执行 FFmpeg 命令
        
        Args:
            subtitle_indices: 所有字幕流的索引列表，用于计算相对索引
            
        Returns:
            如果是干运行模式，返回命令行参数列表；否则返回执行结果
            
        Raises:
            subprocess.CalledProcessError: 如果命令执行失败
        """
        command = self.build_command(subtitle_indices)
        
        if self.dry_run:
            return command
        
        import subprocess
        result = subprocess.run(command, check=True)
        return result


class FFmpegCommandDirector:
    """
    FFmpeg命令构建的主管类
    
    协调FFmpegCommandBuilder的各个构建步骤，简化客户端代码
    """
    
    @staticmethod
    def create_conversion_command(
        params: FFmpegParams, 
        input_file: str, 
        output_file: str, 
        audio_stream=None,
        subtitle_stream=None,
        external_subtitle_file=None,
        subtitle_indices=None,
        dry_run=False
    ):
        """
        创建用于视频转换的FFmpeg命令
        
        Args:
            params: FFmpeg参数对象
            input_file: 输入文件路径
            output_file: 输出文件路径
            audio_stream: 音频流对象
            subtitle_stream: 字幕流对象
            external_subtitle_file: 外部字幕文件路径
            subtitle_indices: 所有字幕流的索引列表
            dry_run: 是否为干运行模式
            
        Returns:
            完整的FFmpeg命令行参数列表
        """
        builder = FFmpegCommandBuilder(params, input_file, output_file)
        
        if audio_stream:
            builder.set_audio_stream(audio_stream)
        
        if subtitle_stream:
            builder.set_subtitle_stream(subtitle_stream)
        elif external_subtitle_file:
            builder.set_external_subtitle(external_subtitle_file)
        
        builder.set_dry_run(dry_run)
        
        return builder.build_command(subtitle_indices)