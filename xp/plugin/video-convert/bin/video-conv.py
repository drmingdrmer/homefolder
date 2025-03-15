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
    def __init__(self, video_bitrate="149k", video_width=854, fps=24, audio_stream=None, subtitle_stream=None, start_time=None, end_time=None):
        self.video_bitrate = video_bitrate
        self.video_width = video_width
        self.fps = fps
        self.audio_stream = audio_stream
        self.subtitle_stream = subtitle_stream
        self.start_time = start_time  # Start time in seconds or HH:MM:SS format
        self.end_time = end_time      # End time in seconds or HH:MM:SS format

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
    854: FFmpegParams(video_bitrate="220k", video_width=854, fps=24),

    # HD quality (1280p)
    1280: FFmpegParams(video_bitrate="480k", video_width=1280, fps=24),

    # Full HD quality (1920p)
    1920: FFmpegParams(video_bitrate="1000k", video_width=1920, fps=24),
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
    output_name = f"{output_name_without_ext}-{params.video_width}x-{params.video_bitrate}"
    
    # Add time range info if specified
    if params.start_time is not None or params.end_time is not None:
        time_info = ""
        if params.start_time is not None:
            # Replace colons with underscores for filename compatibility
            time_info += f"-from_{params.start_time.replace(':', '_')}"
        if params.end_time is not None:
            # Replace colons with underscores for filename compatibility
            time_info += f"-to_{params.end_time.replace(':', '_')}"
        output_name += time_info
    
    output_name += ext

    return output_name


def get_ffmpeg_template(params):
    """
    Return ffmpeg command template with parameters from FFmpegParams
    """
    template = []

    # Add time range options if specified
    if params.start_time is not None:
        template.extend(["-ss", params.start_time])
    
    if params.end_time is not None:
        template.extend(["-to", params.end_time])

    # Add mapping options for video and audio streams
    if params.audio_stream is not None:
        # Map video stream (always the first one, 0:0)
        template.extend(["-map", "0:0"])
        # Map the specified audio stream
        template.extend(["-map", f"0:{params.audio_stream}"])
    
    # Add subtitle mapping if specified
    if params.subtitle_stream is not None:
        # Map the specified subtitle stream
        template.extend(["-map", f"0:{params.subtitle_stream}"])
        # Burn subtitles into the video
        template.extend(["-c:s", "mov_text"])

    template.extend([
        "-c:v",             "libaom-av1",
        "-b:v",             params.video_bitrate,
        "-vf",              params.get_scale_filter() + (f",subtitles='{os.path.abspath(params.input_file)}':stream_index={params.subtitle_stream}" if params.subtitle_stream is not None else ""),
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
        for stream in data.get("streams", []):
            if stream.get("codec_type") == "audio":
                # Get stream index
                stream_index = stream.get("index")
                
                # Get stream metadata
                tags = stream.get("tags", {})
                language = tags.get("language", "unknown")
                title = tags.get("title", "")
                handler = tags.get("handler_name", "")

                # Store stream info
                stream_info = {
                    "index": stream_index,
                    "language": language,
                    "title": title,
                    "handler": handler
                }
                audio_streams.append(stream_info)

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


def detect_subtitle_streams(input_file):
    """
    Detect subtitle streams in the input file using ffprobe

    Args:
        input_file: Input video file path

    Returns:
        A list of dictionaries containing subtitle stream information
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

        # Find all subtitle streams
        subtitle_streams = []
        for stream in data.get("streams", []):
            if stream.get("codec_type") == "subtitle":
                # Get stream index
                stream_index = stream.get("index")
                
                # Get stream metadata
                tags = stream.get("tags", {})
                language = tags.get("language", "unknown")
                title = tags.get("title", "")
                disposition = stream.get("disposition", {})
                is_default = disposition.get("default", 0) == 1
                is_forced = disposition.get("forced", 0) == 1

                # Store stream info
                stream_info = {
                    "index": stream_index,
                    "language": language,
                    "title": title,
                    "default": is_default,
                    "forced": is_forced
                }
                subtitle_streams.append(stream_info)

        return subtitle_streams

    except subprocess.CalledProcessError as e:
        print(f"Error detecting subtitle streams: {e}", file=sys.stderr)
        return []
    except json.JSONDecodeError:
        print("Error parsing ffprobe output", file=sys.stderr)
        return []
    except Exception as e:
        print(f"Unexpected error detecting subtitle streams: {e}", file=sys.stderr)
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
    if stream.get("handler", ""):
        info += f", handler: {stream['handler']}"
    if stream.get("default", False):
        info += ", default"
    if stream.get("forced", False):
        info += ", forced"

    return info


def print_audio_stream_info(stream):
    """
    Print audio stream information
    
    Args:
        stream: Audio stream object
    """
    print(f"Audio Stream: #{stream['index']}")
    if stream.get("language") and stream["language"] != "unknown":
        print(f"  Language: {stream['language']}")
    if stream.get("title"):
        print(f"  Title: {stream['title']}")
    if stream.get("handler"):
        print(f"  Handler: {stream['handler']}")


def print_subtitle_stream_info(stream):
    """
    Print subtitle stream information
    
    Args:
        stream: Subtitle stream object
    """
    print(f"Subtitle Stream: #{stream['index']}")
    if stream.get("language") and stream["language"] != "unknown":
        print(f"  Language: {stream['language']}")
    if stream.get("title"):
        print(f"  Title: {stream['title']}")
    if stream.get("default"):
        print(f"  Default: Yes")
    if stream.get("forced"):
        print(f"  Forced: Yes")


def convert_video(args, audio_stream, subtitle_stream=None):
    """
    Convert video files using ffmpeg

    Args:
        args: Parsed command line arguments
        audio_stream: Selected audio stream object
        subtitle_stream: Selected subtitle stream object (optional)
    """
    # Get parameters based on width
    if args.width not in PRESET_PARAMS:
        print(f"Error: Width {args.width} not found in presets")
        print("Available width presets:", ", ".join(str(w) for w in sorted(PRESET_PARAMS.keys())))
        sys.exit(1)

    params = PRESET_PARAMS[args.width]

    # Print conversion summary
    print("\n=== Conversion Summary ===")
    
    # Set and print audio stream information
    params.audio_stream = audio_stream["index"]
    print_audio_stream_info(audio_stream)

    # Set and print subtitle stream information if provided
    if subtitle_stream is not None:
        params.subtitle_stream = subtitle_stream["index"]
        print_subtitle_stream_info(subtitle_stream)

    # Set and print time range if provided
    params.start_time = args.start_time
    params.end_time = args.end_time
    if args.start_time is not None or args.end_time is not None:
        print("Time Range:")
        if args.start_time is not None:
            print(f"  Start: {args.start_time}")
        if args.end_time is not None:
            print(f"  End: {args.end_time}")

    # Store input file path for subtitle filter
    params.input_file = args.input_file

    # Override and print bitrate if custom value is provided
    if args.video_bitrate:
        params.video_bitrate = args.video_bitrate
        print(f"Custom Bitrate: {args.video_bitrate}")

    # Print video parameters
    print(f"Video Parameters: width={params.video_width}, bitrate={params.video_bitrate}, fps={params.fps}")

    # Determine output filename
    output_dir = f"output-{args.width}x"
    output = get_output_name(params, output_dir, args.input_file, args.output_file)
    # mkdir for the output_file if it doesn't exist
    os.makedirs(os.path.dirname(output), exist_ok=True)

    print(f"\nInput: {args.input_file}")
    print(f"Output: {output}")
    print("\nStarting conversion...")

    # Get ffmpeg command template and build the final command
    ffmpeg_template = get_ffmpeg_template(params)
    ffmpeg_cmd = ["ffmpeg", "-i", args.input_file] + ffmpeg_template + [output]

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
    parser.add_argument('--subtitle-stream', '-s', type=int, dest='subtitle_stream',
                        help='Subtitle stream index to embed (e.g., 2 for Stream #0:2)')
    parser.add_argument('--bitrate', '-b', dest='video_bitrate',
                        help='Override video bitrate (e.g., "200k", "1M")')
    parser.add_argument('--start-time', '-ss', dest='start_time',
                        help='Start time for conversion (format: HH:MM:SS or seconds, e.g., "00:01:30" or "90")')
    parser.add_argument('--end-time', '-to', dest='end_time',
                        help='End time for conversion (format: HH:MM:SS or seconds, e.g., "00:05:00" or "300")')

    # Parse arguments
    args = parser.parse_args()

    # Detect audio streams
    audio_streams = detect_audio_streams(args.input_file)

    if not audio_streams:
        print("No audio streams detected in the input file.")
        sys.exit(1)
    else:
        print(f"Found {len(audio_streams)} audio stream(s):")
        for stream in audio_streams:
            index = stream["index"]
            info = format_stream_info(stream)
            print(f"  [{index}] {info}")

    # Handle audio stream selection
    requested_audio_stream = args.audio_stream

    # Extract just the indices for easier comparison
    audio_stream_indices = [stream["index"] for stream in audio_streams]

    # If audio_stream is not provided, use the first one
    if requested_audio_stream is None:
        if len(audio_streams) == 1:
            selected_audio_stream = audio_streams[0]
            print(f"Using default audio stream:")
            print_audio_stream_info(selected_audio_stream)
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
        # Find the audio stream object with the requested index
        selected_audio_stream = next(stream for stream in audio_streams if stream["index"] == requested_audio_stream)
        print(f"Using specified audio stream:")
        print_audio_stream_info(selected_audio_stream)

    # Detect subtitle streams
    subtitle_streams = detect_subtitle_streams(args.input_file)
    selected_subtitle_stream = None

    # Handle subtitle stream selection
    if subtitle_streams:
        print(f"\nFound {len(subtitle_streams)} subtitle stream(s):")
        for stream in subtitle_streams:
            index = stream["index"]
            info = format_stream_info(stream)
            print(f"  [{index}] {info}")
            
        requested_subtitle_stream = args.subtitle_stream
        subtitle_stream_indices = [stream["index"] for stream in subtitle_streams]

        # Check if there's only one subtitle stream
        if len(subtitle_streams) == 1:
            # If no specific stream requested, use the only available one
            if requested_subtitle_stream is None:
                selected_subtitle_stream = subtitle_streams[0]
                print(f"Automatically using the only available subtitle stream:")
                print_subtitle_stream_info(selected_subtitle_stream)
            # If specific stream requested, check if it exists
            else:
                if requested_subtitle_stream not in subtitle_stream_indices:
                    print(f"Error: Specified subtitle stream {requested_subtitle_stream} not found in the input file.")
                    print(f"Available subtitle streams: {', '.join(map(str, subtitle_stream_indices))}")
                    sys.exit(1)
                else:
                    selected_subtitle_stream = next(stream for stream in subtitle_streams if stream["index"] == requested_subtitle_stream)
                    print(f"Using specified subtitle stream:")
                    print_subtitle_stream_info(selected_subtitle_stream)
        # Handle multiple subtitle streams
        else:
            # If no specific stream requested, ask user to specify
            if requested_subtitle_stream is None:
                print("Multiple subtitle streams detected. Please specify one with --subtitle-stream/-s option:")
                for stream in subtitle_streams:
                    index = stream["index"]
                    info = format_stream_info(stream)
                    print(f"  [{index}] {info}")

                print("\nExample usage:")
                print(f"  {sys.argv[0]} {args.width} \"{args.input_file}\" --subtitle-stream <STREAM_NUMBER>")
                sys.exit(1)
            # If specific stream requested, check if it exists
            else:
                if requested_subtitle_stream not in subtitle_stream_indices:
                    print(f"Error: Specified subtitle stream {requested_subtitle_stream} not found in the input file.")
                    print(f"Available subtitle streams: {', '.join(map(str, subtitle_stream_indices))}")
                    sys.exit(1)
                else:
                    selected_subtitle_stream = next(stream for stream in subtitle_streams if stream["index"] == requested_subtitle_stream)
                    print(f"Using specified subtitle stream:")
                    print_subtitle_stream_info(selected_subtitle_stream)

    # Convert video
    convert_video(args, selected_audio_stream, selected_subtitle_stream)


if __name__ == "__main__":
    main()
