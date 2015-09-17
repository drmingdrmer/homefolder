if exists("g:__RC_PROFILE_VIM__")
    finish
endif
let g:__RC_PROFILE_VIM__ = 1

" exe 'profile start ' . $HOME . '/prof.txt'


fun! s:GetCmdOutput( cmd ) "{{{
    let l:a = ""

    redir => l:a
    exe a:cmd
    redir END

    return l:a
endfunction "}}}

fun! s:Init() "{{{
    let s:list = split( s:GetCmdOutput( 'silent verbose function' ), "\n" )
endfunction "}}}

fun! s:Profile( fn ) "{{{
    call s:Init()

    let i = 0
    while i < len( s:list )

        let funcname = matchstr( s:list[i], '\Vfunction \zs\[^(]\*' )
        let funcfile = matchstr( s:list[i + 1], '\VLast set from \zs\.\*' )

        if funcfile =~ a:fn
            exe 'profile func' funcname
            " echo 'profile func' funcname
        endif

        let i += 2
    endwhile

endfunction "}}}

fun! s:StartProfile() "{{{

    call s:Profile( '\V\.' )
    return

    call s:Profile( '\VXPT.vim' )
    call s:Profile( '\Vxptemplate.vim' )
    call s:Profile( '\Vxpreplace.vim' )
    call s:Profile( '\Vxpopup.vim' )
    call s:Profile( '\Vxpmark.vim' )
    call s:Profile( '\Vxpt.plugin.highlight.vim' )
    call s:Profile( '\Vutil.vim' )
    call s:Profile( '\Vxptemplate.parser.vim' )

    call s:Profile( '\Veval.vim' )
    call s:Profile( '\Vflt.vim' )
    call s:Profile( '\Vftsc.vim' )
    call s:Profile( '\Vgroup.vim' )
    call s:Profile( '\Vmsvr.vim' )
    call s:Profile( '\Vng.vim' )
    call s:Profile( '\Vparser.vim' )
    call s:Profile( '\Vph.vim' )
    call s:Profile( '\Vrctx.vim' )
    call s:Profile( '\Vrender.vim' )
    call s:Profile( '\Vsnip.vim' )
    call s:Profile( '\Vsnipf.vim' )
    call s:Profile( '\Vsnipline.vim' )
    call s:Profile( '\Vst.vim' )
    call s:Profile( '\Vstsw.vim' )
    call s:Profile( '\Vutil.vim' )


endfunction "}}}

nnoremap <Leader><Leader>pf :call <SID>StartProfile()<CR>
" call s:StartProfile()

fun! StartProf() "{{{
    call s:StartProfile()
endfunction "}}}

