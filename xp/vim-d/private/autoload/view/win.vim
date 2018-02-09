fun! view#win#SaveCursorPosition() "{{{
    let s:saved_cursor = [winline(), line("."), col(".")]
endfunction "}}}

fun! view#win#RestoreCursorPosition() "{{{
    let [winln, line, col] = s:saved_cursor

    " restore cursor in buffer
    call cursor(line, col)

    " restore cursor inf window
    let winln2 = winline()
    if winln2 > winln
        exe "normal! " . (winln2 - winln) . "\<C-e>"
    elseif winln2 < winln
        exe "normal! " . (winln - winln2) . "\<C-y>"
    endif
endfunction "}}}
