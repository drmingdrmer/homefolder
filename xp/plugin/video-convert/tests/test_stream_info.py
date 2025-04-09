#!/usr/bin/env python
# coding: utf-8

import sys
import os
import pytest

# 添加项目根目录到Python路径，以便测试能够导入模块
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '../bin')))

from stream_info import StreamInfo


class TestStreamInfo:
    """StreamInfo类的测试用例"""

    def test_video_stream_initialization(self):
        """测试视频流信息的初始化"""
        # 创建模拟视频流数据
        video_data = {
            "index": 0,
            "codec_type": "video",
            "r_frame_rate": "24/1",
            "tags": {
                "language": "eng",
                "title": "Main Video"
            }
        }
        
        # 初始化StreamInfo对象
        stream_info = StreamInfo(video_data)
        
        # 验证基本属性
        assert stream_info.index == 0
        assert stream_info.codec_type == "video"
        assert stream_info.language == "eng"
        assert stream_info.title == "Main Video"
        
        # 验证视频特有属性
        assert stream_info.fps == 24.0
        
        # 验证其他属性的默认值
        assert stream_info.handler is None
        assert not stream_info.default
        assert not stream_info.forced

    def test_audio_stream_initialization(self):
        """测试音频流信息的初始化"""
        # 创建模拟音频流数据
        audio_data = {
            "index": 1,
            "codec_type": "audio",
            "tags": {
                "language": "jpn",
                "title": "Japanese Audio",
                "handler_name": "SoundHandler"
            }
        }
        
        # 初始化StreamInfo对象
        stream_info = StreamInfo(audio_data)
        
        # 验证基本属性
        assert stream_info.index == 1
        assert stream_info.codec_type == "audio"
        assert stream_info.language == "jpn"
        assert stream_info.title == "Japanese Audio"
        
        # 验证音频特有属性
        assert stream_info.handler == "SoundHandler"
        
        # 验证其他属性的默认值
        assert stream_info.fps is None
        assert not stream_info.default
        assert not stream_info.forced

    def test_subtitle_stream_initialization(self):
        """测试字幕流信息的初始化"""
        # 创建模拟字幕流数据
        subtitle_data = {
            "index": 2,
            "codec_type": "subtitle",
            "tags": {
                "language": "chi",
                "title": "Chinese Subtitles"
            },
            "disposition": {
                "default": 1,
                "forced": 0
            }
        }
        
        # 初始化StreamInfo对象
        stream_info = StreamInfo(subtitle_data)
        
        # 验证基本属性
        assert stream_info.index == 2
        assert stream_info.codec_type == "subtitle"
        assert stream_info.language == "chi"
        assert stream_info.title == "Chinese Subtitles"
        
        # 验证字幕特有属性
        assert stream_info.default is True
        assert stream_info.forced is False
        
        # 验证其他属性的默认值
        assert stream_info.handler is None
        assert stream_info.fps is None

    def test_missing_data_handling(self):
        """测试处理缺失数据的情况"""
        # 创建最小数据集
        minimal_data = {
            "index": 3,
            "codec_type": "unknown"
        }
        
        # 初始化StreamInfo对象
        stream_info = StreamInfo(minimal_data)
        
        # 验证默认值
        assert stream_info.index == 3
        assert stream_info.codec_type == "unknown"
        assert stream_info.language == "unknown"
        assert stream_info.title == ""
        assert stream_info.handler is None
        assert stream_info.fps is None
        assert not stream_info.default
        assert not stream_info.forced

    def test_invalid_fps_handling(self):
        """测试处理无效FPS数据的情况"""
        # 测试除以零的情况
        zero_den_data = {
            "index": 0,
            "codec_type": "video",
            "r_frame_rate": "24/0"
        }
        
        stream_info = StreamInfo(zero_den_data)
        assert stream_info.fps is None
        
        # 测试格式错误的情况
        invalid_format_data = {
            "index": 0,
            "codec_type": "video",
            "r_frame_rate": "invalid"
        }
        
        stream_info = StreamInfo(invalid_format_data)
        assert stream_info.fps is None

    def test_string_representation(self):
        """测试字符串表示方法"""
        # 测试完整信息
        full_data = {
            "index": 2,
            "codec_type": "subtitle",
            "tags": {
                "language": "eng",
                "title": "English"
            },
            "disposition": {
                "default": 1,
                "forced": 1
            }
        }
        
        stream_info = StreamInfo(full_data)
        string_repr = str(stream_info)
        assert "language: eng" in string_repr
        assert "title: English" in string_repr
        assert "default" in string_repr
        assert "forced" in string_repr
        
        # 测试最小信息
        minimal_data = {
            "index": 0,
            "codec_type": "video"
        }
        
        stream_info = StreamInfo(minimal_data)
        assert str(stream_info) == "unknown"

    def test_get_audio_info(self):
        """测试获取格式化的音频信息"""
        audio_data = {
            "index": 1,
            "codec_type": "audio",
            "tags": {
                "language": "eng",
                "title": "English Audio",
                "handler_name": "AudioHandler"
            }
        }
        
        stream_info = StreamInfo(audio_data)
        audio_info = stream_info.get_audio_info()
        
        assert "Language: eng" in audio_info
        assert "Title: English Audio" in audio_info
        assert "Handler: AudioHandler" in audio_info
        
        # 测试最小信息
        minimal_audio_data = {
            "index": 1,
            "codec_type": "audio"
        }
        
        stream_info = StreamInfo(minimal_audio_data)
        assert stream_info.get_audio_info() == ""

    def test_get_subtitle_info(self):
        """测试获取格式化的字幕信息"""
        subtitle_data = {
            "index": 2,
            "codec_type": "subtitle",
            "tags": {
                "language": "spa",
                "title": "Spanish Subtitles"
            },
            "disposition": {
                "default": 1,
                "forced": 1
            }
        }
        
        stream_info = StreamInfo(subtitle_data)
        subtitle_info = stream_info.get_subtitle_info()
        
        assert "Language: spa" in subtitle_info
        assert "Title: Spanish Subtitles" in subtitle_info
        assert "Default: Yes" in subtitle_info
        assert "Forced: Yes" in subtitle_info
        
        # 测试最小信息
        minimal_subtitle_data = {
            "index": 2,
            "codec_type": "subtitle"
        }
        
        stream_info = StreamInfo(minimal_subtitle_data)
        assert stream_info.get_subtitle_info() == ""


if __name__ == "__main__":
    pytest.main(["-xvs", __file__]) 