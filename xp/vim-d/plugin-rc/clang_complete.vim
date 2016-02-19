if has("mac")
    let g:clang_library_path = "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/libclang.dylib"
else
    " let g:clang_library_path = ""
endif
let g:clang_complete_copen = 1
" let g:clang_snippets = 1
