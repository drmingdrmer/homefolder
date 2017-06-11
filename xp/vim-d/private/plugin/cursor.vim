" {{{ reserved mark
" j        quick mark

" }}}


"Set 7 lines to the curors - when moving vertical..
set scrolloff=6
" horizontal scroll context space
set sidescrolloff=5
" scroll horizontally 1 char each time
set sidescroll=1

" move 1 line when line wrap on
silent nnoremap <silent> j gj
silent nnoremap <silent> k gk

" dont use vmap, vmap apply maps to select mode too
xnoremap <silent> j gj
xnoremap <silent> k gk

" quick move
nnoremap <M-j> 5<down>
nnoremap <M-k> 5<up>
xnoremap <M-j> 5<down>
xnoremap <M-k> 5<up>

nnoremap <M-l> 4<right>
xnoremap <M-j> 4<down>

" quick scroll
nnoremap <M-e> 5<C-e>
nnoremap <M-y> 5<C-y>


" move in insert mode
inoremap <M-h> <Left>
inoremap <M-j> <Down>
inoremap <M-k> <Up>
inoremap <M-l> <Right>


fun! s:ToHome(isVisual) range "{{{

    let synName = synIDattr(synID(line("."), col("."), 1), "name")

    let cur = col(".")

    if synName =~? '\vcomment'

        if cur == 1

            call search( '\w', '', line( "." ) )

            let cu2 = col(".")

            if cu2 == cur
                normal! ^
            endif

        else
            call cursor( line( "." ), 1 )
            call search( '\w', '', line( "." ) )

            let cu2 = col(".")

            if cu2 >= cur
                normal! ^

                let cu3 = col(".")

                if cur == cu3
                    exe "normal! \<Home>"
                endif
            endif
        endif

    else

        if cur == 1

            call search( '\w', '', line( "." ) )

            let cu2 = col(".")

            if cu2 == cur
                normal! ^
            endif

        else

            normal! ^

            let cu2 = col(".")

            if cur == cu2
                exe "normal! \<Home>"
            endif

        endif

    endif


    if a:isVisual
        normal mo
        normal gv`o
    endif

endfunction "}}}


nnoremap 0 :call <SID>ToHome(0)<cr>
xnoremap 0 <C-c>:call <SID>ToHome(1)<cr>

" goto last insert place
nmap g6 `^

" goto prev {
" nmap <space>[ [{

" goto next }
" nmap <space>] ]}

nmap gl <space><space>[[n<Leader>h


" TODO not finish
function! SuperIndent(lnum) "{{{
  let ln = line(".") | let cur = col(".") | let vc0 = virtcol(".")
  normal k
  call search("\\s")
  call search("\\S")
  let vc = virtcol(".")

  call cursor(ln, cur)
  if line(".") == ln-1
    
  else
  endif
  return
endfunction " }}}


nnoremap <expr> <CR> <SID>FuncCR()
nnoremap <expr> g<CR> <SID>FuncG_CR()

fun! s:FuncCR() "{{{
    if &buftype == ''
        return 'g;'
    else
        return "\<CR>"
    endif
endfunction "}}}

fun! s:FuncG_CR() "{{{
    if &buftype == ''
        return 'g,'
    else
        return "\<CR>"
    endif
endfunction "}}}



" scroll screen with cursor to top
nnoremap z<cr> zt


" fjk:call <SNR>17_Res()
