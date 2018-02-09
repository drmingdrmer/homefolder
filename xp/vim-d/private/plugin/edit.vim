if exists( "g:__XP__PLUGIN__EDIT_VIM__" )
    finish
endif
let g:__XP__PLUGIN__EDIT_VIM__ = 1

set history=500

set virtualedit=block,onemore,insert           " cursor could located outside of content in visual mode and in normal mode the last char
set whichwrap+=<,>,h,l,[,]                     " allow to move to other line
set backspace=indent,eol,start                 " <backspace> behavior

set nostartofline

"How many tenths of a second to blink
set matchtime=2


set formatoptions=c       " auto wrap comment
set formatoptions+=r      " auto insert current comment leader on <CR>
set formatoptions+=o      " auto insert current comment leader on o
set formatoptions+=q      " allow formatting of comment with gq
set formatoptions+=l      " long lines are not broken in insert mode

set cindent

set joinspaces		" Join adds two spaces after a period.
set completeopt=menu,longest

" netrw tree window
let g:netrw_liststyle=3 " tree view
let g:netrw_browse_split=4 " open in previous window
let g:netrw_hide=1
let g:netrw_list_hide='\V.svn/\$'

" use register 0 always
xnoremap d ygvd
nnoremap dd yydd

xnoremap p "0p
nnoremap p "0p

xnoremap P "0P
nnoremap P "0P



" <C-g><C-c>



"
"map{{{
inoremap <expr> <Plug>edit:insert:toNormal <SID>InsertToNormal()
nnoremap <Plug>edit:error_next        :cn<CR>
nnoremap <Plug>edit:error_prev        :cp<CR>
nmap     <Plug>edit:tagAllDoc         :call <SID>TagAllDoc()<CR>
imap     <Plug>edit:del               <Del>
nmap     <Plug>edit:del               <Del>
vmap     <Plug>edit:del               <Del>
vmap     <Plug>case:camelize          :s/\<\w/\u\0/g<cr><Leader>h
vmap     <Plug>case:switch_camel_underline          <Plug>edit:selectWord
imap     <Plug>complete:omni          <C-x><C-o>
nmap     <Plug>edit:copy_cur_word     :let @"=<C-r>='expand("<cword>")'<cr><cr>
vnoremap <Plug>edit:copy_to_tmp       :w! ~/clp<cr>gv"+y

fun! s:try_map_clipboard() "{{{
    let t = reltime()
    let text = '' . (t[0] * 1000 * 1000 + t[1])

    try
        let saved = @+
        let @+ = text
        if @+ == text

            xnoremap <Plug>edit:x_copy            ygv"+y
            inoremap <Plug>edit:x_paste           <C-o>"+p
            let @+ = saved

            return
        endif
    catch /.*/
    endtry

    if executable("xclip")
        xnoremap <Plug>edit:x_copy            :w! ~/..clp<cr>:silent !cat ~/..clp\|xclip -selection clipboard<cr>gvy
        inoremap <Plug>edit:x_paste           <esc>:r! xclip -o -selection clipboard<cr>
        return
    endif

    xnoremap <Plug>edit:x_copy            :w! ~/..clp<cr>gvy
    inoremap <Plug>edit:x_paste           <esc>:r ~/..clp<cr>

endfunction "}}}
call s:try_map_clipboard()

imap          <Plug>edit:paste_from_tmp    <esc>:r ~/clp<cr>i
nmap          <Plug>edit:move_up           mz:m-2<cr>`z==
nmap          <Plug>edit:move_down         mz:m+<cr>`z==

vnoremap      <Plug>edit:move_up           :m'<-2<cr>gv=gv
vnoremap      <Plug>edit:move_down         :m'>+<cr>gv=gv

vnoremap      <Plug>edit:move_left         x<left>Pgv<left>o<left>o
vnoremap      <Plug>edit:move_right        xpgv<right>o<right>o
nmap     <Plug>edit:select_all        ggVG
nmap     <Plug>edit:switch_paste_mode :set paste!<cr>
nnoremap <Plug>edit:dupli_line        yy"0p
nnoremap <Plug>edit:paste_and_format  jm'kp=''
" paste from "0, the yank register, and replace ""(the current reg) content
vnoremap <Plug>edit:paste_yanked      "0p:let @"=@0<cr>
inoremap <Plug>insert:insert_tab      <C-v><tab>
imap     <Plug>edit:move_right        <C-o>x<C-o>p<left>
imap     <Plug>edit:move_left         <C-o>x<left><C-o>P<left>
nnoremap <Plug>format:3line           3k=6j3j
"map}}}

nmap =<space> <Plug>format:3line
nmap =3 <Plug>format:3line


" convert to underline form
vmap <Leader><Leader>el :s/\(\l\)\(\u\)/\1_\l\2/eg<cr><Leader>h
" nmap <Leader><Leader>el mo<space>w<Leader><Leader>el`o

vmap <Leader><Leader>em :s/\(\l\)_\(\l\)/\1\u\2/eg<cr><Leader>h
" nmap <Leader><Leader>em mo<space>w<Leader><Leader>em`o

nmap <C-b> i<cr><C-c>=k$

" nnoremap <space>p "0p
" nnoremap <space>P "0P

imap <M-p> <C-r>0

imap <M-w> <C-o>de
vnoremap zf <C-c>'<:s/\s*$/ /<cr>'>:s/\s*$/ /<cr>gvzf/<C-v><C-v><cr>
" nmap d<space> dd


fun! s:InsertToNormal() "{{{
    let pum_close = ""
    if pumvisible()
        let pum_close = "\<C-e>"
    endif
    let post = ""
    if col( "." ) > 1 && getline( line(".") ) !~ '\v^\s*$'
        let post = "\<Right>"
    endif
    return pum_close . "\<C-c>" . post
endfunction "}}}

fun! s:TagAllDoc() "{{{
    for rtp in split( &rtp, ',' )
        echom rtp
        exe 'helptags' rtp . '/doc'
    endfor
endfunction "}}}

let s:curReg = 1
fun! s:SelDelReg(i)
  let s:curReg = s:curReg + a:i
  if (s:curReg < 1 || s:curReg > 9)
    let s:curReg -= a:i
  endif

  let cur = eval("@".s:curReg)
  let @" = cur

  echo s:curReg." : ".substitute(cur, '\n\_.*', '', 'g')

endfunction


let s:SelRegEna = 0
fun! s:SetupSelReg()
  let s:SelRegEna = 1 - s:SelRegEna
  if (s:SelRegEna)
    nmap <buffer> j :call <SID>SelDelReg(1)<cr>
    nmap <buffer> k :call <SID>SelDelReg(-1)<cr>
    " use yank register as default
    nmap <buffer> l :let @"=@0<cr>:call <SID>SetupSelReg()<cr>
    nmap <buffer> <cr> :call <SID>SetupSelReg()<cr>
  else
    nunmap <buffer> j
    nunmap <buffer> k
    nunmap <buffer> l
    nunmap <buffer> <cr>
  endif
endfunction
nmap ,r :call <SID>SetupSelReg()<cr>


function! CpPath()
  " let x = getcwd()."/".bufname("%")
  let x = expand("%:p")
  if has("win32")
    let x = substitute(x, "/", "\\", "g")
  endif
  let @+ =x
endfunction

fun! s:remove_trailing_blank() "{{{
    let search = @/
    call view#win#SaveCursorPosition()

    %s/\s*$//g

    call view#win#RestoreCursorPosition()
    let @/ = search
endfunction "}}}

fun! s:remove_blank_lines() "{{{
    call view#win#SaveCursorPosition()

    %g/^\s*$/normal dd

    call view#win#RestoreCursorPosition()
endfunction "}}}


"Copy Current path
com! XXcc call CpPath()

com! XXtagdoc call <SID>TagAllDoc()
com! XXrmeb call <SID>remove_trailing_blank()
com! XXrmbl call <SID>remove_blank_lines()

" shrink blank
com XXsbl %s/\s+/ /g

"fold close comment
com! XXfcc g/\/\*\*/normal zC
com! XXfoc g/\/\*\*/normal zO



" Edit configs

if v:version >=703
    set noundofile
    set undoreload=1000
    set undodir=.
endif
