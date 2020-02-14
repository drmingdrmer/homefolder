XPTemplate priority=all

let s:f = g:XPTfuncs()

XPTvar $TIME_FMT     '%H:%M:%S'
XPTvar $DATETIME_FMT     '%Y-%m-%d-%H:%M:%S'

call XPTdefineSnippet("Now", {}, "`datetime()^")
call XPTdefineSnippet("diary", {}, "-   `datetime()^ ")
