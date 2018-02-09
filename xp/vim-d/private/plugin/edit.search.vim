
" if the search pattern contains upper case letter, use case sensitive search
set smartcase

" do incremental searching
set incsearch

" Highlight search thing
set hlsearch

fun! GetCvStr()
    let s = inputdialog("pattern")
    let s1 = substitute(s, "[\\*.{}]", "\\\\\\0", "")
    echo s1
    return s1
endfunction

fun! Rep()
    let p = GetCvStr()
    let r = GetCvStr()
    let c = ":%s//g"
endfunction
nmap <Leader><leader>replaceAll <esc>:call GetCvStr()<cr>


fun! BlkStart()
    normal [{
    return line(".")
endfunction

fun! BlkEnd()
    exe "normal %"
    return line(".")
endfunction

fun! GetBlockLines()
    normal [{
    let ln1 = line(".")

    normal %
    let ln2 = line(".")

    return ln1.",".ln2
endfunction

fun! GetFuncRange()
    XpFuncStart
    let ln1 = line(".")

    XpFuncEnd
    let ln2 = line(".")

    return ln1.",".ln2
endfunction

fun! s:replace_in_range(pattern, replace, range)
    let cmd = a:range."s/".a:pattern."/".a:replace."/gc"
    exe cmd
endfunction

fun! ReplaceInBlock()
    let ptn = inputdialog("pattern : ")
    let rep = inputdialog("replace to : ")
    let rng = GetBlockLines()
    call s:replace_in_range(ptn, rep, rng)
endfunction

fun! RelaceCurrentWordInBlock()
    let ln = line(".")
    let cur = col(".")

    let word = expand("<cword>")
    let ptn = "\\<".word.'\>'
    let rep = inputdialog("replace to : ", word)
    let rng = GetBlockLines()
    call s:replace_in_range(ptn, rep, rng)

    call cursor(ln, cur)
endfunction

fun! RelaceCurrentWordInFunc()
    let currentPos = [ line( "." ), col( "." ) ]

    let word = expand("<cword>")
    let ptn = "\\<".word.'\>'
    let rep = inputdialog("replace to : ", word)
    let rng = GetFuncRange()
    call s:replace_in_range(ptn, rep, rng)

    call cursor( currentPos )
endfunction

fun! RelaceCurrentWord()
    call view#win#SaveCursorPosition()
    " let ln = line(".")
    " let cur = col(".")

    let word = expand("<cword>")
    let rep = inputdialog("replace to : ", word)
    let ptn = '\<'.word.'\>'
    let rng = "%"
    call s:replace_in_range(ptn, rep, rng)

    " call cursor(ln, cur)
    call view#win#RestoreCursorPosition()
    let @/ = '\<' . rep . '\>'
endfunction

" fun! s:fixSearchHighLight(toReplace, replacement)
" if a:toReplace == @/
" if a:replacement =~ '^\w*$'
" let @/ = '\<' . a:replacement . '\>'
" else
" let @/ = a:replacement
" endif
" endif
" endfunction

nmap <Leader>rb :call ReplaceInBlock()<cr>
nmap <Leader><Leader>rc :call RelaceCurrentWordInBlock()<cr>
nmap <Leader><Leader>rf :call RelaceCurrentWordInFunc()<cr>
nmap <Leader><Leader>ra :call RelaceCurrentWord()<cr>
