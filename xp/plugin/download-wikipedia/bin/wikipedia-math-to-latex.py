#!/usr/bin/env python3
# coding: utf-8

import sys
from bs4 import BeautifulSoup
from bs4 import Comment
import re

def convert_math_to_latex(html_content):
    soup = BeautifulSoup(html_content, 'html.parser')

    # 删除HTML注释
    comments = soup.find_all(string=lambda text: isinstance(text, Comment))
    for comment in comments:
        comment.extract()

    # 删除display: none的span标签
    hidden_spans = soup.find_all('span', style=lambda value: value and 'display: none' in value)
    for span in hidden_spans:
        span.decompose()

    # 删除navbox div
    navboxes = soup.find_all('div', class_='navbox')
    for navbox in navboxes:
        navbox.decompose()

    navboxes = soup.find_all('div', class_='navbox-styles')
    for navbox in navboxes:
        navbox.decompose()

    # 删除 编辑 按钮
    edit_links = soup.find_all('span', class_='mw-editsection')
    for navbox in edit_links:
        navbox.decompose()

    # 处理texhtml的span标签
    texhtml_spans = soup.find_all('span', class_='texhtml')
    for span in texhtml_spans:
        text = span.get_text().strip()
        span.replace_with(f'`{text}`')

    # 去掉i标签
    i_spans = soup.find_all('i')
    for span in i_spans:
        text = span.get_text().strip()
        span.replace_with(f'{text}')

    # 替换站内链接
    links = soup.find_all('a')
    for link in links:
        href = link.get('href', '')
        # 检查是否是站内链接 (/wiki/ 开头)
        # 页面不存在链接: /w/index.php?***
        if href.startswith('/wiki/') or href.startswith('/w/index.php'):
            # 获取链接文本
            link_text = link.get_text()
            # 替换链接为[[text]]格式
            link.replace_with(f'[[{link_text}]]')

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
            text = latex.group(1).strip()
            latex_text = f'${text}$'
            # 替换原始的img标签
            img.replace_with(latex_text)

    html_content_2 = soup.prettify()
    soup = BeautifulSoup(html_content_2, 'html.parser')

    # 自定义格式化函数
    def formatter(text, **kwargs):
        if text:
            # 移除文本中的换行符，但保留前后的空白
            return text.strip('\n')
        return text

    # 返回转换后的文本，使用自定义formatter
    return soup.prettify(formatter=formatter)
    # 返回转换后的文本
    return soup.prettify(formatter='html5')

fn = sys.argv[1]
with open(fn, 'r') as f:
    html_content = f.read()

converted_text = convert_math_to_latex(html_content)
output_fn = sys.argv[2]
with open(output_fn, 'w') as f:
    f.write(converted_text)
