let s:funcDef = "\\(^\\)*function\\s\\{1,\\}\\w\\{1,\\}\\s*("
let s:funcDef = s:funcDef . "\\|" . "function\\s*("
let g:funcDef = s:funcDef

fun! s:CurLineCursor()
  return line(".") * 50000 + col(".")
endfunction


fun! s:CurFunc()
  " normal [{
  call search(s:funcDef, "w")
  call search(s:funcDef, "bw")
endfunction

fun! s:CurFuncEnd()
  call s:CurFunc()
  call search("{", "W")
  normal %
endfunction

fun! s:PreFunc()
  call search(s:funcDef, "bW")
endfunction

fun! s:NextFunc()
  call search(s:funcDef, "W")
endfunction

fun! s:NextFuncEnd()
  let ln = s:CurLineCursor()
  call s:CurFuncEnd()
  let firstFunc = s:CurLineCursor()
  if firstFunc > ln
    return
  endif
  call s:NextFunc()
  call s:CurFuncEnd()
endfunction

fun! s:PreFuncEnd()
  let ln = s:CurLineCursor()
  call s:CurFuncEnd()
  let l2 = s:CurLineCursor()
  if l2 < ln
    return
  endif
  echo ln.' '.l2
  call s:PreFunc()
  call s:PreFunc()
  call s:CurFuncEnd()
endfunction

nmap <buffer> [<space> :call <SID>CurFunc()<cr>
" previous func block
nmap <buffer> [[ :call <SID>PreFunc()<cr>
nmap <buffer> ]] :call <SID>NextFunc()<cr>
nmap <buffer> [] :call <SID>PreFuncEnd()<cr>
nmap <buffer> ][ :call <SID>NextFuncEnd()<cr>




" {
" function  xp(a, b, c){
"
" }
" 
" t : function (b, d){
"
" }
"
" t : function (b, d){
"
" }
"
"}
