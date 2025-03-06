#!/usr/bin/env python3
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
    def __init__(self, video_bitrate="149k", video_width=854, fps=24, audio_stream=None):
        self.video_bitrate = video_bitrate
        self.video_width = video_width
        self.fps = fps
        self.audio_stream = audio_stream

    def get_scale_filter(self):
        return f"scale={self.video_width}:-2,fps={self.fps}"


# Predefined parameter sets indexed by video width
PRESET_PARAMS = {
    # Low quality / small size (480p)
    480: FFmpegParams(video_bitrate="80k", video_width=480, fps=24),

    # Medium quality (640p)
    640: FFmpegParams(video_bitrate="120k", video_width=640, fps=24),

    # Standard quality (720p)
    720: FFmpegParams(video_bitrate="150k", video_width=720, fps=24),

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
    template = []
    
    # Add mapping options if audio stream is specified
    if params.audio_stream is not None:
        # Map video stream (always the first one, 0:0)
        template.extend(["-map", "0:0"])
        # Map the specified audio stream
        template.extend(["-map", f"0:{params.audio_stream}"])
    
    template.extend([
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
    ])
    
    return template


def detect_audio_streams(input_file):
    """
    Detect audio streams in the input file using ffprobe
    
    Args:
        input_file: Input video file path
        
    Returns:
        A list of dictionaries containing audio stream information
    """
    try:
        # Run ffprobe to get stream information in JSON format
        cmd = [
            "ffprobe", 
            "-v", "quiet", 
            "-print_format", "json", 
            "-show_streams", 
            input_file
        ]
        result = subprocess.run(cmd, check=True, capture_output=True, text=True)
        data = json.loads(result.stdout)
        
        # Find all audio streams
        audio_streams = []
        for i, stream in enumerate(data.get("streams", [])):
            if stream.get("codec_type") == "audio":
                # Get stream metadata
                tags = stream.get("tags", {})
                language = tags.get("language", "unknown")
                title = tags.get("title", "")
                handler = tags.get("handler_name", "")
                
                # Store stream info
                stream_info = {
                    "index": i,
                    "language": language,
                    "title": title,
                    "handler": handler
                }
                audio_streams.append(stream_info)
                
                # Print stream info
                print(f"Found audio stream #{i}: {handler} ({language})")
        
        return audio_streams
    
    except subprocess.CalledProcessError as e:
        print(f"Error detecting audio streams: {e}", file=sys.stderr)
        return []
    except json.JSONDecodeError:
        print("Error parsing ffprobe output", file=sys.stderr)
        return []
    except Exception as e:
        print(f"Unexpected error detecting audio streams: {e}", file=sys.stderr)
        return []


def format_stream_info(stream):
    """
    Format audio stream information into a readable string
    
    Args:
        stream: Dictionary containing stream information
        
    Returns:
        Formatted string with stream details
    """
    language = stream["language"]
    info = f"language: {language}"
    
    if stream["title"]:
        info += f", title: {stream['title']}"
    if stream["handler"]:
        info += f", handler: {stream['handler']}"
        
    return info


def convert_video(width, audio_stream, input_file, output_file=None):
    """
    Convert video files using ffmpeg

    Args:
        width: Width to select from predefined parameter sets
        audio_stream: Audio stream index to select (e.g., 1 for Stream #0:1)
        input_file: Input video file path
        output_file: Output file path or directory
    """
    # Get parameters based on width
    if width not in PRESET_PARAMS:
        print(f"Error: Width {width} not found in presets")
        print("Available width presets:", ", ".join(str(w) for w in sorted(PRESET_PARAMS.keys())))
        sys.exit(1)

    params = PRESET_PARAMS[width]
    
    # Set audio stream
    params.audio_stream = audio_stream
    print(f"Using audio stream: {audio_stream}")

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
    # Create argument parser
    parser = argparse.ArgumentParser(description='Convert video files using ffmpeg with customizable parameters.')
    
    # Add arguments
    parser.add_argument('width', type=int, choices=sorted(PRESET_PARAMS.keys()),
                        help=f'Video width preset. Available presets: {", ".join(str(w) for w in sorted(PRESET_PARAMS.keys()))}')
    parser.add_argument('input_file', help='Input video file path')
    parser.add_argument('output_file', nargs='?', default=None, 
                        help='Output file path or directory. If not specified, a default output directory will be used.')
    parser.add_argument('--audio-stream', '-a', type=int, dest='audio_stream', 
                        help='Audio stream index to select (e.g., 1 for Stream #0:1)')
    
    # Parse arguments
    args = parser.parse_args()
    
    # Detect audio streams
    audio_streams = detect_audio_streams(args.input_file)
    
    if not audio_streams:
        print("No audio streams detected in the input file.")
        sys.exit(1)
    
    # Handle audio stream selection
    requested_audio_stream = args.audio_stream
    
    # Extract just the indices for easier comparison
    audio_stream_indices = [stream["index"] for stream in audio_streams]
    
    # If audio_stream is not provided, use the first one
    if requested_audio_stream is None:
        if len(audio_streams) == 1:
            audio_stream = audio_streams[0]["index"]
            print(f"Using default audio stream: {audio_stream}")
        else:
            print("Multiple audio streams detected. Please specify one with --audio-stream/-a option:")
            for stream in audio_streams:
                index = stream["index"]
                info = format_stream_info(stream)
                print(f"  [{index}] {info}")
            
            print("\nExample usage:")
            print(f"  {sys.argv[0]} {args.width} \"{args.input_file}\" --audio-stream <STREAM_NUMBER>")
            sys.exit(1)
    # If audio_stream is specified but not in the detected streams, report error
    elif requested_audio_stream not in audio_stream_indices:
        print(f"Error: Specified audio stream {requested_audio_stream} not found in the input file.")
        print(f"Available audio streams: {', '.join(map(str, audio_stream_indices))}")
        sys.exit(1)
    else:
        audio_stream = requested_audio_stream

    # Convert video
    convert_video(args.width, audio_stream, args.input_file, args.output_file)


if __name__ == "__main__":
    main()
