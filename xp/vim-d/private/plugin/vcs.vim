" Re-edit a line at the commit it is last edited.
" It opens a new shell and a new vim for editing.
" It is actually a customized git-rebase command.
" It relies on xp's script git-gotofix
nnoremap <Plug>git:gotofix :Git gotofix "<C-r>%" <C-r>=line(".")<CR><CR>
