#!/bin/sh

autopep8  -i -aaa $(find . -name "*.py")
autoflake -i      $(find . -name "*.py")
isort             $(find . -name "*.py")
