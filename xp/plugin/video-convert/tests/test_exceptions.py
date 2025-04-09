#!/usr/bin/env python
# coding: utf-8

import sys
import os
import pytest

# 添加项目根目录到Python路径，以便测试能够导入模块
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '../bin')))

from exceptions import ConversionError


class TestConversionError:
    """ConversionError类的测试用例"""

    def test_initialization_with_defaults(self):
        """测试使用默认参数初始化"""
        error = ConversionError("Test error message")
        
        # 验证属性
        assert error.message == "Test error message"
        assert error.exit_code == 1
        
        # 验证作为异常的行为
        assert str(error) == "Test error message"
        
        # 验证继承性
        assert isinstance(error, Exception)

    def test_initialization_with_custom_exit_code(self):
        """测试使用自定义退出码初始化"""
        error = ConversionError("Error with custom exit code", exit_code=5)
        
        # 验证属性
        assert error.message == "Error with custom exit code"
        assert error.exit_code == 5

    def test_raising_and_catching(self):
        """测试抛出和捕获异常"""
        try:
            raise ConversionError("Test raising error", exit_code=2)
            assert False, "异常应该被抛出"
        except ConversionError as e:
            assert e.message == "Test raising error"
            assert e.exit_code == 2

    def test_message_formatting(self):
        """测试消息格式化"""
        # 格式化字符串
        width = 720
        error = ConversionError(f"Invalid width: {width}")
        assert error.message == "Invalid width: 720"
        
        # 多行消息
        multiline_message = "Line 1\nLine 2\nLine 3"
        error = ConversionError(multiline_message)
        assert error.message == multiline_message
        assert str(error) == multiline_message
    
    def test_zero_exit_code(self):
        """测试退出码为0的情况 (正常退出)"""
        error = ConversionError("Informational message", exit_code=0)
        assert error.exit_code == 0
        assert error.message == "Informational message"


if __name__ == "__main__":
    pytest.main(["-xvs", __file__]) 