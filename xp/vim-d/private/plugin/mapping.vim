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

" user complete
inoremap <unique> <M-i> <C-x><C-u>

fun! s:DoMap() "{{{
    let mapping = [
          \ [ 'nmap', "[[",                   "<Plug>func_start" ],
          \ [ 'nmap', "][",                   "<Plug>func_end" ],
          \
          \ [ 'imap', "<C-a><C-v>",           "<Plug>edit:x_paste" ],
          \ [ 'imap', "<M-f>",                "<Plug>insert:comment" ],
          \ [ 'imap', "<C-c>",                "<Plug>edit:insert:toNormal" ],
          \ [ 'imap', "<C-space>",            "<Plug>complete:omni" ],
          \ [ 'imap', "<C-u>",                "<Plug>edit:del" ],
          \ [ 'imap', "<M-v>",                "<Plug>edit:paste_from_tmp" ],
          \ [ 'nmap', ",0",                   "<Plug>buffer:to0" ],
          \ [ 'nmap', ",1",                   "<Plug>buffer:to1" ],
          \ [ 'nmap', ",9",                   "<Plug>buffer:to9" ],
          \ [ 'nmap', ",<Plug>F4",            "<Plug>buffer:rm_buf_win" ],
          \ [ 'nmap', ",me",                  "<Plug>buffer:make_executable" ],
          \
          \ [ 'nmap', "<C-w><C-]>",           "<Plug>buffer:tag_in_preview_right" ],
          \ [ 'nmap', "<C-w>]",               "<Plug>buffer:tag_in_preview_top" ],
          \
          \ [ 'nmap', "<Leader><Leader>ds",  "<Plug>diff:diff_with_saved" ],
          \
          \ [ 'nmap', "<C-g><C-]>",           "<Plug>edit:gtags:goto-definition" ],
          \ [ 'nmap', "<C-g><C-r>",           "<Plug>edit:gtags:goto-reference" ],
          \ [ 'nmap', "<C-g><C-n>",           ":cnext<CR>" ],
          \ [ 'nmap', "<C-g><C-p>",           ":cprevious<CR>" ],
          \ [ 'nmap', "<C-g><C-l>",           ":clist<CR>" ],
          \ [ 'nmap', "<M-3>",                "<Plug>window:quickfix:toggle" ],
          \ [ 'nmap', ",3",                   "<Plug>window:location:toggle" ],
          \
          \ [ 'nmap', "<C-w><C-l>",           ":call edit#preview#Open()<CR>" ],
          \ [ 'nmap', ",p",                   "<Plug>edit:paste_and_format" ],
          \ [ 'nmap', ",x",                   "<Plug>eidt:switch_word" ],
          \ [ 'nmap', "<C-j>",                "<Plug>edit:move_down" ],
          \ [ 'nmap', "<C-k>",                "<Plug>edit:move_up" ],
          \ [ 'nmap', "<Leader><Leader>idn",  "<Plug>format:json_format" ],
          \ [ 'nmap', "<Leader><Leader>ff",   "<Plug>format:format_file" ],
          \ [ 'nmap', "<Leader><Leader>fi",   "<Plug>format:import" ],
          \ [ 'nmap', "<Leader><Leader>rr",   "<Plug>refactor:rename" ],
          \ [ 'nmap', "<Leader><Leader>sd",   "<Plug>search:word_in_cwd" ],
          \ [ 'nmap', "<Leader><Leader>sf",   "<Plug>search:word_in_cfile" ],
          \ [ 'nmap', "<Leader><Leader>sr",   "<Plug>search:word_ref" ],
          \ [ 'nmap', "<Leader><Leader>sc",   "<Plug>search:word_callstack" ],
          \ [ 'nmap', "<Leader><Leader>sp",   "<Plug>edit:switch_paste_mode" ],
          \ [ 'nmap', "<Leader><Leader>tt",   "<Plug>buffer:createTags" ],
          \ [ 'nmap', "<Leader>bw",           "<Plug>buffer:rm_buf_only" ],
          \ [ 'nmap', "<Leader>ccm",          "V<Plug>case:camelize" ],
          \ [ 'nmap', "<Leader>pc",           "<Plug>path:to_cur_file" ],
          \ [ 'nmap', "<Leader>e",            "<Plug>edit:error_next" ],
          \ [ 'nmap', "<Leader>E",            "<Plug>edit:error_prev" ],
          \ [ 'nmap', "<M-I>",                "<Plug>nav:tab_move_forward" ],
          \ [ 'nmap', "<M-U>",                "<Plug>nav:tab_move_backword" ],
          \ [ 'nmap', "<M-c>",                "<Plug>buffer:rm_buf_win" ],
          \ [ 'nmap', "<M-W>",                "<Plug>buffer:rm_buf_win" ],
          \ [ 'nmap', "<M-i>",                "<Plug>nav:tab_next" ],
          \ [ 'nmap', "<M-o>",                "<Plug>buffer:prev" ],
          \ [ 'nmap', "<M-p>",                "<Plug>buffer:next" ],
          \ [ 'nmap', "<M-u>",                "<Plug>nav:tab_prev" ],
          \ [ 'nmap', "<Plug>F4",             "<Plug>buffer:rm_buf_only" ],
          \ [ 'nmap', "<M-w>",                "<Plug>buffer:rm_buf_close" ],
          \ [ 'nmap', "ga",                   "<Plug>edit:select_all" ],
          \ [ 'nmap', "yp",                   "<Plug>edit:dupli_line" ],
          \ [ 'nmap', "yw",                   "<Plug>edit:copy_cur_word" ],
          \ [ 'xmap', ",b",                   "<Plug>format:c:func_split_80" ],
          \ [ 'xmap', ",c",                   "<Plug>format:c:func_with_blank" ],
          \ [ 'xmap', "<C-h>",                "<Plug>edit:move_left" ],
          \ [ 'xmap', "<C-j>",                "<Plug>edit:move_down" ],
          \ [ 'xmap', "<C-k>",                "<Plug>edit:move_up" ],
          \ [ 'xmap', "<C-l>",                "<Plug>edit:move_right" ],
          \ [ 'xmap', "<Leader>ccm",          "<Plug>case:camelize" ],
          \ [ 'xmap', "<M-c>",                "<Plug>edit:copy_to_tmp" ],
          \ [ 'xmap', "c",                    "<Plug>edit:x_copy" ],
          \ [ 'xmap', "DW",                   ":call edit#align#VerticalDeleteToWordStart()<CR>" ],
          \
          \ [ 'nmap', "<Leader><Leader>th",   "<Plug>view:highlight_focus_toggle" ],
          \ [ 'nmap', "<M-K>",                "<Plug>view:highlight_focus_prev" ],
          \ [ 'nmap', "<M-J>",                "<Plug>view:highlight_focus_next" ],
          \ ]
    for [ cmd, key, cont ] in mapping
        exe cmd "<unique>" key cont
    endfor

    " xmap <unique> ,a                  <Plug>format:c:1_func_1_line
    " nmap <unique> <M-w>               <Plug>buffer:rm_buf_only
endfunction "}}}
call s:DoMap()

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
