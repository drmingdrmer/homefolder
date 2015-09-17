XPTemplate priority=lang

let s:f = g:XPTfuncs()

XPTvar $TRUE          1
XPTvar $FALSE         0
XPTvar $NULL          NULL
XPTvar $UNDEFINED     NULL

" if () ** {
" else ** {
XPTvar $BRif     ' '

" } ** else {
XPTvar $BRel     \n

" for () ** {
" while () ** {
" do ** {
XPTvar $BRloop   ' '

" struct name ** {
XPTvar $BRstc    ' '

" int fun() ** {
" class name ** {
XPTvar $BRfun    ' '

XPTinclude
    \ _common/common


XPT debug " call s:log.Debug\(  )
call s:log.Debug(`$SParg^`^`$SParg^)

XPT log " call s:log.Log\(  )
call s:log.Log(`$SParg^`^`$SParg^)

XPT info " call s:log.Info\(  )
call s:log.Info(`$SParg^`^`$SParg^)

XPT warn " call s:log.Warn\(  )
call s:log.Warn(`$SParg^`^`$SParg^)

XPT error " call s:log.Error\(  )
call s:log.Error(`$SParg^`^`$SParg^)

