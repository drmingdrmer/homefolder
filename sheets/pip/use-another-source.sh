#!/bin/sh

# http://pypi.douban.com/  豆瓣
# http://pypi.hustunique.com/  华中理工大学
# http://pypi.sdutlinux.org/  山东理工大学
# http://pypi.mirrors.ustc.edu.cn/  中国科学技术大学

pip install web.py -i http://pypi.douban.com/simple


# ~/.pip/pip.conf
# [global]
# index-url = http://pypi.douban.com/simple
# [install]
# trusted-host=pypi.douban.com

# [global]
# index-url = http://mirrors.aliyun.com/pypi/simple/
# [install]
# trusted-host=mirrors.aliyun.com
