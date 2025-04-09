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
        lines = []
        if self.language != "unknown":
            lines.append(f"Language: {self.language}")
        if self.title:
            lines.append(f"Title: {self.title}")
        if self.handler:
            lines.append(f"Handler: {self.handler}")
        return "\n".join(lines)

    def get_subtitle_info(self):
        """
        Get formatted subtitle stream information
        """
        lines = []
        if self.language != "unknown":
            lines.append(f"Language: {self.language}")
        if self.title:
            lines.append(f"Title: {self.title}")
        if self.default:
            lines.append("Default: Yes")
        if self.forced:
            lines.append("Forced: Yes")
        return "\n".join(lines) 