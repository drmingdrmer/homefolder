#!/usr/bin/env python3
# coding: utf-8

import sys
import os
import re
import requests
from urllib.parse import quote
from urllib.parse import unquote
from bs4 import BeautifulSoup
from bs4 import Comment


def get_wiki_content(parsed_url):
    url = "https://{lang}.wikipedia.org/w/api.php?format=json&action=parse&format=json&prop=displaytitle|text&variant=zh-hans&page={escaped_title}".format(**parsed_url)

    # requests will automatically use proxy settings from environment variables
    # including http_proxy, https_proxy, all_proxy
    response = requests.get(url, timeout=30)
    response.raise_for_status()  # Check response status
    return response.json()

def parse_url(url: str):
    g = re.search(r'https://(.*?).wikipedia.org/wiki/(.*)', url)
    if g:
        lang = g.group(1)
        escaped_title = g.group(2)
        title = unquote(escaped_title)
    else:
        raise ValueError("invalid wikipedia url: " + url)

    return {"lang": lang,
            "title": title,
            "escaped_title": escaped_title,
    }

def convert_math_to_latex(html_content):
    soup = BeautifulSoup(html_content, 'html.parser')

    # Remove HTML comments
    comments = soup.find_all(string=lambda text: isinstance(text, Comment))
    for comment in comments:
        comment.extract()

    # Remove span tags with display: none
    hidden_spans = soup.find_all('span', style=lambda value: value and 'display: none' in value)
    for span in hidden_spans:
        span.decompose()

    # Remove navbox divs
    navboxes = soup.find_all('div', class_='navbox')
    for navbox in navboxes:
        navbox.decompose()

    navboxes = soup.find_all('div', class_='navbox-styles')
    for navbox in navboxes:
        navbox.decompose()

    # Remove edit buttons
    edit_links = soup.find_all('span', class_='mw-editsection')
    for navbox in edit_links:
        navbox.decompose()

    # Process texhtml span tags
    texhtml_spans = soup.find_all('span', class_='texhtml')
    for span in texhtml_spans:
        text = span.get_text().strip()
        span.replace_with(f'`{text}`')

    # Remove i tags
    i_spans = soup.find_all('i')
    for span in i_spans:
        text = span.get_text().strip()
        span.replace_with(f'{text}')

    # Replace internal links
    links = soup.find_all('a')
    for link in links:
        href = link.get('href', '')
        # Check if it's an internal link (starts with /wiki/)
        # Non-existent page links: /w/index.php?***
        if href.startswith('/wiki/') or href.startswith('/w/index.php'):
            # Get link text
            link_text = link.get_text()
            # Replace link with [[text]] format
            link.replace_with(f'[[{link_text}]]')

    # Find all img tags
    img_elements = soup.find_all('img')

    # Replace each img tag
    for img in img_elements:
        alttext = img.get('alt', '')
        # Extract LaTeX expression using escaped braces
        latex = re.search(r'\{\\displaystyle (.*)\}', alttext)
        if latex:
            # Surround LaTeX expression with $
            text = latex.group(1).strip()
            latex_text = f'${text}$'
            # Replace original img tag
            img.replace_with(latex_text)

    html_content_2 = soup.prettify()
    soup = BeautifulSoup(html_content_2, 'html.parser')

    # Custom formatter function
    def formatter(text, **kwargs):
        if text:
            # Remove newlines from text while preserving leading/trailing whitespace
            return text.strip('\n')
        return text

    # Return converted text using custom formatter
    return soup.prettify(formatter=formatter)
    # Return converted text
    return soup.prettify(formatter='html5')

def xx(url: str):
    unescaped_url = unquote(url)
    parsed = parse_url(url)

    j = get_wiki_content(parsed)
    display_title = j["parse"]["title"]
    html_text = j["parse"]["text"]["*"]

    html_latex_text = convert_math_to_latex(html_text)

    output_fn = parsed["title"] + '.html'

    with open(output_fn, 'w') as f:
        f.write(url)
        f.write("<br/>")
        f.write(unescaped_url)
        f.write("\n")
        f.write("<h1>{}</h1>".format(display_title))
        f.write("\n")
        f.write(html_latex_text)

    print(output_fn)

# Usage example
if __name__ == "__main__":
    escaped_url = sys.argv[1]
    xx(escaped_url)
