fun! s:ExtractFuncDec() "{{{
    normal mO

    normal ]]
    call search('.', 'b')
    normal! mP

    call search('\V(', 'b')
    call search('.', 'b')
    " special to C
    call search('\V;\|}\|/', 'b')
    " TODO line comment compliant
    call search('\w')

    normal! v`P

    normal! y

    normal! gg
    call search('\V/* FUNC_DEC_END */')
    normal! mP

    normal! O
    normal! p

    normal! v`Pk$
    normal! J
    normal! A;


    call search('\V/* FUNC_DEC_START */')
    normal! jv`Pk
    normal ,a
    normal! gv
    exe "normal! :sort\<cr>"

    " normal! gv
    silent! '<,'>s/\v^(.*)\n\1/\1/g


    normal `O
endfunction "}}}

nmap <Leader><Leader>ef :call <SID>ExtractFuncDec()<cr>










fun! ExtractMethod() range
    let name = inputdialog("Name of new method:")
    '<
    exe "normal O\<bs>private ". name ."()\<cr>{\<esc>"
    '>
    exe "normal oreturn ;\<cr>}\<esc>k"
    s/return/\/\/ return/ge
    normal j%
    normal kf(
    ")
    exe "normal yyPi// = \<esc>wdwA;\<esc>"
    normal ==
    normal j0w
endfunction 

vmap <Leader>em :call ExtractMethod()<cr>


" replace in direcotry

" let g:workingFT = "*.php|*.tpl|*.js|*.html"
let g:workingFT = "*.php"
let g:workingFTex = "*.tpl.php"
let g:searchSkipPtn = '.svn\|^tags\|.git'

fun! s:ReplaceInDir()
    let wrd = expand("<cword>")
    let wrd = escape(wrd, '$^|\')

    let rep = inputdialog("to replace:", wrd)
    let tmp = tempname()
    " exe ':!grep -R --include='.g:workingFT.' "\b'.wrd.'\b" * \\| grep -v "'.escape(g:searchSkipPtn, '|\').'" > '.tmp

    let filetypes = input( 'file patter=', '*.' . expand("%:e") )
    let command = ':!repl.sh '.wrd.' '.rep.' '.'"'. filetypes .'"'

    let command = substitute( command, '\V#', '\\#', 'g' )


    echom command
    exe command

endfunction

" nnoremap <Leader><Leader>rd :!sed -i 's/\b<C-r><C-w>\b/<C-\>egetcmdline().inputdialog("repl:")."/g' *.c *.h"<cr>
nnoremap <Leader><Leader>rd :call <SID>ReplaceInDir()<cr>


fun! s:ExtractVar() range
    call StoreReg()
    call StoreCursor()
    let name = inputdialog("Name of new method:")

    normal `<v`>y
    let ptr = '\<'.@@.'\>'

    " goto the first occurence of the statement.
    normal [[
    exe "/\\M".ptr
    normal k

    call append(line("."), 'var '.name.' = '.@@.';')
    normal j==jmo

    normal [{%mp
    exe "'o,'ps/\\M".ptr."/".name."/cg"



    call BackToLastCursor()
    call RestoreReg()
endfunction

xmap <Leader><Leader>ev :call <SID>ExtractVar()<cr>
nmap <Leader><Leader>ev <space>w<Leader><Leader>ev
