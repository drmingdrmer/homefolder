# vim-tiny-unittest

A tiny unittest engine for vim script.

##  Usage

It is recommended to put all unittest script into `autoload` thus
no unittest script will be loaded during daily usage.

There is an example test script in `autoload/tut/test_example.vim`, which is a
simple test for this plugin itself.

```
fun! s:TestThis(t)
    let t = a:t

    call t.Eq( 1, 1, 'ok' )
    call t.Eq( [1, 2, 3], [1, 2, 3], 'list comparison' )
    call t.Ne( 1, 2, 'not equal' )
    call t.Ne( {'a':1}, {'a':2}, 'dict comparison' )
    call t.True( 1 == 1, 'true' )
    try
        call t.Is( {}, {}, 'is' )
        call t.Fail('should not pass')
    catch /.*/
    endtry
endfunction

exe tut#unittest#run
```

In a unittest script, functions defined as `script-local` and with name
starting with `Test` will be loaded and run by this plugin:
```
fun! s:TestXXX(t)
```

`t` is a dictionary which provides several assertion functions.

At last a statement `exe tut#unittest#run` is required to be added at the
bottom of each unittest script.

To run unittests, call function: `:call tut#unittest#RunFnmatch('*')`.

##  Installation

Installing with [pathogen.vim](https://github.com/tpope/vim-pathogen)
 is recommended. Copy and paste:

```sh
cd ~/.vim/bundle
git clone git://github.com/drmingdrmer/vim-tiny-unittest.git
```

Or manually:

Download [vim-tiny-unittest.zip](https://github.com/drmingdrmer/vim-tiny-unittest/archive/master.zip)
and unzip it into `~/.vim`.
