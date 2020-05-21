if exists( "g:__VIEW_VIM__" )
    " finish
endif
let g:__VIEW_VIM__ = 1

set ruler         " show the cursor position all the time

set number

set showcmd       " display incomplete commands
set cmdheight=2   " The commandbar is 2 high

set nowrap
" not used if 'textwidth' is non-zero
set wrapmargin=2

" break line at char in 'breakat', rather than the last char
set linebreak
" wrapped line continue visually indented
    call xputil#Set('breakindent')
    " a char at the start of lines that have been wrapped
" call xputil#Set('showbreak', '>>')
call xputil#Set('showbreak', '')

set tabstop=8     " how many space a tab represents
set shiftwidth=4  " indent length
set softtabstop=4 " space a 'tab' key stroke results in
set expandtab     " use space as tab

set list
set listchars=tab:].,trail:\|,extends:<,precedes:>

set smarttab
set autoindent

set wildmenu      "Turn on WiLd menu
set wildmode=longest:full

set lazyredraw

set textwidth=80

set noerrorbells
set visualbell

" set visualbell to nothing
set t_vb=

" With gvim 't_vb' may be set by VIM after runtime files loaded. Thus setting
" t_vb has no effect.
augroup NO_VISUAL_BELL
    au!
    au BufNew,BufRead,BufAdd,BufEnter * set t_vb=
augroup END

set updatetime=200

" =======================================================================================================================================================================
if v:version >=703
    " high light 3 columns after textwidth
    " see hi-ColorColumn
    " " disable annoying bar
    " set colorcolumn=-3,-2,-1,-0,+40
endif

nmap <Leader><Leader>wm  <Plug>view:width_max
nnoremap <Plug>view:width_max :set columns=999<CR>

noremap <Plug>(view:scroll:ignorebind:u) :call view#scroll#IgnoreBinding("u")<CR>
noremap <Plug>(view:scroll:ignorebind:d) :call view#scroll#IgnoreBinding("d")<CR>
