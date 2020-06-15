
let g:syntastic_mode_map = {
      \ "mode": "passive",
      \ "active_filetypes": [],
      \ "passive_filetypes": [] }


let g:syntastic_lua_checkers = ["luac","luacheck"]
let g:syntastic_lua_luacheck_args = "--no-redefined --std ngx_lua+lua51c+luajit --codes"

let g:syntastic_always_populate_loc_list = 0
let g:syntastic_auto_loc_list = 0
let g:syntastic_check_on_open = 1

" this makes :w slow
let g:syntastic_check_on_wq = 0
let g:syntastic_aggregate_errors = 1

" python 3.5+ type hint checker
let g:syntastic_python_checkers=['mypy']
let g:syntastic_python_flake8_args = '--max-line-length=120'
