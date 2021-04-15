" assumes VIM-go is installed

nnoremap <buffer> <silent> <Plug>(refactor:rename)     :GoRename<CR>
nnoremap <buffer> <silent> <Plug>(format:file)         :GoFmt<CR>
nnoremap <buffer> <silent> <Plug>(format:import)       :GoImports<CR>
nnoremap <buffer> <silent> <Plug>search:word_ref       :GoReferrers<CR>
nnoremap <buffer> <silent> <Plug>search:word_callstack :GoCallstack<CR>
nnoremap <buffer> <silent> <Plug>run:build             :GoBuild<CR>
nnoremap <buffer> <silent> <Plug>run:run               :GoRun<CR>
nnoremap <buffer> <silent> <Plug>run:test:current_dir  :GoTest<CR>
nnoremap <buffer> <silent> <Plug>run:test:func         :GoTestFunc<CR>
nnoremap <buffer> <silent> <Plug>run:coverage:run      :GoCoverage<CR>
nnoremap <buffer> <silent> <Plug>run:coverage:toggle   :GoCoverageToggle<CR>
