syn match vimprofile10th /\V0.\zs\[1-9]\d\+/
syn match vimprofileCent /\V0.0\zs\[1-9]\d\+/
syn match vimprofileMill /\V0.00\zs\[1-9]\d\+/
syn match vimprofileU /\V0.000\zs\[1-9]\d\+/
" syn match vimprofileNum  /\V\[1-9]\d\+/ contained containedin=vimprofile10th,vimprofileCent,vimprofileMill


hi link vimprofile10th             Label
hi link vimprofileCent             Statement
hi link vimprofileMill             Function
hi link vimprofileU                Title
" hi link vimprofileNum              ModeMsg

