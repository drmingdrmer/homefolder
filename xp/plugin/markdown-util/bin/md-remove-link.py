#!/usr/bin/env python
# coding: utf-8

import sys
import re

def remove_links(content):
    # Remove inline links [text](url) but not images ![alt](url)
    content = re.sub(r'(?<!!)\[([^\]]+)\]\([^)]+\)', r'\1', content)
    # Remove reference links [text][ref] but not images ![alt][ref]
    content = re.sub(r'(?<!!)\[([^\]]+)\]\[[^\]]*\]', r'\1', content)
    # Remove reference definitions [ref]: url
    content = re.sub(r'^\[[^\]]+\]:\s*http[s]?://(?:[a-zA-Z]|[0-9]|[$-_@.&+]|[!*\\(\\),]|(?:%[0-9a-fA-F][0-9a-fA-F]))+', '', content, flags=re.MULTILINE)
    return content

def main():
    if len(sys.argv) != 2:
        print("Usage: remove-link.py <markdown_file>", file=sys.stderr)
        sys.exit(1)
    
    try:
        with open(sys.argv[1], 'r', encoding='utf-8') as f:
            content = f.read()
        
        result = remove_links(content)
        print(result, end='')
        
    except FileNotFoundError:
        print(f"Error: File '{sys.argv[1]}' not found", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"Error: {str(e)}", file=sys.stderr)
        sys.exit(1)

if __name__ == '__main__':
    main()
