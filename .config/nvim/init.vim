set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc

finish

" the following is from #91
" by:
" https://github.com/roket1428


call plug#begin('~/.config/nvim/bundle')
Plug 'drmingdrmer/xptemplate'
call plug#end()

let g:xptemplate_key = "<tab>"
let g:xptemplate_key_visual = "<tab>"
let g:xptemplate_nav_prev = "<a-tab>"
let g:xptemplate_fallback = "<tab>"
let g:xptemplate_snippet_folders = [$XDG_CONFIG_HOME . "/nvim/snips"]

set langmap=TD
" set langmap=AA
cno <a-h> <left>
cno <a-j> <down>
cno <a-k> <up>
cno <a-l> <right>

no <a-v> <c-v>
no <a-r> <c-r>

ino <a-e> <c-n>
ino <a-i> <c-p>

no j g<down>
no k g<up>
no $ g$
no 0 g0
no ^ g^

nn <leader>vh <C-w><left>
nn <leader>vj <C-w><down>
nn <leader>vk <C-w><up>
nn <leader>vl <C-w><right>

nn <leader>vH <C-w>>
nn <leader>vJ <C-w>-
nn <leader>vK <C-w>+
nn <leader>vL <C-w><

cno w!! w !sudo tee % >/dev/null

nno <tab> za
xno <tab> zf
nno <expr> <a-tab> &foldlevel ? "zM" : "zR"

nno <silent> <a-w> :w<cr>
ino <silent> <a-w> <esc>:w<cr>a

tno <a-tab> <c-\><c-n>

for i in range(10)
  if !i
    nno <a-0> 10gt
    no! <a-0> <esc>10gt
    continue
  endif
    exe "nno <a-" . i . "> <esc>" . i . "gt"
    exe "no! <a-" . i . "> <esc>" . i . "gt"
endfor
