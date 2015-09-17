if exists("g:__RC_PATH_VIM__")
    finish
endif
let g:__RC_PATH_VIM__ = 1

" set tags+=~/commonTags
      " \~/gccTags

set path+=./include
      \inc,
      \/usr/local/include,
      \/usr/include,
      \/usr/lib/gcc/i386-redhat-linux/3.4.3/include
