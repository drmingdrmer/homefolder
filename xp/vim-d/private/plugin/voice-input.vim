" see: ~/xp/bash-d/plugin/voice-input-azure/bin/voice-input.py

" inoremap <C-d><C-d> <C-r>=system('voice-input.py cn')<CR>
" inoremap <C-d><C-e> <C-r>=system('voice-input.py en')<CR>

" inoremap <silent> <C-d><C-d> <C-r>=<SID>ContinuouslyVoiceInput('cn')<CR><C-o>:redraw<CR><C-d><C-d>
" inoremap <silent> <C-d><C-e> <C-r>=<SID>ContinuouslyVoiceInput('en')<CR><C-o>:redraw<CR><C-d><C-e>
inoremap <silent> <C-d><C-d> <C-r>=<SID>ContinuouslyVoiceInput('cn')<CR>
inoremap <silent> <C-d><C-e> <C-r>=<SID>ContinuouslyVoiceInput('en')<CR>

" listen and output text to after cursr, and continue listening.
" If user say 退出退出 or quit quit, it won't keep listening.
fun! s:ContinuouslyVoiceInput(lang) "{{{
    " sleep 10m
    echom "Voice input listening..."
    let cont = system('voice-input.py ' . a:lang)

    echom "input:" . cont
    let quit = 0
    if cont =~ "退出.*退出"
        let cont = substitute(cont, "退出，退出。", "", "")
        let quit = 1
    endif
    if cont =~? "quit[.].*quit"
        let cont = substitute(cont, "Quit. Quit.", "", "")
        let quit = 1
    endif

    call feedkeys(cont, "n")
    call feedkeys("\<C-o>:redraw\<CR>")
    if quit == 1
        echom "Voice input quit"
        return ""
    endif

    if a:lang == "cn"
        call feedkeys("\<C-d>\<C-d>")
    else
        call feedkeys("\<C-d>\<C-e>")
    endif
    return ""
endfunction "}}}
