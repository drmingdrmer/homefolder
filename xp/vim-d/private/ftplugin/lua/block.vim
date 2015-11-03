" if exists("g:__ftp_lua_block_f8sf8dsf__")
"     finish
" endif
" let g:__ftp_lua_block_f8sf8dsf__ = 1

fun! s:func_start() "{{{
    call searchpairpos('\V\<function\>', '', '\V\<end\>', 'b')
endfunction "}}}

nmap [[ :call <SID>func_start()<CR>
