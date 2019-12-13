FinishIfNotLoaded

if ''==mapcheck("<Plug>(doc:ref)", "n")
    nmap         <Plug>(doc:ref)        <Plug>ManPageView
endif

" make ManPageView happy: it tries to bind `K` as unique.
nmap <Plug>(doc:manpagevew)        <Plug>ManPageView

