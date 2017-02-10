" Vim color file
" Maintainer:   Bram Moolenaar <Bram@vim.org>
" Last Change:  2001 Jul 23

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

hi Normal       cterm=none ctermbg=black       ctermfg=grey
hi IncSearch    cterm=none ctermbg=blue        ctermfg=white
hi Search       cterm=none ctermbg=white       ctermfg=black
hi ColorColumn  cterm=none ctermbg=none        ctermfg=yellow
hi Comment      cterm=none                     ctermfg=darkblue
hi Conditional  cterm=none                     ctermfg=green
hi CursorColumn cterm=none ctermbg=darkmagenta ctermfg=none
hi CursorLine   cterm=none ctermbg=none        ctermfg=none
hi Folded       cterm=none ctermbg=none        ctermfg=grey
hi VertSplit    cterm=none                     ctermfg=darkgrey
hi Function     cterm=none                     ctermfg=blue
hi Identifier   cterm=none                     ctermfg=cyan
hi LineNr       cterm=none ctermbg=black       ctermfg=darkgrey
hi Label        cterm=none                     ctermfg=yellow
hi MatchParen   cterm=none ctermbg=cyan        ctermfg=none
hi NonText      cterm=none                     ctermfg=darkcyan
hi Operator     cterm=none                     ctermfg=darkyellow
hi PmenuSel     cterm=none ctermbg=white       ctermfg=black
hi PmenuThumb   cterm=none ctermbg=green       ctermfg=black
hi Repeat       cterm=none                     ctermfg=green
hi SpecialKey   cterm=none                     ctermfg=darkcyan
hi Statement    cterm=none                     ctermfg=darkyellow
hi StorageClass cterm=none                     ctermfg=darkgreen
hi String       cterm=none                     ctermfg=magenta
hi Title        cterm=none ctermbg=none        ctermfg=yellow
hi Type         cterm=none ctermbg=none        ctermfg=green
hi TabLineFill  cterm=none ctermbg=cyan        ctermfg=grey
hi TabLine      cterm=none ctermbg=cyan        ctermfg=white
hi TabLineSel   cterm=none ctermbg=white       ctermfg=black
hi Visual       cterm=none ctermbg=darkCyan
hi DiffAdd      cterm=none ctermbg=green       ctermfg=white       guibg=LightBlue
hi DiffChange   cterm=none ctermbg=darkCyan
hi DiffDelete   cterm=none ctermbg=black       ctermfg=darkgrey
hi DiffText     cterm=none ctermbg=darkblue    ctermfg=white


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
