#!/usr/bin/env python
# coding: utf-8

import sys
import re
import argparse

def remove_links(content):
    # Remove inline links [text](url) but not images ![alt](url)
    content = re.sub(r'(?<!!)\[([^\]]+)\]\([^)]+\)', r'\1', content)
    # Remove reference links [text][ref] but not images ![alt][ref]
    content = re.sub(r'(?<!!)\[([^\]]+)\]\[[^\]]*\]', r'\1', content)
    # Remove reference definitions [ref]: url
    content = re.sub(r'^\[[^\]]+\]:\s*http[s]?://(?:[a-zA-Z]|[0-9]|[$-_@.&+]|[!*\\(\\),]|(?:%[0-9a-fA-F][0-9a-fA-F]))+', '', content, flags=re.MULTILINE)
    return content

def main():
    parser = argparse.ArgumentParser(description='Remove links from markdown file')
    parser.add_argument('file', help='Input markdown file')
    args = parser.parse_args()
    
    try:
        with open(args.file, 'r', encoding='utf-8') as f:
            content = f.read()
        
        result = remove_links(content)
        print(result, end='')
        
    except FileNotFoundError:
        print(f"Error: File '{args.file}' not found", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"Error: {str(e)}", file=sys.stderr)
        sys.exit(1)

if __name__ == '__main__':
    main()
