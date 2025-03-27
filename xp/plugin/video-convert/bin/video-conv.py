#!/usr/bin/env python
# coding: utf-8

import os
import sys
import subprocess
import json
import argparse


class FFmpegParams:
    """
    Class to store and manage ffmpeg parameters
    """
    def __init__(self, video_bitrate="149k", video_width=854, fps=24, audio_stream=None, subtitle_stream=None, start_time=None, end_time=None, external_subtitle_file=None):
        self.video_bitrate = video_bitrate
        self.video_width = video_width
        self.fps = fps
        self.audio_stream = audio_stream
        self.subtitle_stream = subtitle_stream
        self.start_time = start_time  # Start time in seconds or HH:MM:SS format
        self.end_time = end_time      # End time in seconds or HH:MM:SS format
        self.input_file = None
        self.external_subtitle_file = external_subtitle_file  # Path to external subtitle file

    def get_scale_filter(self):
        return f"scale={self.video_width}:-2,fps={self.fps}"


PRESET_PARAMS = {
    480: FFmpegParams(video_bitrate="80k", video_width=480, fps=24),
    640: FFmpegParams(video_bitrate="120k", video_width=640, fps=24),
    720: FFmpegParams(video_bitrate="150k", video_width=720, fps=24),
    854: FFmpegParams(video_bitrate="220k", video_width=854, fps=24),
    1280: FFmpegParams(video_bitrate="480k", video_width=1280, fps=24),
    1920: FFmpegParams(video_bitrate="1000k", video_width=1920, fps=24),
}


def get_output_name(params: FFmpegParams, default_output_dir: str, input_file: str, output_arg: str = None):
    input_fn = input_file

    # get the part since "./", if not found, use the whole input_fn
    if input_file.find("./") != -1:
        input_fn = input_file[input_file.find("./") + 2:]

    # strip the extension
    input_name_without_ext = os.path.splitext(input_fn)[0]

    output_name = None

    if output_arg is None:
        os.makedirs(default_output_dir, exist_ok=True)
        output_name = os.path.join(default_output_dir, input_fn)
    elif '*' in output_arg:
        output_name = output_arg.replace('*', input_name_without_ext)
    elif output_arg.endswith('/'):
        os.makedirs(output_arg, exist_ok=True)
        output_name = os.path.join(output_arg, input_fn)
    else:
        return output_arg

    output_name_without_ext, ext = os.path.splitext(output_name)
    output_name = f"{output_name_without_ext}-{params.video_width}x-{params.video_bitrate}"
    
    if params.start_time is not None or params.end_time is not None:
        time_info = ""
        if params.start_time is not None:
            time_info += f"-from_{params.start_time.replace(':', '_')}"
        if params.end_time is not None:
            time_info += f"-to_{params.end_time.replace(':', '_')}"
        output_name += time_info
    
    if params.external_subtitle_file is not None:
        # Add suffix to indicate external subtitles were used
        subtitle_base = os.path.basename(params.external_subtitle_file)
        subtitle_name = os.path.splitext(subtitle_base)[0]
        output_name += f"-with_sub_{subtitle_name}"
    
    output_name += ext

    return output_name


class StreamInfo:
    """
    Class to store and manage stream information
    """
    def __init__(self, stream_data):
        """
        Initialize StreamInfo from ffprobe stream data
        """
        self.index = stream_data.get("index")
        self.codec_type = stream_data.get("codec_type")
        
        # Get tags
        tags = stream_data.get("tags", {})
        self.language = tags.get("language", "unknown")
        self.title = tags.get("title", "")
        
        # Initialize optional fields
        self.handler = None
        self.default = False
        self.forced = False
        self.fps = None
        
        # Set type-specific fields
        if self.codec_type == "audio":
            self.handler = tags.get("handler_name", "")
        elif self.codec_type == "subtitle":
            disposition = stream_data.get("disposition", {})
            self.default = disposition.get("default", 0) == 1
            self.forced = disposition.get("forced", 0) == 1
        elif self.codec_type == "video":
            # Get FPS from video stream
            r_frame_rate = stream_data.get("r_frame_rate", "")
            if r_frame_rate:
                try:
                    num, den = map(int, r_frame_rate.split("/"))
                    self.fps = round(num / den, 3)
                except (ValueError, ZeroDivisionError):
                    self.fps = None

    def __str__(self):
        info_parts = []
        if self.language != "unknown":
            info_parts.append(f"language: {self.language}")
        if self.title:
            info_parts.append(f"title: {self.title}")
        if self.handler:
            info_parts.append(f"handler: {self.handler}")
        if self.default:
            info_parts.append("default")
        if self.forced:
            info_parts.append("forced")
        return ", ".join(info_parts) if info_parts else "unknown"

    def get_audio_info(self):
        """
        Get formatted audio stream information
        """
        lines = [f"Audio Stream: #{self.index}"]
        if self.language != "unknown":
            lines.append(f"  Language: {self.language}")
        if self.title:
            lines.append(f"  Title: {self.title}")
        if self.handler:
            lines.append(f"  Handler: {self.handler}")
        return "\n".join(lines)

    def get_subtitle_info(self):
        """
        Get formatted subtitle stream information
        """
        lines = [f"Subtitle Stream: #{self.index}"]
        if self.language != "unknown":
            lines.append(f"  Language: {self.language}")
        if self.title:
            lines.append(f"  Title: {self.title}")
        if self.default:
            lines.append("  Default: Yes")
        if self.forced:
            lines.append("  Forced: Yes")
        return "\n".join(lines)


def detect_all_streams(input_file: str):
    cmd = [
        "ffprobe",
        "-v", "quiet",
        "-print_format", "json",
        "-show_streams",
        input_file
    ]
    result = subprocess.run(cmd, check=True, capture_output=True, text=True)
    data = json.loads(result.stdout)
    
    return [StreamInfo(stream_data) for stream_data in data.get("streams", [])]


class VideoConverter:
    """
    Class to handle video conversion process
    """
    def __init__(self, args):
        self.args = args
        self.all_streams = []
        self.audio_streams = []
        self.subtitle_streams = []
        self.selected_audio_stream = None
        self.selected_subtitle_stream = None
        self.params = None
        self.subtitle_languages = set()
        self.subtitle_titles = set()
        self.subtitle_indices = []
        self.external_subtitle_file = args.external_subtitle_file
        self.original_fps = None
        
        self._detect_streams()
        
    def _detect_streams(self):
        """
        Detect all streams in the input file
        """
        self.all_streams = detect_all_streams(self.args.input_file)
        self.audio_streams = [s for s in self.all_streams if s.codec_type == "audio"]
        self.subtitle_streams = [s for s in self.all_streams if s.codec_type == "subtitle"]
        
        # Get original FPS from video stream
        video_streams = [s for s in self.all_streams if s.codec_type == "video"]
        if video_streams and video_streams[0].fps is not None:
            self.original_fps = video_streams[0].fps
            print(f"Original video FPS: {self.original_fps}")
        
        self.subtitle_languages = set(s.language for s in self.subtitle_streams)
        self.subtitle_titles = set(s.title for s in self.subtitle_streams)
        self.subtitle_indices = [stream.index for stream in self.subtitle_streams]
        
    def select_audio_stream(self):
        requested_audio_stream = self.args.audio_stream
        audio_stream_indices = [stream.index for stream in self.audio_streams]
        
        if not self.audio_streams:
            print("No audio streams detected in the input file.")
            return False
            
        if requested_audio_stream is None:
            if len(self.audio_streams) == 1:
                self.selected_audio_stream = self.audio_streams[0]
                print(f"Using default audio stream:")
                print(self.selected_audio_stream.get_audio_info())
                return True
            else:
                print("Multiple audio streams detected. Please specify one with --audio-stream/-a option:")
                for stream in self.audio_streams:
                    print(f"  [{stream.index}] {stream}")

                print("\nExample usage:")
                print(f"  {sys.argv[0]} {self.args.width} \"{self.args.input_file}\" --audio-stream <STREAM_NUMBER>")
                return False
        elif requested_audio_stream not in audio_stream_indices:
            print(f"Error: Specified audio stream {requested_audio_stream} not found in the input file.")
            print(f"Available audio streams: {', '.join(map(str, audio_stream_indices))}")
            return False
        else:
            self.selected_audio_stream = next(stream for stream in self.audio_streams if stream.index == requested_audio_stream)
            print(f"Using specified audio stream:")
            print(self.selected_audio_stream.get_audio_info())
            return True
    
    def select_subtitle_stream(self):
        """
        Select the subtitle stream to use based on command line arguments
        """
        self.selected_subtitle_stream = None
        
        # Check if both embedded and external subtitles were specified
        if (self.args.subtitle_stream is not None or self.args.subtitle_language is not None or self.args.subtitle_title is not None) and self.external_subtitle_file is not None:
            print("\nWarning: Both embedded and external subtitles were specified.")
            print("Embedded subtitles will be used. External subtitle file will be ignored.")
            self.external_subtitle_file = None
        
        if not self.subtitle_streams:
            if self.args.subtitle_stream is not None or self.args.subtitle_language is not None or self.args.subtitle_title is not None:
                print("Error: No subtitle streams found in the input file, but subtitle selection was requested.")
                return False
            else:
                print("No subtitle streams found in the input file.")
                return True
        
        if self.args.list_subtitles:
            print(f"\nAvailable subtitle streams in '{self.args.input_file}':")
            print("Index | Language | Title | Default | Forced")
            print("-" * 60)
            for stream in self.subtitle_streams:
                default = "Yes" if stream.default else "No"
                forced = "Yes" if stream.forced else "No"
                print(f"{stream.index:5} | {stream.language:8} | {stream.title:20} | {default:7} | {forced}")
            return False
        
        print(f"\nFound {len(self.subtitle_streams)} subtitle stream(s):")
        for stream in self.subtitle_streams:
            print(f"  [{stream.index}] {stream}")
        
        requested_subtitle_stream = self.args.subtitle_stream
        
        if self.args.subtitle_language is not None:
            language_matches = [s for s in self.subtitle_streams if s.language.lower() == self.args.subtitle_language.lower()]
            if language_matches:
                self.selected_subtitle_stream = language_matches[0]
                print(f"Selected subtitle stream by language '{self.args.subtitle_language}':")
                print(self.selected_subtitle_stream.get_subtitle_info())
            else:
                print(f"Error: No subtitle stream with language '{self.args.subtitle_language}' found.")
                print(f"Available subtitle languages: {', '.join(self.subtitle_languages)}")
                return False
        elif self.args.subtitle_title is not None:
            title_matches = [s for s in self.subtitle_streams if self.args.subtitle_title.lower() in s.title.lower()]
            if title_matches:
                self.selected_subtitle_stream = title_matches[0]
                print(f"Selected subtitle stream by title '{self.args.subtitle_title}':")
                print(self.selected_subtitle_stream.get_subtitle_info())
            else:
                print(f"Error: No subtitle stream with title containing '{self.args.subtitle_title}' found.")
                print(f"Available subtitle titles: {', '.join(self.subtitle_titles)}")
                return False
        elif requested_subtitle_stream is not None:
            if requested_subtitle_stream not in self.subtitle_indices:
                print(f"Error: Specified subtitle stream {requested_subtitle_stream} not found in the input file.")
                print(f"Available subtitle streams: {', '.join(map(str, self.subtitle_indices))}")
                return False
            else:
                self.selected_subtitle_stream = next(stream for stream in self.subtitle_streams if stream.index == requested_subtitle_stream)
                print(f"Using specified subtitle stream #{requested_subtitle_stream}:")
                print(self.selected_subtitle_stream.get_subtitle_info())
        else:
            print("No subtitle stream specified. Subtitles will not be included.")
        
        return True
    
    def calculate_subtitle_relative_index(self, absolute_index):
        sorted_streams = sorted(self.subtitle_streams, key=lambda s: s.index)
        
        for i, stream in enumerate(sorted_streams):
            if stream.index == absolute_index:
                return i
        
        return 0
    
    def convert(self):
        if self.args.width not in PRESET_PARAMS:
            print(f"Error: Width {self.args.width} not found in presets")
            print("Available width presets:", ", ".join(str(w) for w in sorted(PRESET_PARAMS.keys())))
            return False
        
        self.params = PRESET_PARAMS[self.args.width]
        
        # Use original FPS if available
        if self.original_fps is not None:
            self.params.fps = self.original_fps
            print(f"Using original video FPS: {self.original_fps}")
        
        print("\n=== Conversion Summary ===")
        
        self.params.audio_stream = self.selected_audio_stream.index
        print(self.selected_audio_stream.get_audio_info())
        
        if self.selected_subtitle_stream is not None:
            self.params.subtitle_stream = self.selected_subtitle_stream.index
            print(self.selected_subtitle_stream.get_subtitle_info())
            
            relative_index = self.calculate_subtitle_relative_index(self.selected_subtitle_stream.index)
            print(f"  Absolute Stream Index: {self.selected_subtitle_stream.index}")
            print(f"  Relative Subtitle Index: {relative_index} (used in filter)")
        elif self.external_subtitle_file is not None:
            # Validate external subtitle file
            if not os.path.exists(self.external_subtitle_file):
                print(f"Error: External subtitle file not found: {self.external_subtitle_file}")
                return False
                
            self.params.external_subtitle_file = self.external_subtitle_file
            print(f"External Subtitle File: {self.external_subtitle_file}")
        else:
            print("Subtitles: None (not included in output)")
        
        self.params.start_time = self.args.start_time
        self.params.end_time = self.args.end_time
        if self.args.start_time is not None or self.args.end_time is not None:
            print("Time Range:")
            if self.args.start_time is not None:
                print(f"  Start: {self.args.start_time}")
            if self.args.end_time is not None:
                print(f"  End: {self.args.end_time}")
        
        self.params.input_file = self.args.input_file
        
        if self.args.video_bitrate:
            self.params.video_bitrate = self.args.video_bitrate
            print(f"Custom Bitrate: {self.args.video_bitrate}")
        
        print(f"Video Parameters: width={self.params.video_width}, bitrate={self.params.video_bitrate}, fps={self.params.fps}")
        
        output_dir = f"output-{self.args.width}x"
        output = get_output_name(self.params, output_dir, self.args.input_file, self.args.output_file)
        os.makedirs(os.path.dirname(output), exist_ok=True)
        
        print(f"\nInput: {self.args.input_file}")
        print(f"Output: {output}")
        
        # Check if output file already exists
        if os.path.exists(output):
            if self.args.skip_exists:
                print(f"\nOutput file already exists. Skipping conversion (--skip-exists is set).")
                return True
            else:
                print(f"\nError: Output file already exists: {output}")
                print("Use --skip-exists or -se to skip with normal exit when file exists.")
                return False
        
        ffmpeg_template = self._get_ffmpeg_template()
        ffmpeg_cmd = ["ffmpeg", "-i", self.args.input_file]
        
        # Add external subtitle file as input if specified
        if self.params.external_subtitle_file is not None:
            ffmpeg_cmd.extend(["-i", self.params.external_subtitle_file])
        
        ffmpeg_cmd.extend(ffmpeg_template + [output])
        
        print("\nCommand to be executed:")
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
            print(f"Conversion failed: {e}", file=sys.stderr)
            return False
    
    def _get_ffmpeg_template(self):
        """
        Return ffmpeg command template with parameters from FFmpegParams
        """
        template = []
        
        if self.params.start_time is not None:
            template.extend(["-ss", self.params.start_time])
        
        if self.params.end_time is not None:
            template.extend(["-to", self.params.end_time])
        
        if self.params.audio_stream is not None:
            template.extend(["-map", "0:0"])  # Map video stream
            template.extend(["-map", f"0:{self.params.audio_stream}"])  # Map audio stream
        
        subtitle_filter = ""
        if self.params.subtitle_stream is not None:
            # Handle embedded subtitle
            relative_subtitle_index = self.calculate_subtitle_relative_index(self.params.subtitle_stream)
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
    
    if not converter.select_audio_stream():
        sys.exit(1)
    
    if not converter.select_subtitle_stream():
        sys.exit(0 if args.list_subtitles else 1)
    
    if not converter.convert():
        sys.exit(1)


if __name__ == "__main__":
    main()
