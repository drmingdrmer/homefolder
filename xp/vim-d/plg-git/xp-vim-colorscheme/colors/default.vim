" Vim color file
" Maintainer:	Bram Moolenaar <Bram@vim.org>
" Last Change:	2001 Jul 23

" This is the default color scheme.  It doesn't define the Normal
" highlighting, it uses whatever the colors used to be.

" Set 'background' back to the default.  The value can't always be estimated
" and is then guessed.
hi clear Normal
set bg&

" Remove all existing highlighting and set the defaults.
hi clear

" Load the syntax highlighting defaults, if it's enabled.
if exists("syntax_on")
  syntax reset
endif

let colors_name = "default"

"
"
hi Normal       cterm=none ctermbg=black       ctermfg=grey
hi IncSearch    cterm=none ctermbg=blue       ctermfg=white
hi Search       cterm=none ctermfg=black     ctermbg=white
hi ColorColumn             ctermfg=yellow    ctermbg=darkcyan

" hi Comment      cterm=none         ctermfg=darkcyan
hi Comment      cterm=none         ctermfg=darkblue
hi Conditional  cterm=none         ctermfg=green
hi CursorColumn cterm=none         ctermfg=none       ctermbg=darkmagenta
" hi CursorLine   cterm=underline    ctermfg=none       ctermbg=none
" hi CursorLine   cterm=bold	    ctermfg=none       ctermbg=black
hi CursorLine   cterm=none     ctermfg=none       ctermbg=none
" hi CursorLine   cterm=none	    ctermfg=none       ctermbg=darkcyan
hi Folded       cterm=none         ctermfg=grey       ctermbg=none


hi Function     cterm=none         ctermfg=blue
hi Identifier   cterm=none	   ctermfg=cyan
hi LineNr       cterm=none         ctermfg=darkgrey      ctermbg=black
hi Label        cterm=none         ctermfg=yellow

hi MatchParen   cterm=none         ctermfg=none      ctermbg=cyan

" hi NonText      cterm=none         ctermfg=darkgrey
hi NonText      cterm=none         ctermfg=darkcyan
hi Operator     cterm=none         ctermfg=darkyellow
hi PmenuSel     cterm=none         ctermfg=black      ctermbg=white
hi PmenuThumb   cterm=none         ctermfg=black      ctermbg=green

hi Repeat       cterm=none         ctermfg=green
hi SpecialKey   cterm=none         ctermfg=darkcyan
hi Statement    cterm=none         ctermfg=darkyellow
hi StorageClass cterm=none         ctermfg=darkgreen
hi String       cterm=none         ctermfg=magenta

hi Type         cterm=none ctermfg=green  ctermbg=none


hi TabLineFill  cterm=none         ctermfg=grey      ctermbg=cyan
hi TabLine      cterm=none         ctermfg=white      ctermbg=cyan
hi TabLineSel   cterm=none         ctermfg=black      ctermbg=white

hi Visual       cterm=none         ctermbg=darkCyan


" hi DiffAdd      term=none ctermbg=green guibg=LightBlue
" hi DiffChange   term=bold ctermfg=white ctermbg=darkblue guibg=LightMagenta
" hi DiffDelete   term=bold ctermfg=white ctermbg=darkmagenta guibg=LightMagenta

hi DiffAdd      term=none ctermfg=white ctermbg=green guibg=LightBlue
hi DiffChange   cterm=none         ctermbg=darkCyan
hi DiffDelete   cterm=none         ctermfg=darkgrey      ctermbg=black
hi DiffText      term=none      ctermbg=darkblue ctermfg=white


hi def link MyTagListTagName Visual


hi StatuslinePath      cterm=none    ctermfg=white  ctermbg=green   guibg=#70a070 guifg=black
hi StatuslineFileName  cterm=none    ctermfg=white  ctermbg=blue    guibg=#608060 guifg=black
hi StatuslineFileType  cterm=bold    ctermbg=white  ctermfg=black   guibg=#4d737f guifg=white
hi StatuslineFileEnc   cterm=none    ctermfg=white  ctermbg=yellow  guibg=#305070 guifg=white
hi StatuslineRed       cterm=none    ctermbg=white  ctermfg=yellow  guibg=#406050 guifg=white
hi StatuslineSomething cterm=reverse ctermfg=white  ctermbg=darkred guibg=#c0c0f0 guifg=black
hi StatuslineGreyGreen cterm=none    ctermfg=black  ctermbg=cyan    guibg=#90c070 guifg=black


" visualmark
highlight SignTxtColor cterm=NONE ctermbg=NONE ctermfg=NONE
highlight SignColor ctermfg=white ctermbg=blue guifg=white guibg=RoyalBlue3


" vim: ts=8:sw=4:sts=4
