#!/usr/bin/env python
# coding: utf-8

# convert timestamp to time string

import datetime
import sys

t = sys.argv[1]

t = int(t)

# Convert millis, micros or nano to seconds
while t > 2000000000:
    t = t / 1000

# 将时间戳转换为 datetime 对象
dt_object = datetime.datetime.fromtimestamp(t)

# 格式化为指定格式的字符串
formatted_time = dt_object.strftime('%Y-%m-%d %H:%M:%S')

print(formatted_time)

