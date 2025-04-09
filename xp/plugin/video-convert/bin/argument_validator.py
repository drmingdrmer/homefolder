#!/usr/bin/env python
# coding: utf-8

import os
import argparse

# 支持直接运行和测试环境
try:
    from exceptions import ConversionError
    from ffmpeg_params import PRESET_PARAMS
except ImportError:
    from bin.exceptions import ConversionError
    from bin.ffmpeg_params import PRESET_PARAMS


class ArgumentValidator:
    """
    参数验证与预处理类
    
    负责验证命令行参数，确保其满足程序运行的需求，
    并进行必要的预处理转换和规范化。
    """
    
    @staticmethod
    def validate_width(width):
        """
        验证视频宽度参数
        
        Args:
            width: 视频宽度，应为PRESET_PARAMS中的一个预设值
            
        Returns:
            有效的宽度值
            
        Raises:
            ConversionError: 如果宽度不在预设值中
        """
        if width not in PRESET_PARAMS:
            available_widths = ", ".join(str(w) for w in sorted(PRESET_PARAMS.keys()))
            raise ConversionError(
                f"Width {width} not found in presets. Available width presets: {available_widths}"
            )
        return width
    
    @staticmethod
    def validate_input_file(input_file):
        """
        验证输入文件路径
        
        Args:
            input_file: 输入文件路径
            
        Returns:
            规范化后的输入文件路径
            
        Raises:
            ConversionError: 如果文件不存在或无法访问
        """
        if not input_file:
            raise ConversionError("Input file path cannot be empty")
        
        if not os.path.exists(input_file):
            raise ConversionError(f"Input file not found: {input_file}")
        
        if not os.path.isfile(input_file):
            raise ConversionError(f"Input path is not a file: {input_file}")
        
        # 返回绝对路径，避免相对路径带来的问题
        return os.path.abspath(input_file)
    
    @staticmethod
    def validate_output_file(output_file, input_file):
        """
        验证输出文件路径
        
        Args:
            output_file: 输出文件路径，可以为None
            input_file: 输入文件路径，用于生成默认输出路径
            
        Returns:
            输出文件路径，如为None则返回None（将使用默认路径）
        """
        # 如果output_file为None，返回None，后续会使用默认输出路径
        if output_file is None:
            return None
        
        # 如果output_file是目录路径且不以/结尾，添加/
        if os.path.isdir(output_file) and not output_file.endswith('/'):
            return output_file + '/'
        
        return output_file
    
    @staticmethod
    def validate_external_subtitle(external_subtitle_file):
        """
        验证外部字幕文件
        
        Args:
            external_subtitle_file: 外部字幕文件路径
            
        Returns:
            规范化后的字幕文件路径，如不存在则返回None
            
        Raises:
            ConversionError: 如果字幕文件无法访问
        """
        if not external_subtitle_file:
            return None
        
        if not os.path.exists(external_subtitle_file):
            raise ConversionError(f"External subtitle file not found: {external_subtitle_file}")
        
        if not os.path.isfile(external_subtitle_file):
            raise ConversionError(f"External subtitle path is not a file: {external_subtitle_file}")
        
        # 返回绝对路径
        return os.path.abspath(external_subtitle_file)
    
    @staticmethod
    def validate_time_format(time_str, param_name="time"):
        """
        验证时间格式
        
        Args:
            time_str: 时间字符串，可以是HH:MM:SS格式或秒数
            param_name: 参数名称，用于错误信息
            
        Returns:
            规范化后的时间字符串，如为None则返回None
            
        Raises:
            ConversionError: 如果时间格式无效
        """
        if time_str is None:
            return None
        
        # 尝试解析为秒数
        if time_str.isdigit():
            return time_str
        
        # 尝试解析为HH:MM:SS格式
        parts = time_str.split(':')
        
        if len(parts) == 3:
            try:
                hours = int(parts[0])
                minutes = int(parts[1])
                seconds = int(parts[2])
                
                if hours < 0 or minutes < 0 or seconds < 0 or minutes >= 60 or seconds >= 60:
                    raise ValueError("Invalid time values")
                
                return time_str
            except ValueError:
                pass
        
        raise ConversionError(
            f"Invalid {param_name} format: {time_str}. "
            f"Use HH:MM:SS format (e.g., '00:01:30') or seconds (e.g., '90')."
        )
    
    @staticmethod
    def validate_video_bitrate(bitrate):
        """
        验证视频比特率格式
        
        Args:
            bitrate: 比特率字符串，如"500k", "1.5M"
            
        Returns:
            有效的比特率字符串，如为None则返回None
            
        Raises:
            ConversionError: 如果比特率格式无效
        """
        if bitrate is None:
            return None
        
        # 检查格式：数字后跟k或M
        valid_formats = ['k', 'K', 'm', 'M']
        
        if any(bitrate.endswith(suffix) for suffix in valid_formats):
            prefix = bitrate[:-1]
            try:
                # 尝试将前缀转换为浮点数
                float(prefix)
                return bitrate
            except ValueError:
                pass
        
        # 检查是否为纯数字（表示bps）
        try:
            int(bitrate)
            return bitrate
        except ValueError:
            pass
        
        raise ConversionError(
            f"Invalid video bitrate format: {bitrate}. "
            f"Use 'k' or 'M' suffix (e.g., '500k', '1.5M') or numeric value."
        )
    
    @classmethod
    def validate_args(cls, args):
        """
        验证命令行参数并进行预处理
        
        Args:
            args: 解析后的命令行参数
            
        Returns:
            验证和预处理后的参数对象
            
        Raises:
            ConversionError: 如参数无效
        """
        # 创建新参数对象，避免修改原始对象
        validated_args = argparse.Namespace()
        
        # 验证并更新各个参数
        validated_args.width = cls.validate_width(args.width)
        validated_args.input_file = cls.validate_input_file(args.input_file)
        validated_args.output_file = cls.validate_output_file(args.output_file, args.input_file)
        validated_args.external_subtitle_file = cls.validate_external_subtitle(args.external_subtitle_file)
        validated_args.start_time = cls.validate_time_format(args.start_time, "start time")
        validated_args.end_time = cls.validate_time_format(args.end_time, "end time")
        validated_args.video_bitrate = cls.validate_video_bitrate(args.video_bitrate)
        
        # 直接复制其他参数
        validated_args.audio_stream = args.audio_stream
        validated_args.subtitle_stream = args.subtitle_stream
        validated_args.subtitle_language = args.subtitle_language
        validated_args.subtitle_title = args.subtitle_title
        validated_args.list_subtitles = args.list_subtitles
        validated_args.dry_run = args.dry_run
        validated_args.skip_exists = args.skip_exists
        
        # 验证时间范围的逻辑
        if validated_args.start_time and validated_args.end_time:
            if cls._convert_to_seconds(validated_args.start_time) >= cls._convert_to_seconds(validated_args.end_time):
                raise ConversionError(
                    f"Start time ({validated_args.start_time}) must be earlier than end time ({validated_args.end_time})"
                )
        
        return validated_args
    
    @staticmethod
    def _convert_to_seconds(time_str):
        """
        将时间字符串转换为秒数
        
        Args:
            time_str: 时间字符串，可以是HH:MM:SS格式或秒数
            
        Returns:
            时间的秒数表示
        """
        if time_str.isdigit():
            return int(time_str)
        
        parts = time_str.split(':')
        if len(parts) == 3:
            hours, minutes, seconds = map(int, parts)
            return hours * 3600 + minutes * 60 + seconds
        
        return 0  # 不应该到达这里，因为validate_time_format已经验证过格式


def create_argument_parser():
    """创建命令行参数解析器"""
    parser = argparse.ArgumentParser(description='Convert video files using ffmpeg with customizable parameters.')

    parser.add_argument('width', type=int, choices=sorted(PRESET_PARAMS.keys()),
                        help=f'Video width preset. Available presets: {", ".join(str(w) for w in sorted(PRESET_PARAMS.keys()))}')
    parser.add_argument('input_file', help='Input video file path. If path contains "./" (e.g., "foo/./videos/file.mp4"), the output filename will be split at this point.')
    parser.add_argument('output_file', nargs='?', default=None,
                        help='Output file path or directory. If not specified, a default output directory will be used.')
    parser.add_argument('--audio-stream', '-a', type=int, dest='audio_stream',
                        help='Audio stream index to select (e.g., 1 for Stream #0:1)')
    parser.add_argument('--subtitle-stream', '-s', type=int, dest='subtitle_stream',
                        help='Optional subtitle stream index to embed (e.g., 2 for Stream #0:2). If not specified, no subtitles will be included.')
    parser.add_argument('--subtitle-language', '-sl', dest='subtitle_language',
                        help='Select subtitle by language code (e.g., "chi" for Chinese, "eng" for English)')
    parser.add_argument('--subtitle-title', '-st', dest='subtitle_title',
                        help='Select subtitle by title (e.g., "中文（简体）")')
    parser.add_argument('--external-subtitle', '-es', dest='external_subtitle_file',
                        help='Path to external subtitle file to embed (e.g., "subtitle.srt")')
    parser.add_argument('--list-subtitles', '-ls', action='store_true', dest='list_subtitles',
                        help='List all available subtitle streams and exit')
    parser.add_argument('--bitrate', '-b', dest='video_bitrate',
                        help='Override video bitrate (e.g., "200k", "1M")')
    parser.add_argument('--start-time', '-ss', dest='start_time',
                        help='Start time for conversion (format: HH:MM:SS or seconds, e.g., "00:01:30" or "90")')
    parser.add_argument('--end-time', '-to', dest='end_time',
                        help='End time for conversion (format: HH:MM:SS or seconds, e.g., "00:05:00" or "300")')
    parser.add_argument('--dry-run', '-n', action='store_true', dest='dry_run',
                        help='Print information and conversion command without executing it')
    parser.add_argument('--skip-exists', '-se', action='store_true', dest='skip_exists',
                        help='Skip with normal exit if output file already exists (default: exit with error)')
    
    return parser 