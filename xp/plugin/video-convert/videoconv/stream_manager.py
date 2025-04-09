#!/usr/bin/env python
# coding: utf-8

import subprocess
import json
import sys

# 导入自己包内的模块
from videoconv.stream_info import StreamInfo
from videoconv.exceptions import ConversionError

def print_subsection_header(title):
    """Print a subsection header with a line separator"""
    print(f"\n{title}")
    print("-" * len(title))


class StreamManager:
    """
    Class to manage media file streams detection and selection
    """
    def __init__(self, input_file):
        self.input_file = input_file
        self.all_streams = []
        self.audio_streams = []
        self.subtitle_streams = []
        self.selected_audio_stream = None
        self.selected_subtitle_stream = None
        self.subtitle_languages = set()
        self.subtitle_titles = set()
        self.subtitle_indices = []
        self.original_fps = None
        
        self._detect_streams()
        
    def _detect_streams(self):
        """
        Detect all streams in the input file
        """
        self.all_streams = self.detect_all_streams(self.input_file)
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
    
    @staticmethod
    def detect_all_streams(input_file):
        """
        Detect all streams in a media file using ffprobe
        """
        cmd = [
            "ffprobe",
            "-v", "quiet",
            "-print_format", "json",
            "-show_streams",
            input_file
        ]
        try:
            result = subprocess.run(cmd, check=True, capture_output=True, text=True)
            data = json.loads(result.stdout)
            return [StreamInfo(stream_data) for stream_data in data.get("streams", [])]
        except subprocess.CalledProcessError as e:
            raise ConversionError(f"Failed to detect streams: {e}")
        except json.JSONDecodeError as e:
            raise ConversionError(f"Failed to parse ffprobe output: {e}")
    
    def select_audio_stream(self, stream_index=None, show_available=True):
        """
        Select an audio stream based on index
        
        Args:
            stream_index: The index of the audio stream to select
            show_available: Whether to show available streams if selection failed
            
        Returns:
            The selected audio stream
            
        Raises:
            ConversionError: If no audio stream is found or selection failed
        """
        audio_stream_indices = [stream.index for stream in self.audio_streams]
        
        if not self.audio_streams:
            raise ConversionError("No audio streams detected in the input file.")
            
        if stream_index is None:
            if len(self.audio_streams) == 1:
                self.selected_audio_stream = self.audio_streams[0]
                print_subsection_header("Selected Audio Stream")
                print(f"Stream #{self.selected_audio_stream.index}")
                print(self.selected_audio_stream.get_audio_info())
                return self.selected_audio_stream
            else:
                if show_available:
                    print_subsection_header("Available Audio Streams")
                    for stream in self.audio_streams:
                        print(f"Stream #{stream.index}")
                        print(stream.get_audio_info())
                        print()

                    print("\nExample usage:")
                    print(f"  {sys.argv[0]} <width> \"{self.input_file}\" --audio-stream <STREAM_NUMBER>")
                raise ConversionError("Please specify an audio stream to use.")
        elif stream_index not in audio_stream_indices:
            error_msg = f"Specified audio stream {stream_index} not found in the input file. Available audio streams: {', '.join(map(str, audio_stream_indices))}"
            raise ConversionError(error_msg)
        else:
            self.selected_audio_stream = next(stream for stream in self.audio_streams if stream.index == stream_index)
            print_subsection_header("Selected Audio Stream")
            print(f"Stream #{self.selected_audio_stream.index}")
            print(self.selected_audio_stream.get_audio_info())
            return self.selected_audio_stream
    
    def select_subtitle_stream(self, stream_index=None, language=None, title=None, external_subtitle_file=None, list_subtitles=False, show_available=True):
        """
        Select a subtitle stream based on index, language, or title
        
        Args:
            stream_index: The index of the subtitle stream to select
            language: The language of the subtitle stream to select
            title: The title of the subtitle stream to select
            external_subtitle_file: Path to external subtitle file
            list_subtitles: Whether to list available subtitles and exit
            show_available: Whether to show available streams
            
        Returns:
            The selected subtitle stream or None if no subtitle is selected
            
        Raises:
            ConversionError: If subtitle selection failed
        """
        self.selected_subtitle_stream = None
        
        # Check if both embedded and external subtitles were specified
        if (stream_index is not None or language is not None or title is not None) and external_subtitle_file is not None:
            print("\nWarning: Both embedded and external subtitles were specified.")
            print("Embedded subtitles will be used. External subtitle file will be ignored.")
            external_subtitle_file = None
        
        if not self.subtitle_streams:
            if stream_index is not None or language is not None or title is not None:
                raise ConversionError("No subtitle streams found in the input file, but subtitle selection was requested.")
            else:
                print("No subtitle streams found in the input file.")
                return None
        
        if list_subtitles:
            print_subsection_header("Available Subtitle Streams")
            print("Index | Language | Title | Default | Forced")
            print("-" * 60)
            for stream in self.subtitle_streams:
                default = "Yes" if stream.default else "No"
                forced = "Yes" if stream.forced else "No"
                print(f"{stream.index:5} | {stream.language:8} | {stream.title:20} | {default:7} | {forced}")
            # Special case: with list_subtitles, we want to exit with code 0
            raise ConversionError("Listed available subtitle streams.", exit_code=0)
        
        if show_available:
            print_subsection_header("Available Subtitle Streams")
            for stream in self.subtitle_streams:
                print(f"Stream #{stream.index}")
                print(stream.get_subtitle_info())
                print()
        
        if language is not None:
            language_matches = [s for s in self.subtitle_streams if s.language.lower() == language.lower()]
            if language_matches:
                self.selected_subtitle_stream = language_matches[0]
                print_subsection_header("Selected Subtitle Stream")
                print(f"Stream #{self.selected_subtitle_stream.index}")
                print(self.selected_subtitle_stream.get_subtitle_info())
            else:
                available_langs = ', '.join(self.subtitle_languages)
                error_msg = f"No subtitle stream with language '{language}' found. Available subtitle languages: {available_langs}"
                raise ConversionError(error_msg)
        elif title is not None:
            title_matches = [s for s in self.subtitle_streams if title.lower() in s.title.lower()]
            if title_matches:
                self.selected_subtitle_stream = title_matches[0]
                print_subsection_header("Selected Subtitle Stream")
                print(f"Stream #{self.selected_subtitle_stream.index}")
                print(self.selected_subtitle_stream.get_subtitle_info())
            else:
                available_titles = ', '.join(self.subtitle_titles)
                error_msg = f"No subtitle stream with title containing '{title}' found. Available subtitle titles: {available_titles}"
                raise ConversionError(error_msg)
        elif stream_index is not None:
            if stream_index not in self.subtitle_indices:
                available_streams = ', '.join(map(str, self.subtitle_indices))
                error_msg = f"Specified subtitle stream {stream_index} not found in the input file. Available subtitle streams: {available_streams}"
                raise ConversionError(error_msg)
            else:
                self.selected_subtitle_stream = next(stream for stream in self.subtitle_streams if stream.index == stream_index)
                print_subsection_header("Selected Subtitle Stream")
                print(f"Stream #{self.selected_subtitle_stream.index}")
                print(self.selected_subtitle_stream.get_subtitle_info())
        else:
            print("No subtitle stream specified. Subtitles will not be included.")
        
        return self.selected_subtitle_stream
    
    def calculate_subtitle_relative_index(self, absolute_index):
        """
        Calculate the relative subtitle index for ffmpeg subtitle filter
        
        Args:
            absolute_index: The absolute stream index
            
        Returns:
            The relative index (0-based within subtitle streams)
        """
        sorted_streams = sorted(self.subtitle_streams, key=lambda s: s.index)
        
        for i, stream in enumerate(sorted_streams):
            if stream.index == absolute_index:
                return i
        
        return 0
    
    def get_video_streams(self):
        """Get all video streams"""
        return [s for s in self.all_streams if s.codec_type == "video"]
    
    def get_audio_streams(self):
        """Get all audio streams"""
        return self.audio_streams
    
    def get_subtitle_streams(self):
        """Get all subtitle streams"""
        return self.subtitle_streams 