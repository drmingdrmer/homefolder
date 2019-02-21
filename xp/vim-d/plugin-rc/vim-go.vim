nnoremap <buffer> <Plug>format:format_file :GoFmt<CR>
let g:go_fmt_autosave = 0

" gotype - Syntactic and semantic analysis similar to the Go compiler.
" deadcode - Finds unused code.
" gocyclo - Computes the cyclomatic complexity of functions.
" golint - Google's (mostly stylistic) linter.
" varcheck - Find unused global variables and constants.
" structcheck - Find unused struct fields.
" maligned - Detect structs that would take less memory if their fields were sorted.
" errcheck - Check that error return values are used.
" staticcheck - Statically detect bugs, both obvious and subtle ones.
" dupl - Reports potentially duplicated code.
" ineffassign - Detect when assignments to existing variables are not used.
" unconvert - Detect redundant type conversions.
" goconst - Finds repeated strings that could be replaced by a constant.
" gosec - Inspects source code for security problems by scanning the Go AST.
let g:go_metalinter_enabled = [
      \ 'deadcode',
      \ 'dupl',
      \ 'errcheck',
      \ 'goconst',
      \ 'golint',
      \ 'gosec',
      \ 'gotype',
      \ 'ineffassign',
      \ 'maligned',
      \ 'staticcheck',
      \ 'structcheck',
      \ 'unconvert',
      \ 'varcheck',
      \ 'vet',
      \]

" let g:go_disable_autoinstall = 0
