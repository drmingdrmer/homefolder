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