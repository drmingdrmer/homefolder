let b:module_root = '.*\\modules\\'
let b:module_root_end = '\('.b:module_root.'\)\@<='

fun! s:GetNameByPath(path)
  let path = substitute(a:path, b:module_root, "", "g")
  let path = substitute(path, '\\', ".", "g")
  let path = substitute(path, '.module.js', '', 'g')
  return path
endfunction

fun! s:GetCurPathToRoot()
  let path = substitute(expand("%:p"), b:module_root, "", "g")
  return path
endfunction

fun! b:GetCurNameByPath()
  return s:GetNameByPath(expand("%:p"))
endfunction
