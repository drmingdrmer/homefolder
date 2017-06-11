let b:strConnector = ""
let b:EnhCommentifyUseSyntax="no"
setlocal foldmethod=syntax
setlocal foldlevel=1
set keywordprg=man\ -S\ 2,3

set cinoptions=>s,e0,n0,f0,{0,}0,^0,:s,=s,l0,b0,gs,hs,ps,ts,is,+s,c3,C0,/0,(2s,us,w0,W0,m0,j0,)20,*30,#0
set cinoptions=
set cinoptions+=+2s             " break line indent
set cinoptions+=l1              " case block indent
set cinoptions+=U1s             " parentheses indent

" cino=(0                          cino=(0,W4 >
"   a_long_line(                    a_long_line(
"               argument,               argument,
"               argument);              argument);
"   a_short_line(argument,          a_short_line(argument,
"                argument);                      argument);
set cinoptions+=(0,W2s          " parentheses indent
set cinoptions+=M0              " parentheses indent
set cinoptions+=m1              " closing parenthese

" let c_c_vim_compatible = 1
" let c_C99 = 1
