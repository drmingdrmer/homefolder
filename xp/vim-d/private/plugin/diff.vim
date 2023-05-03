if exists( "g:once_xp_plugin_diff_3djf80flqe" )
    finish
endif
let g:once_xp_plugin_diff_3djf80flqe = 1

fun! XpDiff()
    let opt = []
    let opt +=["--minimal"]
    let opt +=["--text"]
    let opt +=["--expand-tabs"]
    " let opt +=["--ignore-all-space"]
    " let opt +=["--ignore-space-change"]


    if &diffopt =~ "icase"
        let opt += ["-i"]
    endif
    if &diffopt =~ "iwhite"
        let opt += ["--ignore-space-change"]
    endif

    try
        silent execute "!diff " . join(opt, ' ') . " ". v:fname_in . " ". v:fname_new . " > ". v:fname_out
    catch /.*/
        echo v:exception . ' while diff ' . v:fname_in . " ". v:fname_new . " > ". v:fname_out
    endtry
endfunction

set diffexpr=XpDiff()
set diffopt=filler


fun! s:Put() "{{{
    if ! &diff
        return ''
    endif

    let wnr = winnr()

    let targetBufNr = 0

    wincmd h
    let lwnr = winnr()
    wincmd l

    if wnr == lwnr
        " At the left most
        wincmd l
        let targetBufNr = winbufnr(".")
        wincmd h

    endif


    wincmd l
    let rwnr = winnr()
    wincmd h

    if wnr == rwnr
        " At the right most

        wincmd h
        let targetBufNr = winbufnr(".")
        wincmd l

    endif


    if targetBufNr != 0
        exe "diffput" targetBufNr
        diffupdate
        if !has( 'gui_running' )
            redraw!
        endif
        " do not collapse
        " normal! zM
    endif

endfunction "}}}


nnoremap <Plug>diff:put :call <SID>Put()<CR>
nmap dp  <Plug>diff:put

nnoremap <Plug>diff:update :diffupdate<CR>:redraw!<CR>zM
nmap du  <Plug>diff:update

function! s:DiffWithSaved()
    let filetype=&ft

    diffthis

    vnew | r # | normal! 1Gdd
    exe "setlocal bt=nofile bh=wipe nobl noswf ro ft=" . filetype
    diffthis
    au BufUnload <buffer> diffoff!

    redraw!
endfunction

nnoremap <Plug>diff:diff_with_saved :call <SID>DiffWithSaved()<CR>
