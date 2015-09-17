let s:left = '^\V<<<<<<< .\w'
let s:mid = '^\V======='
let s:right = '^\V>>>>>>> .\w'


fun! s:ConflictDiff()

  exe "w! ".expand("%:p").'.bkp'

  let currentBuf = bufnr(".")
  let tmpfile = tempname()
  let ft = &ft

  wincmd o

  diffthis

  normal! ggV
  call cursor('$', 1)
  if mode() =~ 's' | exe "normal! <C-g>" | endif

  normal! "0y

  exe "botright vertical split ".tmpfile

  set buftype=nofile

  normal! "0pggdd
  let &ft = ft

  diffthis

  normal! ggzR

  " at right
  while 1
    call cursor( 1, 1 )
    let pos = searchpos( s:left, 'W' )

    if pos == [0, 0]
      break
    endif

    let midpos = searchpos( s:mid, 'W' )

    if midpos == [ 0, 0 ]
      break
    endif


    normal! V
    call cursor(pos)
    if mode() =~ 's' | exe "normal! <C-g>" | endif
    normal! dzR

    let right = searchpos( s:right, 'cW' )
    if right == [ 0, 0 ]
      break
    endif

    normal! ddzR

  endwhile
  


  " at left
  exe bufwinnr(currentBuf)."wincmd w"
  normal! ggzR
  while 1
    call cursor( 1, 1 )
    let pos = searchpos( s:left, 'W' )

    if pos == [0, 0]
      break
    endif

    normal! ddzR

    let midpos = searchpos( s:mid, 'cW' )

    if midpos == [ 0, 0 ]
      break
    endif


    let right = searchpos( s:right, 'W' )
    if right == [ 0, 0 ]
      break
    endif
    normal! V
    call cursor(midpos)
    if mode() =~ 's' | exe "normal! <C-g>" | endif
    normal! dzR


  endwhile

  normal! zM


endfunction


" call ConflictDiff()

com! XConflict call <SID>ConflictDiff()



try 
<<<<<<< .working
" TODO eval default value in-time
" TODO expandable has to be adjuested
" TODO default value popup list
=======
>>>>>>> .merge-right.r813
catch /.*/
endtry
