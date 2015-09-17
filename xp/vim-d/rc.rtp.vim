if exists("g:__RC_RTP_VIM__")
    finish
endif
let g:__RC_RTP_VIM__ = 1

fun! s:GenerateRTP()
    let xp_rtp = []

    let xp_rtp += [	'private'				]

    let xp_rtp += [	'plugins.modified/' . 'matchparen'	]

    let xp_rtp += [	'plugins/' . 'colorschemes'	]

    let xp_rtp += [ '.vim'	]
    let xp_rtp += [ 'after'	]
    return xp_rtp
endfunction

fun! s:ConfigRTP() "{{{

    " load system depended resource file


    let afterDirs = ''
    let xp_rtp = s:GenerateRTP()


    " backup runtime path setting
    let xp = &rtp
    let xp = substitute(xp, "[A-Z]:\\\\Docu.\\{-}\\(,\\|$\\)", "",  "g")

    set rtp=

    for rtppath in xp_rtp
        if rtppath !~ '^\V\w:\\' && rtppath !~ '^/'
            let rtppath = g:XPvimrcCurrentDir .'/'. rtppath
        endif


        let aft = globpath(rtppath, 'after')
        if aft != ''
            let afterDirs .= ',' . rtppath . '/after'
        endif


        let &rtp .= rtppath . ','
    endfor

    " remove the last ','
    let &rtp = &rtp[ : -2 ]

    exe "so" g:XPvimrcCurrentDir . '/rc.vim-scripts.vim'

    " appand backupped rtp
    let &rtp .= ',' . xp .  afterDirs . ',' . g:XPvimrcCurrentDir . '/after'


    " TODO needed?
    " As we have reset all the runtime path, ftdetect scripts must be reloaded
    runtime! ftdetect/*.vim

endfunction "}}}

call s:ConfigRTP()

" vim:tw=78:ts=8:sw=4:sts=4:et:norl:fdm=marker:fmr={{{,}}}
