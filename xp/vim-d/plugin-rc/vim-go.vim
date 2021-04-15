let g:go_fmt_autosave = 1
let g:go_fmt_command = "goimports"

" let g:go_def_mode = 'godef'

let g:go_fold_enable = [
      \ 'block',
      \ 'import',
      \ 'varconst',
      \ 'package_comment',
      \ 'comment',
      \]

" -s: auto simplify
let g:go_fmt_options = {
      \ "gofmt": "-s",
      \ "goimports": "",
      \ }

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

" for metalint
" let g:go_metalinter_enabled = [
      " \ 'errcheck',
      " \ 'goconst',
      " \ 'golint',
      " \ 'gosec',
      " \ 'gotype',
      " \ 'ineffassign',
      " \ 'maligned',
      " \ 'misspell',
      " \ 'staticcheck',
      " \ 'structcheck',
      " \ 'unconvert',
      " \ 'varcheck',
      " \ 'vet',
      " \]

" " golangci-lint enabled 
" deadcode:    Finds unused code [fast: true, auto-fix: false]
" errcheck:    Errcheck is a program for checking for unchecked errors in go programs. These unchecked errors can be critical bugs in some cases [fast: true, auto-fix: false]
" gosimple:    Linter for Go source code that specializes in simplifying a code [fast: false, auto-fix: false]
" govet        (vet, vetshadow): Vet examines Go source code and reports suspicious constructs, such as Printf calls whose arguments do not align with the format string [fast: false, auto-fix: false]
" ineffassign: Detects when assignments to existing variables are not used [fast: true, auto-fix: false]
" staticcheck: Staticcheck is a go vet on steroids, applying a ton of static analysis checks [fast: false, auto-fix: false]
" structcheck: Finds an unused struct fields [fast: true, auto-fix: false]
" typecheck:   Like the front-end of a Go compiler, parses and type-checks Go code [fast: true, auto-fix: false]
" unused:      Checks Go code for unused constants, variables, functions and types [fast: false, auto-fix: false]
" varcheck:    Finds unused global variables and constants [fast: true, auto-fix: false]

" " golangci-lint disabled
" depguard:         Go linter that checks if package imports are in a list of acceptable packages [fast: true, auto-fix: false]
" dupl:             Tool for code clone detection [fast: true, auto-fix: false]
" gochecknoglobals: Checks that no globals are present in Go code [fast: true, auto-fix: false]
" gochecknoinits:   Checks that no init functions are present in Go code [fast: true, auto-fix: false]
" goconst:          Finds repeated strings that could be replaced by a constant [fast: true, auto-fix: false]
" gocritic:         The most opinionated Go source code linter [fast: true, auto-fix: false]
" gocyclo:          Computes and checks the cyclomatic complexity of functions [fast: true, auto-fix: false]
" gofmt:            Gofmt checks whether code was gofmt-ed. By default this tool runs with -s option to check for code simplification [fast: true, auto-fix: true]
" goimports:        Goimports does everything that gofmt does. Additionally it checks unused imports [fast: true, auto-fix: true]
" golint:           Golint differs from gofmt. Gofmt reformats Go source code, whereas golint prints out style mistakes [fast: true, auto-fix: false]
" gosec             (gas): Inspects source code for security problems [fast: true, auto-fix: false]
" interfacer:       Linter that suggests narrower interface types [fast: false, auto-fix: false]
" lll:              Reports long lines [fast: true, auto-fix: false]
" maligned:         Tool to detect Go structs that would take less memory if their fields were sorted [fast: true, auto-fix: false]
" misspell:         Finds commonly misspelled English words in comments [fast: true, auto-fix: true]
" nakedret:         Finds naked returns in functions greater than a specified function length [fast: true, auto-fix: false]
" prealloc:         Finds slice declarations that could potentially be preallocated [fast: true, auto-fix: false]
" scopelint:        Scopelint checks for unpinned variables in go programs [fast: true, auto-fix: false]
" stylecheck:       Stylecheck is a replacement for golint [fast: false, auto-fix: false]
" unconvert:        Remove unnecessary type conversions [fast: true, auto-fix: false]
" unparam:          Reports unused function parameters [fast: false, auto-fix: false]

let g:go_metalinter_command = 'golangci-lint'
let g:go_metalinter_enabled = [
      \ 'deadcode',
      \ 'errcheck',
      \ 'goconst',
      \ 'golint',
      \ 'gosec',
      \ 'gosimple',
      \ 'govet',
      \ 'ineffassign',
      \ 'maligned',
      \ 'misspell',
      \ 'staticcheck',
      \ 'structcheck',
      \ 'typecheck',
      \ 'unconvert',
      \ 'unused',
      \ 'varcheck',
      \]

" let g:go_disable_autoinstall = 0
