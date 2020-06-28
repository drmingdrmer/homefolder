#!/usr/bin/python
#coding=utf-8

"""
为clion的初始化CMakeList.txt
到项目根目录执行该命令即可初始化CMakeList.txt
"""

#config param
cmake_version = "3.3"
source_file_type = [".h",".hpp",".c",".cc",".cpp"]
include_file_type = [".h",".hpp"]

import string
import os
import sys

include_directories_set = set()
source_files = []

def SplitDirectory(path):
    retlist = path.split("/")
    for i in range(2, len(retlist)+1):
        include_directories_set.add("/".join(retlist[1:i]))

def ScanDirectory():
    for rt, dirs, files in os.walk("."):
        needInclude = False
        for i in files:
            for sft in source_file_type:
                if i[-len(sft):] == sft:
                    source_files.append((rt + "/" + i)[2:])
                    break
            for ift in include_file_type:
                if i[-len(ift):] == ift:
                    needInclude = True
                    break
        if needInclude:
            SplitDirectory(rt)

tvars = dict(
        cpp=14,

)

if __name__ == "__main__":
    f = open('CMakeLists.txt', 'w')
    ScanDirectory()

    lines = [
            "# Init by clioninit.py",
            "",
            "add_definitions(-D" "FIU_ENABLE=1)",
            "",
            "include_directories(/usr/local/include)",
            "cmake_minimum_required(VERSION " + cmake_version + ")",
            "project(" + os.path.basename(os.getcwd()) + ")",
            "",
            'set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ' + '-std=c++{cpp}")'.format(**tvars),
            "",
            "set(SOURCE_FILES",
    ]

    f.write("\n".join(lines))
    f.write("\n")


    for i in source_files:
        f.write("    " + i + "\n")
    f.write(")\n\n")

    f.write("add_executable(" + os.path.basename(os.getcwd()) + " ${SOURCE_FILES})\n")
    include_directories = list(include_directories_set)
    include_directories.sort()
    for i in include_directories:
        f.write("include_directories(" + i + ")\n")
