#!/usr/bin/env python
# coding: utf-8

from setuptools import setup, find_packages

setup(
    name="video-convert",
    version="0.1.0",
    description="Video conversion tool using ffmpeg",
    author="XP",
    packages=find_packages(),
    install_requires=[],
    entry_points={
        'console_scripts': [
            'video-convert=videoconv.cli:entry_point',
        ],
    },
    classifiers=[
        'Development Status :: 3 - Alpha',
        'Intended Audience :: End Users/Desktop',
        'License :: OSI Approved :: MIT License',
        'Programming Language :: Python :: 3',
        'Topic :: Multimedia :: Video :: Conversion',
    ],
) 