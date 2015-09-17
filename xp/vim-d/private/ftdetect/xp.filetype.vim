augroup XPfiletype
  " clear all
  au!

  " google proto buffer
  au BufRead,BufNewFile *.proto setfiletype proto

  " xp's module 
  au BufRead,BufNewFile *.module.js set filetype=module.javascript

  " nginx configure
  au BufRead,BufNewFile *nginx.conf set filetype=ngx 

  au BufRead,BufNewFile *vim.log set filetype=vimlog 

  au BufRead,BufNewFile *prof.txt set filetype=vimprofile

augroup END
