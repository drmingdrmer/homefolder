
fun! HLinRange(st, ed, kw, clr) " {{{
  if a:clr >= 1000
    exe 'syntax clear Arg'.(a:clr-1000)
  else
    exe 'syntax clear Arg'.a:clr
    exe 'syntax match Arg'.a:clr.' /\%<'.a:ed.'l\%>'.a:st.'l\<'.a:kw.'\>/ containedin=ALL'
  endif
endfunction " }}}


fun! s:HL() " {{{

    set hlsearch
    let oldsearch = @/
    let w = expand('<cword>')
    if '\<' . w . '\>' ==# oldsearch
        let @/ = w
    else
        let @/='\<' . w . '\>'
    endif

endfunction " }}}

" TODO correct cursor position in window
" TODO simplify begin/end position determine.
fun! HLinBlock(clr) " {{{
  let ln = line(".")
  let cur2 = col(".")

  let winln = winline()

  let kw = expand("<cword>")
  let kw = substitute(kw, "'", "", "g")
  if (stridx(kw, "*") > -1) 
    return
  endif

  let line = getline(ln)
  if (match(line, "function.*\(.*".kw) > -1 )
    call cursor(ln, 1000)
  endif


  let st = BlkStart()-1

  exe "normal %"
  let ed = line(".")+1
  exe "normal %"


  if (exists("g:lastBlockHL")) 
    exe g:lastBlockHL
  endif
  let i= HLinRange(st, ed, kw, a:clr) 
  let g:lastBlockHL = "call HLinRange(".st.", ".ed.", '".kw."', 1000)"
  call cursor(ln, cur2) 
  " fix cursor move to first column bug in vim 6
  if v:version < 700
    exe "normal \<left>\<right>"
  endif 
  let winln2 = winline()
  if (winln2 > winln)
    exe "normal! " . (winln2-winln) . "\<C-e>"
  elseif winln2 < winln
    exe "normal! " . (winln-winln2) . "\<C-y>"
  endif
endfunction " }}}


let g:hlBlock=0
fun! HLinBlockToggle() " {{{
  call HLinBlock(g:hlBlock)
  let g:hlBlock = 1000-g:hlBlock
endfunction " }}}
" nmap <Leader>h :call HLinBlock(0)<cr>
" nmap <Leader><Space> :call HLinBlock(0)<cr>
nmap <Leader><tab> :call HLinBlock(1000)<cr>



fun! HLFuncArg(t) " {{{
  let ln = line(".")
  let cur = col(".")

  let line = getline(ln)
  if (match(line, "function.*\(") > -1 )
    normal $
    let st = ln
  else
    let st = BlkStart()
  endif

  let ed = BlkEnd()

  echo st." ".ed
  let topLn = st
  let line = getline(st)
  if (match(line, "function.*\(") > -1 )
    "this is a function 
    " call cursor(ln, 1000)
    call cursor(st, 1)
    exe "normal f("
    let clr = 0
    while (line[col(".")-1] != ")" && clr < 15)
      let clr = clr % 6 + 1
      exe "normal w"
      let kw = expand("<cword>")
      if a:t==1
        exe "normal :call HLinRange(".(st-1).", ".(ed+1).", '".kw."', ".clr.")\<cr>w"
      else
        exe "normal :call HLinRange(".(st-1).", ".(ed+1).", '".kw."', ".(1000+clr).")\<cr>w"
      endif

    endwhile

  endif

  " exe "normal :".ln."\<cr>"
  call cursor(ln, cur)
endfunction " }}}

nnoremap <silent> <Plug>view:highlight_cursor_word :silent! call <SID>HL()<cr>
xnoremap <silent> <Plug>view:highlight_cursor_word <ESC>:call view#highlight#Visual()<CR>

nmap <Leader><leader>fa :call HLFuncArg(1)<cr>
nmap <Leader><leader>fb :call HLFuncArg(0)<cr>


" autocommand group
aug HL

  au! HL
  if v:version > 700 && has('gui_running')
      " au CursorHold * <space>
  endif
  " au HL CursorHold * call <SID>HL()

  " au HL CursorHold * let @/=expand('<cword>')
  " au HL CursorHoldI * call <SID>HL()

augroup END
" no high light for current word
com! XXnhw au! HL
com! XXhw au HL CursorHold * call <SID>HL()
 





fun! s:HLCursor() "{{{
  let c = getpos(".")[1:2]

  let p1 = searchpos('\<\w', 'bWc')
  let p2 = searchpos('\w\>', 'Wc')

  let cn = c[0] * 10000 + c[1]
  let p1n = p1[0] * 10000 + p1[1]
  let p2n = p2[0] * 10000 + p2[1]

  if p1 != [0, 0] && cn >= p1n - 1 && cn <= p2n + 1
    let w = getline(p1[0])[p1[1] - 1 : p2[1] - 1]
    let w = escape( w, '\ ' )

    try
      call matchdelete(99)
    catch 
    endtry

    call matchadd('XPhighLightedItem', '\<\V' . w . '\m\%(\>\|.\%#\)', -1, 99)
    let b:intimesearch = w
  endif
  
  call cursor(c)
endfunction "}}}


fun! s:SearchIntimeMark(flg) "{{{
  if exists("b:intimesearch")
    call search('\V\<'.escape(b:intimesearch, '\/').'\>', a:flg)
  endif
endfunction "}}}

fun! s:ToggleHighlight() "{{{
  if exists("b:__xphl__")

    unlet b:__xphl__

    augroup HLXP
      au!
    augroup END

    try
      call matchdelete(99)
    catch 
    endtry

    try
      unlet b:intimesearch
    catch
    endtry

  else

    let b:__xphl__ = 1

    augroup HLXP
      au!
      au CursorHold * call <SID>HLCursor()
      au CursorHoldI * call <SID>HLCursor()
      au CursorMovedI * call <SID>HLCursor()
    augroup END

  endif

endfunction "}}}


nnoremap <Plug>view:highlight_focus_toggle :call <SID>ToggleHighlight()<CR>
nnoremap <Plug>view:highlight_focus_prev :call <SID>SearchIntimeMark('b')<CR>
nnoremap <Plug>view:highlight_focus_next :call <SID>SearchIntimeMark('')<CR>

hi def link XPhighLightedItem VisualNOS


" high light word in WORD
" testWordtestWordtestWordtestWordtestWordtestWordtestWordtestWordtestWord
" TESFwordfjdskl

" hi link XPWordSeg0  Hint
" match XPWordSeg0 /\%(\<\u\+\|\<.\l*\|\u\l*\)\zs\u\l\+/
