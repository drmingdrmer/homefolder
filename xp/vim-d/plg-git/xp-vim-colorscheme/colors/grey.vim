runtime macro/colorConvert.vim
" Set 'background' back to the default.  The value can't always be estimated
" and is then guessed.
hi clear Normal
set background=dark

" Remove all existing highlighting and set the defaults.
" hi clear

" Load the syntax highlighting defaults, if it's enabled.
if exists("syntax_on")
    syntax reset
endif
"

set guifont=Courier\ 10\ Pitch\ 12
" set guifont=FixedsysTTF\ Bold\ 11
" set guifont=Monospace\ 10
" set guifont=Monospace\ Bold\ 10

let colors_name = "grey"


" Normal Define Character Constant Todo Label Identifier Keyword Function Question Tag Statement Cursor Search Type Visual Folded Operator Number Comment Directory Title Special Underlined String PreProc SpecialChar Hint Emphasize 
"
" CursorLine CursorColumn DiffAdd DiffChange DiffDelete DiffText ErrorMsg FoldColumn Ignore IncSearch LineNr ModeMsg MoreMsg NonText Pmenu PmenuSel SpecialKey VertSplit VisualNOS WarningMsg WildMenu



hi  Normal       gui=none      guifg=#e4e4e4     guibg=#202020

hi  Define       gui=none      guifg=#af4282     guibg=NONE
hi  Character    gui=none      guifg=#a0576a     guibg=NONE
hi  Constant     gui=none      guifg=#d73030     guibg=NONE
hi  Todo         gui=none      guifg=#000000     guibg=#d07c16
hi  Label        gui=none      guifg=#eba700     guibg=#4c4646
hi  Identifier   gui=none      guifg=#b4785d     guibg=NONE
hi  Keyword      gui=none      guifg=#ffb194
hi  Function     gui=none      guifg=#bca869     guibg=NONE
hi  Question     gui=none      guifg=#82c000     guibg=NONE
hi  Tag          gui=none      guifg=#7b9f63     guibg=NONE
hi  Statement    gui=none      guifg=#75d775     guibg=NONE
hi  Cursor       gui=none      guifg=#000000     guibg=#00ff00
hi  Search       gui=none      guifg=#ffffff     guibg=#4b7435
hi  Type         gui=none      guifg=#5da85e     guibg=NONE
hi  Visual       gui=none      guifg=NONE        guibg=#304050
hi  Folded       gui=none      guifg=#8790b4     guibg=NONE
hi  Operator     gui=none      guifg=#db6e77     guibg=NONE
hi  Number       gui=none      guifg=#797be4     guibg=#181818
hi  Comment      gui=none      guifg=#768eff     guibg=NONE
hi  Directory    gui=none      guifg=#8080d0     guibg=NONE
hi  Title        gui=none      guifg=#d090f0     guibg=NONE
hi  Special      gui=none      guifg=#827dff     guibg=NONE
hi  Underlined   gui=underline guifg=#8962ce     guibg=NONE
hi  PreProc      gui=none      guifg=#7b83ff     guibg=#181818
hi  String       gui=none      guifg=#bb9191     guibg=#101010

hi  SpecialChar  gui=none      guifg=NONE        guibg=NONE
hi  Hint         gui=underline guifg=NONE        guibg=NONE
hi  Emphasize    gui=none      guifg=#000000     guibg=NONE
hi  CursorLine   gui=none                        guibg=#404040
hi  CursorColumn gui=none                        guibg=#304030
hi  DiffAdd      gui=none      guifg=NONE        guibg=#283734
hi  DiffChange   gui=none      guifg=NONE        guibg=#895b33
hi  DiffDelete   gui=none      guifg=NONE        guibg=#3e535c
hi  DiffText     gui=none      guifg=#dddddd     guibg=#cc7733
hi  ErrorMsg     gui=none      guifg=#ffffff     guibg=#880000
hi  FoldColumn   gui=none      guifg=#507080     guibg=#a0a0a0
hi  Ignore       gui=none      guifg=#6c6c6c     guibg=NONE
hi  IncSearch    gui=none      guifg=NONE        guibg=#4c55f8
hi  LineNr       gui=none      guifg=#535384     guibg=#080808
hi  ModeMsg      gui=none      guifg=#cbfd4b     guibg=NONE
hi  MoreMsg      gui=none      guifg=#47d347     guibg=NONE
hi  NonText      gui=none      guifg=#606060     guibg=NONE
hi  Pmenu        gui=none      guifg=#303030     guibg=#a3a3c4
hi  PmenuSel     gui=none      guifg=#000000     guibg=#81e781
hi  SpecialKey   gui=none      guifg=#5c5c5c     guibg=NONE
hi  VertSplit    gui=none      guifg=#a7a7a2     guibg=#546292
hi  VisualNOS    gui=none      guifg=#aaaaaa        guibg=#000000
hi  WarningMsg   gui=none      guifg=#cf2323     guibg=NONE
hi  WildMenu     gui=none      guifg=#ffffff     guibg=#506080

call EmphasizeHLs(-30, [
            \'Character',
            \'Comment',
            \'Constant',
            \'Cursor',
            \'CursorLine',
            \'CursorColumn',
            \'Define',
            \'DiffAdd',
            \'DiffChange',
            \'DiffDelete',
            \'DiffText',
            \'Directory',
            \'Emphasize',
            \'ErrorMsg',
            \'FoldColumn',
            \'Folded',
            \'Function',
            \'Hint',
            \'Identifier',
            \'Ignore',
            \'IncSearch',
            \'Keyword',
            \'Label',
            \'LineNr',
            \'ModeMsg',
            \'MoreMsg',
            \'NonText',
            \'Normal',
            \'Number',
            \'Operator',
            \'Pmenu',
            \'PmenuSel',
            \'PreProc',
            \'Question',
            \'Search',
            \'Special',
            \'SpecialChar',
            \'SpecialKey',
            \'Statement',
            \'String',
            \'String',
            \'Tag',
            \'Title',
            \'Todo',
            \'Type',
            \'Underlined',
            \'VertSplit',
            \'Visual',
            \'VisualNOS',
            \'WarningMsg',
            \'WildMenu',
            \])





hi  Arg0         gui=none      guibg=#8CCBEA
hi  Arg1         gui=none      guibg=#A4E57E
hi  Arg2         gui=none      guibg=#FFDB72
hi  Arg3         gui=none      guibg=#FF7272
hi  Arg4         gui=none      guibg=#FFB3FF
hi  Arg5         gui=none      guibg=#9999FF
hi  Arg6         gui=none      guibg=#8fff96
hi  ArgGrey      gui=none      guifg=#a2d4a2

hi link Boolean         Constant
hi link Float           Number
hi link Conditional     Statement
hi link Repeat          Statement
hi link Exception       Statement
hi link Include         PreProc
hi link Macro           PreProc
hi link PreCondit       PreProc
hi link StorageClass    Type
hi link Structure       Type
hi link Typedef         Type
hi link SpecialChar     Special
hi link Delimiter       Special
hi link SpecialComment  Special
hi link Debug           Special
hi link vimfunction     function


" fixing {{{
hi link vimVar          Identifier
" }}}

hi XPhighLightedItem term=underline cterm=underline gui=none guibg=#3c3c5c

" plugin support {{{

hi def link MyTagListTagName Visual
hi def link MyTagListFileName Identifier

" hi XPTcurrentPH         gui=none   guibg=#3a684e guifg=#94ffe1
" hi XPTfollowingPH       gui=none   guibg=#304030 guifg=#8aefcd
" hi XPTnextItem          gui=none   guibg=#404015 guifg=#a8895a

hi XPTcurrentPH         gui=underline   guibg=#3c3c3c guifg=NONE
hi XPTfollowingPH       gui=underline	guibg=NONE guifg=NONE
hi XPTnextItem          gui=none	guibg=#3e3e68 guifg=#dddddd





hi MatchParen     gui=none guibg=#244c5c guifg=NONE
" }}}


" personal {{{
hi XPFadeGrey0 gui=none  guibg=#f0d0d0 guifg=NONE
hi XPFadeGrey1 gui=none  guibg=#d0f0f0 guifg=NONE
hi XPFadeGrey2 gui=none  guibg=#f0f0b0 guifg=NONE

hi XPCharGrey0 gui=none  guifg=#606060 guibg=NONE
hi XPCharGrey1 gui=none  guifg=#707070 guibg=NONE
hi XPCharGrey2 gui=none  guifg=#808080 guibg=NONE
" }}}



hi StatuslineBufNr     cterm=none    ctermfg=black  ctermbg=cyan    gui=none guibg=#840c0c guifg=#ffffff
hi StatuslineFlag      cterm=none    ctermfg=black  ctermbg=cyan    gui=none guibg=#bc5b4c guifg=#ffffff
hi StatuslinePath      cterm=none    ctermfg=white  ctermbg=green   gui=none guibg=#8d6c47 guifg=black
hi StatuslineFileName  cterm=none    ctermfg=white  ctermbg=blue    gui=none guibg=#d59159 guifg=black
hi StatuslineFileEnc   cterm=none    ctermfg=white  ctermbg=yellow  gui=none guibg=#ffff77 guifg=black
hi StatuslineFileType  cterm=bold    ctermbg=white  ctermfg=black   gui=none guibg=#acff84 guifg=black
hi StatuslineTermEnc   cterm=none    ctermbg=white  ctermfg=yellow  gui=none guibg=#77cf77 guifg=black
hi StatuslineChar      cterm=none    ctermbg=white  ctermfg=yellow  gui=none guibg=#66b06f guifg=black
hi StatuslineSyn       cterm=none    ctermbg=white  ctermfg=yellow  gui=none guibg=#60af9f guifg=black
hi StatuslineRealSyn   cterm=none    ctermbg=white  ctermfg=yellow  gui=none guibg=#5881b7 guifg=black
hi StatusLine          cterm=none    ctermbg=white  ctermfg=yellow  gui=none guibg=#3f4d77 guifg=#729eb0 
hi StatuslineTime      cterm=none    ctermfg=black  ctermbg=cyan    gui=none guibg=#3a406e guifg=#000000
hi StatuslineSomething cterm=reverse ctermfg=white  ctermbg=darkred gui=none guibg=#c0c0f0 guifg=black
hi StatusLineNC                                                     gui=none guibg=#304050 guifg=#70a0a0 


" visualmark
highlight SignTxtColor guibg=NONE
highlight SignColor    guibg=NONE guifg=#dd0000



" call Fade('#cfcf68', '#634bd0', 'guibg',
            " \ 'StatuslinePath',
            " \ 'StatuslineFileName',
            " \ 'StatuslineFileEnc',
            " \ 'StatuslineFileType',
            " \ 'StatuslineTermEnc',
            " \ 'StatuslineChar',
            " \ 'StatuslineSyn',
            " \ 'StatuslineRealSyn',
            " \ 'StatusLine',
            " \ 'StatuslineTime',
            " \)

" call Fade('#000000', '#0c071c', 'guifg',
            " \ 'StatuslinePath',
            " \ 'StatuslineFileName',
            " \ 'StatuslineFileEnc',
            " \ 'StatuslineFileType',
            " \ 'StatuslineTermEnc',
            " \ 'StatuslineChar',
            " \ 'StatuslineSyn',
            " \ 'StatuslineRealSyn',
            " \ 'StatusLine',
            " \ 'StatuslineTime',
            " \)

