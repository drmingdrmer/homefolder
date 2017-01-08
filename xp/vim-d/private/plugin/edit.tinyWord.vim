
" select block
nmap <Leader>5 [{V%

let s:upLtr  = '\u'
let s:lowLtr = '\l'
let s:allLtr = '\w'
let s:nonLtr = '\W'
let s:blank  = '\s'
let s:nonBlk = '\S'
let s:under = '_'

let s:or = '\|'
let s:lq = '\('
let s:rq = '\)'

let s:followNon = s:allLtr . '\@<!'
let s:followLtr = s:allLtr . '\@<='
let s:followBlk = s:blank  . '\@<='
let s:followUnd = s:under  . '\@<='

let s:beforeUp  = s:upLtr  . '\@='
let s:beforeNon = s:allLtr . '\@!'
let s:beforeLtr = s:allLtr . '\@='
let s:beforeBlk = s:blank  . '\@='
let s:beforeUnd = s:under  . '\@='

let s:tinyStart = '\u'
          \ . '\|' . '\W' . '\zs' . '\w'
          \ . '\|' . '\s' . '\zs' . '\S'
          \ . '\|' . '_'  . '\zs' . '\w'
          " \ . '\|' . s:followLtr . '\zs' . s:nonLtr

let s:tinyEnd   = s:allLtr.s:beforeNon
          \.s:or .s:lowLtr.s:beforeUp
          \.s:or .s:nonBlk.s:beforeBlk
          \.s:or .s:allLtr.s:beforeUnd
          \.s:or .s:nonLtr.s:beforeLtr
          " \.s:or .s:beforeBlk

fun! s:SelectTinyWord()
  let c = strpart(getline("."), col(".") - 1, 1)

  " if current char is not letter  | if it is a letter the result is 0
  if match(c, s:allLtr)
    NonBlkA
    " normal lbvhe
    " return
  endif
   
  let ln = line(".")

  call search(s:tinyStart, "bc", ln)
  normal v
  call search(s:tinyEnd, "c", ln)

endfunction

fun! s:Vmove(end)
  normal gv

  let ln0 = line(".") | let cr0 = col(".")
  normal o
  let ln1 = line(".") | let cr1 = col(".")

  let forward = ln1 * 10000 + cr1 < ln0 * 10000 + cr0
  if forward |
    normal o
  end
  if !a:end
    normal o
  end
endfunction

fun! s:VtinyRight()
  call s:Vmove(1)
  call s:TinyRight()
endfunction

fun! s:VtinyLeft()
  call s:Vmove(0)
  call s:TinyLeft()
endfunction

fun! s:TinyRight()
  call search(s:tinyEnd, "")
endfunction

fun! s:TinyLeft()
  call search(s:tinyStart, "b")
endfunction

com! NonBlk call search('\S', "c", line("."))
com! NonBlkA call search('\S', "c")
com! SelWB call search('\<', "bc", line("."))
com! SelWE call search('.\>\@=', "c")












vmap <M-l> <esc>:call <SID>VtinyRight()<cr>
vmap <M-h> <esc>:call <SID>VtinyLeft()<cr>

" for linux cant receive S-space without Ctrl pressed
nmap <C-space> :call <SID>SelectTinyWord()<cr>
nmap <S-space> :call <SID>SelectTinyWord()<cr>
" nmap <space>s :call <SID>SelectTinyWord()<cr>
nmap [s :call <SID>SelectTinyWord()<cr>

vmap <C-space> :<C-w>NonBlk<cr>:SelWB<cr>mO:<C-w>SelWE<cr>v`O
vmap <S-space> :<C-w>NonBlk<cr>:SelWB<cr>mO:<C-w>SelWE<cr>v`O
" nmap <space>w  :NonBlk<cr>:SelWB<cr>mO:<C-w>SelWE<cr>v`O

nmap [w  <Plug>edit:selectWord

" nmap <Plug>edit:selectWord :NonBlk<cr>:SelWB<cr>mO:<C-w>SelWE<cr>v`O
nmap <Plug>edit:selectWord :call <SID>SelectWord()<CR>

fun! s:SelectWord() "{{{
    let c = col( "." )
    let char = getline( "." )[ c - 1 : c - 1 ]
    if char =~ '\V\w'
        call search('\S', "c", line("."))
        call search('\<', "bc", line("."))
        normal! v
        call search('.\>\@=', "c")
    else
        normal! v
    endif
endfunction "}}}


nnoremap [b [{v% 
nnoremap [f [[v% 
nmap =b mx\b='x
nmap =f m'[[v%=`'
" select current word
" vmap <space> <C-c>wbve

" nmap <space>n [[v%o---:Narrow<cr>zM


" nmap <M-l> <right>:<C-w>call <SID>TinyRight()<cr>
" nmap <M-h> <left>:<C-w>call <SID>TinyLeft()<cr>
nmap <M-l> :<C-w>call <SID>TinyRight()<cr>
nmap <M-h> :<C-w>call <SID>TinyLeft()<cr>



" AbcdAbcdfjks
" Abcd

