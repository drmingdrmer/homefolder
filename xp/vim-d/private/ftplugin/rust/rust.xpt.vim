XPTemplate priority=lang

let s:f = g:XPTfuncs()

" use snippet 'varConst' to generate contant variables
" use snippet 'varFormat' to generate formatting variables
" use snippet 'varSpaces' to generate spacing variables


XPTinclude
      \ _common/common


XPT main " fn main
fn main() {
    `cursor^
}

XPT ddbg " #[derive\(Debug)]
#[derive(Debug)]

