#!/usr/bin/env python
# coding: utf-8

import os
import sys
import subprocess
import json
import argparse

# 导入自己包内的模块
from videoconv.stream_info import StreamInfo
from videoconv.ffmpeg_params import FFmpegParams, PRESET_PARAMS
from videoconv.output_utils import get_output_name
from videoconv.exceptions import ConversionError
from videoconv.stream_manager import StreamManager
from videoconv.ffmpeg_command_builder import FFmpegCommandBuilder, FFmpegCommandDirector
from videoconv.argument_validator import ArgumentValidator, create_argument_parser

# 使用标准ConversionError，不需要别名
# 之前是为了解决导入路径不一致的问题

def print_section_header(title):
    """Print a section header with a line separator"""
    print(f"\n{title}")
    print("=" * len(title))


def print_subsection_header(title):
    """Print a subsection header with a line separator"""
    print(f"\n{title}")
    print("-" * len(title))


class VideoConverter:
    """
    Class to handle video conversion process
    """
    def __init__(self, args):
        # 使用已验证的参数对象
        self.args = args
        self.stream_manager = StreamManager(args.input_file)
        self.selected_audio_stream = None
        self.selected_subtitle_stream = None
        self.params = None
        self.external_subtitle_file = args.external_subtitle_file
        
    def select_streams(self):
        """
        Select audio and subtitle streams based on command line arguments
        """
        # Select audio stream
        self.selected_audio_stream = self.stream_manager.select_audio_stream(self.args.audio_stream)
        
        # Select subtitle stream
        self.selected_subtitle_stream = self.stream_manager.select_subtitle_stream(
            stream_index=self.args.subtitle_stream,
            language=self.args.subtitle_language,
            title=self.args.subtitle_title,
            external_subtitle_file=self.external_subtitle_file,
            list_subtitles=self.args.list_subtitles
        )
        
        # Update external subtitle file
        if self.selected_subtitle_stream is not None:
            self.external_subtitle_file = None
    
    def initialize_params(self):
        """
        Initialize and configure FFmpeg parameters
        """
        self.params = PRESET_PARAMS[self.args.width]
        
        # Set start and end time parameters
        self.params.start_time = self.args.start_time
        self.params.end_time = self.args.end_time
        
        # Use original FPS if available
        if self.stream_manager.original_fps is not None:
            self.params.fps = self.stream_manager.original_fps
            print(f"Using original video FPS: {self.stream_manager.original_fps}")
        
        # Set input file
        self.params.input_file = self.args.input_file
        
        # Set external subtitle file if available
        if self.external_subtitle_file is not None:
            self.params.external_subtitle_file = self.external_subtitle_file
            
        # Set custom video bitrate if provided
        if self.args.video_bitrate:
            self.params.video_bitrate = self.args.video_bitrate
            
        return self.params

    def convert(self):
        """
        Execute the conversion process
        """
        # Initialize params at the beginning
        self.initialize_params()
        
        print_section_header("Conversion Summary")
        
        print_subsection_header("Audio Stream")
        print(f"Stream #{self.selected_audio_stream.index}")
        print(self.selected_audio_stream.get_audio_info())
        
        if self.selected_subtitle_stream is not None:
            print_subsection_header("Subtitle Stream")
            print(f"Stream #{self.selected_subtitle_stream.index}")
            print(self.selected_subtitle_stream.get_subtitle_info())
            
            relative_index = self.stream_manager.calculate_subtitle_relative_index(self.selected_subtitle_stream.index)
            print(f"Absolute Stream Index: {self.selected_subtitle_stream.index}")
            print(f"Relative Subtitle Index: {relative_index} (used in filter)")
        elif self.external_subtitle_file is not None:
            # 外部字幕文件已在ArgumentValidator中验证过，不需要再验证
            print_subsection_header("External Subtitle")
            print(f"File: {self.external_subtitle_file}")
        else:
            print_subsection_header("Subtitles")
            print("None (not included in output)")
        
        if self.args.start_time is not None or self.args.end_time is not None:
            print_subsection_header("Time Range")
            if self.args.start_time is not None:
                print(f"Start: {self.args.start_time}")
            if self.args.end_time is not None:
                print(f"End: {self.args.end_time}")
        
        if self.args.video_bitrate:
            print_subsection_header("Custom Settings")
            print(f"Bitrate: {self.args.video_bitrate}")
        
        print_subsection_header("Video Parameters")
        print(f"Width: {self.params.video_width}")
        print(f"Bitrate: {self.params.video_bitrate}")
        print(f"FPS: {self.params.fps}")
        
        output_dir = f"output-{self.args.width}x"
        output = get_output_name(self.params, output_dir, self.args.input_file, self.args.output_file)
        os.makedirs(os.path.dirname(output), exist_ok=True)
        
        print_subsection_header("File Information")
        print(f"Input: {self.args.input_file}")
        print(f"Output: {output}")
        
        # Check if output file already exists
        if os.path.exists(output):
            if self.args.skip_exists:
                print(f"\nOutput file already exists. Skipping conversion (--skip-exists is set).")
                return True
            else:
                raise ConversionError(f"Output file already exists: {output}\nUse --skip-exists or -se to skip with normal exit when file exists.")
        
        # 使用FFmpegCommandDirector构建命令
        command_builder = FFmpegCommandBuilder(self.params, self.args.input_file, output)
        command_builder.set_audio_stream(self.selected_audio_stream)
        
        if self.selected_subtitle_stream is not None:
            command_builder.set_subtitle_stream(self.selected_subtitle_stream)
        elif self.external_subtitle_file is not None:
            command_builder.set_external_subtitle(self.external_subtitle_file)
        
        command_builder.set_dry_run(self.args.dry_run)
        
        # 获取格式化的命令字符串用于显示
        print_subsection_header("FFmpeg Command")
        print(command_builder.get_pretty_command())
        
        if self.selected_subtitle_stream is not None:
            print("\nNote: Using relative subtitle index in the filter. The subtitles filter uses")
            print("a 0-based index that counts only subtitle streams, not all streams.")
        
        if self.args.dry_run:
            print("\nDry run mode - command not executed.")
            return True
            
        print("\nStarting conversion...")
        
        try:
            # 执行命令
            command_builder.execute(self.stream_manager.subtitle_indices)
            print(f"Conversion completed: {output}")
            return True
        except subprocess.CalledProcessError as e:
            raise ConversionError(f"Conversion failed: {e}")


def main():
    """主程序入口点"""
    # 使用参数验证器定义的解析器
    parser = create_argument_parser()
    raw_args = parser.parse_args()

    print(f"raw_args: {raw_args}")
    
    # 验证并获取处理后的参数
    try:
        args = ArgumentValidator.validate_args(raw_args)
    except ConversionError as e:
        print(f"Error: {e.message}", file=sys.stderr)
        sys.exit(e.exit_code)

    print(f"validated args: {args}")
    
    # 使用验证过的参数创建转换器
    converter = VideoConverter(args)
    
    # 进行转换
    converter.select_streams()
    converter.convert()
    
    # 如果到达这里，说明一切顺利


if __name__ == "__main__":
    try:
        main()
    except ConversionError as e:
        print(f"Error: {e.message}", file=sys.stderr)
        sys.exit(e.exit_code)
    except KeyboardInterrupt:
        print("\nOperation cancelled by user.", file=sys.stderr)
        sys.exit(130)
    except Exception as e:
        print(f"Unexpected error: {str(e)}", file=sys.stderr)
        sys.exit(1)
