#!/usr/bin/env python3
# coding: utf-8

import os
import sys
import subprocess


class FFmpegParams:
    """
    Class to store and manage ffmpeg parameters
    """
    def __init__(self, video_bitrate="149k", video_width=854, fps=24):
        self.video_bitrate = video_bitrate
        self.video_width = video_width
        self.fps = fps

    def get_scale_filter(self):
        return f"scale={self.video_width}:-2,fps={self.fps}"


# Predefined parameter sets indexed by video width
PRESET_PARAMS = {
    # Low quality / small size (480p)
    480: FFmpegParams(video_bitrate="80k", video_width=480, fps=24),

    # Medium quality (640p)
    640: FFmpegParams(video_bitrate="120k", video_width=640, fps=24),

    # Standard quality (720p)
    720: FFmpegParams(video_bitrate="140k", video_width=720, fps=24),

    # High quality (854p)
    854: FFmpegParams(video_bitrate="200k", video_width=854, fps=24),

    # HD quality (1280p)
    1280: FFmpegParams(video_bitrate="320k", video_width=1280, fps=24),

    # Full HD quality (1920p)
    1920: FFmpegParams(video_bitrate="400k", video_width=1920, fps=24),
}


def get_output_name(params, default_output_dir, input_file, output_arg=None):
    """
    Determine the output file path based on input file and output argument

    Args:
        params: FFmpegParams object containing encoding parameters
        default_output_dir: Default output directory if no output_arg is provided
        input_file: Input video file path
        output_arg: Optional output path specification
    """
    input_fn = os.path.basename(input_file)
    input_name_without_ext = os.path.splitext(input_fn)[0]
    
    output_name = None
    
    if output_arg is None:
        # Default output directory
        os.makedirs(default_output_dir, exist_ok=True)
        output_name = os.path.join(default_output_dir, input_fn)
    
    elif '*' in output_arg:
        # Replace wildcard with filename (without extension)
        output_name = output_arg.replace('*', input_name_without_ext)
    
    elif output_arg.endswith('/'):
        # Directory path - ensure it exists and append filename
        os.makedirs(output_arg, exist_ok=True)
        output_name = os.path.join(output_arg, input_fn)
    
    else:
        # Direct output path
        return output_arg

    # Add width and bitrate to the output name
    output_name_without_ext, ext = os.path.splitext(output_name)
    output_name = f"{output_name_without_ext}-{params.video_width}x-{params.video_bitrate}{ext}"

    return output_name


def get_ffmpeg_template(params):
    """
    Return ffmpeg command template with parameters from FFmpegParams
    """
    return [
        "-c:v",             "libaom-av1",
        "-b:v",             params.video_bitrate,
        "-vf",              params.get_scale_filter(),
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
    ]


def convert_video(width, input_file, output_file=None):
    """
    Convert video files using ffmpeg

    Args:
        width: Width to select from predefined parameter sets
        input_file: Input video file path
        output_file: Output file path or directory
    """
    # Get parameters based on width
    if width not in PRESET_PARAMS:
        print(f"Error: Width {width} not found in presets")
        print("Available width presets:", ", ".join(str(w) for w in sorted(PRESET_PARAMS.keys())))
        sys.exit(1)

    params = PRESET_PARAMS[width]

    # Determine output filename
    output_dir = f"output-{width}x"
    output = get_output_name(params, output_dir, input_file, output_file)
    # mkdir for the output_file if it doesn't exist
    os.makedirs(os.path.dirname(output), exist_ok=True)

    print(f"{input_file} ===> {output}")
    print(f"Using parameters: width={params.video_width}, bitrate={params.video_bitrate}, fps={params.fps}")

    # Get ffmpeg command template and build the final command
    ffmpeg_template = get_ffmpeg_template(params)
    ffmpeg_cmd = ["ffmpeg", "-i", input_file] + ffmpeg_template + [output]

    # Execute ffmpeg command
    try:
        subprocess.run(ffmpeg_cmd, check=True)
        print(f"Conversion completed: {output}")
    except subprocess.CalledProcessError as e:
        print(f"Conversion failed: {e}", file=sys.stderr)
        sys.exit(1)


def main():
    if len(sys.argv) < 3:
        print("Usage: python video_converter.py width input_file [output_file/directory]")
        print("Available width presets:", ", ".join(str(w) for w in sorted(PRESET_PARAMS.keys())))
        sys.exit(1)

    # Width is now the first parameter
    try:
        width = int(sys.argv[1])
    except ValueError:
        print(f"Error: Invalid width: {sys.argv[1]}")
        print("Available width presets:", ", ".join(str(w) for w in sorted(PRESET_PARAMS.keys())))
        sys.exit(1)

    input_file = sys.argv[2]

    # Output file is the third parameter (optional)
    output_file = sys.argv[3] if len(sys.argv) > 3 else None

    convert_video(width, input_file, output_file)


if __name__ == "__main__":
    main()
