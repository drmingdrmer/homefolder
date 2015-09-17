if exists( "g:__FUZZYGOTO_fkjd786ds7__" )
    " finish
endif
let g:__FUZZYGOTO_fkjd786ds7__ = 1


nmap ; <Plug>fuzzygoto_skipword
nnoremap <Plug>fuzzygoto_skipany :call <SID>StartGoto('\.', '')<CR>
nnoremap <Plug>fuzzygoto_skipword :call <SID>StartGoto('\w', '')<CR>
nnoremap <Plug>fuzzygoto_skipwordspace :call <SID>StartGoto('\(\w\|\s\)', '')<CR>

hi def link FuzzyGotoCandidate Visual
hi def link FuzzyGotoSelect Search

let g:fuzzygoto_this_screnn = 1
let g:fuzzygoto_from = 'screentop'
let g:fuzzygoto_from = ''
let g:fuzzygoto_update_search_register = 1

" augroup fuzzygoto
"     au CursorHoldI * call s:UpdatePattern()
" augroup END

fun! s:StartGoto( trivial, direction_flag ) "{{{

    let curpos = [ line("."), col(".") ]
    let cursearch = @/

    if g:fuzzygoto_from == 'screentop'
        normal! H
    endif

    if g:fuzzygoto_update_search_register
        let @/ = ''
    endif


    let any = a:trivial . '\{-\}'
    let ptn = ''
    let lst = []
    let cancel_code = {
          \ 3: 'c-c',
          \ 13: 'cr',
          \ 27: 'esc',
          \ }
    let m = 0
    let next_match_id = 0

    while 1

        echo join( lst, '' ) . "  fuzzy goto>"
        let chr_nr = getchar()

        if m != 0
            call matchdelete(m)
            let m = 0
        end
        if next_match_id !=0
            call matchdelete( next_match_id )
            let next_match_id = 0
        end

        " cr
        if chr_nr == 13 && len(lst) > 0
            " call search( ptn, 'c' )
            return
        end

        if has_key( cancel_code, chr_nr )
            let @/ = cursearch
            call cursor(curpos)
            return
        endif


        if chr_nr == "\<BS>"
            if len(lst) > 0
                call remove(lst, -1)
            else
                " quit
                call cursor(curpos)
                return
            endif

        elseif chr_nr == 9
            " <tab>

            if len(lst) > 0
                call search( ptn )
            end

        elseif chr_nr == "\<S-TAB>"

            if len(lst) > 0
                call search( ptn, 'b' )
            end

        else
            let chr = nr2char(chr_nr)
            if chr == '\'
                let chr = '\\'
            endif
            call add( lst, chr )

        end

        " remove leading text as much as possible
        let ptn = ''

        " match whole word if possible
        let ptn = ptn . '\(' . join(lst, '')

        " match fuzzy
        let ptn = ptn . '\|' . join( lst, any ) . '\)'

        let ptn = '\V\c' . ptn


        call search( ptn, 'c' )
        let m = matchadd( 'FuzzyGotoCandidate', ptn )

        let pos = searchpos( ptn, 'cn' )
        call cursor( pos )
        if pos[0] != 0
            let next_match_id = matchadd( 'FuzzyGotoSelect',
                  \ '\V\%' . pos[0] . 'l\%' . pos[1] . 'c' . ptn )
        end

        if g:fuzzygoto_update_search_register
            let @/ = ptn
        endif

        redraw!

    endwhile

endfunction "}}}
