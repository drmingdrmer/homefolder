XPTemplate priority=personal

XPTvar $code_quote ```
XPTvar $bquote `

XPTinclude
      \ _common/common

XPT readme " template of README.md

#   Name

x

#   Status

This library is considered production ready.

#   Description

`cursor^

#   Author

Zhang Yanpo (张炎泼) <drdr.xp@gmail.com>

#   Copyright and License

The MIT License (MIT)

Copyright (c) 2015 Zhang Yanpo (张炎泼) <drdr.xp@gmail.com>


XPT install

# Install

`$code_quote^shell
./configure
make
sudo make install
`$code_quote^


XPT fsyntax
**syntax**:
\``^\`

XPT freturn
**return**:
`^

XPT farguments
**arguments**:
`^

XPT largument
-   \``x^\`:
    `cursor^
