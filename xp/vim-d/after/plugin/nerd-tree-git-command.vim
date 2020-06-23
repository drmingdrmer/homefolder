call NERDTreeAddKeyMap({
       \ 'key': ',va',
       \ 'callback': 'NERDTreeXP_addNode',
       \ 'quickhelpText': 'echo full path of current node',
       \ 'scope': 'Node' })

function! NERDTreeXP_addNode(dirnode)
    let r = &lazyredraw
    set lazyredraw


    let p = a:dirnode.path.str()
    echom "add:" . p
    " silent! exec 'silent!' 'Git' 'add' p
    exec 'Git' 'add' string(p)
    call g:NERDTreeGitStatusRefresh()
    call nerdtree#ui_glue#invokeKeyMap("r")

    let &lazyredraw = r
    redraw!
endfunction
