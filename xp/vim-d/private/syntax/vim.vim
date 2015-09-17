" *) starting with at least 2 upper case chars, it is treated as a small word
" *) starting with upper or lower case char, following with some lower case
" char, it is treated as a small word
syntax match vimFunctionEmph  /\<\u\{2,}\zs\l\+\|\%(\<\u\+\|\<.\l*\|\u\l*\)\zs\u\l\+/ containedin=vimfunction contained
syntax match vimUserFuncEmph  /\<\u\{2,}\zs\l\+\|\%(\<\u\+\|\<.\l*\|\u\l*\)\zs\u\l\+/ containedin=vimUserFunc contained
syntax match vimVarEmph       /\<\u\{2,}\zs\l\+\|\%(\<\u\+\|\<.\l*\|\u\l*\)\zs\u\l\+/ containedin=vimVar contained
syntax match vimOperParenEmph /\<\u\{2,}\zs\l\+\|\%(\<\u\+\|\<.\l*\|\u\l*\)\zs\u\l\+/ containedin=vimOperParen contained
syntax match vimFuncVarEmph   /\<\u\{2,}\zs\l\+\|\%(\<\u\+\|\<.\l*\|\u\l*\)\zs\u\l\+/ containedin=vimFuncVar contained
syntax match vimIsCommandEmph /\<\u\{2,}\zs\l\+\|\%(\<\u\+\|\<.\l*\|\u\l*\)\zs\u\l\+/ containedin=vimIsCommand contained
syntax match vimGroupNameEmph /\<\u\{2,}\zs\l\+\|\%(\<\u\+\|\<.\l*\|\u\l*\)\zs\u\l\+/ containedin=vimGroupName contained


hi link vimfunction Function
hi link vimFunctionEmph    FunctionEmphasize
hi link vimVarEmph    IdentifierEmphasize
hi link vimOperParenEmph    NormalEmphasize
hi link vimFuncVarEmph   IdentifierEmphasize
hi link vimIsCommandEmph   NormalEmphasize
hi link vimGroupNameEmph   NormalEmphasize
hi link vimUserFunc    Function
hi link vimUserFuncEmph    FunctionEmphasize



" Char '#' in function name is annoying
syntax match vimFunSharp  /\V#/ containedin=vimfunction contained

hi link vimFunSharp    NonText
