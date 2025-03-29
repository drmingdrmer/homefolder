#!/usr/bin/env python
# coding: utf-8

import sys
import re
import argparse

# Predefined regex patterns
INLINE_LINK_PATTERN = r'(?<!!)\[([^\]]+)\]\([^)]+\)'
REFERENCE_LINK_PATTERN = r'(?<!!)\[([^\]]+)\]\[[^\]]*\]'
REFERENCE_DEF_PATTERN = r'^\[[^\]]+\]:\s*http[s]?://(?:[a-zA-Z]|[0-9]|[$-_@.&+]|[!*\\(\\),]|(?:%[0-9a-fA-F][0-9a-fA-F]))+'

def remove_links(content, remove_text=False):
    # Determine replacement pattern based on remove_text
    replacement = r'' if remove_text else r'\1'
    
    # Remove inline links [text](url)
    content = re.sub(INLINE_LINK_PATTERN, replacement, content)
    # Remove reference links [text][ref]
    content = re.sub(REFERENCE_LINK_PATTERN, replacement, content)
    
    # Remove reference definitions [ref]: url
    content = re.sub(REFERENCE_DEF_PATTERN, '', content, flags=re.MULTILINE)
    return content

def main():
    parser = argparse.ArgumentParser(description='Remove links from markdown file')
    parser.add_argument('file', help='Input markdown file')
    parser.add_argument('-r', '--remove-text', action='store_true', help='Remove link text completely instead of keeping it')
    args = parser.parse_args()
    
    try:
        with open(args.file, 'r', encoding='utf-8') as f:
            content = f.read()
        
        result = remove_links(content, args.remove_text)
        print(result, end='')
        
    except FileNotFoundError:
        print(f"Error: File '{args.file}' not found", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"Error: {str(e)}", file=sys.stderr)
        sys.exit(1)

if __name__ == '__main__':
    main()
