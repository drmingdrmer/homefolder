#!/bin/sh

python -m unittest discover -s test/ -v

# https://docs.python.org/2/library/unittest.html

# The discover sub-command has the following options:

# -v, --verbose
# Verbose output

# -s, --start-directory directory
# Directory to start discovery (. default)

# -p, --pattern pattern
# Pattern to match test files (test*.py default)

# -t, --top-level-directory directory
# Top level directory of project (defaults to start directory)

# The -s, -p, and -t options can be passed in as positional arguments in that order. The following two command lines are equivalent:

# python -m unittest discover -s project_directory -p "*_test.py"
# python -m unittest discover project_directory "*_test.py"
#
# As well as being a path it is possible to pass a package name, for example
# myproject.subpackage.test, as the start directory. The package name you
# supply will then be imported and its location on the filesystem will be used
# as the start directory.

