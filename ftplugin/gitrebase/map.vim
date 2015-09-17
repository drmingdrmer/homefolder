nnoremap <buffer> P :s/\v^\S* /pick /<CR>:let @/=""<CR><Down>
nnoremap <buffer> R :s/\v^\S* /reword /<CR>:let @/=""<CR><Down>
nnoremap <buffer> E :s/\v^\S* /edit /<CR>:let @/=""<CR><Down>
nnoremap <buffer> S :s/\v^\S* /squash /<CR>:let @/=""<CR><Down>
nnoremap <buffer> F :s/\v^\S* /fixup /<CR>:let @/=""<CR><Down>

" p, pick = use commit
" r, reword = use commit, but edit the commit message
" e, edit = use commit, but stop for amending
" s, squash = use commit, but meld into previous commit
" f, fixup = like "squash", but discard this commit's log message
" x, exec = run command (the rest of the line) using shell
