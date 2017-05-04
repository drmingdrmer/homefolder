set pumheight=40

" imap        <tab> <Plug>edit:complete_noselect
inoremap    <M-.> <C-x><C-o>

inoremap <Plug>edit:complete_noselect <C-r>=<SID>Compl()<cr>

augroup XPcompl
    au!
    au CursorMovedI * call <SID>ClearRecord()
augroup END

let s:lastword = ''
fun! s:ClearRecord()
    let s:lastword = ''
endfunction

fun! s:Compl() "{{{
  if pumvisible() 

      let pos = [ line( "." ), col( "." ) ]
      let start = searchpos( '\<', 'nbW', line( "." ) )
      let word = getline( "." )[ start[1] - 1 : pos[1] - 1 ]


      if s:lastword != word
          let act =  "\<C-y>\<C-n>"
      elseif s:lastword == word
          " press <tab> twice
          let act =  "\<C-y>\<C-n>\<C-y>"
      endif

      let s:lastword = word
      return act
  else
      return "	"
    " return "\<C-n>"
  endif
endfunction "}}}
