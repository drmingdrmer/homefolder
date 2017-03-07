let g:syntastic_lua_checkers = ["luac","luacheck"]
" let g:syntastic_lua_luacheck_args = "--no-redefined --std ngx_lua+lua51c+luajit --codes --module"
let g:syntastic_lua_luacheck_args = "--no-redefined --std ngx_lua+lua51c+luajit --codes"

let g:syntastic_always_populate_loc_list = 0
let g:syntastic_auto_loc_list = 0
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 1
let g:syntastic_aggregate_errors = 1
