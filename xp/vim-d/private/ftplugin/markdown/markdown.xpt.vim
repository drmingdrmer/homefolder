XPTemplate priority=personal

XPTvar $code_quote ```

XPTinclude
      \ _common/common

XPT readme " template of README.md

# `name^

x

# Status

This library is considered production ready.

# Description

`cursor^

# Author

Zhang Yanpo (张炎泼) <drdr.xp@gmail.com>

# Copyright and License

The MIT License (MIT)

Copyright (c) 2015 Zhang Yanpo (张炎泼) <drdr.xp@gmail.com>


XPT install

# Install

`$code_quote^shell
./configure
make
sudo make install
`$code_quote^
