#!/usr/bin/env python3
# coding: utf-8

import sys
from bs4 import BeautifulSoup
import re

def convert_math_to_latex(html_content):
    soup = BeautifulSoup(html_content, 'html.parser')

    # 删除display: none的span标签
    hidden_spans = soup.find_all('span', style=lambda value: value and 'display: none' in value)
    for span in hidden_spans:
        span.decompose()

    # 找到所有img标签
    img_elements = soup.find_all('img')

    # 替换每个img标签
    for img in img_elements:
        alttext = img.get('alt', '')
        #  print(alttext)
        # 提取LaTeX表达式，使用转义的花括号
        latex = re.search(r'\{\\displaystyle (.*)\}', alttext)
        #  print(latex)
        if latex:
            # 用$包围LaTeX表达式
            latex_text = f'${latex.group(1)}$'
            # 替换原始的img标签
            img.replace_with(latex_text)

    # 返回转换后的文本
    return str(soup)

fn = sys.argv[1]
with open(fn, 'r') as f:
    html_content = f.read()

converted_text = convert_math_to_latex(html_content)
output_fn = sys.argv[2]
with open(output_fn, 'w') as f:
    f.write(converted_text)
