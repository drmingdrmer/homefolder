" 08-03-13 add fold level shortcuts

runtime plugin/util.vim

function! FoldText() "   {{{
    let tb     = &tabstop
    let tbstr  = repeat(" ", tb)
    let width  = winwidth(0) - 6

    " folding text
    let txt = getline(v:foldstart)

    " replace tabs with spaces
    let txt = substitute(txt, '\t', tbstr, "g")

    let text_lines = (v:foldend-v:foldstart) . ''

    let textWidth = width - strlen(text_lines)

    " cut too long text
    if strlen(txt) > textWidth
        let txt = strpart(txt, 0, textWidth)
    endif

    " create space
    let len = strlen(txt) + strlen(text_lines)
    let space = repeat('.', width - len) . " "

    return txt.space.text_lines
endfunction " }}}

set foldminlines=1
" set foldcolumn=1
set foldtext=FoldText()

if &foldmethod == "manual"
    set foldmethod=syntax
endif

vnoremap zf <C-c>:'<s/\s*$/ /<cr>:'>s/\s*$/ /<cr>gvzf:set nohlsearch<cr>



com! -bar XXfmm set foldmethod=marker
com! -bar XXfms set foldmethod=syntax


com! XXfc XXfmm | set foldmarker=/*,*/
com! XXfn XXfmm | set foldmarker={,}
com! XXfv XXfmm | set foldmarker={{{,}}}

" increase/decrease fold column
fun! s:Adjustments(i)

    let oldcmdheight = &cmdheight

    if a:i
        let &cmdheight = 6
        redraw!

        echo 'c: fold Column'
        echo 'l: fold Level'
        echo 't: Tab stop'
        echo '-------------------'
        echo 'h/l to adjust, choose:'

        let c = nr2char( getchar() )

        if c == 'c'
            nmap <buffer> l :set foldcolumn+=1<cr>
            nmap <buffer> h :set foldcolumn-=1<cr>
        elseif c == 'l'
            nmap <buffer> l :set foldlevel+=1<cr>
            nmap <buffer> h :set foldlevel-=1<cr>
        elseif c == 't'
            nmap <buffer> l :let &tabstop=&tabstop * 2<cr>
            nmap <buffer> h :let &tabstop=&tabstop / 2<cr>
        endif

        nmap <buffer> <enter> :call <SID>Adjustments(0)<cr>

    else
        redraw!

        nunmap <buffer> l
        nunmap <buffer> h
        nunmap <buffer> <enter>

    endif

    let &cmdheight = oldcmdheight
    redraw!
endfunction

nmap ,f :call <SID>Adjustments(1)<cr>

" open all folding of current block
nnoremap <silent> z<Space> :call SaveWinPosition()<CR>zMzO:call RestoreWinPosition()<CR>
nnoremap <Leader>z zczO
noremap z9 zMzv
nnoremap <silent> <M-*> zA

