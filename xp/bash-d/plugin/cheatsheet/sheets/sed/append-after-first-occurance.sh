#!/bin/sh

# but it still leaves a trailing space..
# gnu-sed command a\
# a\
# text
# As a GNU extension, this command accepts two addresses.
# Queue the lines of text which follow this command (each but the last ending with a \, which are removed from the output) to be output at the end of the current cycle, or when the next input line is read.

# Escape sequences in text are processed, so you should use \\ in text to print a single backslash.

# As a GNU extension, if between the a and the newline there is other than a whitespace-\ sequence, then the text of this line, starting at the first non-whitespace character after the a, is taken as the first line of the text block. (This enables a simplification in scripting a one-line add.) This extension also works with the i and c commands. 

gsed -i '0,/^import/{/^import /a\import logging\
}' xxx
