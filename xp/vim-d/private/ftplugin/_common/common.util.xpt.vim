XPTemplate priority=all

let s:f = g:XPTfuncs()

XPTvar $TIME_FMT     '%H:%M:%S'

call XPTdefineSnippet("Now", {}, "`time()^")
