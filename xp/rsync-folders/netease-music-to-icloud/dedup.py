#!/usr/bin/env python
# coding: utf-8

# remove duplicate files with difference of trailing "foo (\d).xxx",
# and rename all them to foo.xxx

import sys
import os
import hashlib
import re
from collections import defaultdict

def calculate_md5(file_path, chunk_size=8*1024*1024):
    """Calculate the MD5 checksum of a file."""
    md5 = hashlib.md5()
    with open(file_path, 'rb') as f:
        for chunk in iter(lambda: f.read(chunk_size), b''):
            md5.update(chunk)
    return md5.hexdigest()

def get_base_name(file_name):
    """Extract the base name by removing trailing numbers and extension."""
    match = re.match(r'^(.*?)( \(\d+\))?(\.[^.]+)$', file_name)
    #  match = re.match(r'^(.*?)( 2)?(\.[^.]+)$', file_name)
    if match:
        return match.group(1) + (match.group(3) if match.group(3) else '')
    return file_name

def find_and_remove_duplicates(directory):
    """Find files with the same base name but different MD5 checksums and remove duplicates."""
    files_by_base_name = defaultdict(list)

    # Group files by base name
    for file_name in os.listdir(directory):
        file_path = os.path.join(directory, file_name)
        if os.path.isfile(file_path):
            base_name = get_base_name(file_name)
            files_by_base_name[base_name].append(file_path)

    # Check for duplicates within each group
    for base_name, file_paths in files_by_base_name.items():
        if len(file_paths) > 1:
            for file_path in file_paths[1:]:
                #  print(f"Removing duplicate file: {file_path}")
                os.remove(file_path)

        #  print("rename", file_paths[0], os.path.join(directory, base_name))
        os.rename(file_paths[0], os.path.join(directory, base_name))

if __name__ == "__main__":
    directory = sys.argv[1]
    find_and_remove_duplicates(directory)
