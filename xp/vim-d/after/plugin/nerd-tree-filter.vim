if exists("g:__jfkdslfjdklsfdf__jf")
    finish
endif
let g:__jfkdslfjdklsfdf__jf = 1


call NERDTreeAddPathFilter('XpNerdTreeFilter')

function! XpNerdTreeFilter(params)
    "params is a dict containing keys: 'nerdtree' and 'path' which are
    "g:NERDTree and g:NERDTreePath objects
    "return 1 to ignore params['path'] or 0 otherwise


    " ignore target if there is a sibling Cargo.toml
    let seg = a:params.path.pathSegments
    if seg[-1] == 'target'
        let p = '/' . join(seg[:-2], '/') . '/Cargo.toml'
        if filereadable(p)
            return 1
        endif
    endif

    return 0
endfunction
