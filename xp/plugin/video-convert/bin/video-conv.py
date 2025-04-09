#!/usr/bin/env python
# coding: utf-8

import os
import sys
import subprocess
import json
import argparse
from stream_info import StreamInfo
from ffmpeg_params import FFmpegParams, PRESET_PARAMS
from output_utils import get_output_name
from exceptions import ConversionError
from stream_manager import StreamManager


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
    
    def convert(self):
        """
        Execute the conversion process
        """
        if self.args.width not in PRESET_PARAMS:
            available_widths = ", ".join(str(w) for w in sorted(PRESET_PARAMS.keys()))
            raise ConversionError(f"Width {self.args.width} not found in presets. Available width presets: {available_widths}")
        
        self.params = PRESET_PARAMS[self.args.width]
        
        # Set start and end time parameters
        self.params.start_time = self.args.start_time
        self.params.end_time = self.args.end_time
        
        # Use original FPS if available
        if self.stream_manager.original_fps is not None:
            self.params.fps = self.stream_manager.original_fps
            print(f"Using original video FPS: {self.stream_manager.original_fps}")
        
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
            # Validate external subtitle file
            if not os.path.exists(self.external_subtitle_file):
                raise ConversionError(f"External subtitle file not found: {self.external_subtitle_file}")
                
            self.params.external_subtitle_file = self.external_subtitle_file
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
        
        self.params.input_file = self.args.input_file
        
        if self.args.video_bitrate:
            self.params.video_bitrate = self.args.video_bitrate
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
        
        ffmpeg_template = self._get_ffmpeg_template()
        ffmpeg_cmd = ["ffmpeg", "-i", self.args.input_file]
        
        # Add external subtitle file as input if specified
        if self.params.external_subtitle_file is not None:
            ffmpeg_cmd.extend(["-i", self.params.external_subtitle_file])
        
        ffmpeg_cmd.extend(ffmpeg_template + [output])
        
        print_subsection_header("FFmpeg Command")
        print(" ".join([f'"{arg}"' if ' ' in arg else arg for arg in ffmpeg_cmd]))
        
        if self.params.subtitle_stream is not None:
            print("\nNote: Using relative subtitle index in the filter. The subtitles filter uses")
            print("a 0-based index that counts only subtitle streams, not all streams.")
        
        if self.args.dry_run:
            print("\nDry run mode - command not executed.")
            return True
            
        print("\nStarting conversion...")
        
        try:
            subprocess.run(ffmpeg_cmd, check=True)
            print(f"Conversion completed: {output}")
            return True
        except subprocess.CalledProcessError as e:
            raise ConversionError(f"Conversion failed: {e}")
    
    def _get_ffmpeg_template(self):
        """
        Return ffmpeg command template with parameters from FFmpegParams
        """
        template = []
        
        if self.params.start_time is not None:
            template.extend(["-ss", self.params.start_time])
        
        if self.params.end_time is not None:
            template.extend(["-to", self.params.end_time])
        
        if self.selected_audio_stream is not None:
            template.extend(["-map", "0:0"])  # Map video stream
            template.extend(["-map", f"0:{self.selected_audio_stream.index}"])  # Map audio stream
        
        subtitle_filter = ""
        if self.selected_subtitle_stream is not None:
            # Handle embedded subtitle
            relative_subtitle_index = self.stream_manager.calculate_subtitle_relative_index(self.selected_subtitle_stream.index)
            subtitle_filter = f",subtitles='{os.path.abspath(self.params.input_file)}':stream_index={relative_subtitle_index}"
        elif self.params.external_subtitle_file is not None:
            # Handle external subtitle
            subtitle_filter = f",subtitles='{os.path.abspath(self.params.external_subtitle_file)}'"
        
        template.extend([
            "-c:v",             "libaom-av1",
            "-b:v",             self.params.video_bitrate,
            "-vf",              self.params.get_scale_filter() + subtitle_filter,
            "-pix_fmt",         "yuv420p",
            "-color_primaries", "bt709",
            "-color_trc",       "bt709",
            "-colorspace",      "bt709",
            "-c:a",             "aac",
            "-b:a",             "116k",
            "-ar",              "48000",
            "-ac",              "2",
            "-preset",          "slower",
            "-cpu-used",        "3",
            "-threads",         "0",
        ])
        
        return template


def main():
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

    args = parser.parse_args()
    
    converter = VideoConverter(args)
    
    # These methods now raise exceptions instead of returning True/False
    converter.select_streams()
    converter.convert()
    
    # If we get here, everything was successful


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
