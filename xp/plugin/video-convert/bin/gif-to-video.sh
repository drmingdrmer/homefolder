#!/bin/sh

# movflags – This option optimizes the structure of the MP4 file so the browser
# can load it as quickly as possible.

# pix_fmt – MP4 videos store pixels in different formats. We include this option
# to specify a specific format which has maximum compatibility across all
# browsers.

# vf – MP4 videos using H.264 need to have a dimensions that are divisible by 2.
# This option ensures that’s the case.

# -movflags faststart:
# 让视频文件的元数据移到文件开头
# 这样视频可以在完全下载前就开始播放
#
# -pix_fmt yuv420p:
# 设置像素格式为 YUV420P
# 这种格式可以获得更好的兼容性,特别是在浏览器中播放
#
# -vf "scale=trunc(iw/2)*2:trunc(ih/2)*2":
# -vf 是视频滤镜参数
# 确保视频尺寸为偶数,因为某些编码器要求宽高必须是偶数
# iw 是输入宽度,ih 是输入高度
# trunc() 用于向下取整

ffmpeg -i "$1" \
    -movflags faststart -pix_fmt yuv420p \
    -vf "scale=trunc(iw/2)*2:trunc(ih/2)*2" \
    "${1%.gif}.mp4"
