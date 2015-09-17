syn match vimlogStack /^\w\+:::.*/ contains=vimlogFunctionName,vimlogLevel
syn match vimlogLevel /^\w\+\ze:::/ contained
syn match vimlogFunctionName /[^:.]\+\ze\%(\.\.\|$\)/ contained contains=vimlogFunctionSID
syn match vimlogFunctionSID /<SNR>\d\+_/


hi def link vimlogStack             Statement
hi def link vimlogLevel             Label
hi def link vimlogFunctionName      Function
hi def link vimlogFunctionSID       Title
