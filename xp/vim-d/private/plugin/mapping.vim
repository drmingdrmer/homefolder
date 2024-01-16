if exists( "g:__XP__PLUGIN__MAPPING_VIM__" )
    finish
endif
let g:__XP__PLUGIN__MAPPING_VIM__ = 1

try
    " prevent conflicting to vim default mapping
    iunmap <C-u>
catch /.*/
endtry

nnoremap <silent> <Plug>edit:highlight_none             :let @/=""<CR>
nnoremap <silent> <Plug>plugin:nerd_tree:toggle         :silent! WinRem<cr>:silent! NERDTreeToggle<cr>:silent! WinBack<cr>
xnoremap <Plug>edit:visual:delete                       d

nmap ,,                         <Plug>view:highlight_cursor_word
xmap ,,                         <Plug>view:highlight_cursor_word
nmap <Leader>h                  <Plug>edit:highlight_none
nmap <Leader><space>            :XX
map Q                           gq
nmap <M-7>                      :WinRem<cr>:TlistToggle<CR>:WinBack<cr>
nmap <M-2>                      <Plug>plugin:nerd_tree:toggle
nmap ,w :w<cr>
nmap <Leader><Leader>wr :w<cr>:so %<cr>
nmap <Leader><Leader>wmk :w<cr>:make<cr>
nmap <Leader><Leader>wmr :w<cr>:!rake<cr>

" matchit remap
nmap [<space> [%
nmap ]<space> ]%
xmap [<space> [%
xmap ]<space> ]%

nmap <unique> <Leader>s <Plug>view:switchSetting
nmap <unique> ^         <Plug>(edit:case:switch)

" Deprecated, use xp/bash-d/bin/normfn.sh
" make a line of text valid fn string
" - replace non word char with "-"
" - convert to lower case
" nmap <unique> <Leader><Leader>fn :s/\W\W*/-/g<CR>Vgu

" TODO only on mac it uses open
" it also redraw to update vim display.
nnoremap <Plug>(buffer:open:with-external-editor) :silent! !open "%"<CR>:redraw!<CR>

" " user complete
" inoremap <unique> <M-i> <C-x><C-u>

" mapping:
" key --> abstract function        --> function impl
" 99rr    <Plug>(refactor:rename)      <Plug>(coc-rename)    // for rust
"                                      :GoRename<CR>         // for go
"
"                                      in ftplugin or other plugin rc


xmap <unique> DW                  	 :call edit#align#VerticalDeleteToWordStart()<CR>
nmap <unique> <C-w><C-l>          	 :call edit#preview#Open()<CR>
nmap <unique> <C-g><C-l>          	 :clist<CR>
nmap <unique> <C-g><C-n>          	 :cnext<CR>
nmap <unique> <C-g><C-p>          	 :cprevious<CR>
nmap <unique> <Leader><Leader>tt  	 <Plug>buffer:createTags
nmap <unique> ,me                 	 <Plug>buffer:make_executable
nmap <unique> <M-p>               	 <Plug>buffer:next
nmap <unique> <M-o>               	 <Plug>buffer:prev
nmap <unique> <M-w>               	 <Plug>buffer:rm_buf_close
nmap <unique> <Leader>bw          	 <Plug>buffer:rm_buf_only
nmap <unique> <Plug>F4            	 <Plug>buffer:rm_buf_only
nmap <unique> ,<Plug>F4           	 <Plug>buffer:rm_buf_win
nmap <unique> <M-c>               	 <Plug>buffer:rm_buf_win
nmap <unique> <M-W>               	 <Plug>buffer:rm_buf_win
nmap <unique> <C-w><C-]>          	 <Plug>buffer:tag_in_preview_right

nmap <unique> go                  	 <Plug>(buffer:open:with-external-editor)
nmap <unique> <Leader>fa          	 <Plug>(code:action)
nmap <unique> <Leader>ff          	 <Plug>(code:fix)
imap <unique> <M-i>               	 <Plug>(complete:syntax)
nmap <unique> K                   	 <Plug>(doc:ref)
imap <unique> <C-]>               	 <Plug>(edit:digraph:trigger)
nmap <unique> <Leader><Leader>ff  	 <Plug>(format:file)
nmap <unique> <Leader><Leader>fi  	 <Plug>(format:import)
nmap <unique> <C-]>               	 <Plug>(goto:definition)
nmap <unique> gi                  	 <Plug>(goto:impl)
nmap <unique> gr                  	 <Plug>(goto:reference)
nmap <unique> gt                  	 <Plug>(goto:type)
nmap <unique> <Leader>e           	 <Plug>(navigate:error_next)
nmap <unique> <Leader>E           	 <Plug>(navigate:error_prev)
nmap <unique> <Leader><Leader>rr  	 <Plug>(refactor:rename)

" nmap <unique> <C-y>               	 <Plug>(view:scroll:ignorebind:u)
" nmap <unique> <C-e>               	 <Plug>(view:scroll:ignorebind:d)
nmap <unique> <M-H>               	 <Plug>(view:scroll:left:10)
nmap <unique> <M-L>               	 <Plug>(view:scroll:right:10)
nmap <unique> <M-J>               	 <Plug>(view:scroll:down:5)
nmap <unique> <M-K>               	 <Plug>(view:scroll:up:5)

nmap <unique> <C-w>]              	 <Plug>buffer:tag_in_preview_top
nmap <unique> ,0                  	 <Plug>buffer:to0
nmap <unique> ,1                  	 <Plug>buffer:to1
nmap <unique> ,2                  	 <Plug>buffer:to2
nmap <unique> ,3                  	 <Plug>buffer:to3
nmap <unique> ,9                  	 <Plug>buffer:to9
xmap <unique> <Leader>ccm         	 <Plug>case:camelize
nmap <unique> <Leader><Leader>ds  	 <Plug>diff:diff_with_saved
nmap <unique> yw                  	 <Plug>edit:copy_cur_word
xmap <unique> <M-c>               	 <Plug>edit:copy_to_tmp
imap <unique> <C-u>               	 <Plug>edit:del
nmap <unique> yp                  	 <Plug>edit:dupli_line
nmap <unique> <C-g><C-]>          	 <Plug>edit:gtags:goto-definition
nmap <unique> <C-g><C-r>          	 <Plug>edit:gtags:goto-reference
imap <unique> <C-c>               	 <Plug>edit:insert:toNormal
nmap <unique> <C-j>               	 <Plug>edit:move_down
xmap <unique> <C-j>               	 <Plug>edit:move_down
xmap <unique> <C-h>               	 <Plug>edit:move_left
xmap <unique> <C-l>               	 <Plug>edit:move_right
nmap <unique> <C-k>               	 <Plug>edit:move_up
xmap <unique> <C-k>               	 <Plug>edit:move_up
nmap <unique> ,p                  	 <Plug>edit:paste_and_format
imap <unique> <M-v>               	 <Plug>edit:paste_from_tmp
nmap <unique> ga                  	 <Plug>edit:select_all
nmap <unique> <Leader><Leader>sp  	 <Plug>edit:switch_paste_mode
xmap <unique> c                   	 <Plug>edit:x_copy
imap <unique> <C-a><C-v>          	 <Plug>edit:x_paste
nmap <unique> ,x                  	 <Plug>edit:switch_word
xmap <unique> ,b                  	 <Plug>format:c:func_split_80
xmap <unique> ,c                  	 <Plug>format:c:func_with_blank
nmap <unique> <Leader><Leader>idn 	 <Plug>format:json_format
nmap <unique> ][                  	 <Plug>func_end
nmap <unique> [[                  	 <Plug>func_start
imap <unique> <M-f>               	 <Plug>insert:comment
nmap <unique> <M-U>               	 <Plug>nav:tab_move_backword
nmap <unique> <M-I>               	 <Plug>nav:tab_move_forward
nmap <unique> <M-i>               	 <Plug>nav:tab_next
nmap <unique> <M-u>               	 <Plug>nav:tab_prev
nmap <unique> <Leader>pc          	 <Plug>path:to_cur_file
nmap <unique> <Leader><Leader>gf  	 <Plug>git:gotofix
nmap <unique> <Leader><Leader>ub  	 <Plug>run:build
nmap <unique> <Leader><Leader>ur  	 <Plug>run:run
nmap <unique> <Leader><Leader>ut  	 <Plug>run:test:current_dir
nmap <unique> <Leader><Leader>uf  	 <Plug>run:test:func
nmap <unique> <Leader><Leader>uc  	 <Plug>run:coverage:run
nmap <unique> <Leader><Leader>ud  	 <Plug>run:coverage:toggle
nmap <unique> <Leader><Leader>sc  	 <Plug>search:word_callstack
nmap <unique> <Leader><Leader>sf  	 <Plug>search:word_in_cfile
nmap <unique> <Leader><Leader>sd  	 <Plug>search:word_in_cwd
nmap <unique> <Leader><Leader>sr  	 <Plug>search:word_ref
" nmap <unique> <M-J>               	 <Plug>view:highlight_focus_next
" nmap <unique> <M-K>               	 <Plug>view:highlight_focus_prev
nmap <unique> <Leader><Leader>th  	 <Plug>view:highlight_focus_toggle
nmap <unique> <M-3>               	 <Plug>window:quickfix:loop
nmap <unique> <Leader>ccm         	 V<Plug>case:camelize

" xmap <unique> ,a                  <Plug>format:c:1_func_1_line
" nmap <unique> <M-w>               <Plug>buffer:rm_buf_only

" if !has('win32')
"     smap <unique> <C-c>               <C-o><Plug>edit:x_copy
" endif
"
"conflict with other mapping..
" imap     <M-L>		    <Plug>edit:move_right
" imap	 <M-H>		    <Plug>edit:move_left
"
" disabled
" vmap <unique> ,d                  <Plug>format:c:func_split_args



" remap plugin's
vmap ,d <Leader>adec
