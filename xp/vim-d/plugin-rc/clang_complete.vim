if has("mac")
    let g:clang_library_path = "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/libclang.dylib"
else
    " let g:clang_library_path = ""
endif
let g:clang_jumpto_declaration_key = '<C-g><C-d>'
let g:clang_complete_copen = 1
let g:clang_complete_macros = 1
let g:clang_complete_auto = 0
" let g:clang_snippets = 1
