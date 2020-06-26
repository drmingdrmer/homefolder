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

if __name__ == "__main__":
    f = open('CMakeLists.txt', 'w')
    ScanDirectory()
    f.write("#Init by clioninit.py\n")

    f.write("add_definitions(-D" "FIU_ENABLE=1)\n")
    f.write("include_directories(/usr/local/include)\n")

    f.write("cmake_minimum_required(VERSION " + cmake_version + ")\n")
    f.write("project(" + os.path.basename(os.getcwd()) + ")\n\n")
    f.write("set(CMAKE_CXX_FLAGS \"${CMAKE_CXX_FLAGS} -std=c++11\")\n\n")
    f.write("set(SOURCE_FILES\n")
    for i in source_files:
        f.write("    " + i + "\n")
    f.write(")\n\n")
    f.write("add_executable(" + os.path.basename(os.getcwd()) + " ${SOURCE_FILES})\n")
    include_directories = list(include_directories_set)
    include_directories.sort()
    for i in include_directories:
        f.write("include_directories(" + i + ")\n")
