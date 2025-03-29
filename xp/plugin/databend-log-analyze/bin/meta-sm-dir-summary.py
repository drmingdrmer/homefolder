#!/usr/bin/env python
# coding: utf-8


# read the user specified file, parse the ndjson format.
# the file format is like this:
# ```
# ["state_machine/0",{"GenericKV":{"key":"__fd_object_owners/zdcyc/table-by-id/111902752","value":{"seq":111902758,"meta":{"expire_at":null},"data":[10,22,110,112,115,102,122,104,103,103,119,121,104,95,97,100,109,105,110,95,114,111,108,101,18,27,18,19,10,7,100,101,102,97,117,108,116,16,148,193,159,38,24,160,128,174,53,160,6,107,168,6,24,160,6,107,168,6,24]}}}]
# ["state_machine/0",{"GenericKV":{"key":"__fd_object_owners/zdcyc/table-by-id/111902768","value":{"seq":111902774,"meta":{"expire_at":null},"data":[10,22,110,112,115,102,122,104,103,103,119,121,104,95,97,100,109,105,110,95,114,111,108,101,18,27,18,19,10,7,100,101,102,97,117,108,116,16,148,193,159,38,24,176,128,174,53,160,6,107,168,6,24,160,6,107,168,6,24]}}}]
# ["state_machine/0",{"GenericKV":{"key":"__fd_object_owners/zdcyc/table-by-id/111902781","value":{"seq":111902787,"meta":{"expire_at":null},"data":[10,22,110,112,115,102,122,104,103,103,119,121,104,95,97,100,109,105,110,95,114,111,108,101,18,27,18,19,10,7,100,101,102,97,117,108,116,16,148,193,159,38,24,189,128,174,53,160,6,107,168,6,24,160,6,107,168,6,24]}}}]
# ["state_machine/0",{"GenericKV":{"key":"__fd_object_owners/zdcyc/table-by-id/111902814","value":{"seq":111902820,"meta":{"expire_at":null},"data":[10,22,110,112,115,102,122,104,103,103,119,121,104,95,97,100,109,105,110,95,114,111,108,101,18,27,18,19,10,7,100,101,102,97,117,108,116,16,148,193,159,38,24,222,128,174,53,160,6,107,168,6,24,160,6,107,168,6,24]}}}]
# ["state_machine/0",{"GenericKV":{"key":"__fd_object_owners/zdcyc/table-by-id/111902821","value":{"seq":111902827,"meta":{"expire_at":null},"data":[10,22,110,112,115,102,122,104,103,103,119,121,104,95,97,100,109,105,110,95,114,111,108,101,18,27,18,19,10,7,100,101,102,97,117,108,116,16,148,193,159,38,24,229,128,174,53,160,6,107,168,6,24,160,6,107,168,6,24]}}}]
# ["state_machine/0",{"GenericKV":{"key":"__fd_object_owners/zdcyc/table-by-id/111902850","value":{"seq":111902856,"meta":{"expire_at":null},"data":[10,22,110,112,115,102,122,104,103,103,119,121,104,95,97,100,109,105,110,95,114,111,108,101,18,27,18,19,10,7,100,101,102,97,117,108,116,16,148,193,159,38,24,130,129,174,53,160,6,107,168,6,24,160,6,107,168,6,24]}}}]
# ["state_machine/0",{"GenericKV":{"key":"__fd_object_owners/zdcyc/table-by-id/111902912","value":{"seq":111902918,"meta":{"expire_at":null},"data":[10,22,110,112,115,102,122,104,103,103,119,121,104,95,97,100,109,105,110,95,114,111,108,101,18,27,18,19,10,7,100,101,102,97,117,108,116,16,148,193,159,38,24,192,129,174,53,160,6,107,168,6,24,160,6,107,168,6,24]}}}]
# ["state_machine/0",{"GenericKV":{"key":"__fd_object_owners/zdcyc/table-by-id/111902937","value":{"seq":111902943,"meta":{"expire_at":null},"data":[10,22,110,112,115,102,122,104,103,103,119,121,104,95,97,100,109,105,110,95,114,111,108,101,18,27,18,19,10,7,100,101,102,97,117,108,116,16,148,193,159,38,24,217,129,174,53,160,6,107,168,6,24,160,6,107,168,6,24]}}}]
# ["state_machine/0",{"GenericKV":{"key":"__fd_object_owners/zdcyc/table-by-id/111903014","value":{"seq":111903020,"meta":{"expire_at":null},"data":[10,22,110,112,115,102,122,104,103,103,119,121,104,95,97,100,109,105,110,95,114,111,108,101,18,27,18,19,10,7,100,101,102,97,117,108,116,16,148,193,159,38,24,166,130,174,53,160,6,107,168,6,24,160,6,107,168,6,24]}}}]
# ```
# Only process the lines starting with "state_machine/0", and only the lines with "GenericKV" key,
# and process only the lines with `key` starting with `__fd`.   
# Note that all of the lines are already sorted by the `key` field.
# This script should extract the `key` string, split by slashes ("/"),
# and count the number of entries for each directory, excluding the last entry.
# For example, from the above data, it should output:
#   __fd_object_owners/zdcyc/table-by-id/: 10
#   __fd_object_owners/zdcyc/: 10
#   __fd_object_owners/: 10

import json
import sys
from collections import defaultdict

def read_ndjson(filename) -> iter:
    with open(filename, 'r') as file:
        for line in file:
            line = line.strip()
            if not line:
                continue
            yield json.loads(line)

def filter_lines(lines) -> iter:
    for line in lines:
        if not (line[0] == "state_machine/0" and 
                "GenericKV" in line[1] and 
                "key" in line[1]["GenericKV"] and
                line[1]["GenericKV"]["key"].startswith("__fd")):
            continue
        yield line

def count_prefix(lines) -> iter:
    dir_counts = defaultdict(int)
    last_parts  = []
    
    for line in lines:
        key = line[1]["GenericKV"]["key"]
        
        parts = key.split('/')
        parts.pop(-1)

        c = 0
        while len(parts) > c and len(last_parts) > c and parts[c] == last_parts[c]:
            c += 1

        common_prefix_count = c

        while len(last_parts) > common_prefix_count:
            s = '/'.join(last_parts)
            yield (s, dir_counts[s])
            del dir_counts[s]
            last_parts.pop(-1)

        for i in range(0, len(parts)):
            dir_path = '/'.join(parts[:i+1])
            dir_counts[dir_path] += 1

        last_parts = parts

    while len(last_parts) > 0:
        s = '/'.join(last_parts)
        yield (s, dir_counts[s])
        del dir_counts[s]
        last_parts.pop(-1)
    

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python meta-sm-dir-summary.py <filename>")
        sys.exit(1)

    ndjson_lines = read_ndjson(sys.argv[1])
    filtered_lines = filter_lines(ndjson_lines) 
    results = count_prefix(filtered_lines)

    for dir_path, count in results:
        print(f"  {dir_path}: {count}")
