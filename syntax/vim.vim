if exists( "g:__XP_SYNTAX_SUPPORT_VIM__" ) && g:__XP_SYNTAX_SUPPORT_VIM__ >= 1
    finish
endif
let g:__XP_SYNTAX_SUPPORT_VIM__ = 1

runtime! syntax/vim.vim


let s:fn = expand("%:p")

if s:fn =~ '/\%(colors\|syntax\)/.*\.vim$'
  syn clear vimGroup
endif


let s:AllSynNames = [ 'Comment', 'Character', 'Constant', 'Cursor', 'CursorColumn',
      \ 'CursorLine', 'Debug', 'Define', 'Delimiter', 'DiffAdd', 'DiffChange', 'DiffDelete',
      \ 'DiffText', 'Directory', 'Error', 'ErrorMsg', 'FoldColumn', 'Folded', 'Function',
      \ 'Identifier', 'Ignore', 'IncSearch', 'Keyword', 'Label', 'LineNr', 'Macro', 'MatchParen',
      \ 'ModeMsg', 'MoreMsg', 'Normal', 'NonText', 'Number', 'Operator', 'Pmenu', 'PmenuSbar',
      \ 'PmenuSel', 'PmenuThumb', 'PreProc', 'Question', 'Repeat', 'Search', 'SignColumn',
      \ 'Special', 'SpecialKey', 'SpellBad', 'SpellCap', 'SpellLocal', 'SpellRare', 'Statement',
      \ 'StatusLine', 'StatusLineNC', 'String', 'Tag', 'TabLine', 'TabLineFill', 'TabLineSel',
      \ 'Title', 'Todo', 'Type', 'Underlined', 'VertSplit', 'Visual', 'VisualNOS', 'WarningMsg',
      \ 'WildMenu', ]

let s:pref = 'XPsyntax_'
for n in s:AllSynNames

    " syntax keyword XPsyntax_Comment Comment contained containedin=vimHiGroup,vimLineComment
    " hi def link XPsyntax_Comment Comment

    exe 'syntax keyword ' . s:pref . n . ' ' .  n . ' contained containedin=vimHiGroup,vimLineComment'
    exe 'hi def link ' . s:pref . n . ' ' . n

endfor
