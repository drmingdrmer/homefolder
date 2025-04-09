#!/usr/bin/env python
# coding: utf-8

import sys
import os
import pytest
import subprocess
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
    def test_detect_all_streams_errors(self, mock_run):
        """测试流检测中的错误处理"""
        # 测试subprocess异常
        mock_run.side_effect = subprocess.CalledProcessError(1, "ffprobe", "Error")
        with pytest.raises(ConversionError) as exc_info:
            StreamManager.detect_all_streams("test.mp4")
        assert "Failed to detect streams" in str(exc_info.value)
        
        # 测试JSON解析异常
        mock_result = MagicMock()
        mock_result.stdout = "invalid json"
        mock_run.side_effect = None
        mock_run.return_value = mock_result
        
        with pytest.raises(ConversionError) as exc_info:
            StreamManager.detect_all_streams("test.mp4")
        assert "Failed to parse ffprobe output" in str(exc_info.value)
    
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
    def test_stream_manager_initialization_no_video_fps(self, mock_run):
        """测试初始化时没有视频FPS信息的情况"""
        mock_result = MagicMock()
        mock_result.stdout = '''
        {
            "streams": [
                {
                    "index": 0,
                    "codec_type": "video",
                    "tags": {"language": "eng", "title": "Main Video"}
                },
                {
                    "index": 1,
                    "codec_type": "audio",
                    "tags": {"language": "eng", "title": "English Audio"}
                }
            ]
        }
        '''
        mock_run.return_value = mock_result
        
        with patch('builtins.print'):  # 屏蔽打印输出
            manager = StreamManager("test.mp4")
        
        # 验证视频FPS为None
        assert manager.original_fps is None
    
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
    def test_audio_stream_selection_no_audio(self, mock_run):
        """测试没有音频流的情况"""
        # 模拟没有音频流
        mock_result = MagicMock()
        mock_result.stdout = '''
        {
            "streams": [
                {"index": 0, "codec_type": "video", "r_frame_rate": "24/1"}
            ]
        }
        '''
        mock_run.return_value = mock_result
        
        with patch('builtins.print'):  # 屏蔽打印输出
            manager = StreamManager("test.mp4")
            
            # 应该抛出异常
            with pytest.raises(ConversionError) as exc_info:
                manager.select_audio_stream(show_available=False)
            
            assert "No audio streams detected" in str(exc_info.value)
    
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
    def test_subtitle_stream_selection_errors(self, mock_run):
        """测试字幕流选择中的错误情况"""
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
                }
            ]
        }
        '''
        mock_run.return_value = mock_result
        
        with patch('builtins.print'):  # 屏蔽打印输出
            manager = StreamManager("test.mp4")
            
            # 测试同时指定内嵌字幕和外部字幕
            # 会发出警告，但使用内嵌字幕
            selected = manager.select_subtitle_stream(
                stream_index=2,
                external_subtitle_file="subtitle.srt",
                show_available=False
            )
            assert selected.index == 2
            
            # 测试指定不存在的语言
            with pytest.raises(ConversionError) as exc_info:
                manager.select_subtitle_stream(language="fra", show_available=False)
            assert "No subtitle stream with language 'fra' found" in str(exc_info.value)
            
            # 测试指定不存在的标题
            with pytest.raises(ConversionError) as exc_info:
                manager.select_subtitle_stream(title="French", show_available=False)
            assert "No subtitle stream with title containing 'French' found" in str(exc_info.value)
            
            # 测试指定不存在的流索引
            with pytest.raises(ConversionError) as exc_info:
                manager.select_subtitle_stream(stream_index=5, show_available=False)
            assert "Specified subtitle stream 5 not found" in str(exc_info.value)
    
    @patch('subprocess.run')
    def test_subtitle_stream_selection_list_subtitles(self, mock_run):
        """测试列出字幕流的功能"""
        # 模拟字幕流
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
                }
            ]
        }
        '''
        mock_run.return_value = mock_result
        
        with patch('builtins.print'):  # 屏蔽打印输出
            manager = StreamManager("test.mp4")
            
            # 测试list_subtitles参数，应该抛出特殊的退出异常
            with pytest.raises(ConversionError) as exc_info:
                manager.select_subtitle_stream(list_subtitles=True, show_available=False)
            
            # 验证这是一个正常的退出（exit_code=0）
            assert exc_info.value.exit_code == 0
            assert "Listed available subtitle streams" in str(exc_info.value)
    
    @patch('subprocess.run')
    def test_subtitle_stream_selection_no_subtitles(self, mock_run):
        """测试没有字幕流的情况"""
        # 模拟没有字幕流
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
            
            # 没有指定字幕，应该返回None
            assert manager.select_subtitle_stream(show_available=False) is None
            
            # 指定了字幕但文件没有字幕流，应该抛出异常
            with pytest.raises(ConversionError) as exc_info:
                manager.select_subtitle_stream(stream_index=2, show_available=False)
            assert "No subtitle streams found in the input file" in str(exc_info.value)
    
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
    
    @patch('subprocess.run')
    def test_get_streams_methods(self, mock_run):
        """测试获取流的方法"""
        # 模拟多种类型流
        mock_result = MagicMock()
        mock_result.stdout = '''
        {
            "streams": [
                {"index": 0, "codec_type": "video", "r_frame_rate": "24/1"},
                {"index": 1, "codec_type": "video", "r_frame_rate": "30/1"},
                {"index": 2, "codec_type": "audio", "tags": {"language": "eng"}},
                {"index": 3, "codec_type": "audio", "tags": {"language": "jpn"}},
                {"index": 4, "codec_type": "subtitle", "tags": {"language": "eng"}},
                {"index": 5, "codec_type": "subtitle", "tags": {"language": "jpn"}}
            ]
        }
        '''
        mock_run.return_value = mock_result
        
        with patch('builtins.print'):  # 屏蔽打印输出
            manager = StreamManager("test.mp4")
            
            # 测试获取视频流
            video_streams = manager.get_video_streams()
            assert len(video_streams) == 2
            assert video_streams[0].index == 0
            assert video_streams[1].index == 1
            
            # 测试获取音频流
            audio_streams = manager.get_audio_streams()
            assert len(audio_streams) == 2
            assert audio_streams[0].index == 2
            assert audio_streams[1].index == 3
            
            # 测试获取字幕流
            subtitle_streams = manager.get_subtitle_streams()
            assert len(subtitle_streams) == 2
            assert subtitle_streams[0].index == 4
            assert subtitle_streams[1].index == 5
    
    def test_print_subsection_header(self, capsys):
        """测试小节标题打印函数"""
        from stream_manager import print_subsection_header
        
        print_subsection_header("Test Header")
        captured = capsys.readouterr()
        
        assert "\nTest Header" in captured.out
        assert "-----------" in captured.out


if __name__ == "__main__":
    pytest.main(["-xvs", __file__]) 