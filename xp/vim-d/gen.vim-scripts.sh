#!/bin/sh

fn=./vim.xp/rc.vim-scripts.vim

cd ..
>$fn
echo "let s:pref = \",\" . g:XPvimrcCurrentDir . \"/plg-git/\"" > $fn

echo '
if ! exists( "g:xp_disabled" )
    let g:xp_disabled = "xxxxxxxxxxxxxxxxxx"
endif
fun! s:add(k)
    if a:k !~ g:xp_disabled
        let &rtp .= s:pref . a:k
    endif
endfunction
' >> $fn

for n in `git submodule --quiet foreach 'echo $path' | grep "vim.xp/plg-git"`; do

    case $n in

    */JavaScript-Indent)        continue;;
    */JavaScript-syntax)        continue;;
    */OmniCppComplete)          continue;;
    */ZenCoding.vim)            continue;;
    */python-mode.git)          continue;;
    */snipmate-snippets.git)    continue;;
    */vim-snipmate.garbas)      continue;;
    */vim-multiple-cursors)     continue;;
    */xptdev)                   continue;;

    esac

    n=${n##*/}
    echo "call s:add('$n')" >> $fn
    if [ -d $n/after ]; then
        echo "call s:add('$n/after')" >> $fn
    fi

done
