fun! s:XScriptLatestVer(id, tofile) "{{{
  let url = "http://www.vim.org/scripts/script.php?script_id=".a:id
  new 
  set buftype=nofile
  exe 'silent Nread '.url
  " exe 'Nread '.url

  let startStr = "Click on the package to download"

  call cursor( 1, 1 )


  let p = searchpos( startStr, 'W' )
  if p == [ 0, 0 ]
  endif

  if searchpos( 'download_script.php' ) == [ 0, 0 ]
        bw
      return [ "", "", "" ]
  endif

  let line = getline( line(".") )
  let lineNext = getline( line(".") + 1 )

  let name = matchstr( line, '\V>\zs\[^>]\*\ze</a>' )
  let linkid = matchstr( line, '\Vsrc_id=\zs\.\*\ze"' )

  let linkUrl = "http://www.vim.org/scripts/download_script.php?src_id=" . linkid
  let ver = matchstr( lineNext, '\V<b>\zs\.\+\ze</b>' )



  bw

  call writefile( [ 'package=' . name, 'newver=' . ver, 'url=' . linkUrl ], a:tofile )

  return [ name, ver, linkUrl ]

endfunction "}}}

com! -nargs=* XscriptVer call <SID>XScriptLatestVer(<f-args>) | quit
" com! -nargs=* XscriptVer echom string( <SID>XScriptLatestVer(<f-args>) )
