if exists( "g:__PLG_CNF_VIMEXPLORER_j3rk23hl2k4hl42" )
    finish
endif
let g:__PLG_CNF_VIMEXPLORER_j3rk23hl2k4hl42 = 1

" let g:VEConf_filePanelFilter = '*.torrent'
let g:VEConf_fileDeleteConfirm = 0

fun! s:changeVEFilter() "{{{

    let fn = getline( "." )

    " remove leading space
    let fn = substitute( fn, '\V\^\s\*', "", "" )
    " remove <tab> and following contents
    let fn = substitute( fn, '\V\t\.\*', "", "" )

    let suffix = matchstr( fn, '\V\.\[^.]\+\$' )
    let suffix = "*" . suffix

    if suffix == g:VEConf.filePanelFilter
        let g:VEConf.filePanelFilter = "*"
    else
        let g:VEConf.filePanelFilter = suffix
    endif

endfunction "}}}

nnoremap <Leader>ve :call <SID>changeVEFilter()<CR>:call VE_RefreshFilePanel()<CR>
