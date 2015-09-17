if exists( "b:__XP_MACRO_COLOR_EDIT_VIM__" )
    finish
endif
let b:__XP_MACRO_COLOR_EDIT_VIM__ = 1


let ftToContainer = {
    \ 'vim' : 'vimHiGuiRgb',
    \ 'css' : 'cssColor',
    \ }

let b:__syn_colors__ = {}

let b:colorContainerName = get( ftToContainer, &filetype, '' )

if b:colorContainerName != ''
    let b:colorContainerName = 'containedin=' . b:colorContainerName
endif


fun! Draw()
  let curpos = [line("."), col(".")]

  call cursor(1, 1)

  call cursor(curpos)
endfunction

fun! s:highLightColor( clr )
  let clr = a:clr

  if clr !~ '\x\{6}'
    " echom "not a color : " . clr
    return
  endif

  let clr = matchstr( clr, '\x\{6}' )

  " echom "to match color:" . clr

  if has_key( b:__syn_colors__, clr )
    return
  endif


  let b:__syn_colors__[ clr ] = 1


  if &iskeyword =~ '\V#'
    exe 'syntax keyword XPS_' . clr . ' #' . clr . ' ' . b:colorContainerName . ' contained'
  else
    exe 'syntax keyword XPS_' . clr . ' ' . clr . ' ' . b:colorContainerName . '  contained'
  endif

  " exe 'syntax keyword XPS_' . clr . ' ' . clr . ' '


  if clr =~ '^[0-7]'
    let fg = 'white'
  else
    let fg = 'black'
  endif
  exe 'hi XPS_' . clr . ' guifg=' . fg . ' guibg=#' . clr

  " echom "highlighted:" . clr


endfunction


let s:mapI = {
      \'0' : '1', 
      \'1' : '2', 
      \'2' : '3', 
      \'3' : '4', 
      \'4' : '5', 
      \'5' : '6', 
      \'6' : '7', 
      \'7' : '8', 
      \'8' : '9', 
      \'9' : 'a', 
      \'a' : 'b', 
      \'b' : 'c', 
      \'c' : 'd', 
      \'d' : 'e', 
      \'e' : 'f', 
      \'f' : '0'
      \}
let s:mapD = {
      \'0' : 'f', 
      \'1' : '0', 
      \'2' : '1', 
      \'3' : '2', 
      \'4' : '3', 
      \'5' : '4', 
      \'6' : '5', 
      \'7' : '6', 
      \'8' : '7', 
      \'9' : '8', 
      \'a' : '9', 
      \'b' : 'a', 
      \'c' : 'b', 
      \'d' : 'c', 
      \'e' : 'd', 
      \'f' : 'e'
      \}
fun! s:ChangeRGB(i, inc)
  if a:inc == 1
    return s:mapI[ a:i ]
  else
    return s:mapD[ a:i ]
  endif
endfunction

nnoremap <buffer> + s<C-r>=<SID>ChangeRGB(@",1)<cr><esc>:exe getline(".")<cr>
nnoremap <buffer> _ s<C-r>=<SID>ChangeRGB(@",0)<cr><esc>:exe getline(".")<cr>

augroup XPsyntaxColor
  au!
  au CursorHold,CursorHoldI <buffer> call <SID>highLightColor(expand( "<cword>" ))
augroup END


function! s:RGB_HSV(red, green, blue) "{{{
  let max = a:red > a:green ? a:red : a:green
  let max = max > a:blue ? max : a:blue
  let min = a:red < a:green ? a:red : a:green
  let min = min < a:blue ? min : a:blue
  let value = max
  let d = max - min
  if d > 0
    let saturation = 255*d/max
    if a:red == max
      let hue = 60*(a:green - a:blue)/d
    elseif a:green == max
      let hue = 120 + 60*(a:blue - a:red)/d
    else
      let hue = 240 + 60*(a:red - a:green)/d
    endif
    let hue = (hue + 360) % 360
  else
    let saturation = 0
    let hue = 0
  endif

  return [ hue, saturation, value ]
endfun "}}}

function! s:HSV_RGB(hue, saturation, value) "{{{
  let red   = s:HSV_R(a:hue, a:saturation, a:value)
  let green = s:HSV_G(a:hue, a:saturation, a:value)
  let blue  = s:HSV_B(a:hue, a:saturation, a:value)
  return [ red, green, blue ]
endfun "}}}

function! s:HSV_R(h, s, v) "{{{
  if a:s == 0
    return a:v
  endif
  let f = a:h % 60
  let i = a:h/60
  if i == 0 || i == 5
    return a:v
  elseif i == 2 || i == 3
    return a:v*(255 - a:s)/255
  elseif i == 1
    return a:v*(255*60 - (a:s*f))/60/255
  else
    return a:v*(255*60 - a:s*(60 - f))/60/255
  endif
endfun "}}}

function! s:HSV_G(h, s, v) "{{{
  if a:s == 0
    return a:v
  endif
  let f = a:h % 60
  let i = a:h/60
  if i == 1 || i == 2
    return a:v
  elseif i == 4 || i == 5
    return a:v*(255 - a:s)/255
  elseif i == 3
    return a:v*(255*60 - (a:s*f))/60/255
  else
    return a:v*(255*60 - a:s*(60 - f))/60/255
  endif
endfun "}}}

function! s:HSV_B(h, s, v) "{{{
  if a:s == 0
    return a:v
  endif
  let f = a:h % 60
  let i = a:h/60
  if i == 3 || i == 4
    return a:v
  elseif i == 0 || i == 1
    return a:v*(255 - a:s)/255
  elseif i == 5
    return a:v*(255*60 - (a:s*f))/60/255
  else
    return a:v*(255*60 - a:s*(60 - f))/60/255
  endif
endfun "}}}


let s:step = 4
fun! s:ChangeHSV( clr, key ) "{{{
    " let color = expand( '<cword>' )
    let color = a:clr
    let color = matchstr( color, '[a-zA-Z0-9]\{6}' )
    if color == ''
        return
    endif


    let rgb = split( color, '..\zs' )
    call map( rgb, 'eval("0x" . v:val)' )

    let hsv = s:RGB_HSV( rgb[0], rgb[1], rgb[2] )

    if a:key ==# 'h'
        let hsv[0] += s:step
    elseif a:key ==# 'H'
        let hsv[0] -= s:step
    elseif a:key ==# 's'
        let hsv[1] += s:step
    elseif a:key ==# 'S'
        let hsv[1] -= s:step
    elseif a:key ==# 'v'
        let hsv[2] += s:step
    elseif a:key ==# 'V'
        let hsv[2] -= s:step
    endif

    let rgb = s:HSV_RGB( hsv[0], hsv[1], hsv[2] )

    call map( rgb, 'v:val > 255 ? 255 : v:val' )
    call map( rgb, 'v:val < 0 ? 0 : v:val' )

    
    if &iskeyword =~ '\V#'
        let sharpChar = '#'
    else
        let sharpChar = ''
    endif
    return sharpChar . printf( '%02x%02x%02x', rgb[0], rgb[1], rgb[2] )

endfunction "}}}
" #123456

nnoremap <buffer> <M-h> :call search( '\<', 'bcW' )<cr>cw<C-r>=<SID>ChangeHSV(@", 'h')<cr><esc>:silent! exe getline(".")<cr>
nnoremap <buffer> <M-H> :call search( '\<', 'bcW' )<cr>cw<C-r>=<SID>ChangeHSV(@", 'H')<cr><esc>:silent! exe getline(".")<cr>

nnoremap <buffer> <M-s> :call search( '\<', 'bcW' )<cr>cw<C-r>=<SID>ChangeHSV(@", 's')<cr><esc>:silent! exe getline(".")<cr>
nnoremap <buffer> <M-S> :call search( '\<', 'bcW' )<cr>cw<C-r>=<SID>ChangeHSV(@", 'S')<cr><esc>:silent! exe getline(".")<cr>

nnoremap <buffer> <M-v> :call search( '\<', 'bcW' )<cr>cw<C-r>=<SID>ChangeHSV(@", 'v')<cr><esc>:silent! exe getline(".")<cr>
nnoremap <buffer> <M-V> :call search( '\<', 'bcW' )<cr>cw<C-r>=<SID>ChangeHSV(@", 'V')<cr><esc>:silent! exe getline(".")<cr>

nnoremap <buffer> <M-l> :call search( '\<', 'bcW' )<cr>cw<C-r>=<SID>ChangeHSV(@", 'v')<cr><esc>:silent! exe getline(".")<cr>
nnoremap <buffer> <M-L> :call search( '\<', 'bcW' )<cr>cw<C-r>=<SID>ChangeHSV(@", 'V')<cr><esc>:silent! exe getline(".")<cr>
