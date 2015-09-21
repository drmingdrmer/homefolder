fun! s:TestThis(t)
    let t = a:t

    call t.Eq( 1, 1, 'ok' )
    call t.Eq( [1, 2, 3], [1, 2, 3], 'list comparison' )
    call t.Ne( 1, 2, 'not equal' )
    call t.Ne( {'a':1}, {'a':2}, 'dict comparison' )
    call t.True( 1 == 1, 'true' )
    try
        call t.Is( {}, {}, 'is' )
        call t.Fail('should not pass')
    catch /.*/
    endtry
endfunction

" Add the following line so that tiny-unittest loads and runs all script-local
" function that starts with 's:Test'
exe tut#unittest#run
