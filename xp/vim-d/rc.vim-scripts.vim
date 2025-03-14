let s:pref = "," . g:XPvimrcCurrentDir . "/plg-git/"

let g:xp_enabled_plugin = {}

if ! exists( "g:xp_disabled" )
    let g:xp_disabled = "xxxxxxxxxxxxxxxxxx"
endif
fun! s:add(k)
    if a:k !~ g:xp_disabled
        let &rtp .= s:pref . a:k
        let g:xp_enabled_plugin[a:k] = a:k
    endif
endfunction

com FinishIfNotLoaded if !has_key(g:xp_enabled_plugin, expand("<sfile>:t")[:-5]) | finish | endif

call s:add('Align')
call s:add('FuzzyFinder')
call s:add('IndentAnything')
call s:add('L9')
call s:add('ManPageView')
call s:add('Mark--Karkat')
call s:add('nerdcommenter')
call s:add('nerdtree')
call s:add('nerdtree-git-plugin')
call s:add('VimExplorer')
call s:add('ansible-vim')
call s:add('clang_complete')
call s:add('colorsel.vim')
call s:add('ctrlp')
call s:add('gv.vim')
call s:add('diffchanges.vim')
call s:add('github_vim_theme')
call s:add('grep.vim')
call s:add('gtags.vim')
call s:add('pangu.vim')

" call s:add('python-mode.git')
call s:add('supertab')
call s:add('syntastic')
call s:add('tagbar.majutsushi')
call s:add('unite-gtags')
call s:add('unite.vim')
call s:add('vcscommand.vim.git')
call s:add('vim-color-edit')
call s:add('vim-flatbuffers')
call s:add('vim-fugitive')
call s:add('vim-fuzzyjumpto')
call s:add('vim-gitgutter')
call s:add('vim-go.fatih')
call s:add('vim-highlight-emphasize')
call s:add('vim-indent-lua')
call s:add('vim-javascript')
call s:add('vim-jsx')
call s:add('vim-mac-classic-theme')
" vim-syntax-markdown must come first
" call s:add('vim-syntax-markdown')
call s:add('vim-markdown')
call s:add('vim-syntax-util')
call s:add('vim-tabbar')
call s:add('vim-toggle-quickfix')
call s:add('vim-visual-increment')
call s:add('vim-yaml')
call s:add('vim-toml')
call s:add('xmledit')

call s:add('vim-xpsnip')
call s:add('xp-vim-colorscheme')
call s:add('xp-vim-git')
call s:add('xptemplate')

" rust
" call s:add('rust.vim')

" call s:add('vim-racer')

call s:add('coc.nvim')

" call s:add('Hints-for-C-Library-Functions')
" call s:add('Hints-for-C-Library-Functions-B')
" call s:add('auto-pairs')
" call s:add('neocomplcache')
" call s:add('taglist.vim')
" call s:add('ultisnips')
" call s:add('vim-autoformat')
" call s:add('vim-polyglot')
" call s:add('vim-snippets.honza')
