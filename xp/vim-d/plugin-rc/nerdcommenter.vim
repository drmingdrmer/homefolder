if exists( "g:__THE_NERD_COMMENTER_VIM__8fds3jhkfs" )
    finish
endif
let g:__THE_NERD_COMMENTER_VIM__8fds3jhkfs = 1

let NERDSpaceDelims = 1
let NERDCreateDefaultMappings = 0
let g:NERDComInInsertMap = "<C-f>"
imap <C-f> <esc><Plug>NERDCommenterTogglej
nmap <C-f> <Plug>NERDCommenterTogglej
xnoremap <C-f> <ESC>:call <SID>NERDdelegate()<CR>

fun! s:NERDdelegate() "{{{
    if &commentstring =~ '\V%s\$'
        call feedkeys( "gv\<Plug>NERDCommenterAlignLeft", 'm' )
    else
        call feedkeys( "gv\<Plug>NERDCommenterSexy", 'm' )
    endif
endfunction "}}}
