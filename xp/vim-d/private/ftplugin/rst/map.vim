setlocal ve=all
xnoremap <buffer> ,e1 <C-c>`>a**<C-c>`<i**<esc>
xmap <buffer> ,ee ,e1
nmap <buffer> ,ee <Plug>edit:selectWord,ee
nmap <buffer> ,el V,ee


fun! s:MakeTitle(lvl) 
  let lvl = a:lvl
  let upt = 0
  if lvl =~ '[=\-]\{2}' 
    let upt = 1
    let lvl = lvl[0:0]
  endif

  call StoreCursor()
  .s/\s*$//g
  normal $
  let c = virtcol(".")
  call append(line('.'), repeat(lvl, c))
  exe '.+2g/^'.lvl.'*$/d'
  call BackToLastCursor()

  if !upt 
    return 
  endif

  exe '.-1g/^'.lvl.'*$/d'
  normal $
  let c = virtcol(".")
  call append(line('.')-1, repeat(lvl, c))
  call BackToLastCursor()
  normal j
  
endfunction
nmap <buffer> ,tt :call <SID>MakeTitle('==')<cr>
nmap <buffer> ,ty :call <SID>MakeTitle('--')<cr>
nmap <buffer> ,t1 :call <SID>MakeTitle('=')<cr>
nmap <buffer> ,t2 :call <SID>MakeTitle('-')<cr>
nmap <buffer> ,t3 :call <SID>MakeTitle('`')<cr>
nmap <buffer> ,t4 :call <SID>MakeTitle('~')<cr>
nmap <buffer> ,t5 :call <SID>MakeTitle('^')<cr>


fun! s:Convert()
  let fname = '"'.expand("%:p").'"'
  let name =  '"'.expand("%:p").'"'
  let name = substitute(name, '.rst', '.html', '')
  exe "!rst2html -l zh_cn ".fname." > ".name
  echo "!rst2html -l zh_cn ".fname." > ".name
  " echo name
endfunction
nnoremap <silent> <buffer> ,cnv :silent! call <SID>Convert()<cr><C-l>


" table
fun! s:CreateTable()
  let r = inputdialog("row : ")
  let c = inputdialog("column : ")

  let ln = '+'.repeat('-----+', c)
  let hln = substitute(ln, '-', '=', 'g')
  let bln = substitute(ln, '-', ' ', 'g')
  let bln = substitute(bln, '+', '|', 'g')
  let lnu = line(".")

  let i = r
  while (i>1)
    call append(lnu, ln)
    call append(lnu, bln)
    let i = i - 1
  endwhile

  call append(lnu, hln)
  call append(lnu, bln)
  call append(lnu, ln)

endfunction

nmap <buffer> ,ct :call <SID>CreateTable()<cr>

fun! s:NewTableLine()

  let cur = [ line( "." ), col( "." ) ]

  let endLine = search( '^[^+|]\|$', 'nW' )
  if endLine == 0
    normal! o
    return 
  endif

  
  let p = search( '^+.*', 'W', endLine )
  if p == 0
    normal! o
    return 
  endif

  normal! yy

  call cursor( cur[0] , cur[1] )

  normal! p
  .s/[\-=]/ /g
  .s/+/|/g

  call cursor( cur[0] + 1, cur[1] )

  call search( '|', 'bW', cur[0] + 1 )


endfunction
nnoremap <buffer> o :call <SID>NewTableLine()<cr>a

fun! s:NewRow()
  let cur = [ line( "." ), col( "." ) ]

  let p = search( '^+.*' )
  if p == 0
    return 
  endif

  normal! yypp
  normal! k
  .s/[\-=]/ /g
  .s/+/|/g

endfunction

nnoremap <buffer> ,cr :call <SID>NewRow()<cr>.


fun! s:AlignTable() range
  '<,'>s/+\([-=]\)[-=]*+\@=/+\1/g

  AlignCtrl = \(+\||\)\{1,}
  AlignCtrl p1P1
  "AlignCtrl rrrll 
  AlignCtrl l 
  AlignCtrl I
  '<,'>Align

  silent '<,'>g/^\s*[+-]*/s/-\s*+/\=repeat('-', strlen(submatch(0))-1).'+'/g
  silent '<,'>g/^\s*[+-]*/s/+\s*-/\='+'.repeat('-', strlen(submatch(0))-1)/g
  silent '<,'>g/^\s*[+=]*/s/=\s*+/\=repeat('=', strlen(submatch(0))-1).'+'/g
  silent '<,'>g/^\s*[+=]*/s/+\s*=/\='+'.repeat('=', strlen(submatch(0))-1)/g
  normal '<='>
  set nohlsearch

endfunction
vmap <buffer> ,at :call <SID>AlignTable()<cr>
nmap <buffer> ,at :XXStCur<cr>?^$<cr>/+<cr>V/^$<cr><up>,at:XXBkCur<cr>



hi RstMargin guibg=lightred ctermbg=darkred 
syn match RstMargin /\%>80v./
