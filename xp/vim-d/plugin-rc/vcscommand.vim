
" nnoremap ,vd :VCSVimDiff<CR><C-w>=
" nnoremap ,vD :VCSVimDiff HEAD~<CR><C-w>=
nnoremap ,va :VCSAdd<CR>
nnoremap ,vc :VCSCommit<CR>
nnoremap ,vs :VCSStatus<CR>
nnoremap ,vu :VCSUpdate<CR>
nnoremap ,vo :XPVCSVimDiffClose<CR><C-w>=

com! XPVCSVimDiffClose call s:VCSVimDiffClose()
let g:VCSMatchOnMulti = 'first'

fun! s:VCSVimDiffClose() "{{{
    let curwinnr = winnr()

    let bufnr = winbufnr( curwinnr )
    let bufname = bufname( bufnr )
    if bufname =~ '\V review '
        exe 'bw' bufnr
    endif

    let nextwinnr = curwinnr + 1

    let bufnr = winbufnr( nextwinnr )
    let bufname = bufname( bufnr )
    if bufname =~ '\V review '
        exe 'bw' bufnr
    endif

endfunction "}}}
