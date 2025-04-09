#!/usr/bin/env python
# coding: utf-8

import sys
import os
import pytest
from unittest.mock import patch, MagicMock

# 添加项目根目录到Python路径，以便测试能够导入模块
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '../bin')))

from stream_manager import StreamManager
from stream_info import StreamInfo
from exceptions import ConversionError


class TestStreamManager:
    """StreamManager类的测试用例"""
    
    @patch('subprocess.run')
    def test_detect_all_streams(self, mock_run):
        """测试流检测功能"""
        # 模拟ffprobe输出JSON数据
        mock_result = MagicMock()
        mock_result.stdout = '''
        {
            "streams": [
                {
                    "index": 0,
                    "codec_type": "video", 
                    "r_frame_rate": "24/1",
                    "tags": {"language": "eng", "title": "Main Video"}
                },
                {
                    "index": 1,
                    "codec_type": "audio",
                    "tags": {"language": "eng", "title": "English Audio"}
                },
                {
                    "index": 2,
                    "codec_type": "subtitle",
                    "tags": {"language": "eng", "title": "English Subtitles"},
                    "disposition": {"default": 1, "forced": 0}
                }
            ]
        }
        '''
        mock_run.return_value = mock_result
        
        # 测试静态方法
        streams = StreamManager.detect_all_streams("test.mp4")
        
        # 验证结果
        assert len(streams) == 3
        assert streams[0].codec_type == "video"
        assert streams[1].codec_type == "audio"
        assert streams[2].codec_type == "subtitle"
    
    @patch('subprocess.run')
    def test_stream_manager_initialization(self, mock_run):
        """测试StreamManager初始化和流分类"""
        # 模拟ffprobe输出
        mock_result = MagicMock()
        mock_result.stdout = '''
        {
            "streams": [
                {
                    "index": 0,
                    "codec_type": "video", 
                    "r_frame_rate": "24/1",
                    "tags": {"language": "eng", "title": "Main Video"}
                },
                {
                    "index": 1,
                    "codec_type": "audio",
                    "tags": {"language": "eng", "title": "English Audio"}
                },
                {
                    "index": 2,
                    "codec_type": "audio",
                    "tags": {"language": "jpn", "title": "Japanese Audio"}
                },
                {
                    "index": 3,
                    "codec_type": "subtitle",
                    "tags": {"language": "eng", "title": "English Subtitles"},
                    "disposition": {"default": 1, "forced": 0}
                },
                {
                    "index": 4,
                    "codec_type": "subtitle",
                    "tags": {"language": "jpn", "title": "Japanese Subtitles"},
                    "disposition": {"default": 0, "forced": 0}
                }
            ]
        }
        '''
        mock_run.return_value = mock_result
        
        with patch('builtins.print'):  # 屏蔽打印输出
            manager = StreamManager("test.mp4")
        
        # 验证流分类
        assert len(manager.all_streams) == 5
        assert len(manager.audio_streams) == 2
        assert len(manager.subtitle_streams) == 2
        assert manager.original_fps == 24.0
        assert manager.subtitle_languages == {"eng", "jpn"}
        assert "English Subtitles" in manager.subtitle_titles
        assert "Japanese Subtitles" in manager.subtitle_titles
        assert manager.subtitle_indices == [3, 4]
    
    @patch('subprocess.run')
    def test_audio_stream_selection_auto(self, mock_run):
        """测试自动选择单个音频流"""
        # 模拟只有一个音频流
        mock_result = MagicMock()
        mock_result.stdout = '''
        {
            "streams": [
                {"index": 0, "codec_type": "video", "r_frame_rate": "24/1"},
                {"index": 1, "codec_type": "audio", "tags": {"language": "eng"}}
            ]
        }
        '''
        mock_run.return_value = mock_result
        
        with patch('builtins.print'):  # 屏蔽打印输出
            manager = StreamManager("test.mp4")
            selected = manager.select_audio_stream(show_available=False)
        
        assert selected is not None
        assert selected.index == 1
        assert selected.codec_type == "audio"
        assert selected.language == "eng"
    
    @patch('subprocess.run')
    def test_audio_stream_selection_manual(self, mock_run):
        """测试手动选择音频流"""
        # 模拟多个音频流
        mock_result = MagicMock()
        mock_result.stdout = '''
        {
            "streams": [
                {"index": 0, "codec_type": "video", "r_frame_rate": "24/1"},
                {"index": 1, "codec_type": "audio", "tags": {"language": "eng"}},
                {"index": 2, "codec_type": "audio", "tags": {"language": "jpn"}}
            ]
        }
        '''
        mock_run.return_value = mock_result
        
        with patch('builtins.print'):  # 屏蔽打印输出
            manager = StreamManager("test.mp4")
            
            # 测试选择指定的流
            selected = manager.select_audio_stream(stream_index=2, show_available=False)
            assert selected.index == 2
            assert selected.language == "jpn"
            
            # 测试选择不存在的流
            with pytest.raises(ConversionError):
                manager.select_audio_stream(stream_index=3, show_available=False)
            
            # 测试不指定流(多个音频流的情况)
            with pytest.raises(ConversionError):
                manager.select_audio_stream(show_available=False)
    
    @patch('subprocess.run')
    def test_subtitle_stream_selection(self, mock_run):
        """测试字幕流选择"""
        # 模拟多语言字幕
        mock_result = MagicMock()
        mock_result.stdout = '''
        {
            "streams": [
                {"index": 0, "codec_type": "video", "r_frame_rate": "24/1"},
                {"index": 1, "codec_type": "audio", "tags": {"language": "eng"}},
                {
                    "index": 2, 
                    "codec_type": "subtitle", 
                    "tags": {"language": "eng", "title": "English"}, 
                    "disposition": {"default": 1, "forced": 0}
                },
                {
                    "index": 3, 
                    "codec_type": "subtitle", 
                    "tags": {"language": "jpn", "title": "Japanese"}, 
                    "disposition": {"default": 0, "forced": 0}
                }
            ]
        }
        '''
        mock_run.return_value = mock_result
        
        with patch('builtins.print'):  # 屏蔽打印输出
            manager = StreamManager("test.mp4")
            
            # 按索引选择
            selected = manager.select_subtitle_stream(stream_index=3, show_available=False)
            assert selected.index == 3
            assert selected.language == "jpn"
            
            # 按语言选择
            selected = manager.select_subtitle_stream(language="eng", show_available=False)
            assert selected.index == 2
            assert selected.language == "eng"
            
            # 按标题选择
            selected = manager.select_subtitle_stream(title="Japan", show_available=False)
            assert selected.index == 3
            assert selected.language == "jpn"
            
            # 不选择字幕
            selected = manager.select_subtitle_stream(show_available=False)
            assert selected is None
    
    @patch('subprocess.run')
    def test_calculate_subtitle_relative_index(self, mock_run):
        """测试字幕相对索引计算"""
        # 模拟多个字幕流，索引不连续
        mock_result = MagicMock()
        mock_result.stdout = '''
        {
            "streams": [
                {"index": 0, "codec_type": "video"},
                {"index": 1, "codec_type": "audio"},
                {"index": 2, "codec_type": "subtitle", "tags": {"language": "eng"}},
                {"index": 4, "codec_type": "subtitle", "tags": {"language": "jpn"}},
                {"index": 7, "codec_type": "subtitle", "tags": {"language": "chi"}}
            ]
        }
        '''
        mock_run.return_value = mock_result
        
        with patch('builtins.print'):  # 屏蔽打印输出
            manager = StreamManager("test.mp4")
            
            # 验证相对索引计算
            assert manager.calculate_subtitle_relative_index(2) == 0  # 第一个字幕
            assert manager.calculate_subtitle_relative_index(4) == 1  # 第二个字幕
            assert manager.calculate_subtitle_relative_index(7) == 2  # 第三个字幕
            
            # 验证不存在的索引
            assert manager.calculate_subtitle_relative_index(999) == 0


if __name__ == "__main__":
    pytest.main(["-xvs", __file__]) 