runtime macro/colorConvert.vim
" Set 'background' back to the default.  The value can't always be estimated
" and is then guessed.
hi clear Normal
set background=light

" Remove all existing highlighting and set the defaults.
" hi clear

" Load the syntax highlighting defaults, if it's enabled.
if exists("syntax_on")
  syntax reset
endif

let colors_name = "white"

hi  Character    gui=none      guifg=#b06060     guibg=NONE
hi  Comment      gui=none      guifg=#a0b0e0     guibg=NONE
hi  Constant     gui=none      guifg=#bb6666     guibg=NONE
hi  Cursor       gui=none      guifg=#000000     guibg=#ff0000
hi  CursorLine   gui=none      guibg=#dcfaff
hi  Define       gui=none      guifg=#9f438f     guibg=NONE
hi  DiffAdd      gui=none      guifg=#aaeeaa     guibg=#447744
hi  DiffChange   gui=none      guifg=lightyellow guibg=#ddbb55
hi  DiffDelete   gui=none      guifg=#336633     guibg=#aaccaa
hi  DiffText     gui=none      guifg=lightyellow guibg=#cc7733
hi  Directory    gui=none      guifg=Red         guibg=NONE
hi  Emphasize    gui=none      guifg=#000000     guibg=NONE
hi  ErrorMsg     gui=none      guifg=white       guibg=DarkRed
hi  FoldColumn   gui=none      guifg=darkblue    guibg=grey
hi  Folded       gui=none      guifg=#90b080     guibg=#ffffff
hi  Function     gui=none      guifg=#107090     guibg=NONE
hi  Hint         gui=underline      guifg=NONE        guibg=NONE
hi  Identifier   gui=none      guifg=#a070a0     guibg=NONE
hi  Ignore       gui=none      guifg=grey        guibg=NONE
hi  IncSearch    gui=none      guifg=yellow      guibg=#449944
hi  Keyword      gui=none      guifg=#4f51ff
hi  Label        gui=none      guifg=#bb7700     guibg=NONE
hi  LineNr       gui=none      guifg=brown       guibg=lightgrey
hi  ModeMsg      gui=none      guifg=#007700     guibg=#aaccaa
hi  MoreMsg      gui=none      guifg=darkgreen   guibg=NONE
hi  NonText      gui=none      guifg=#bebebe     guibg=#ffffff
hi  Normal       gui=none      guifg=#555555     guibg=#ffffff
hi  Number       gui=none      guifg=#707070     guibg=#f0f0f0
hi  Operator     gui=none      guifg=#404040     guibg=NONE
hi  Pmenu        gui=none      guifg=#000000     guibg=#8f8fac
hi  PmenuSel     gui=none      guifg=black       guibg=#b0ffb0
hi  PreProc      gui=none      guifg=#5c5cbf     guibg=#f0f0f0
hi  Question     gui=none      guifg=darkgreen   guibg=NONE
hi  Search       gui=none      guifg=NONE        guibg=#fefe74    
hi  Special      gui=none      guifg=#ab4f93     guibg=NONE
hi  SpecialChar  gui=none      guifg=NONE        guibg=NONE
hi  SpecialKey   gui=none      guifg=#d0d0d0     guibg=NONE
hi  Statement    gui=none      guifg=#60a819     guibg=NONE
hi  StatusLine   gui=none      guifg=#80624d     guibg=#ddd9b8
hi  StatusLineNC gui=none      guifg=#808080     guibg=#d7d7d2
hi  String       gui=none      guifg=#a05050     guibg=#f0f0f0
hi  Tag          gui=none      guifg=#7b9f63     guibg=NONE
hi  Title        gui=none      guifg=#dd00dd     guibg=NONE
hi  Todo         gui=none      guifg=#ffffff     guibg=#7090c0
hi  Type         gui=none      guifg=#5080e0     guibg=NONE
hi  Underlined   gui=underline guifg=darkmagenta guibg=NONE
hi  VertSplit    gui=none      guifg=#a7a7a2     guibg=#d7d7d2
hi  Visual       gui=none      guifg=NONE        guibg=#ffe6b4
hi  VisualNOS    gui=none      guifg=grey        guibg=black
hi  WarningMsg   gui=none      guifg=Red         guibg=NONE
hi  WildMenu     gui=none      guifg=black       guibg=lightyellow





hi  CharacterEmphasize    gui=none      guifg=#b06060     guibg=NONE
hi  CommentEmphasize      gui=none      guifg=#a0b0e0     guibg=NONE
hi  ConstantEmphasize     gui=none      guifg=#bb6666     guibg=NONE
hi  CursorEmphasize       gui=none      guifg=#000000     guibg=#ff0000
hi  CursorLineEmphasize   gui=none      guibg=#dcfaff
hi  DefineEmphasize       gui=none      guifg=#9f438f     guibg=NONE
hi  DiffAddEmphasize      gui=none      guifg=#aaeeaa     guibg=#447744
hi  DiffChangeEmphasize   gui=none      guifg=lightyellow guibg=#ddbb55
hi  DiffDeleteEmphasize   gui=none      guifg=#336633     guibg=#aaccaa
hi  DiffTextEmphasize     gui=none      guifg=lightyellow guibg=#cc7733
hi  DirectoryEmphasize    gui=none      guifg=Red         guibg=NONE
hi  EmphasizeEmphasize    gui=none      guifg=#000000     guibg=NONE
hi  ErrorMsgEmphasize     gui=none      guifg=white       guibg=DarkRed
hi  FoldColumnEmphasize   gui=none      guifg=darkblue    guibg=grey
hi  FoldedEmphasize       gui=none      guifg=#90b080     guibg=#ffffff
hi  FunctionEmphasize     gui=none      guifg=#003060     guibg=NONE
hi  HintEmphasize         gui=underline      guifg=NONE        guibg=NONE
hi  IdentifierEmphasize   gui=none      guifg=#802080     guibg=NONE
hi  IgnoreEmphasize       gui=none      guifg=grey        guibg=NONE
hi  IncSearchEmphasize    gui=none      guifg=yellow      guibg=#449944
hi  KeywordEmphasize      gui=none      guifg=#4f51ff
hi  LabelEmphasize        gui=none      guifg=#bb7700     guibg=NONE
hi  LineNrEmphasize       gui=none      guifg=brown       guibg=lightgrey
hi  ModeMsgEmphasize      gui=none      guifg=#007700     guibg=#aaccaa
hi  MoreMsgEmphasize      gui=none      guifg=darkgreen   guibg=NONE
hi  NonTextEmphasize      gui=none      guifg=#c6c6c6     guibg=#e0e0e0
hi  NormalEmphasize       gui=none      guifg=#909090     guibg=white
hi  NumberEmphasize       gui=none      guifg=#707070     guibg=#f0f0f0
hi  OperatorEmphasize     gui=none      guifg=#b09070     guibg=NONE
hi  PreProcEmphasize      gui=none      guifg=#5c5cbf     guibg=#f0f0f0
hi  QuestionEmphasize     gui=none      guifg=darkgreen   guibg=NONE
hi  SearchEmphasize       gui=none      guibg=#fefe74    
hi  SpecialEmphasize      gui=none      guifg=#ab4f93     guibg=NONE
hi  SpecialCharEmphasize  gui=none      guifg=NONE        guibg=NONE
hi  SpecialKeyEmphasize   gui=none      guifg=#d0d0d0     guibg=NONE
hi  StatementEmphasize    gui=none      guifg=#74b024     guibg=NONE
hi  StatusLineEmphasize   gui=none      guifg=#80624d     guibg=#ddd9b8
hi  StatusLineNCEmphasize gui=none      guifg=#808080     guibg=#d7d7d2
hi  StringEmphasize       gui=none      guifg=#a05050     guibg=#f0f0f0
hi  TagEmphasize          gui=none      guifg=#7b9f63     guibg=NONE
hi  TitleEmphasize        gui=none      guifg=#dd00dd     guibg=NONE
hi  TodoEmphasize         gui=none      guifg=#ffffff     guibg=#7090c0
hi  TypeEmphasize         gui=none      guifg=#3050c0     guibg=NONE
hi  UnderlinedEmphasize   gui=underline guifg=darkmagenta guibg=NONE
hi  VertSplitEmphasize    gui=none      guifg=#a7a7a2     guibg=#d7d7d2
hi  VisualEmphasize       gui=none      guifg=NONE        guibg=#ffe2b0
hi  VisualNOSEmphasize    gui=none      guifg=grey        guibg=black
hi  WarningMsgEmphasize   gui=none      guifg=Red         guibg=NONE
hi  WildMenuEmphasize     gui=none      guifg=black       guibg=lightyellow
















hi  Arg0         gui=none      guibg=#8CCBEA
hi  Arg1         gui=none      guibg=#A4E57E
hi  Arg2         gui=none      guibg=#FFDB72
hi  Arg3         gui=none      guibg=#FF7272
hi  Arg4         gui=none      guibg=#FFB3FF
hi  Arg5         gui=none      guibg=#9999FF
hi  Arg6         gui=none      guibg=#8fff96
hi  ArgGrey      gui=none      guifg=#a2d4a2

hi link Character       Constant
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

hi XPhighLightedItem term=underline cterm=underline gui=none guibg=#d0d0d0

" plugin support {{{

hi def link MyTagListTagName Visual
hi def link MyTagListFileName Identifier

" }}}


" personal {{{
hi XPFadeGrey0 gui=none  guibg=#f0d0d0 guifg=NONE
hi XPFadeGrey1 gui=none  guibg=#d0f0f0 guifg=NONE
hi XPFadeGrey2 gui=none  guibg=#f0f0b0 guifg=NONE

hi XPCharGrey0 gui=none  guifg=#606060 guibg=NONE
hi XPCharGrey1 gui=none  guifg=#707070 guibg=NONE
hi XPCharGrey2 gui=none  guifg=#808080 guibg=NONE
" }}}

hi StatuslineBufNr     cterm=none    ctermfg=black  ctermbg=cyan    gui=none guibg=#f0f060 guifg=black
hi StatuslineFlag      cterm=none    ctermfg=black  ctermbg=cyan    gui=none guibg=#a00000 guifg=#ffffff
hi StatuslinePath      cterm=none    ctermfg=white  ctermbg=green   gui=none guibg=#c0c060 guifg=black
hi StatuslineFileName  cterm=none    ctermfg=white  ctermbg=blue    gui=none guibg=#bd712f guifg=black
hi StatuslineFileEnc   cterm=none    ctermfg=white  ctermbg=yellow  gui=none guibg=#9a623e guifg=black
hi StatuslineFileType  cterm=bold    ctermbg=white  ctermfg=black   gui=none guibg=#77534d guifg=black
hi StatuslineTermEnc   cterm=none    ctermbg=white  ctermfg=yellow  gui=none guibg=#54445c guifg=black
hi StatuslineChar      cterm=none    ctermbg=white  ctermfg=yellow  gui=none guibg=#54445c guifg=black
hi StatuslineSyn       cterm=none    ctermbg=white  ctermfg=yellow  gui=none guibg=#54445c guifg=black
hi StatusLine          cterm=none    ctermbg=white  ctermfg=yellow  gui=none guibg=#31356b guifg=#729eb0 
hi StatuslineTime      cterm=none    ctermfg=black  ctermbg=cyan    gui=none guibg=#70a090 guifg=#60b070
hi StatusLineNC                                                     gui=none guibg=#b0d0b0 guifg=#6c8c6c 
hi StatuslineSomething cterm=reverse ctermfg=white  ctermbg=darkred gui=none guibg=#c0c0f0 guifg=black




call Fade('ff6e2c', '34ab46', 'guibg',
            \ 'StatuslinePath',
            \ 'StatuslineFileName',
            \ 'StatuslineFileEnc',
            \ 'StatuslineFileType',
            \ 'StatuslineTermEnc',
            \ 'StatuslineChar',
            \ 'StatuslineSyn',
            \ 'StatuslineRealSyn',
            \ 'StatusLine',
            \ 'StatuslineTime',
            \)

call Fade('020c00', '#245070', 'guifg',
            \ 'StatuslinePath',
            \ 'StatuslineFileName',
            \ 'StatuslineFileEnc',
            \ 'StatuslineFileType',
            \ 'StatuslineTermEnc',
            \ 'StatuslineChar',
            \ 'StatuslineSyn',
            \ 'StatuslineRealSyn',
            \ 'StatusLine',
            \ 'StatuslineTime',
            \)

"hi javascriptDocTags         
