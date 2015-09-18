#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import cmd
import time
import fnmatch
import httplib
import shlex
import argparse

# TODO continue previous download.
# TODO command completion
# TODO nice error handling and overriding check

VDISK_LIB_VERSION = '0.1'
AVAILABLE_ACTIONS = {'upload': 'Upload file to vdisk',
                        'getinfo': 'Get file info (with direct download link)',
                        'secretshare': 'Get secret sharing link',
                        'ls': 'List files',
                        'sh': 'interactive shell',
                        'quota': 'Check available space'}

def checkaction(argdict): # FIXME: add path_required / fid_required ...
  actions = AVAILABLE_ACTIONS.keys()
  cnt = 0
  for i in actions:
    if argdict[i]: cnt += 1
  if cnt > 1: raise Exception, 'More than one action are given'
  # FIXME: return the matched action?
  return (cnt == 1)

parser = argparse.ArgumentParser(description='VDisk CLI Client by fcicq, ver ' + VDISK_LIB_VERSION)
parser.add_argument('files', help='Files to be uploaded', action='store', nargs='*')
parser.add_argument('-u', '--user', help='Account (Weibo or Vdisk)')
parser.add_argument('-p', '--pass', help='Password')
parser.add_argument('--traverse', action='store_true', help='Use with --ls, to traverse all directory recursively')
parser.add_argument('--vdiskuser', action='store_true', help='Use Vdisk account (rather than weibo account)')
parser.add_argument('--path', help='Upload Path, default is /, will be created if not exist')
parser.add_argument('--fid', help='File ID')

for act, helpstr in AVAILABLE_ACTIONS.items():
  parser.add_argument('--' + act, action='store_true', help=helpstr)

# TODO: read config file
config = {}
config['default_user'] = ''
config['default_pass'] = ''

class VdiskCmd( cmd.Cmd ):

  def __init__( self, user, token, initpath ):

    cmd.Cmd.__init__( self )
    # Mac issue:
    # http://stackoverflow.com/questions/7116038/python-tab-completion-mac-osx-10-7-lion
    import readline
    import rlcompleter
    if 'libedit' in readline.__doc__:
        readline.parse_and_bind("bind ^I rl_complete")
    else:
        readline.parse_and_bind("tab: complete")

    # issue: after importing readline, raw_intput does not return after <cr>
    # pressed if there is utf-8 chars

    self.user = user
    self.prompt = user + " >"
    self.token = token

    self.path = initpath
    self.dir_id = 0
    self._refresh_dir_id()

    self.parsers = {}
    self.init_parsers()

    self.last = {
        'files': [],
        'dirs': [],
    }

  def init_parsers( self ):

    ap = argparse.ArgumentParser

    p = ap(description='ls [-r]')
    p.add_argument( '-r', '--traverse', help="traverse descendants",
                    action="store_true" )
    p.add_argument( '-d', '--dironly', help="show only dir",
                    action="store_true" )
    self.parsers[ 'ls' ] = p

    p = ap(description='cd path')
    p.add_argument('path', help='path', action='store', nargs='?')
    self.parsers[ 'cd' ] = p

    p = ap(description='upload local file to current dir')
    p.add_argument('paths', help='local file paths to upload', action='store',
                   nargs='*')
    self.parsers[ 'upload' ] = p

    p = ap(description='download file to current local dir')
    p.add_argument('paths', help='remote file to download', action='store',
                   nargs='+')
    self.parsers[ 'download' ] = p

    p = ap( description='delete file' )
    p.add_argument('paths', help='remote file to delete', action='store',
                   nargs='+')
    self.parsers[ 'del' ] = p

    p = ap( description='delete dir' )
    p.add_argument('paths', help='remote dir to delete', action='store',
                   nargs='+')
    self.parsers[ 'rmdir' ] = p

  def mes( self, *strings ):
    print " ".join( strings )

  def mes_sl( self, *strings ):
    TERM_SWOLLOW_LINE = "\r\033[K"
    os.write( 1, TERM_SWOLLOW_LINE + " ".join( strings ) )

  def _refresh_dir_id( self ):
    dir_id = vdisk.vdisk_mkdir( self.token, self.path )
    if isinstance(dir_id, dict):
      raise Exception, "Create Directory Failed"
    self.dir_id = dir_id

  def _ls_iter( self, dir_id, traverse):
    rpc = vdisk.vdiskrpc()
    l = rpc.get_list(token=self.token, dir_id=dir_id)
    qdir = []
    qfile = []

    if isinstance(l.get('data', None), list):

      l = l.get('data', [])
      for i in l:
        if 'sha1' in i:
          qfile.append( i )
        else:
          qdir.append( i )

      qdir.sort()
      qfile.sort()

      for d in qdir:
        yield d

      for f in qfile:
        yield f

    if traverse:
      for i in qdir:
        i = int( i[ 'id' ] )
        for sub in _ls_iter(i, traverse):
          yield sub

  def ls_show( self, dir_id, ftype, traverse, show=True ):

    self.last[ 'files' ] = []
    self.last[ 'dirs' ] = []

    for i in self._ls_iter( dir_id, traverse ):

      try:
        if 'sha1' in i:
          if 'f' in ftype:
            self.last[ 'files' ].append( i[ 'name' ] );
            if show:
              self.mes( '-', "%10s" % i['id'], "%7s" % readable_int(
                  int( i['length'] ) ), vdisk.to_console(i['name']) )
        else:
          if 'd' in ftype:
            self.last[ 'dirs' ].append( i[ 'name' ] );
            if show:
              self.mes( 'd', "%10s" % i['id'], '%7s' % i[ 'file_num' ],
                        vdisk.to_console(i['name']) )
      except Exception as e:
        print repr( e )

  def complete_cd( self, text, line, s, e ):
    return self._compl( text, line, s, e, self.last[ 'dirs' ] )

  def complete_download( self, text, line, s, e ):
    return self._compl( text, line, s, e, self.last[ 'files' ] )

  def complete_del( self, text, line, s, e ):
    return self._compl( text, line, s, e, self.last[ 'files' ] )

  def complete_rmdir( self, text, line, s, e ):
    return self._compl( text, line, s, e, self.last[ 'dirs' ] )

  def _compl( self, text, line, s, e, resource ):
    text = text.decode( "utf-8" )
    return [ x.encode( 'utf-8' ) for x in resource
             if x.startswith( text ) ]


  def do_cd( self, argstr ):
    args = _args( self.parsers[ 'cd' ], argstr )
    p = args[ 'path' ] or '/'

    if not p.startswith( "/" ):
      p = self.path + p
      p = os.path.normpath( p ) + '/'
    else:
      if p != '/':
        p = os.path.normpath( p ) + '/'

    self.path = p
    self._refresh_dir_id()
    self.mes( "Change to ", self.path )

    self.prompt = self.user + ' at ' + self.path + ' >'

    # update index
    self.ls_show( self.dir_id, 'fd', False, show=False )

  def do_ls( self, argstr ):
    args = _args( self.parsers[ 'ls' ], argstr )
    self.ls_show( self.dir_id, 'd' if args[ 'dironly' ] else 'fd', args['traverse'])

  def do_del( self, argstr ):

    args = _args( self.parsers[ 'del' ], argstr )
    rpc = vdisk.vdiskrpc()

    for ent in self._ls_iter( self.dir_id, traverse=False ):

      if 'sha1' not in ent:
        continue

      if not self._fnmatch_any( ent[ 'name' ], args[ 'paths' ] ):
          continue

      r = rpc.delete_file(token=self.token, fid=ent[ 'id' ])
      if r and r[ 'errcode' ] == 0:
        mes = 'OK '
      else:
        mes = 'Failure '
        self.mes( repr( r ) )
      self.mes( mes + "delete    " + ent[ 'name' ].encode( 'utf-8' ) )

  def do_rmdir( self, argstr ):

    args = _args( self.parsers[ 'rmdir' ], argstr )
    rpc = vdisk.vdiskrpc()

    for ent in self._ls_iter( self.dir_id, traverse=False ):

      if 'sha1' in ent \
          or not self._fnmatch_any( ent[ 'name' ], args[ 'paths' ] ):
        continue

      r = rpc.delete_dir(token=self.token, dir_id=ent[ 'id' ])
      if r and r[ 'errcode' ] == 0:
        mes = 'OK '
      else:
        mes = 'Failure '
        self.mes( repr( r ) )
      self.mes( mes + "rmdir    " + ent[ 'name' ].encode( 'utf-8' ) )

  def _fnmatch_any( self, fn, ptns ):
    for ptn in ptns:

      if fnmatch.fnmatch( fn, ptn.strip().decode( 'utf-8' ) ):
        return True
    else:
      return False

  def do_upload( self, argstr ):
    args = _args( self.parsers[ 'upload' ], argstr )

    for fpath in argdict['paths']:
      fid = vdisk.upload_bigfile(self.token, fpath, dir_id=self.dir_id)
      if isinstance(fid, dict):
        if not fid.get('fid', None):
          self.mes( 'Upload Failed, errmsg: ', fid.get('err_msg', '-') )
          continue
      self.mes( "OK upload", fpath )

  def do_download( self, argstr ):
    args = _args( self.parsers[ 'download' ], argstr )
    traverse = False

    for ent in self._ls_iter( self.dir_id, traverse ):
      if 'sha1' in ent:
        for ptn in args[ 'paths' ]:
          if fnmatch.fnmatch( ent[ 'name' ], ptn.strip().decode( 'utf-8' ) ):
            # TODO download
            self._download_file( ent );
        else:
          pass

  def _download_file( self, ent ):
    local_fn = ent[ 'name' ]
    fid = ent[ 'id' ]
    fsize = int(ent[ 'length' ])

    rpc = vdisk.vdiskrpc()

    info = rpc.get_file_info( token=self.token, fid=fid )
    if info[ 'errcode' ] != 0:
      self.mes( "Failure get info of fid=", fid )
      return

    info = info[ 'data' ]
    url = info[ 's3_url' ]
    self.mes( "downloading... ", local_fn )
    self.mes( url )

    host = url.split( '//' )[ 1 ]
    host, uri = host.split( '/', 1 )
    uri = '/' + uri
    port = 80

    conn = httplib.HTTPConnection( host, port )
    conn.request( 'GET', uri )

    resp = conn.getresponse()

    if resp.status != 200:
      self.mes( "Failure download: ", repr(resp.status), resp.getheaders() )
      return


    try:
      fd = os.open( local_fn, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0644 )
      self.mes( "opened: ", str(fd), local_fn )

      dl = 0
      t0 = time.time()
      while True:
        buf = resp.read( 1024*1024*1 )
        if buf == '':
          break

        dl += len( buf )
        elapsed = int(time.time() - t0)
        left = elapsed * (fsize - dl) / dl
        self.mes_sl( '{perc}% {dl} / {fsize} time left: {min:>2}m{sec:>2}s'.format(
            perc=int( dl*100 / fsize ),
            dl=readable_int( dl ),
            fsize=readable_int( fsize ),
            min=left / 60,
            sec=left % 60,
        ) )
        os.write( fd, buf )

      self.mes()
      self.mes( "finished" )

    except Exception as e:
      self.mes( repr( e ) )
      import traceback
      self.mes( traceback.format_exc() )
    finally:
      os.close( fd )


def _args( p, argstr ):
  return p.parse_args( shlex.split( argstr ) ).__dict__

def readable_int( i, sz = None ):

  K = 1024
  M = K * K
  G = M * K
  T = G * K
  P = T * K
  E = P * K
  Z = E * K
  Y = Z * K

  digName = {}
  digName[ str( 1 ) ] = ''
  digName[ str( K ) ] = 'K'
  digName[ str( M ) ] = 'M'
  digName[ str( G ) ] = 'G'
  digName[ str( T ) ] = 'T'
  digName[ str( P ) ] = 'P'
  digName[ str( E ) ] = 'E'
  digName[ str( Z ) ] = 'Z'
  digName[ str( Y ) ] = 'Y'

  i = int( i )

  if sz is not None:
    return '%d%s' % ( i / sz, digName[ str( sz ) ] )

  else:
    m = K

    # keep at least 2 digit
    while i / m > 0:
      m *= K

    m /= K

    v = i * 1.0 / m

    if v == int(v):
      return '%d%s' % ( v,
                digName[ str( m ) ] )
    else:
      if v > 10:
        vlen = 1
      elif v > 1:
        vlen = 2
      else:
        vlen = 3

      return ('%.' + str(vlen) + 'f%s') % ( v, digName[ str( m ) ] )


import vdisk_upload as vdisk
if __name__ == '__main__':
  args = parser.parse_args()
  argdict = args.__dict__

  if not checkaction(argdict): # FIXME
    raise Exception, 'No action is given'

  # login
  # TODO: may save token in config file.
  acc_user, acc_pass = argdict.get('user', config['default_user']), argdict.get('pass', config['default_pass'])
  if not acc_user or not acc_pass: raise Exception, 'User / Password Empty?'
  token = vdisk.get_token(acc_user, acc_pass, argdict['vdiskuser'])
  if not token: raise Exception, "Login Failed"
  print 'Login ok with user %s' % acc_user

  if argdict[ 'sh' ]:
    VdiskCmd( acc_user, token, argdict[ 'path' ] or '/' ).cmdloop()

  dir_id = 0
  if argdict['path']:
    dir_id = vdisk.vdisk_mkdir(token, argdict['path'])
    if isinstance(dir_id, dict): raise Exception, "Create Directory Failed"

  # commands
  if argdict['ls']:
    vdisk.vdisk_ls_dirid(token, dir_id, argdict['traverse'])

  rpc = vdisk.vdiskrpc()
  if argdict['upload']:
    for i in argdict['files']:
      fid = vdisk.upload_bigfile(token, i, dir_id=dir_id)
      if isinstance(fid, dict):
        if not fid.get('fid', None):
          print 'Upload Failed, errmsg: ', fid.get('err_msg', '-')

  if argdict['quota']:
    data = rpc.get_quota(token=token)
    if int(data.get('errcode')) == 0:
      q = data.get('data')
      per = float(q['used']) / float(q['total']) * 100
      print 'Used %d of %d MB Total (%.2f %%)' % (int(q['used']) / 1048576, int(q['total']) / 1048576, per)
    else:
      print 'Failed to get quota data.'
  
  if argdict['secretshare']:
    fid = argdict['fid']
    if not fid:
      print 'fid is required to get file link.'
    else:
      data = rpc.secretshare(token=token, fid=fid)
      if int(data.get('errcode')) == 0:
        ret = data.get('data', {})
        print 'Name: %s\nLink: %s\nPass: %s' % (
		vdisk.to_console(ret.get('name','-')),
		ret.get('url', '-'), ret.get('password', '-'))
      else:
        print 'get link failed: ' + data.get('err_msg', '-')

  if argdict['getinfo']:
    fid = argdict['fid']
    if not fid:
      print 'fid is required to get file info.'
    else:
      data = rpc.get_file_info(token=token, fid=fid)
      if data.get('errcode') == 0:
        data = data.get('data', {})
        print 'File: %s\nSize: %s\nMD5 : %s\nSHA1: %s\nPub : %s\nPriv: %s\nShared: %s\n' % (
		vdisk.to_console(data.get('name', '-')), 
		data.get('length', '-'), 
		data.get('md5', '-'), data.get('sha1', '-'),
		data.get('url', '-'), data.get('s3_url', '-'),
		(data.get('share', '-') == -1) and 'No' or 'Yes')
      else:
        print 'Failed to get info: ', data.get('err_msg', '')

# vim: sw=2 ts=4
