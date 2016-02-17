fun! S3Fn(...) "{{{
  let p = call(function('S3Path'), a:000)
  return substitute(p, '\v.*/', '', '')
endfunction "}}}

fun! S3Path(...) "{{{
  let with_suffix = a:0 == 0 || (!!a:000[0])
  let fn = expand('%')
  if fn =~ '\v^src/'
    let fn = fn[ 4: ]
  endif
  if ! with_suffix
    let fn = substitute(fn, '\V.\[ch]\$', '', '')
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

fun! S3FileID() "{{{
  let fn = S3Path(0)

  let fn = substitute(fn, '\V/s3_', '/', '')
  let fn = substitute(fn, '\V/', '_', 'g')

  let symb = 's3_' . fn . '_'
  return toupper(symb)
endfunction "}}}

fun! S3DotH() "{{{
  let fn = S3Path()

  let fn = substitute(fn, '\V.c\$', '.h', '')
  return fn
endfunction "}}}

fun! S3mod() "{{{
  let fn = S3Path(0)
  let fn = substitute(fn, '\v.*/', '', '')
  let fn = substitute(fn, '\v^s3_', '', '')
  return fn
endfunction "}}}

fun! S3Mod() "{{{
  return S3Capital(S3mod())
endfunction "}}}

fun! S3TypeVar(tp) "{{{
  let tp = substitute(a:tp, '\v^S3', '', '')
  return tolower(tp)
endfunction "}}}

call XPTemplate('modeline', '// vim'.':ts=8:sw=2:et:fdl=1')

call XPTemplate('hhead', [
    \'#ifndef `S3FileID()^',
    \'#define `S3FileID()^',
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
    \'#endif /* `S3FileID()^ */',
    \'// vim' . ':ts=8:sw=2:et:fdl=1',
    \])

call XPTemplate('chead', [
    \'#include "`S3DotH()^"',
    \'',
    \'`cursor^',
    \'',
    \'// vim' . ':ts=8:sw=2:et:fdl=0',
    \])

call XPTemplate('thead', [
    \'#include "ctest.h"',
    \'',
    \'#include "lib/s3_error.h"',
    \'`cursor^',
    \'// vim' . ':ts=8:sw=2:et:fdl=0',
    \])

call XPTemplate('s3tp', [
    \'typedef struct `tp^S3{S3Mod()}^ `tp^;',
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

call XPTemplate('s3construct', [
      \'S3`S3Mod()^ *s3_`S3mod()^_construct() {',
      \'    S3`S3Mod()^ *`x^ = malloc(sizeof(S3`S3Mod()^));',
      \'    if (`x^ == NULL) {',
      \'        return `x^;',
      \'    }',
      \'    *`x^ = (S3`S3Mod()^)s3_`S3mod()^_null;',
      \'    return `x^;',
      \'}',
      \'',
      \'void s3_`S3mod()^_destruct(S3`S3Mod()^ *`x^) {',
      \'    s3_`S3mod()^_destroy(`x^);',
      \'    s3_free(`x^);',
      \'}',
      \])

call XPTemplate('ifs', [
      \'if (ret == S3_OK) {',
      \'  `cursor^',
      \'}',
      \])

call XPTemplate('ifns', [
      \'if (ret != S3_OK) {',
      \'  `return ret;^',
      \'}',
      \])
call XPTemplate('.cmp', 's3_norm_cmp_return_ne(a->`x^, b->`x^);')

call XPTemplate('dd', 'S3_DEBUG(`cursor^);' )
call XPTemplate('dinfo', 'S3_INFO(`cursor^);' )
call XPTemplate('derr', 'S3_ERROR(`cursor^);' )

call XPTemplate('.',  's3_')
call XPTemplate('..', 's3_`S3mod()^_')
call XPTemplate('.ok',  'S3_OK')
call XPTemplate('.fail',  'S3_FAIL')
call XPTemplate('.e',  'S3_ERR_`x^ChooseStr("ERR", "EOF", "BUF_OVERFLOW", "BUF_NOT_ENOUGH", "NUM_OVERFLOW", "OUT_OF_MEM", "CHKSUM", "INVALID_ARG", "INVALID_STATE", "NOT_FOUND", "DUP", "IO", "INIT_TWICE", "INDEX_OUT_OF_RANGE", "TIMEOUT", "NOT_SUPPORTED", "SOCKET_FAIL", "AGAIN")^')
call XPTemplate('.ei',  'S3_ERR_INVALID_ARG')
call XPTemplate('.eoo',  'S3_ERR_OUTOFMEM')
call XPTemplate('.t', 'S3`S3S3Mod()^')
call XPTemplate('.mb', 's3_must_be(`^`, `S3_ERR_INVALID_ARG^);')
call XPTemplate('.mbi', 's3_must_inited(`x^, `S3_ERR_UNINITED^);')
call XPTemplate('.mbui', 's3_must_uninited(`x^, `S3_ERR_INITTWICE^);')

call XPTemplate('.at', 's3_atomic_')
call XPTemplate('.arr', 's3_array_')
call XPTemplate('.buf', 's3_buf_')
call XPTemplate('.ch', 's3_chain_')
call XPTemplate('.cr',  's3_check_ret(ret`^, "`^");')
call XPTemplate('.crw', 's3_check_ret_warn(ret`^, "`^");')
call XPTemplate('.ex', 's3_exit(`cursor^);')
call XPTemplate('out', [
      \'exit:',
      \'    if (ret != S3_OK) {',
      \'        `cursor^',
      \'    }',
      \'    return ret;',
      \])
call XPTemplate('.exw', 's3_exit_warn(`cursor^);')
call XPTemplate('.log', 's3_log_')
call XPTemplate('.mt', 's3_metadb_')
call XPTemplate('.mtc', 's3_metadb_client_')
call XPTemplate('.o', 's3_object_')
call XPTemplate('.oid', 's3_object_id_')
call XPTemplate('.p', 's3_partition_')
call XPTemplate('.ph', 's3_partition_header_')
call XPTemplate('.pid', 's3_partition_id_')
call XPTemplate('.q', 's3_queue_')
call XPTemplate('.r', 's3_record_')
call XPTemplate('.rc', 's3_replica_')
call XPTemplate('.rcid', 's3_replica_id_')
call XPTemplate('.rix', 's3_record_index_')
call XPTemplate('.rb', 's3_rbtree_')
call XPTemplate('.rh',  's3_record_header_')
call XPTemplate('.rid', 's3_record_id_')
call XPTemplate('.rp', 's3_record_position_')
call XPTemplate('.str', 's3_string_')
call XPTemplate('.tm',  's3_timer_')
call XPTemplate('.tcb', 's3_timer_callback_')

call XPTemplate('s3_array_', 'S3Array')
call XPTemplate('S3Array', 's3_array_')

call XPTemplate('s3_buf_', 'S3Buf')
call XPTemplate('S3Buf', 's3_buf_')

call XPTemplate('s3_chain_', 'S3Chain')
call XPTemplate('S3Chain', 's3_chain_')

call XPTemplate('s3_log_', 'S3Log')
call XPTemplate('S3Log', 's3_log_')

call XPTemplate('s3_metadb_', 'S3MetaDb')
call XPTemplate('S3MetaDb', 's3_metadb_')

call XPTemplate('s3_metadb_client_', 'S3MetaDbClient')
call XPTemplate('S3MetaDbClient', 's3_metadb_client_')

call XPTemplate('s3_object_', 'S3Object')
call XPTemplate('S3Object', 's3_object_')

call XPTemplate('s3_object_id_', 'S3ObjectID')
call XPTemplate('S3ObjectID', 's3_object_id_')

call XPTemplate('s3_partition_', 'S3Partition')
call XPTemplate('S3Partition', 's3_partition_')

call XPTemplate('s3_partition_header_', 'S3PartitionHeader')
call XPTemplate('S3PartitionHeader', 's3_partition_header_')

call XPTemplate('s3_partition_id_', 'S3PartitionID')
call XPTemplate('S3PartitionID', 's3_partition_id_')

call XPTemplate('s3_queue_', 'S3Queue')
call XPTemplate('S3Queue', 's3_queue_')

call XPTemplate('s3_record_', 'S3Record')
call XPTemplate('S3Record', 's3_record_')

call XPTemplate('s3_record_header_', 'S3RecordHeader')
call XPTemplate('S3RecordHeader', 's3_record_header_')

call XPTemplate('s3_record_id_', 'S3RecordID')
call XPTemplate('S3RecordID', 's3_record_id_')

call XPTemplate('s3_record_position_', 'S3RecordPosition')
call XPTemplate('S3RecordPosition', 's3_record_position_')

call XPTemplate('s3_record_index_', 'S3RecordIndex')
call XPTemplate('S3RecordIndex', 's3_record_index_')

call XPTemplate('s3_replica_', 'S3Replica')
call XPTemplate('S3Replica', 's3_replica_')

call XPTemplate('s3_replica_id_', 'S3ReplicaID')
call XPTemplate('S3ReplicaID', 's3_replica_id_')

call XPTemplate('s3_rbtree_', 'S3Rbtree')
call XPTemplate('S3Rbtree', 's3_rbtree_')

call XPTemplate('s3_record_header_', 'S3RecordHeader')
call XPTemplate('S3RecordHeader', 's3_record_header_')

call XPTemplate('s3_timer_', 'S3Timer')
call XPTemplate('S3Timer', 's3_timer_')

call XPTemplate('s3_timer_callback_', 'S3TimerCallback')
call XPTemplate('S3TimerCallback', 's3_timer_callback_')

call XPTemplate('s3_string_', 'S3String')
call XPTemplate('S3String', 's3_string_')

call XPTemplate('.ml', '(`tp^S3{S3Capital(S3mod())}^*)s3_malloc(sizeof(`tp^))')
call XPTemplate('.bz', 'bzero(`x^, sizeof(*`x^))')
call XPTemplate('.ifbz', [
      \'if (`x^ != NULL) {',
      \'  bzero(`x^, sizeof(*`x^));',
      \'}',
      \] )

call XPTemplate('test', [
      \'TEST(`S3Fn(0)^, `^) {',
      \'  `cursor^',
      \'}',
      \])
call XPTemplate('.cases', [
      \'struct { `^ } cases[] = {',
      \'  { `cursor^ },',
      \'};',
      \'',
      \'for (int i = 0; i < s3_no_elts(cases); i++) {',
      \'  typeof(cases[0]) c = cases[i];',
      \'}',
      \])

call XPTemplate('eeq', 'EXPECT_EQ(`cursor^)')
call XPTemplate('ene', 'EXPECT_NE(`cursor^)')
call XPTemplate('etrue', 'EXPECT_TRUE(`cursor^)')
call XPTemplate('efalse', 'EXPECT_FALSE(`cursor^)')

call XPTemplate('eq', 'ASSERT_EQ(`cursor^)')
call XPTemplate('ne', 'ASSERT_NE(`cursor^)')
call XPTemplate('true', 'ASSERT_TRUE(`cursor^)')
call XPTemplate('false', 'ASSERT_FALSE(`cursor^)')

call XPTemplate('uchar', 'unsigned char')
call XPTemplate( 'i8',  'int8_t' )
call XPTemplate( 'i16', 'int16_t' )
call XPTemplate( 'i32', 'int32_t' )
call XPTemplate( 'i64', 'int64_t' )
call XPTemplate( 'i74', 'int64_t' ) "typo
call XPTemplate( 'ip',  'intptr_t' )

call XPTemplate( 'u8',  'uint8_t' )
call XPTemplate( 'u16', 'uint16_t' )
call XPTemplate( 'u32', 'uint32_t' )
call XPTemplate( 'u64', 'uint64_t' )
call XPTemplate( 'u74', 'uint64_t' ) "typo
call XPTemplate( 'up',  'uintptr_t' )

call XPTemplate('null', 'NULL')
call XPTemplate('nil', 'NULL')
call XPTemplate('=n', ' == NULL')
call XPTemplate('!n', ' != NULL')

call XPTemplate('>i', '->inited_')
call XPTemplate('.i', '.inited_')

call XPTemplate('=0', ' == 0')
call XPTemplate('=1', ' == 1')

call XPTemplate( 'st',  'size_t' )
call XPTemplate( 'sst',  'ssize_t' )
call XPTemplate( 'so',  'sizeof(`cursor^)' )

fun! s:Conceal() "{{{
  let lst = [
        \['S3'             , {'cchar': '•'}] ,
        \['Array'          , {'cchar': 'A'}] ,
        \['Buf'            , {'cchar': 'B'}] ,
        \['Header'         , {'cchar': 'H'}] ,
        \['Index'          , {'cchar': 'I'}] ,
        \['Log'            , {'cchar': 'L'}] ,
        \['Object'         , {'cchar': 'O'}] ,
        \['Partition'      , {'cchar': 'P'}] ,
        \['Queue'          , {'cchar': 'Q'}] ,
        \['Record'         , {'cchar': 'R'}] ,
        \['RecordsChunk'   , {'cchar': 'C'}] ,
        \['String'         , {'cchar': 'S'}] ,
        \['s3_'            , {'cchar': '·'}] ,
        \['buf_'           , {'cchar': 'b'}] ,
        \['array_'         , {'cchar': 'a'}] ,
        \['header_'        , {'cchar': 'h'}] ,
        \['index_'         , {'cchar': 'i'}] ,
        \['log_'           , {'cchar': 'l'}] ,
        \['object_'        , {'cchar': 'o'}] ,
        \['partition_'     , {'cchar': 'p'}] ,
        \['queue_'         , {'cchar': 'q'}] ,
        \['record_'        , {'cchar': 'r'}] ,
        \['records_chunk_' , {'cchar': 'c'}] ,
        \['string_'        , {'cchar': 's'}] ,
        \['S3_ERR_'        , {'cchar': '▸'}] ,
        \['EXPECT_'        , {'cchar': '▸'}] ,
        \['ASSERT_'        , {'cchar': '!'}] ,
        \['s3_check_ret'   , {'cchar': '«'}] ,
        \]

  let conceal_fprefix = 's3_' . S3mod()
  let mod = 'S3' . S3Capital(S3mod())

  exe 'syn' 'keyword' "cConceal" 'void' 'contained conceal'

  for [k, v] in lst
    exe 'syn' 'match' "cConceal" string(k) 'conceal' 'cchar=' . v.cchar
  endfor

  syn match cConceal '\v\\$' conceal

  " exe 'syn' 'match' "cConceal" '"'.conceal_fprefix.'"' 'conceal' 'cchar=‥'
  " exe 'syn' 'match' "cConceal" '"'.mod.'"' 'conceal' 'cchar=።'
  "‽

  " hi cConceal ctermfg=blue ctermbg=none
  " hi cConceal cterm=b
  hi Conceal ctermfg=white

  setlocal conceallevel=0
  setlocal concealcursor=nv
endfunction "}}}

call s:Conceal()

nmap <buffer> <M-)> :call g:xp_switchers.conceal()<CR>


" vim:filetype=vim:sw=2
