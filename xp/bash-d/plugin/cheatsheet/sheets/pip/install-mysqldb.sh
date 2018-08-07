#!/bin/sh

# MySQLdb

# It's easy to do, but hard to remember the correct spelling:

pip install mysqlclient

# If you need 1.2.x versions (legacy Python only), use
pip install MySQL-python

# Note: Some dependencies might have to be in place when running the above
# command. Some hints on how to install these on various platforms:

# Ubuntu 14, Ubuntu 16, Debian 8.6 (jessie)
sudo apt-get install python-pip python-dev libmysqlclient-dev

# Fedora 24:
sudo dnf install python python-devel mysql-devel redhat-rpm-config gcc

# Mac OS
brew install mysql-connector-c

# if that fails, try
brew install mysql
