
profile start /Users/drdrxp/prof.txt
profile func *xpsnip#snip#*

let s = repeat('1', 1000)
let lst = split(s, '\v.\zs')

let n = 100
" let n = 1

let i = 0
let t_0 = reltime()

while i < n
    let i += 1
    let x = xpsnip#snip#Compile('for ($i = ${s:0}; $i<${e:3}; $i++)', 0, '\v[]')
endwhile

let t_1 = reltime( t_0 )
echom string((t_1[0]*1000000 + t_1[1])/ n)
echom reltimestr( reltime( t_0 ) )
exit
