fun! s:Fn() "{{{
  let fn = expand('%')
  if fn =~ '\v^src/'
    let fn = fn[ 4: ]
  endif
  return fn
endfunction "}}}

fun! S3Capital(s) "{{{
  let s = substitute(a:s, '\v^\w', '\u\0', '')
  return substitute(s, '\v_(\w)', '\u\1', 'g')
endfunction "}}}

fun! S3Underline(s) "{{{
  let s = substitute(a:s, '\v^\w', '\l\0', '')
  return substitute(s, '\v(\u)', '_\l\1', 'g')
endfunction "}}}

fun! S3FileHeader() "{{{
  let fn = s:Fn()

  let fn = substitute(fn, '\V.\[ch]\$', '', '')
  let fn = substitute(fn, '\V/s3_', '/', '')
  let fn = substitute(fn, '\V/', '_', 'g')

  let symb = 's3_' . fn . '_'
  return toupper(symb)
endfunction "}}}

fun! S3DotH() "{{{
  let fn = s:Fn()

  let fn = substitute(fn, '\V.c\$', '.h', '')
  return fn
endfunction "}}}

fun! S3Mod() "{{{
  let fn = s:Fn()
  let fn = substitute(fn, '\v.*/', '', '')
  let fn = substitute(fn, '\v^s3_', '', '')
  let fn = substitute(fn, '\V.\[ch]', '', '')
  return fn
endfunction "}}}

fun! S3TypeVar(tp) "{{{
  let tp = substitute(a:tp, '\v^S3', '', '')
  return tolower(tp)
endfunction "}}}

call XPTemplate('modeline', '// vim'.':ts=8:sw=2:et')

call XPTemplate('hhead', [
    \'#ifndef `S3FileHeader()^',
    \'#define `S3FileHeader()^',
    \'',
    \'#ifdef __cplusplus',
    \'extern "C" {',
    \'#endif',
    \'',
    \'`cursor^',
    \'',
    \'#ifdef __cplusplus',
    \'}',
    \'#endif',
    \'#endif /* `S3FileHeader()^ */',
    \'// vim' . ':ts=8:sw=2:et',
    \])

call XPTemplate('chead', [
    \'#include "`S3DotH()^"',
    \'',
    \'`cursor^',
    \'',
    \'// vim' . ':ts=8:sw=2:et',
    \])

call XPTemplate('s3tp', [
    \'typedef struct `tp^S3{S3Capital(S3Mod())}^ `tp^;',
    \'struct `tp^ {',
    \'  `cursor^',
    \'};',
    \'',
    \'`tp^ *`tp^S3Underline(V())^_construct();',
    \'void `tp^S3Underline(V())^_destruct(`tp^ *`tp^S3TypeVar(V())^);',
    \'',
    \'int `tp^S3Underline(V())^_init(`tp^ *`tp^S3TypeVar(V())^);',
    \'void `tp^S3Underline(V())^_destroy(`tp^ *`tp^S3TypeVar(V())^);',
    \])

call XPTemplate('.',  's3_')
call XPTemplate('..', 's3_`S3Mod()^_')
call XPTemplate('.e',  'S3_ERR_')
call XPTemplate('.t', 'S3`S3Capital(S3Mod())^')
call XPTemplate('.ml', '(`tp^S3{S3Capital(S3Mod())}^*)s3_malloc(sizeof(`tp^))')
call XPTemplate('teq', 'EXPECT_EQ(`^)')
call XPTemplate('tne', 'EXPECT_NE(`^)')
call XPTemplate('ttrue', 'EXPECT_TRUE(`^)')
call XPTemplate('tfalse', 'EXPECT_FALSE(`^)')

call XPTemplate( 'i8',  'int8_t' )
call XPTemplate( 'i16', 'int16_t' )
call XPTemplate( 'i32', 'int32_t' )
call XPTemplate( 'i64', 'int64_t' )
call XPTemplate( 'ip',  'intptr_t' )

call XPTemplate( 'u8',  'uint8_t' )
call XPTemplate( 'u16', 'uint16_t' )
call XPTemplate( 'u32', 'uint32_t' )
call XPTemplate( 'u64', 'uint64_t' )
call XPTemplate( 'up',  'uintptr_t' )

call XPTemplate( 'st',  'size_t' )
call XPTemplate( 'so',  'sizeof(`cursor^)' )


" vim:filetype=vim:sw=2
