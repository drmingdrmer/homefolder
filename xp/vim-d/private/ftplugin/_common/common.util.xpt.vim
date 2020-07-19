XPTemplate priority=all

let s:f = g:XPTfuncs()

XPTvar $TIME_FMT     '%H:%M:%S'
XPTvar $DATETIME_FMT     '%Y-%m-%d-%H:%M:%S'

call XPTdefineSnippet("Now", {}, "`datetime()^")
call XPTdefineSnippet("diary", {}, "-   `datetime()^ ")

XPT obhead
// Copyright (c) 2018-current Alibaba Inc. All Rights Reserved.
// Author:
//   张炎泼-闲泽 <yanpo.zyp@alibaba-inc.com>
//   `:Date:^
