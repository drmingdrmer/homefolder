FinishIfNotLoaded

au FileType rust nmap <C-]>      <Plug>(rust-def)
au FileType rust nmap <C-w>]     <Plug>(rust-def-split)
au FileType rust nmap <C-w><C-]> <Plug>(rust-def-vertical)
au FileType rust nmap K          <Plug>(rust-doc)


let g:racer_experimental_completer = 1
