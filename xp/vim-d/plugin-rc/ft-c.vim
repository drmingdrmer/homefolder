let g:c_comment_strings = 1
let g:c_gnu = 1
let g:c_no_curly_error = 1
let g:c_syntax_for_h=1


" C                                                       c.vim ft-c-syntax

" A few things in C highlighting are optional.  To enable them assign any value
" to the respective variable.  Example:
"         :let c_comment_strings = 1
" To disable them use ":unlet".  Example:
"         :unlet c_comment_strings

" Variable                Highlight
" c_gnu                   GNU gcc specific items
" c_comment_strings       strings and numbers inside a comment
" c_space_errors          trailing white space and spaces before a <Tab>
" c_no_trail_space_error   ... but no trailing spaces
" c_no_tab_space_error     ... but no spaces before a <Tab>
" c_no_bracket_error      don't highlight {}; inside [] as errors
" c_no_curly_error        don't highlight {}; inside [] and () as errors;
"                                 except { and } in first column
" c_curly_error           highlight a missing }; this forces syncing from the
"                         start of the file, can be slow
" c_no_ansi               don't do standard ANSI types and constants
" c_ansi_typedefs          ... but do standard ANSI types
" c_ansi_constants         ... but do standard ANSI constants
" c_no_utf                don't highlight \u and \U in strings
" c_syntax_for_h          for *.h files use C syntax instead of C++ and use objc
"                         syntax instead of objcpp
" c_no_if0                don't highlight "#if 0" blocks as comments
" c_no_cformat            don't highlight %-formats in strings
" c_no_c99                don't highlight C99 standard items
" c_no_c11                don't highlight C11 standard items

" When 'foldmethod' is set to "syntax" then /* */ comments and { } blocks will
" become a fold.  If you don't want comments to become a fold use:
"         :let c_no_comment_fold = 1
" "#if 0" blocks are also folded, unless:
"         :let c_no_if0_fold = 1

" If you notice highlighting errors while scrolling backwards, which are fixed
" when redrawing with CTRL-L, try setting the "c_minlines" internal variable
" to a larger number:
"         :let c_minlines = 100
" This will make the syntax synchronization start 100 lines before the first
" displayed line.  The default value is 50 (15 when c_no_if0 is set).  The
" disadvantage of using a larger number is that redrawing can become slow.

" When using the "#if 0" / "#endif" comment highlighting, notice that this only
" works when the "#if 0" is within "c_minlines" from the top of the window.  If
" you have a long "#if 0" construct it will not be highlighted correctly.

" To match extra items in comments, use the cCommentGroup cluster.
" Example:
"    :au Syntax c call MyCadd()
"    :function MyCadd()
"    :  syn keyword cMyItem contained Ni
"    :  syn cluster cCommentGroup add=cMyItem
"    :  hi link cMyItem Title
"    :endfun

" ANSI constants will be highlighted with the "cConstant" group.  This includes
" "NULL", "SIG_IGN" and others.  But not "TRUE", for example, because this is
" not in the ANSI standard.  If you find this confusing, remove the cConstant
" highlighting:
"         :hi link cConstant NONE
