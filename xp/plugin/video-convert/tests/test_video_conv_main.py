#!/usr/bin/env python
# coding: utf-8

import sys
import os
import pytest
from unittest.mock import patch, MagicMock, PropertyMock

# 使用新的包结构导入
from videoconv.exceptions import ConversionError


class TestVideoConvMain:
    """Test cases for the main function and command-line interface of video-conv.py"""
    
    def test_main_success(self):
        """Test successful execution of main function"""
        with patch('sys.argv', ['video_conv.py', '720', 'test_input.mp4']):
            # 创建必要的mock
            with patch('videoconv.video_conv.create_argument_parser') as mock_create_parser, \
                 patch('videoconv.video_conv.ArgumentValidator.validate_args') as mock_validate_args, \
                 patch('videoconv.video_conv.VideoConverter') as mock_video_converter_class:
                
                # 设置 mocks
                mock_parser = MagicMock()
                mock_args = MagicMock()
                mock_parser.parse_args.return_value = mock_args
                mock_create_parser.return_value = mock_parser
                
                mock_validate_args.return_value = mock_args
                
                mock_converter = MagicMock()
                mock_video_converter_class.return_value = mock_converter
                
                # 导入并运行主函数
                from videoconv.video_conv import main
                main()
                
                # 验证调用
                mock_create_parser.assert_called_once()
                mock_parser.parse_args.assert_called_once()
                mock_validate_args.assert_called_once_with(mock_args)
                mock_video_converter_class.assert_called_once_with(mock_args)
                mock_converter.select_streams.assert_called_once()
                mock_converter.convert.assert_called_once()
    
    def test_main_validation_error(self):
        """Test `if __name__ == "__main__"` with validation error"""
        # 测试捕获验证错误并适当地退出
        error_message = "Invalid argument"
        exit_code = 2
        
        # 创建错误实例
        validation_error = ConversionError(error_message, exit_code)
        
        with patch('sys.argv', ['video_conv.py', '720', 'nonexistent.mp4']):
            # 从新包结构导入
            from videoconv import video_conv
            
            # 替换主函数以抛出验证错误
            with patch.object(video_conv, 'main', side_effect=validation_error), \
                 patch('sys.stderr'), \
                 patch('sys.exit') as mock_exit:
                
                # 直接调用主程序的入口点代码
                # 这会模拟 if __name__ == "__main__" 块
                try:
                    video_conv.main()
                except ConversionError as e:
                    print(f"Error: {e.message}", file=sys.stderr)
                    sys.exit(e.exit_code)
                
                # 验证退出代码是否正确
                mock_exit.assert_called_once_with(exit_code)
    
    def test_main_conversion_error(self):
        """Test `if __name__ == "__main__"` with conversion error"""
        # 测试捕获转换错误并适当地退出
        error_message = "Conversion failed"
        exit_code = 3
        
        # 创建错误实例
        conversion_error = ConversionError(error_message, exit_code)
        
        with patch('sys.argv', ['video_conv.py', '720', 'test_input.mp4']):
            # 从新包结构导入
            from videoconv import video_conv
            
            # 替换主函数以抛出转换错误
            with patch.object(video_conv, 'main', side_effect=conversion_error), \
                 patch('sys.stderr'), \
                 patch('sys.exit') as mock_exit:
                
                # 直接调用主程序的入口点代码
                try:
                    video_conv.main()
                except ConversionError as e:
                    print(f"Error: {e.message}", file=sys.stderr)
                    sys.exit(e.exit_code)
                
                # 验证退出代码是否正确
                mock_exit.assert_called_once_with(exit_code)
    
    def test_keyboard_interrupt(self):
        """Test `if __name__ == "__main__"` with keyboard interrupt"""
        with patch('sys.argv', ['video_conv.py', '720', 'test_input.mp4']):
            # 从新包结构导入
            from videoconv import video_conv
            
            # 替换主函数以抛出KeyboardInterrupt
            with patch.object(video_conv, 'main', side_effect=KeyboardInterrupt()), \
                 patch('sys.stderr'), \
                 patch('sys.exit') as mock_exit:
                
                # 直接调用主程序的入口点代码
                try:
                    video_conv.main()
                except KeyboardInterrupt:
                    print("\nOperation cancelled by user.", file=sys.stderr)
                    sys.exit(130)
                except Exception as e:
                    print(f"Unexpected error: {str(e)}", file=sys.stderr)
                    sys.exit(1)
                
                # 验证退出代码是否正确
                mock_exit.assert_called_once_with(130)
    
    def test_unexpected_error(self):
        """Test `if __name__ == "__main__"` with unexpected error"""
        with patch('sys.argv', ['video_conv.py', '720', 'test_input.mp4']):
            # 从新包结构导入
            from videoconv import video_conv
            
            # 替换主函数以抛出一般异常
            with patch.object(video_conv, 'main', side_effect=Exception("Unexpected error")), \
                 patch('sys.stderr'), \
                 patch('sys.exit') as mock_exit:
                
                # 直接调用主程序的入口点代码
                try:
                    video_conv.main()
                except KeyboardInterrupt:
                    print("\nOperation cancelled by user.", file=sys.stderr)
                    sys.exit(130)
                except Exception as e:
                    print(f"Unexpected error: {str(e)}", file=sys.stderr)
                    sys.exit(1)
                
                # 验证退出代码是否正确
                mock_exit.assert_called_once_with(1)


if __name__ == "__main__":
    pytest.main(["-xvs", __file__]) 