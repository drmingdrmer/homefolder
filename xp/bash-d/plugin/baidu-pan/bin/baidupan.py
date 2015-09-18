#!/usr/bin/env python2.7
# vim: set fileencoding=utf8

import os
import sys
from getpass import getpass
import requests
from requests_toolbelt import MultipartEncoder
import urllib
import json
import cPickle as pk
import re
import time
import argparse
import random
import select
import base64
import md5
from zlib import crc32
import cStringIO
import signal

############################################################
# Defines that should never be changed
OneK = 1024
OneM = OneK * OneK
OneG = OneM * OneK
OneT = OneG * OneK
OneP = OneT * OneK
OneE = OneP * OneK

############################################################
# Default values
MinRapidUploadFileSize = 256 * OneK
DefaultSliceSize = 10 * OneM
MaxSliceSize = 2 * OneG
MaxSlicePieces = 1024
ENoError = 0

############################################################
# wget exit status
wget_es = {
    0: "No problems occurred.",
    2: "User interference.",
    1<<8: "Generic error code.",
    2<<8: "Parse error - for instance, when parsing command-line " \
        "optio.wgetrc or .netrc...",
    3<<8: "File I/O error.",
    4<<8: "Network failure.",
    5<<8: "SSL verification failure.",
    6<<8: "Username/password authentication failure.",
    7<<8: "Protocol errors.",
    8<<8: "Server issued an error response."
}
############################################################

# file extensions
mediatype = {".wma", ".wav", ".mp3", ".aac", ".ra", ".ram", ".mp2", ".ogg", ".aif", ".mpega", ".amr", ".mid", ".midi", ".m4a", ".m4v", ".wmv", ".rmvb", ".mpeg4", ".mpeg2", ".flv", ".avi", ".3gp", ".mpga", ".qt", ".rm", ".wmz", ".wmd", ".wvx", ".wmx", ".wm", ".swf", ".mpg", ".mp4", ".mkv", ".mpeg", ".mov", ".mdf", ".iso"}
imagetype = {".jpg", ".jpeg", ".gif", ".bmp", ".png", ".jpe", ".cur", ".svg", ".svgz", ".tif", ".tiff", ".ico"}
doctype = {".doc", ".docx", ".xls", ".xlsx", ".ppt", ".pptx", ".vsd", ".txt", ".pdf", ".ods", ".ots", ".odt", ".rtf", ".dot", ".dotx", ".odm", ".pps", ".pot", ".xlt", ".xltx", ".csv", ".ppsx", ".potx", ".epub", ".apk", ".exe", ".msi", ".ipa", ".torrent", ".mobi"}
archivetype = {".7z", ".a", ".ace", ".afa", ".alz", ".android", ".apk", ".ar", ".arc", ".arj", ".b1", ".b1", ".ba", ".bh", ".bz2", ".cab", ".cab", ".cfs", ".chm", ".cpio", ".cpt", ".cqm", ".dar", ".dd", ".dgc", ".dmg", ".ear", ".ecc", ".eqe", ".exe", ".f", ".gca", ".gz", ".ha", ".hki", ".html", ".ice", ".id", ".infl", ".iso", ".jar", ".kgb", ".lbr", ".lha", ".lqr", ".lz", ".lzh", ".lzma", ".lzo", ".lzx", ".mar", ".ms", ".net", ".package", ".pak", ".paq6", ".paq7", ".paq8", ".par", ".par2", ".partimg", ".pea", ".pim", ".pit", ".qda", ".rar", ".rk", ".rz", ".s7z", ".sda", ".sea", ".sen", ".sfark", ".sfx", ".shar", ".sit", ".sitx", ".sqx", ".tar", ".tbz2", ".tgz", ".tlz", ".tqt", ".uc", ".uc0", ".uc2", ".uca", ".ucn", ".ue2", ".uha", ".ur2", ".war", ".web", ".wim", ".x", ".xar", ".xp3", ".xz", ".yz1", ".z", ".zip", ".zipx", ".zoo", ".zpaq", ".zz"}

s = '\x1b[%s;%sm%s\x1b[0m'       # terminual color template

cookie_file = os.path.join(os.path.expanduser('~'), '.bp.cookies')
upload_datas_path = os.path.join(os.path.expanduser('~'), '.bp.pickle')

headers = {
    "Accept":"text/html,application/xhtml+xml,application/xml; " \
        "q=0.9,image/webp,*/*;q=0.8",
    "Accept-Encoding":"text/html",
    "Accept-Language":"en-US,en;q=0.8,zh-CN;q=0.6,zh;q=0.4,zh-TW;q=0.2",
    "Content-Type":"application/x-www-form-urlencoded",
    "Referer":"http://www.baidu.com/",
    "User-Agent":"Mozilla/5.0 (X11; Linux i686) AppleWebKit/537.36 "\
        "(KHTML, like Gecko) Chrome/32.0.1700.77 Safari/537.36"
}

ss = requests.session()
ss.headers.update(headers)

# https://stackoverflow.com/questions/1094841/reusable-library-to-get-human-readable-version-of-file-size
def sizeof_fmt(num):
    for x in ['B','KB','MB','GB']:
        if num < 1024.0:
            return "%3.1f%s" % (num, x)
        num /= 1024.0
    return "%3.1f%s" % (num, 'TB')

def print_process_bar(point, total, slice_size, start_time=None, pre='', suf='', msg=''):
    length = 20
    nowpoint = point / (total + 0.0)
    percent = round(100 * nowpoint, 1)
    now = time.time()
    speed = sizeof_fmt(slice_size / (now - start_time)) + '/s'
    t = int(nowpoint*length)

    msg = '\r' + ' '.join([pre, '[%s%s]' % ('='*t, ' '*(length - t)), \
        str(percent) + '%', speed, msg, suf])
    sys.stdout.write(msg)
    sys.stdout.flush()
    return now

class panbaiducom_HOME(object):
    def __init__(self):
        self._download_do = self._play_do if args.play else self._download_do
        self.ondup = 'overwrite'
        self.highlights = []
        self.accounts = self._check_cookie_file()

        for tail in args.tails: self.highlights.append({'text': tail.decode('utf8', 'ignore'), 'is_regex': 0})
        for head in args.heads: self.highlights.append({'text': head.decode('utf8', 'ignore'), 'is_regex': 0})
        for include in args.includes: self.highlights.append({'text': include.decode('utf8', 'ignore'), 'is_regex': 1})

    @staticmethod
    def _check_cookie_file():
        def correct_do():
            g = open(cookie_file, 'wb')
            pk.dump({}, g)
            g.close()
            print s % (1, 97, '  please login')
            sys.exit(1)

        if not os.path.exists(cookie_file):
            correct_do()

        try:
            j = pk.load(open(cookie_file))
        except:
            correct_do()

        if type(j) != type({}):
            correct_do()

        for i in j:
            if type(j[i]) != type({}):
                del j[i]
            else:
                if not j[i].get('cookies') and not j[i].get('on'):
                    del j[i]

        return j

    def init(self):
        if self.accounts:
            j = self.accounts
            u = [u for u in j if j[u]['on']]
            if u:
                ss.cookies.update(j[u[0]]['cookies'])
            else:
                print s % (1, 91, '  !! no account is online, please login or userchange')
                sys.exit(1)

            if not self.check_login():
                print s % (1, 91, '  !! cookie is invalid, please login\n'), u[0]
                sys.exit(1)
            self.save_cookies(u[0])
        else:
            print s % (1, 97, '  no account, please login')
            sys.exit(1)

    @staticmethod
    def save_img(url, ext):
        path = os.path.join(os.path.expanduser('~'), 'vcode.%s' % ext)
        with open(path, 'w') as g:
            data = urllib.urlopen(url).read()
            g.write(data)
        print "  ++ 验证码已保存至", s % (1, 97, path)
        input_code = raw_input(s % (2, 92, "  输入验证码: "))
        return input_code

    def check_login(self):
        #print s % (1, 97, '\n  -- check_login')
        url = 'http://www.baidu.com/home/msg/data/personalcontent'
        r = ss.get(url)
        if 'errNo":"0' in r.content:
            #print s % (1, 92, '  -- check_login success\n')
            #self.get_dsign()
            #self.save_cookies()
            return True
        else:
            print s % (1, 91, '  -- check_login fail\n')
            return False

    def login(self, username, password):
        print s % (1, 97, '\n  -- login')

        # Check if we have to deal with verify codes
        params = {
            'tpl': 'pp',
            'callback': 'bdPass.api.login._needCodestringCheckCallback',
            'index': 0,
            'logincheck': '',
            'time': 0,
            'username': username
        }

        # Ask server
        url = 'https://passport.baidu.com/v2/api/?logincheck'
        r = ss.get(url, params=params)
        # Callback for verify code if we need
        #codestring = r.content[r.content.index('(')+1:r.content.index(')')]
        codestring = re.search(r'\((.+?)\)', r.content).group(1)
        codestring = json.loads(codestring)['codestring']
        codestring = codestring if codestring else ""
        url = 'https://passport.baidu.com/cgi-bin/genimage?'+codestring
        verifycode = self.save_img(url, 'gif') if codestring != "" else ""

        # Now we'll do login
        # Get token
        ss.get('http://www.baidu.com')
        t = ss.get('https://passport.baidu.com/v2/api/?getapi&class=login' \
                   '&tpl=pp&tangram=false').text
        token = re.search(r'login_token=\'(.+?)\'', t).group(1)

        # Construct post body
        data = {
            'token': token,
            'ppui_logintime': '1600000',
            'charset':'utf-8',
            'codestring': codestring,
            'isPhone': 'false',
            'index': 0,
            'u': '',
            'safeflg': 0,
            'staticpage': 'http://www.baidu.com/cache/user/html/jump.html',
            'loginType': 1,
            'tpl': 'pp',
            'callback': 'parent.bd__pcbs__qvljue',
            'username': username,
            'password': password,
            'verifycode': verifycode,
            'mem_pass': 'on',
            'apiver': 'v3'
        }

        # Post!
        # XXX : do not handle errors
        url = 'https://passport.baidu.com/v2/api/?login'
        ss.post(url, data=data)
        #self.save_cookies()

    def save_cookies(self, username):
        self.username = username
        accounts = self.accounts
        accounts[username] = {}
        accounts[username]['cookies'] = ss.cookies.get_dict()
        accounts[username]['on'] = 1
        quota = self._get_quota()
        capacity = '%s/%s' % (sizeof_fmt(quota['used']), sizeof_fmt(quota['total']))
        accounts[username]['capacity'] = capacity
        for u in accounts:
            if u != username:
                accounts[u]['on'] = 0
        with open(cookie_file, 'w') as g:
            pk.dump(accounts, g)

    def _get_bdstoken(self):
        if hasattr(self, 'bdstoken'):
            return self.bdstoken

        self.bdstoken = md5.new(str(time.time())).hexdigest()
        return self.bdstoken

    #def _sift(self, fileslist, name=None, size=None, time=None, head=None, tail=None, include=None, exclude=None):
    def _sift(self, fileslist, **arguments):
        """
        a filter for time, size, name, head, tail, include, exclude
        support regular expression
        """
        def sort(reverse, arg, fileslist=fileslist):
            tdict = {fileslist[i][arg] : i for i in xrange(len(fileslist))}
            keys = tdict.keys()
            keys.sort(reverse=reverse)
            indexs = [tdict[i] for i in keys]
            fileslist = [fileslist[i] for i in indexs]
            return fileslist

        # for time
        if arguments.get('name'):
            reverse = None
            if arguments['name'] == 'reverse':
                reverse = True
            elif arguments['name'] == 'no_reverse':
                reverse = False
            fileslist = sort(reverse, 'server_filename')

        # for size
        if arguments.get('size'):
            reverse = None
            if arguments['size'] == 'reverse':
                reverse = True
            elif arguments['size'] == 'no_reverse':
                reverse = False
            fileslist = sort(reverse, 'size')

        # for time
        if arguments.get('time'):
            reverse = None
            if arguments['time'] == 'reverse':
                reverse = True
            elif arguments['time'] == 'no_reverse':
                reverse = False
            fileslist = sort(reverse, 'server_mtime')

        # for head, tail, include, exclude
        heads = args.heads
        tails = args.tails
        includes = args.includes
        excludes = args.excludes
        keys1, keys2, keys3, keys4 = [], [], [], []
        if heads or tails or includes or excludes:
            tdict = {fileslist[i]['server_filename'] : i for i in xrange(len(fileslist))}
            for head in heads:
                keys1 += [i for i in tdict.keys() if i.lower().startswith(head.decode('utf8', 'ignore').lower())]
            for tail in tails:
                keys2 += [i for i in tdict.keys() if i.lower().endswith(tail.decode('utf8', 'ignore').lower())]
            for include in includes:
                keys3 += [i for i in tdict.keys() if re.search(include.decode('utf8', 'ignore'), i, flags=re.I)]
            for exclude in excludes:
                keys4 += [i for i in tdict.keys() if not re.search(exclude.decode('utf8', 'ignore'), i, flags=re.I)]

            # intersection
            keys = [set(i) for i in [keys1, keys2, keys3, keys4] if i]
            if len(keys) > 1:
                tkeys = keys[0]
                for i in keys:
                    tkeys &= i
                keys = tkeys
            elif len(keys) == 1:
                keys = keys[0]
            elif len(keys) == 0:
                keys = []
                return []

            indexs = [tdict[i] for i in keys]
            indexs.sort()
            fileslist = [fileslist[i] for i in indexs]

        dirs = [i for i in fileslist if i['isdir']]
        t, tt = [], []
        args.type_ = args.type_ if args.type_ else ''
        if 'e' in args.type_:
            for i in dirs:
                d = i['path'].encode('utf8')
                j = self._get_file_list('name', None, d, 1, all=False)
                if not j['list']:
                    t.append(i)
                else:
                    tt.append(i)
        if 'e' in args.type_.split(','): dirs = t
        if 'ne' in args.type_.split(','): dirs = tt
        files = [i for i in fileslist if not i['isdir']]
        if arguments.get('desc') == 1:
            dirs.reverse()
            files.reverse()

        if 'f' in args.type_:
            fileslist = files
        elif 'd' in args.type_:
            fileslist = dirs
        else:
            fileslist = dirs + files

        return fileslist

    def _get_path(self, url):
        t = re.search(r'path=(.+?)(&|$)', url)
        if t:
            t = t.group(1)
        else:
            t = '/'
        t = urllib.unquote_plus(t)
        t = urllib.unquote_plus(t)
        return t

    def _get_quota(self):
        url = 'https://pan.baidu.com/api/quota'
        r = ss.get(url)
        j = r.json()
        if j['errno'] != 0:
            print s % (1, 92, '  !! Error at _get_quota')
            sys.exit(1)
        else:
            return j

    def _get_file_list(self, order, desc, dir_, num, all=True):
        t = {'Referer':'http://pan.baidu.com/disk/home'}
        theaders = headers
        theaders.update(t)

        p = {
            "channel": "chunlei",
            "clienttype": 0,
            "web": 1,
            "showempty": 1,
            "num": num,   ## max amount is 10000
            "t": int(time.time()*1000),
            "dir": dir_,
            "page": 1,
            "desc": 1,   ## reversely
            "order": order, ## sort by name, or size, time
            "_": int(time.time()*1000),
            #"bdstoken": self._get_bdstoken(),
        }
        if not desc: del p['desc']
        url = 'http://pan.baidu.com/api/list'

        infos = []
        while True:
            r = ss.get(url, params=p, headers=theaders)
            j = r.json()
            if j['errno'] != 0:
                print s % (1, 91, '  error: _get_file_list'), '--', j
                sys.exit(1)
            else:
                infos += j['list']

            if not all: return j

            if len(infos) == num:
                p['page'] += 1
            else:
                j['list'] = infos
                return j

    def _get_dsign(self):
        url = 'http://pan.baidu.com/disk/home'
        r = ss.get(url)
        html = r.content
        sign1 = re.search(r'sign1 = \'(.+?)\';', html).group(1)
        sign3 = re.search(r'sign3 = \'(.+?)\';', html).group(1)
        timestamp = re.search(r'timestamp = \'(.+?)\';', html).group(1)

        # following javascript code from http://pan.baidu.com/disk/home
        #yunData.sign2 = function s(j, r) {
        #    var a = [];
        #    var p = [];
        #    var o = \x22\ x22;
        #    var v = j.length;
        #    for (var q = 0; q < 256; q++) {
        #        a[q] = j.substr((q % v), 1).charCodeAt(0);
        #        p[q] = q
        #    }
        #    for (var u = q = 0; q < 256; q++) {
        #        u = (u + p[q] + a[q]) % 256;
        #        var t = p[q];
        #        p[q] = p[u];
        #        p[u] = t
        #    }
        #    for (var i = u = q = 0; q < r.length; q++) {
        #        i = (i + 1) % 256;
        #        u = (u + p[i]) % 256;
        #        var t = p[i];
        #        p[i] = p[u];
        #        p[u] = t;
        #        k = p[((p[i] + p[u]) % 256)];
        #        o += String.fromCharCode(r.charCodeAt(q) ^ k)
        #    }
        #    return o
        #};

        def sign2(j, r):
            a = []
            p = []
            o = ''
            v = len(j)

            for q in xrange(256):
                a.append(ord(j[q % v]))
                p.append(q)

            u = 0
            for q in xrange(256):
                u = (u + p[q] + a[q]) % 256
                t = p[q]
                p[q] = p[u]
                p[u] = t

            i = 0
            u = 0
            for q in xrange(len(r)):
                i = (i + 1) % 256
                u = (u + p[i]) % 256
                t = p[i]
                p[i] = p[u]
                p[u] = t
                k = p[((p[i] + p[u]) % 256)]
                o += chr(ord(r[q]) ^ k)

            return base64.b64encode(o)

        self.dsign = sign2(sign3, sign1)
        self.timestamp = timestamp

    def _get_dlink(self, i):
        if not hasattr(self, 'dsign'):
            self._get_dsign()

        while True:
            params = {
                "channel": "chunlei",
                "clienttype": 0,
                "web": 1,
                #"bdstoken": self._get_bdstoken()
            }

            data = {
                "sign": self.dsign,
                "timestamp": self.timestamp,
                "fidlist": "[%s]" % i['fs_id'],
                "type": "dlink"
            }

            url = 'http://pan.baidu.com/api/download'
            r = ss.post(url, params=params, data=data)
            j = r.json()
            if j['errno'] == 0:
                dlink = j['dlink'][0]['dlink'].encode('utf8')
                dlink = re.sub(r'prisign=.+?(&|$)', r'prisign=unknow\1', dlink)
                dlink = dlink.replace('chkbd=0', 'chkbd=1')
                dlink = dlink.replace('chkv=0', 'chkv=1')
                return dlink
            else:
                self._get_dsign()

    def _get_dlink2(self, i):
        j = self._meta([i['path'].encode('utf8')])
        if j:
            return j['info'][0]['dlink'].encode('utf8')
        else:
            print s % (1, 91, '  !! Error at _get_dlink2')
            sys.exit(1)

    def download(self, paths):
        for path in paths:
            path = self._get_path(path) if path[0] != '/' else path
            base_dir = '' if os.path.split(path)[0] == '/' \
                else os.path.split(path)[0]

            meta = self._meta([path])
            if meta:
                if meta['info'][0]['isdir']:
                    dir_loop = [path]
                    for d in dir_loop:
                        j = self._get_file_list('name', None, d, 10000)
                        if j['list']:
                            if args.recursive:
                                for i in j['list']:
                                    dir_loop.append(i['path'].encode('utf8')) \
                                        if i['isdir'] else None

                            if args.play:
                                j['list'] = [i for i in j['list'] \
                                    if not i['isdir'] and os.path.splitext(i['server_filename'])[-1].lower() in mediatype]

                            if args.heads or args.tails or args.includes or args.excludes:
                                j['list'] = self._sift(j['list'])

                            total_file = len([i for i in j['list'] if not i['isdir']])

                            if args.from_ - 1:
                                j['list'] = j['list'][args.from_-1:] \
                                    if args.from_ else j['list']

                            nn = args.from_
                            for i in j['list']:
                                if i['isdir']: continue

                                t = i['path'].encode('utf8')
                                t = t.replace(base_dir, '')
                                t = t[1:] if t[0] == '/' else t
                                t =  os.path.join(os.getcwd(), t)

                                if not i.has_key('dlink'):
                                    i['dlink'] = self._get_dlink2(i)

                                infos = {
                                    'file': t,
                                    'path': i['path'].encode('utf8'),
                                    'dir_': os.path.split(t)[0],
                                    'dlink': i['dlink'].encode('utf8'),
                                    'name': i['server_filename'].encode('utf8'),
                                    'size': i['size'],
                                    'nn': nn,
                                    'total_file': total_file
                                }
                                nn += 1
                                self._download_do(infos)

                elif not meta['info'][0]['isdir']:
                    t =  os.path.join(os.getcwd(), meta['info'][0]['server_filename'].encode('utf8'))
                    infos = {
                        'file': t,
                        'path': meta['info'][0]['path'].encode('utf8'),
                        'dir_': os.path.split(t)[0],
                        #'dlink': self._get_dlink(meta['info'][0]),
                        'dlink': meta['info'][0]['dlink'].encode('utf8'),
                        'name': meta['info'][0]['server_filename'].encode('utf8'),
                        'size': meta['info'][0]['size'],
                    }
                    self._download_do(infos)

            else:
                print s % (1, 91, '  !! path is not existed.\n'), \
                    ' --------------\n ', path

    @staticmethod
    def _download_do(infos):
        ## make dirs
        if not os.path.exists(infos['dir_']):
            os.makedirs(infos['dir_'])
        else:
            if os.path.exists(infos['file']):
                return 0

        num = random.randint(0, 7) % 7
        col = sizeof_fmt(infos['size']) + ' # ' + s % (2, num + 90, infos['path']) \
            if args.view else s % (2, num + 90, infos['name'])
        infos['nn'] = infos['nn'] if infos.get('nn') else 1
        infos['total_file'] = infos['total_file'] if infos.get('total_file') else 1
        print '\n  ++ download: #', s % (1, 97, infos['nn']), '/', s % (1, 97, infos['total_file']), '#', col

        if args.aria2c:
            quiet = ' --quiet=true' if args.quiet else ''
            taria2c = ' -x %s -s %s' % (args.aria2c, args.aria2c)
            tlimit = ' --max-download-limit %s' % args.limit if args.limit else ''
            cmd = 'aria2c -c%s%s%s ' \
                '-o "%s.tmp" -d "%s" ' \
                '--user-agent "netdisk;4.4.0.6;PC;PC-Windows;6.2.9200;WindowsBaiduYunGuanJia" ' \
                '--header "Referer:http://pan.baidu.com/disk/home" "%s"' \
                % (quiet, taria2c, tlimit, infos['name'], \
                    infos['dir_'], infos['dlink'])
        else:
            quiet = ' -q' if args.quiet else ''
            tlimit = ' --limit-rate %s' % args.limit if args.limit else ''
            cmd = 'wget -c%s%s ' \
                '-O "%s.tmp" ' \
                '--user-agent "netdisk;4.4.0.6;PC;PC-Windows;6.2.9200;WindowsBaiduYunGuanJia" ' \
                '--header "Referer:http://pan.baidu.com/disk/home" "%s"' \
                % (quiet, tlimit, infos['file'], infos['dlink'])

        status = os.system(cmd)
        if status != 0:     # other http-errors, such as 302.
            wget_exit_status_info = wget_es[status]
            print('\n\n ---###   \x1b[1;91mERROR\x1b[0m ==> '\
                '\x1b[1;91m%d (%s)\x1b[0m   ###--- \n\n' \
                 % (status, wget_exit_status_info))
            print s % (1, 91, '  ===> '), cmd
            sys.exit(1)
        else:
            os.rename('%s.tmp' % infos['file'], infos['file'])

    @staticmethod
    def _play_do(infos):
        num = random.randint(0, 7) % 7
        col = sizeof_fmt(infos['size']) + ' # ' + s % (2, num + 90, infos['path']) \
            if args.view else s % (2, num + 90, infos['name'])
        infos['nn'] = infos['nn'] if infos.get('nn') else 1
        infos['total_file'] = infos['total_file'] if infos.get('total_file') else 1
        print '\n  ++ play: #', s % (1, 97, infos['nn']), '/', \
            s % (1, 97, infos['total_file']), '#', col

        if os.path.splitext(infos['file'])[-1].lower() == '.wmv':
            quiet = ' -really-quiet' if args.quiet else ''
            cmd = 'mplayer%s -cache 10000 ' \
                '-http-header-fields "user-agent:netdisk;4.4.0.6;PC;PC-Windows;6.2.9200;WindowsBaiduYunGuanJia" ' \
                '-http-header-fields "Referer:http://pan.baidu.com/disk/home" "%s"' \
                % (quiet, infos['dlink'])
        else:
            quiet = ' --really-quiet' if args.quiet else ''
            cmd = 'mpv%s --cache 10000 --cache-default 10000 ' \
                '--http-header-fields "user-agent:netdisk;4.4.0.6;PC;PC-Windows;6.2.9200;WindowsBaiduYunGuanJia" ' \
                '--http-header-fields "Referer:http://pan.baidu.com/disk/home" "%s"' \
                % (quiet, infos['dlink'])

        status = os.system(cmd)
        timeout = 1
        ii, _, _ = select.select([sys.stdin], [], [], timeout)
        if ii:
            sys.exit(0)
        else:
            pass

    def _make_dir(self, dir_):
        p = {
            "a": "commit",
            "channel": "chunlei",
            "clienttype": 0,
            "web": 1,
            "bdstoken": self._get_bdstoken()
        }
        data = {
            "path": dir_,
            "isdir": 1,
            "size": "",
            "block_list": [],
            "method": "post"
        }
        url = 'http://pan.baidu.com/api/create'
        r = ss.post(url, params=p, data=data)
        j = r.json()
        if j['errno'] != 0:
            print s % (1, 91, '  !! Error at _make_dir'), j
            sys.exit(1)
        else:
            return ENoError

    def _meta(self, file_list):
        p = {
            "channel": "chunlei",
            "app_id": "250528",
            "method": "filemetas",
            "dlink": 1,
            "blocks": 0,  # 0 or 1
            #"bdstoken": self._get_bdstoken()
        }
        data = {'target': json.dumps(file_list)}
        url = 'http://pan.baidu.com/api/filemetas'
        r = ss.post(url, params=p, data=data, verify=False)
        j = r.json()
        if j['errno'] == 0:
            return j
        else:
            return False

    ################################################################
    # for upload

    def _rapidupload_file(self, lpath, rpath):
        print '  |-- upload_function:', s % (1, 97, '_rapidupload_file')
        slice_md5 = md5.new(open(lpath, 'rb').read(256 * OneK)).hexdigest()
        with open(lpath, "rb") as f:
            buf = f.read(OneM)
            content_md5 = md5.new()
            content_md5.update(buf)
            crc = crc32(buf).conjugate()
            while True:
                buf = f.read(OneM)
                if buf:
                    crc = crc32(buf, crc).conjugate()
                    content_md5.update(buf)
                else:
                    break
            content_md5 = content_md5.hexdigest()
            content_crc32 = crc.conjugate() & 0xffffffff

        p = {
            "method" : "rapidupload",
            "app_id": "250528",
            "BDUSS": ss.cookies['BDUSS']
        }
        data = {
            "path": os.path.join(rpath, os.path.basename(lpath)),
            "content-length" : self.__current_file_size,
            "content-md5" : content_md5,
            "slice-md5" : slice_md5,
            "content-crc32" : content_crc32,
            "ondup" : self.ondup
        }
        url = 'https://c.pcs.baidu.com/rest/2.0/pcs/file'
        r = ss.post(url, params=p, data=data, verify=False)
        if r.ok:
            return ENoError
        else:
            return r.json()

    def _upload_one_file(self, lpath, rpath):
        print '  |-- upload_function:', s % (1, 97, '_upload_one_file')
        start_time = time.time()
        p = {
            "method": "upload",
            "app_id": "250528",
            "ondup": self.ondup,
            "dir": rpath,
            "filename": os.path.basename(lpath),
            "BDUSS": ss.cookies['BDUSS'],
        }
        files = {'file': ('file', open(lpath, 'rb'), '')}
        data = MultipartEncoder(files)
        theaders = headers
        theaders['Content-Type'] = data.content_type
        url = 'https://c.pcs.baidu.com/rest/2.0/pcs/file'
        r = ss.post(url, params=p, data=data, verify=False, headers=theaders)
        if r.ok:
            t = self.__current_file_size
            print_process_bar(t, t, t, start_time, pre='     ')
            return ENoError
        else:
            sys.exit(1)

    def _combine_file(self, lpath, rpath):
        p = {
            "method": "createsuperfile",
            "app_id": "250528",
            "ondup": self.ondup,
            "path": os.path.join(rpath, os.path.basename(lpath)),
            "BDUSS": ss.cookies['BDUSS'],
        }
        data = {'param': json.dumps({'block_list': self.upload_datas[lpath]['slice_md5s']})}
        url = 'https://c.pcs.baidu.com/rest/2.0/pcs/file'
        r = ss.post(url, params=p, data=data, verify=False)
        if r.ok:
            return ENoError
        else:
            sys.exit(1)

    def _upload_slice(self):
        p = {
            "method": "upload",
            "app_id": "250528",
            "type": "tmpfile",
            "BDUSS": ss.cookies['BDUSS'],
        }

        file = cStringIO.StringIO(self.__slice_block)
        files = {'file': ('file', file, '')}
        data = MultipartEncoder(files)
        theaders = headers
        theaders['Content-Type'] = data.content_type
        url = 'https://c.pcs.baidu.com/rest/2.0/pcs/file'
        r = ss.post(url, params=p, data=data, verify=False, headers=theaders)
        j = r.json()
        if self.__slice_md5 == j['md5']:
            return ENoError
        else:
            return 'MD5Mismatch'

    def _get_pieces_slice(self):
        pieces = MaxSlicePieces
        slice = DefaultSliceSize
        n = 1
        while True:
            t = n * DefaultSliceSize * MaxSlicePieces
            if self.__current_file_size <= t:
                if self.__current_file_size % (n * DefaultSliceSize) == 0:
                    pieces = self.__current_file_size / (n * DefaultSliceSize)
                    slice = n * DefaultSliceSize
                else:
                    pieces = (self.__current_file_size / (n * DefaultSliceSize)) + 1
                    slice = n * DefaultSliceSize
                break
            elif t > MaxSliceSize * MaxSlicePieces:
                n += 1
            else:
                print s % (1, 91, '  !! file is too big, uploading is not supported.')
                sys.exit(1)

        return pieces, slice

    def _get_upload_function(self, rapidupload_is_fall=False):
        if self.__current_file_size > MinRapidUploadFileSize:
            if not rapidupload_is_fall:
                return '_rapidupload_file'
            else:
                if self.__current_file_size <= DefaultSliceSize:
                    return '_upload_one_file'

                elif self.__current_file_size <= MaxSliceSize * MaxSlicePieces:
                    return '_upload_file_slices'
                else:
                    print s % (1, 91, '  !! Error: size of file is too big.')
                    return 'None'
        else:
            return '_upload_one_file'

    def _upload_file(self, lpath, rpath):
        print s % (1, 94, '  ++ uploading:'), lpath

        __current_file_size = os.path.getsize(lpath)
        self.__current_file_size = __current_file_size
        upload_function = self._get_upload_function()

        if self.upload_datas.has_key(lpath):
            if __current_file_size != self.upload_datas[lpath]['size']:
                self.upload_datas[lpath]['is_over'] = False
                self.upload_datas[lpath]['size'] = __current_file_size
            self.upload_datas[lpath]['upload_function'] = upload_function
        else:
            self.upload_datas[lpath] = {
                'is_over': False,
                'upload_function': upload_function,
                'size': __current_file_size,
                'remotepaths': set()
            }

        if args.type_ and 'e' in args.type_:
            path = os.path.join(rpath, os.path.basename(lpath))
            meta = self._meta([path])
            if meta:
                self.upload_datas[lpath]['is_over'] = True
                self.upload_datas[lpath]['remotepaths'].update([rpath])
                #self.save_upload_datas()
                print s % (1, 93, '  |-- file exists at pan.baidu.com, not upload\n')
                return
            else:
                pass

        while True:
            if not self.upload_datas[lpath]['is_over']:
                m = self.upload_datas[lpath]['upload_function']
                if m == '_upload_file_slices':
                    time.sleep(2)
                    print '  |-- upload_function:', s % (1, 97, '_upload_file_slices')
                    pieces, slice = self._get_pieces_slice()
                    f = open(lpath, 'rb')
                    current_piece_point = len(self.upload_datas[lpath]['slice_md5s'])
                    f.seek(current_piece_point * slice)
                    start_time = time.time()
                    print_process_bar(f.tell(), __current_file_size, 0, start_time, \
                        pre='     ', msg='%s/%s' % (str(current_piece_point), str(pieces)))
                    for piece in xrange(current_piece_point, pieces):
                        self.__slice_block = f.read(slice)
                        if self.__slice_block:
                            self.__slice_md5 = md5.new(self.__slice_block).hexdigest()
                            while True:
                                result = self._upload_slice()
                                if result == ENoError:
                                    break
                                else:
                                    print s % (1, 91, '  |-- slice_md5 does\'n match, retry.')
                            self.upload_datas[lpath]['slice_md5s'].append(self.__slice_md5)
                            #self.save_upload_datas()
                            start_time = print_process_bar(f.tell(), __current_file_size, slice, start_time, \
                                pre='     ', msg='%s/%s' % (str(piece+1), str(pieces)))
                    result = self._combine_file(lpath, rpath)
                    if result == ENoError:
                        self.upload_datas[lpath]['is_over'] = True
                        self.upload_datas[lpath]['remotepaths'].update([rpath])
                        del self.upload_datas[lpath]['slice_md5s']
                        #self.save_upload_datas()
                        print s % (1, 92, '\n  |-- success.\n')
                        break
                    else:
                        print s % (1, 91, '  !! Error at _combine_file')

                elif m == '_upload_one_file':
                    time.sleep(2)
                    result = self._upload_one_file(lpath, rpath)
                    if result == ENoError:
                        self.upload_datas[lpath]['is_over'] = True
                        self.upload_datas[lpath]['remotepaths'].update([rpath])
                        #self.save_upload_datas()
                        print s % (1, 92, '\n  |-- success.\n')
                        break
                    else:
                        print s % (1, 91, '  !! Error: _upload_one_file is fall, retry.')

                elif m == '_rapidupload_file':
                    time.sleep(2)
                    result = self._rapidupload_file(lpath, rpath)
                    if result == ENoError:
                        self.upload_datas[lpath]['is_over'] = True
                        self.upload_datas[lpath]['remotepaths'].update([rpath])
                        #self.save_upload_datas()
                        print s % (1, 92, '  |-- RapidUpload: Success.\n')
                        break
                    else:
                        if args.type_ and 'r' in args.type_.split(','):   # only rapidupload
                            print s % (1, 91, '  |-- can\'t be RapidUploaded\n')
                            break
                        print s % (1, 93, '  |-- can\'t be RapidUploaded, ' \
                            'now trying normal uploading.')
                        upload_function = self._get_upload_function(rapidupload_is_fall=True)
                        self.upload_datas[lpath]['upload_function'] = upload_function
                        if upload_function == '_upload_file_slices':
                            if not self.upload_datas[lpath].has_key('slice_md5s'):
                                self.upload_datas[lpath]['slice_md5s'] = []

                else:
                    print s % (1, 91, '  !! Error: size of file is too big.')
                    break

            else:
                if args.uploadmode == 'c':
                    if rpath in self.upload_datas[lpath]['remotepaths']:
                        print s % (1, 92, '  |-- file was uploaded.\n')
                        break
                    else:
                        self.upload_datas[lpath]['is_over'] = False
                elif args.uploadmode == 'o':
                    print s % (1, 93, '  |-- reupload.')
                    self.upload_datas[lpath]['is_over'] = False

    def _upload_dir(self, lpath, rpath):
        base_dir = os.path.split(lpath)[0]
        for a, b, c in os.walk(lpath):
            for path in c:
                localpath = os.path.join(a, path)
                t = localpath.replace(base_dir + '/', '')
                t = os.path.split(t)[0]
                remotepath = os.path.join(rpath, t)
                self._upload_file(localpath, remotepath)

    def upload(self, localpaths, remotepath):
        self.upload_datas_path = upload_datas_path
        self.upload_datas = {}
        if os.path.exists(self.upload_datas_path):
            f = open(self.upload_datas_path, 'rb')
            upload_datas = pk.load(f)
            if upload_datas:
                self.upload_datas = upload_datas

        for localpath in localpaths:
            lpath = localpath
            if localpath[0] == '~':
                lpath = os.path.expanduser(localpath)
            else:
                lpath = os.path.abspath(localpath)
            rpath = remotepath if remotepath[0] == '/' else '/' + remotepath

            if os.path.exists(lpath):
                pass
            else:
                print s % (1, 91, '  !! Error: localpath doesn\'t exist')
                print s % (1, 91, '  ==>'), lpath
                continue

            if os.path.isdir(lpath):
                self._upload_dir(lpath, rpath)
            elif os.path.isfile(lpath):
                self._upload_file(lpath, rpath)
            else:
                print s % (1, 91, '  !! Error: localpath ?')
                sys.exit(1)

        self.save_upload_datas()

    def save_upload_datas(self):
        g = open(self.upload_datas_path, 'wb')
        pk.dump(self.upload_datas, g)
        g.close()

    ##################################################################
    # for saving shares

    def _share_transfer(self, info):
        meta = self._meta([info['remotepath'].encode('utf8')])
        if not meta:
            self._make_dir(info['remotepath'].encode('utf8'))

        theaders = headers
        theaders.update({'Referer': 'http://pan.baidu.com/share/link?shareid=%s&uk=%s' \
            % (self.shareid, self.uk)})

        p = {
            "channel": "chunlei",
            "clienttype": 0,
            "web": 1,
            "ondup": "overwrite",
            "async": 1,
            "from": self.uk,
            "shareid": self.shareid,
            "bdstoken": self._get_bdstoken()
        }
        data = "path=" + urllib.quote_plus(info['remotepath'].encode('utf8')) + \
            '&' + "filelist=" + urllib.quote_plus('["%s"]' % info['path'].encode('utf8'))

        url = 'http://pan.baidu.com/share/transfer'
        r = ss.post(url, params=p, data=data, headers=theaders, verify=False)
        j = r.json()
        if j['errno'] == 0:
            return ENoError
        else:
            return j['errno']

    def _get_share_list(self, info):
        p = {
            "channel": "chunlei",
            "clienttype": 0,
            "web": 1,
            "num": 10000,
            "dir": info['path'].encode('utf8'),
            "t": int(time.time()*1000),
            "uk": self.uk,
            "shareid": self.shareid,
            #"desc": 1,   ## reversely
            "order": "name", ## sort by name, or size, time
            "_": int(time.time()*1000),
            "bdstoken": self._get_bdstoken()
        }
        url = 'http://pan.baidu.com/share/list'
        r = ss.get(url, params=p)
        j = r.json()
        if j['errno'] != 0:
            print s % (1, 91, '  !! Error at _get_share_list')
            sys.exit(1)
        rpath = '/'.join([info['remotepath'], os.path.split(info['path'])[-1]])
        for x in xrange(len(j['list'])):
            j['list'][x]['remotepath'] = rpath

        return j['list']

    def _get_share_infos(self, url, remotepath, infos):
        r = ss.get(url)
        html = r.content

        self.uk = re.search(r'FileUtils.share_uk="(.+?)"', html).group(1)
        self.shareid = re.search(r'FileUtils.share_id="(.+?)"', html).group(1)
        self.bdstoken = re.search(r'bdstoken="(.+?)"', html).group(1)

        isdirs = [int(x) for x in re.findall(r'\\"isdir\\":(\d)', html)]
        paths = [json.loads('"%s"' % x.replace('\\\\', '\\')) \
            for x in re.findall(r'\\"path\\":\\"(.+?)\\",\\"', html)]
        z = zip(isdirs, paths)
        if not infos:
            infos = [{
                'isdir': x,
                'path': y,
                'remotepath': remotepath if remotepath[-1] != '/' else remotepath[:-1]
            } for x, y in z]

        return infos

    def save_share(self, url, remotepath, infos=None):
        infos = self._get_share_infos(url, remotepath, infos)
        for info in infos:
            print s % (1, 97, '  ++ transfer:'), info['path']
            result = self._share_transfer(info)
            if result == ENoError:
                pass
            elif result == 12:
                print s % (1, 91, '  |-- file had existed.')
                sys.exit()
            elif result == -33:
                if info['isdir']:
                    print s % (1, 93, '  |-- over transferring limit.')
                    infos += self._get_share_list(info)
                else:
                    print s % (1, 91, '  !! Error: can\'t transfer file')
            else:
                print s % (1, 91, '  !! Error at save_share, errno:'), result
                sys.exit(1)

    @staticmethod
    def _secret_or_not(url):
        ss.headers['Referer'] = 'http://pan.baidu.com'
        r = ss.get(url)
        if 'init' in r.url:
            if not args.secret:
                secret = raw_input(s % (2, 92, "  请输入提取密码: "))
            else:
                secret = args.secret
            data = 'pwd=%s' % secret
            url = "%s&t=%d" % (r.url.replace('init', 'verify'), int(time.time()))
            r = ss.post(url, data=data)
            if r.json()['errno']:
                print s % (2, 91, "  !! 提取密码错误\n")
                sys.exit(1)

    #######################################################################
    # for saveing inbox shares

    def _share_inbox_transfer(self, info, burl):
        meta = self._meta([info['remotepath'].encode('utf8')])
        if not meta:
            self._make_dir(info['remotepath'].encode('utf8'))

        p = "channel=chunlei&" + "clienttype=0&" + "web=1&" + \
            "path=%s&" % urllib.quote_plus(info['remotepath'].encode('utf8')) + \
            "object_array=%s&" % urllib.quote_plus('["%s"]' % info['object_id'].encode('utf8')) + \
            "fsid_array=%s&" % urllib.quote_plus('[%s]' % info['fs_id']) + \
            "session_id=%s&" % self.session_id + \
            "founder_uk=%s&" % self.founder_uk + \
            "bdstoken=%s" % self._get_bdstoken()

        url = 'http://pan.baidu.com/inbox/object/transfer?' + p
        r = ss.get(url)
        j = r.json()
        if j['errno'] == 0:
            return ENoError
        else:
            return j['errno']

    def _get_share_inbox_list(self, info):
        p = {
            "channel": "chunlei",
            "clienttype": 0,
            "web": 1,
            "object_id": info['object_id'],
            "object_status": info['object_status'],
            "fs_id": info['fs_id'],
            "path": info['path'],
            "server_filename": info['server_filename'],
            "size": info['size'],
            "server_mtime": info['server_mtime'],
            "server_ctime": info['server_ctime'],
            "local_mtime": info['local_mtime'],
            "local_ctime": info['local_ctime'],
            "isdir": info['isdir'],
            "category": info['category'],
            "founder_uk": self.founder_uk,
            "session_id": self.session_id,
            "bdstoken": self._get_bdstoken(),
        }
        if info.get('ori_path'): p.update({"ori_path": info['ori_path']})
        if info.get('dir_ref'): p.update({"dir_ref": info['dir_ref']})
        if info.get('md5'): p.update({"md5": ""})
        if info.get('create_time'): p.update({"create_time": "1402299935"})
        if info.get('update_time'): p.update({"update_time": "1402299935"})
        if info.get('last_time'): p.update({"last_time": ""})

        url = 'http://pan.baidu.com/inbox/object/unpanfileinfo'
        r = ss.get(url, params=p)
        j = r.json()
        if j['errno'] != 0:
            print s % (1, 91, '  !! Error at _get_share_inbox_list')
            sys.exit(1)
        rpath = '/'.join([info['remotepath'], os.path.split(info['path'])[-1]])
        for x in xrange(len(j['list'])):
            j['list'][x]['remotepath'] = rpath
        return j['list']

    def _get_share_inbox_infos(self, url, remotepath, infos):
        r = ss.get(url)
        html = r.content

        self.founder_uk = re.search(r'FileUtils.founder_uk=(\d+)', html).group(1)
        self.session_id = re.search(r'FileUtils.session_id="(.+?)"', html).group(1)
        self.bdstoken = re.search(r'bdstoken="(.+?)"', html).group(1)

        p = {
            "session_id": self.session_id,
            "founder_uk": self.founder_uk,
            "channel": "chunlei",
            "clienttype": 0,
            "web": 1,
            "bdstoken": self._get_bdstoken(),
        }
        url = 'http://pan.baidu.com/inbox/object/unpanfileinfo'
        r = ss.get(url, params=p)
        j = r.json()
        if j['errno'] == 0:
            for x in xrange(len(j['list'])):
                rpath = '/'.join([remotepath, os.path.split(j['list'][x]['path'])[-1]])
                j['list'][x]['remotepath'] = rpath
            return j['list']
        else:
            print s % (1, 91, '  !! Error at _get_share_inbox_infos')
            sys.exit()

    def save_inbox_share(self, url, remotepath, infos=None):
        ss.headers['Referer'] = 'http://pan.baidu.com'
        remotepath = remotepath if remotepath[-1] != '/' else remotepath[:-1]
        infos = self._get_share_inbox_infos(url, remotepath, infos)
        for info in infos:
            print s % (1, 97, '  ++ transfer:'), info['path']
            result = self._share_inbox_transfer(info, url)
            if result == ENoError:
                pass
            elif result == 12:
                print s % (1, 91, '  |-- file had existed.')
                sys.exit()
            elif result == 1 or result == -33 or result == -10:
                if result == -10:
                    print s % (1, 91, '  |-- _share_inbox_transfer, errno:'), -10, s , \
                        s % (1, 91, 'category of pan is unsatisfied.')
                elif result == -33:
                    print s % (1, 91, '  |-- _share_inbox_transfer, errno:'), -33, s , \
                    s % (1, 93, '  |-- over transferring limit.')
                if info['isdir']:
                    infos += self._get_share_inbox_list(info)
                #else:
                    #print s % (1, 91, '  |-- Error: can\'t transfer file')
            else:
                print s % (1, 91, '  |-- _share_inbox_transfer, errno:'), result
                sys.exit(1)

    #######################################################################
    # for finding files

    def _search(self, keyword, directory):
        p = {
            "channel": "chunlei",
            "clienttype": 0,
            "web": 1,
            "dir": directory if directory else "",
            "key": keyword,
            #"timeStamp": "0.15937364846467972",
            #"bdstoken": self._get_bdstoken(),
        }
        if args.recursive: p['recursion'] = 1
        url = 'http://pan.baidu.com/api/search'
        r = ss.get(url, params=p)
        j = r.json()
        if j['errno'] == 0:
            return j['list']
        else:
            print s % (1, 91, '  !! Error at _search'), j
            sys.exit(1)

    def _highlight_string_zones(self, string, highlights, highlight_color, background_color=None):
        # string is unicoded
        target = ['.' for i in xrange(len(string))]
        for hl in highlights:
            re_tp = hl['text'] if hl['is_regex'] else re.escape(hl['text'])
            for m in re.finditer(re_tp, string, re.I):
                for i in xrange(m.start(), m.end()):
                    target[i] = ' '

        highlight_zones = []
        for m in re.finditer('\s+', ''.join(target)):
            highlight_zones.append(m.start())
            highlight_zones.append(m.end())

        string_zones = []
        for i in xrange(len(highlight_zones)):
            if i == 0:
                string_zones.append(string[:highlight_zones[i]])
                string_zones.append(string[highlight_zones[i]:highlight_zones[i+1]])
            else:
                try:
                    string_zones.append(string[highlight_zones[i]:highlight_zones[i+1]])
                except:
                    string_zones.append(string[highlight_zones[i]:])

        if not string_zones: string_zones = [string]

        t = ''
        for i in xrange(0, len(string_zones), 2):
            if background_color:
                try:
                    t += s % (2, background_color, string_zones[i].encode('utf8')) + s % (2, highlight_color, string_zones[i+1].encode('utf8'))
                except:
                    t += s % (2, background_color, string_zones[i].encode('utf8'))
            else:
                try:
                    t += string_zones[i].encode('utf8') + s % (2, highlight_color, string_zones[i+1].encode('utf8'))
                except:
                    t += string_zones[i].encode('utf8')

        return t

    def _find_display(self, info):
        if args.type_ == 'f':
            if info['isdir']:
                return
        elif args.type_ == 'd':
            if not info['isdir']:
                return
        else:
            pass

        if args.ls_color == 'on':
            isdir = s % (1, 93, 'd') if info['isdir'] else s % (1, 97, '-')
            size = s % (1, 91, sizeof_fmt(info['size']).rjust(8))
            base_dir, filename = os.path.split(info['path'])
            base_dir = s % (2, 95, base_dir.encode('utf8')) if base_dir != '/' else '/'

            if info['isdir']:
                filename = self._highlight_string_zones(filename, self.highlights, 93, background_color=94)
            else:
                filename = self._highlight_string_zones(filename, self.highlights, 93)

            path = os.path.join(base_dir, filename)

        elif args.ls_color == 'off':
            isdir = 'd' if info['isdir'] else '-'
            size = sizeof_fmt(info['size']).rjust(8)
            path = info['path'].encode('utf8')

        if args.view and info.get('md5'):
            smd5 = info['md5'].encode('utf8')
            template = '%s %s %s %s %s' % (isdir, size, info['size'], smd5, path)
        else:
            template = '%s %s %s' % (isdir, size, path)

        print template

    def find(self, keywords, **arguments):
        def do():
            infos = []
            for keyword in keywords:
                infos += self._search(keyword, arguments.get('directory'))
                kw = keyword.decode('utf8', 'ignore')
                self.highlights.append({'text': kw, 'is_regex': 0})
            infos = {i['fs_id']: i for i in infos}.values()
            infos = self._sift(infos, name=arguments.get('name'), \
                size=arguments.get('size'), time=arguments.get('time'), \
                desc=arguments.get('desc'))
            if not arguments.get('pipe'):
                for info in infos:
                    self._find_display(info)

            # pipe to download, play, rnre, remove, move
            def warn(comd, display=True):
                if display:
                    for info in infos:
                        self._find_display(info)
                print s % (1, 93, '  find above ↑')
                ipt = raw_input(s % (1, 91, '  sure you want to %s all the files [y/n]: ' % comd)).lower() if not args.yes else 'y'
                if ipt != 'y':
                    print s % (1, 92, '  ++ aborted.')
                    sys.exit()

            pipe = arguments.get('pipe')
            if pipe:
                comd = pipe[0]
                if comd == 'd' or comd == 'download':
                    warn('download', display=True)
                    paths = [i['path'].encode('utf8') for i in infos]
                    self.download(paths)
                elif comd == 'p' or comd == 'play':
                    warn('move', display=True)
                    paths = [i['path'].encode('utf8') for i in infos]
                    self._download_do = self._play_do
                    self.download(paths)
                elif comd == 'rnr' or comd == 'rnre':
                    if len(pipe) < 3:
                        print s % (1, 91, '  !! rnre foo bar')
                        sys.exit(1)

                    foo = pipe[1]
                    bar = pipe[2]
                    self._rnre_do(foo, bar, infos)
                elif comd == 'rm':
                    warn('remove', display=True)
                    paths = [i['path'].encode('utf8') for i in infos]
                    self.remove(paths)
                elif comd == 'mv':
                    if len(pipe) < 2:
                        print s % (1, 91, '  !! mv /path/to')
                        sys.exit(1)

                    warn('move', display=True)
                    paths = [i['path'].encode('utf8') for i in infos]
                    remotepath = pipe[1]
                    self.move(paths, remotepath)
                else:
                    print s % (1, 91, '  !! command is supported by download, play, rnre, rm, mv')

        if 'all' in args.type_.split(','):
            for user in self.accounts:
                cookie = self.accounts[user]['cookies']
                ss.cookies.clear()
                ss.cookies.update(cookie)

                if args.ls_color:
                    print '\n' + s % (1, 92, user) + ':' if self.accounts[user]['on'] else '\n' + s % (1, 97, user) + ':'
                else:
                    print '\n' + user + ':'

                do()
        else:
            do()

    ##############################################################
    # for ls

    def _ls_display(self, infos, dir_=None):
        if dir_:
            print dir_ + ':'
            for info in infos:
                self._find_display(info)
            print ''
        else:
            self._find_display(infos)

    def _ls_directory(self, order, desc, path):
        directorys = [path.decode('utf8', 'ignore')]
        y = 1
        sum_size = 0
        for dir_ in directorys:
            infos = self._get_file_list(order, desc, dir_.encode('utf8'), 10000)['list']
            tinfos = infos
            if args.heads or args.tails or args.includes or args.excludes or args.type_:
                tinfos = self._sift(infos)
            if args.type_ != 'du':
                self._ls_display(tinfos, dir_)
            else:
                sum_size += sum([i['size'] for i in tinfos])
            if args.recursive:
                subdirs = [i['path'] for i in infos if i['isdir']]
                directorys[y:y] = subdirs
                y += 1

        if args.type_ == 'du': print 'd', s % (1, 91, sizeof_fmt(sum_size)), sum_size, directorys[0]

    def ls(self, order, desc, paths):
        for path in paths:
            meta = self._meta([path])
            if meta:
                if meta['info'][0]['isdir']:
                    self._ls_directory(order, desc, path)
                else:
                    if args.type_ == 'du': args.view = True
                    self._ls_display(meta['info'][0])
            else:
                print s % (1, 91, '  !! path is not existed.\n'), \
                    ' --------------\n ', path

    ###############################################################
    # for file operate

    def _exist(self, list_):
        meta = self._meta(list_)
        if not meta:
            print s % (1, 91, '  !! Error at _exist, some paths are not existed.')
            sys.exit(1)

    def _filemanager(self, opera, data):
        p = {
            "channel": "chunlei",
            "clienttype": 0,
            "web": 1,
            "opera": opera,
            "bdstoken": self._get_bdstoken(),
        }
        url = 'http://pan.baidu.com/api/filemanager'
        r = ss.post(url, params=p, data=data)
        j = r.json()
        if j['errno'] == 0:
            print s % (1, 92, '  ++ success.')
        elif j['errno'] == 12:
            print s % (1, 91, '  !! Error at filemanager:'), "部分文件已存在于目标文件夹中"
        else:
            print s % (1, 91, '  !! Error at filemanager')

    def move(self, paths, remotepath):
        self._exist(paths)

        meta = self._meta([remotepath])
        if not meta:
            self._make_dir(remotepath)
        elif not meta['info'][0]['isdir']:
            print s % (1, 91, '  !! Error at move:'), remotepath, s % (1, 91, 'is a file.')
            sys.exit(1)

        t = [{
                'path': i,
                'dest': remotepath,
                'newname': os.path.basename(i)
        } for i in paths]
        data = 'filelist=' + urllib.quote_plus(json.dumps(t))
        self._filemanager('move', data)

    def copy(self, paths, remotepath):
        self._exist(paths)

        t = None
        if len(paths) != 1:
            meta = self._meta([remotepath])
            if not meta:
                self._make_dir(remotepath)
            elif not meta['info'][0]['isdir']:
                print s % (1, 91, '  !! Error at move:'), remotepath, s % (1, 91, 'is a file.')
                sys.exit(1)

            t = [{
                    'path': i,
                    'dest': remotepath,
                    'newname': os.path.basename(i)
            } for i in paths]
        else:
            meta = self._meta([remotepath])
            if not meta:
                base_dir = os.path.split(remotepath)[0]
                meta = self._meta([base_dir])
                if not meta:
                    self._make_dir(base_dir)
                elif not meta['info'][0]['isdir']:
                    print s % (1, 91, '  !! Error at move:'), remotepath, s % (1, 91, 'is a file.')
                    sys.exit(1)
                t = [{
                        'path': i,
                        'dest':base_dir,
                        'newname': os.path.basename(remotepath)
                } for i in paths]
            elif not meta['info'][0]['isdir']:
                print s % (1, 91, '  !! Error at move:'), remotepath, s % (1, 91, 'is a file.')
                sys.exit(1)
            else:
                t = [{
                        'path': i,
                        'dest': remotepath,
                        'newname': os.path.basename(i)
                } for i in paths]

        data = 'filelist=' + urllib.quote_plus(json.dumps(t))
        self._filemanager('copy', data)

    def remove(self, paths):
        self._exist(paths)

        data = 'filelist=' + urllib.quote_plus(json.dumps(paths))
        self._filemanager('delete', data)

    def rename(self, path, remotepath):
        self._exist([path])

        meta = self._meta([remotepath])
        if meta:
            print s % (1, 91, '  !! Error at rename:'), remotepath, s % (1, 91, 'is existed.')
            sys.exit(1)

        base_dir = os.path.split(remotepath)[0]
        meta = self._meta([base_dir])
        if not meta:
            self._make_dir(base_dir)
        elif not meta['info'][0]['isdir']:
            print s % (1, 91, '  !! Error at rename:'), base_dir, s % (1, 91, 'is a file.')
            sys.exit(1)

        t = [{
                'path': path,
                'dest': base_dir,
                'newname': os.path.basename(remotepath)
        }]
        data = 'filelist=' + urllib.quote_plus(json.dumps(t))
        self._filemanager('move', data)

    ##############################################################
    # for file operate with regex

    def _rnre_do(self, foo, bar, infos):
        self.highlights.append({'text': foo.decode('utf8', 'ignore'), 'is_regex': 1})
        ls, lshl = [], []
        for info in infos:
            # no change directory if recursion
            if args.recursive and info['isdir']: continue

            base_dir, old_filename = os.path.split(info['path'])
            new_filename = re.sub(foo.decode('utf8', 'ignore'), bar.decode('utf8', 'ignore'), old_filename)
            if old_filename == new_filename: continue

            old_path = info['path']
            new_path = os.path.join(base_dir, new_filename).encode('utf8')

            ls.append((old_path.encode('utf8'), new_path))

            # hightlight
            if info['isdir']:
                old_filename_highlight = self._highlight_string_zones(old_filename, self.highlights, 93, background_color=94)
            else:
                old_filename_highlight = self._highlight_string_zones(old_filename, self.highlights, 93)
            old_path_highlight = os.path.join(base_dir.encode('utf8'), old_filename_highlight)
            lshl.append((old_path_highlight, new_path))

        if not ls: return

        print '\n'.join([' '.join([o, s % (1, 92, '==>'), n]) for o, n in lshl])
        print s % (1, 93, '  matched above ↑')

        ipt = raw_input(s % (1, 91, '  sure you want to rename all the files [y/N]: ')).lower() if not args.yes else 'y'
        if ipt == 'y':
            for o, n in ls:
                print s % (1, 97, '  ++ rename:'), ' '.join([o, s % (1, 92, ' ==> '), n])
                self.rename(o, n)
        else:
            print s % (1, 92, '  ++ aborted.')

    def _rmcre_do(self, type, infos, todir=None):
        if 'd' in args.type_:
            infos = [i for i in infos if i['isdir']]
        if 'f' in args.type_:
            infos = [i for i in infos if not i['isdir']]

        if not infos: return

        pathshl = []
        for i in infos:
            base_dir, filename = os.path.split(i['path'])
            if i['isdir']:
                filename_highlight = self._highlight_string_zones(filename, self.highlights, 93, background_color=94)
            else:
                filename_highlight = self._highlight_string_zones(filename, self.highlights, 93)
            path = os.path.join(base_dir.encode('utf8'), filename_highlight)
            pathshl.append(path)
        print '\n'.join(pathshl)
        print s % (1, 93, '  matched above ↑')

        ipt = raw_input(s % (1, 91, '  sure you want to %s all the files [y/N]: ' % type)).lower() if not args.yes else 'y'
        if ipt == 'y':
            paths = [i['path'].encode('utf8') for i in infos]
            if type == 'remove':
                self.remove(paths)
            if type == 'move':
                self.move(paths, todir)
            elif type == 'copy':
                self.copy(paths, todir)
        else:
            print s % (1, 92, '  ++ aborted.')

    def filemanager_re(self, type, dirs, todir=None, foo=None, bar=None):
        tinfos = []
        for path in dirs:
            meta = self._meta([path])
            if meta:
                if meta['info'][0]['isdir']:
                    directorys = [path.decode('utf8', 'ignore')]
                    y = 1
                    for dir_ in directorys:
                        infos = self._get_file_list('name', None, dir_.encode('utf8'), 10000)['list']
                        tinfos += infos
                        if args.recursive:
                            subdirs = [i['path'] for i in infos if i['isdir']]
                            directorys[y:y] = subdirs
                            y += 1
                else:
                    print s % (1, 91, '  !! path is a file.\n'), \
                        ' --------------\n ', path
            else:
                print s % (1, 91, '  !! path is not existed.\n'), \
                    ' --------------\n ', path

        tinfos = self._sift(tinfos)
        if tinfos:
            if type == 'rename':
                self._rnre_do(foo, bar, tinfos)
            else:
                self._rmcre_do(type, tinfos, todir=todir)

    ##############################################################
    # for add_task

    def _get_torrent_info(self, path):
        p = {
            "bdstoken": self._get_bdstoken(),
            "channel": "chunlei",
            "clienttype": 0,
            "web": 1,
            "app_id": 250528,
            "method": "query_sinfo",
            "source_path": path,
            "type": 2,
            "t": int(time.time()*1000),
        }

        url = 'http://pan.baidu.com/rest/2.0/services/cloud_dl'
        r = ss.post(url, params=p)
        j = r.json()
        if j.get('error_code'):
            print s % (1, 91, '  !! Error at _get_torrent_info:'), j['error_msg']
            return None, None
        else:
            return j['torrent_info']['file_info'], j['torrent_info']['sha1']

    def _get_magnet_info(self, url):
        p = {
            "bdstoken": self._get_bdstoken(),
            "channel": "chunlei",
            "clienttype": 0,
            "web": 1,
            "app_id": 250528,
        }
        data = {
            "method": "query_magnetinfo",
            "app_id": 250528,
            "source_url": url,
            "save_path": "/",
            "type": 4,
        }
        url = 'http://pan.baidu.com/rest/2.0/services/cloud_dl'
        r = ss.post(url, params=p, data=data)
        j = r.json()
        if j.get('error_code'):
            print s % (1, 91, '  !! Error at _get_magnet_info:'), j['error_msg']
            return None, None
        else:
            return j['magnet_info'], ''

    def _get_selected_idx(self, infos):
        types = args.type_.split(',')
        if not args.type_: return []
        if 'a' in types: return []

        idx = []
        if 'm' in types:
            for i in xrange(len(infos)):
                idx.append(i+1) if os.path.splitext(infos[i]['file_name'])[-1].lower() in mediatype else None
        if 'i' in types:
            for i in xrange(len(infos)):
                idx.append(i+1) if os.path.splitext(infos[i]['file_name'])[-1].lower() in imagetype else None
        if 'd' in types:
            for i in xrange(len(infos)):
                idx.append(i+1) if os.path.splitext(infos[i]['file_name'])[-1].lower() in doctype else None
        if 'p' in types:
            for i in xrange(len(infos)):
                idx.append(i+1) if os.path.splitext(infos[i]['file_name'])[-1].lower() in archivetype else None
        idx = list(set(idx))
        idx.sort()
        idx = [str(i) for i in idx]
        if not idx: return None
        return idx

    def _add_bt(self, url, remotepath):
        if url.startswith('magnet:'):
            bt_info, ssh1 = self._get_magnet_info(url)
            if not bt_info:
                return

        if url.startswith('/'):
            bt_info, ssh1 = self._get_torrent_info(url)
            if not bt_info:
                return

        selected_idx = self._get_selected_idx(bt_info)
        if selected_idx == None:
            print s % (1, 93, '  !! _get_selected_idx: match nothing.'), url
            return

        p = {
            "bdstoken": self._get_bdstoken(),
            "channel": "chunlei",
            "clienttype": 0,
            "web": 1,
            "app_id": 250528,
        }
        data = {
            "method": "add_task",
            "app_id": 250528,
            "file_sha1": ssh1,
            "save_path": remotepath,
            "selected_idx": ",".join(selected_idx),
            "task_from": 1,
            "t": str(int(time.time())*1000),
        }
        if url.startswith('magnet:'):
            data['source_url'] = url
            data['type'] = 4
        elif url.startswith('/'):
            data['source_path'] = url
            data['type'] = 2

        apiurl = 'http://pan.baidu.com/rest/2.0/services/cloud_dl'
        while True:
            r = ss.post(apiurl, params=p, data=data)
            j = r.json()
            if j.get('error_code') == -19:
                if data.get('vcode'):
                    print s % (2, 91, '  × 错误验证码')
                vcode = j['vcode']
                input_code = panbaiducom_HOME.save_img(j['img'], 'jpg')
                data.update({'input': input_code, 'vcode': vcode})
            elif j.get('error_code') != -19 and j.get('error_code'):
                print s % (1, 91, '  !! Error at _add_bt:'), j['error_msg']
                return
            else:
                print ''
                self.job([str(j['task_id'])])
                if args.view:
                    for i in selected_idx:
                        size = sizeof_fmt(int(bt_info[int(i) - 1]['size'])).rjust(7)
                        filepath = os.path.join(remotepath, bt_info[int(i) - 1]['file_name'])
                        print s % (1, 91, size), filepath
                return

    def _add_task(self, url, remotepath):
        p = {
            "bdstoken": self._get_bdstoken(),
            "channel": "chunlei",
            "clienttype": 0,
            "web": 1,
            "app_id": 250528,
        }
        data = {
            "method": "add_task",
            "app_id": 250528,
            "save_path": remotepath,
            "source_url": url,
            "type": 3,
        }
        apiurl = 'http://pan.baidu.com/rest/2.0/services/cloud_dl'
        while True:
            r = ss.post(apiurl, params=p, data=data)
            j = r.json()
            if j.get('error_code') == -19:
                if data.get('vcode'):
                    print s % (2, 91, '  × 错误验证码')
                vcode = j['vcode']
                input_code = panbaiducom_HOME.save_img(j['img'], 'jpg')
                data.update({'input': input_code, 'vcode': vcode})
            elif j.get('error_code'):
                print s % (1, 91, '  !! Error at _add_task:'), j['error_msg']
                return
            else:
                print ''
                self.job([str(j['task_id'])])
                return

    def add_tasks(self, urls, remotepath):
        for url in urls:
            if url.startswith('magnet:') or url.startswith('/'):
                if url.startswith('/'):
                    meta = self._meta([url])
                    if not meta:
                        print s % (1, 91, '  !! file is not existed.\n'), \
                            ' --------------\n ', url
                        continue
                    elif meta['info'][0]['isdir']:
                        print s % (1, 91, '  !! file is a directory.\n'), \
                            ' --------------\n ', url
                        continue
                    remotepath = os.path.split(url)[0]
                self._add_bt(url, remotepath)
            elif url.startswith('http'):
                self._add_task(url, remotepath)
            elif url.startswith('ftp:'):
                self._add_task(url, remotepath)
            elif url.startswith('ed2k:'):
                self._add_task(url, remotepath)
            else:
                print s % (1, 91, '  !! url is wrong:'), url

    ############################################################
    # for job, jobclear, jobdump, jobclearall

    jobstatus = {
        "0": "下载成功",
        "1": "下载进行中",
        "2": "系统错误",
        "3": "资源不存在",
        "4": "下载超时",
        "5": "资源存在但下载失败",
        "6": "存储空间不足",
        "7": "目标地址数据已存在",
        "8": "任务取消.",
    }

    def _task_display(self, infos):
        template = '%s %s\n' \
                   '%s %s\n' \
                   '%s %s\n' \
                   '%s %s\n' \
                   '%s %s\n' \
                   '%s %s\n' \
                   '------------------------------\n' \
                   % (s % (2, 97, '     id:'), s % (1, 97, "%s"), \
                      s % (1, 97, ' status:'), s % (2, "%s", "%s"), \
                      s % (1, 97, '   done:'), s % (3, 93, "%s"), \
                      s % (2, 97, '   name:'), "%s", \
                      s % (2, 97, '   path:'), "%s", \
                      s % (2, 97, ' source:'), "%s")

        for i in infos:
            if i['result'] == 0:
                status_color = 92 if i['status'] == '0' else 91
                print template % (
                        i['id'].encode('utf8'),
                        status_color, self.jobstatus[i['status'].encode('utf8')],
                        i['done'],
                        i['name'].encode('utf8'),
                        i['path'].encode('utf8'),
                        i['source'].encode('utf8'),
                    )
            else:
                print '%s %s\n' \
                      '%s %s\n' \
                      '------------------------------\n' \
                      % (s % (2, 97, '     id:'), s % (1, 97, i['id'].encode('utf8', 'ignore')), \
                         #s % (2, 91, '  Error:'), s % (2, 97, '要查询的task_id不存在'))
                         s % (2, 91, '  Error, info:'), i)

    def _query_task(self, jobids):
        p = {
            "bdstoken": self._get_bdstoken(),
            "web": 1,
            "app_id": 250528,
            "clienttype": 0,
            "channel": "chunlei",
            "method": "query_task",
            "task_ids": ",".join(jobids),
            "op_type": 1,
            "t": str(int(time.time()*1000)),
        }

        url = 'http://pan.baidu.com/rest/2.0/services/cloud_dl'
        r = ss.get(url, params=p)
        j = r.json()
        if j.get('errno'):
            print s % (1, 91, '  !! Error at _query_task:'), j
            sys.exit(1)

        infos = []
        for i in jobids:
            info = {}
            info['id'] = i
            if j['task_info'][i]['result'] == 0:
                info['source'] = j['task_info'][i]['source_url']
                info['name'] = j['task_info'][i]['task_name']
                info['path'] = j['task_info'][i]['save_path']
                info['status'] = j['task_info'][i]['status']
                info['result'] = j['task_info'][i]['result']

                file_size = int(j['task_info'][i]['file_size'])
                finished_size = int(j['task_info'][i]['finished_size'])
                done = finished_size - file_size
                done = '100.0%   ' + '%s/%s' % (sizeof_fmt(finished_size), sizeof_fmt(file_size)) \
                    if done == 0 and finished_size \
                    else '%.2f' % (finished_size / (file_size + 0.001) * 100) + '%   ' + \
                        '%s/%s' % (sizeof_fmt(finished_size), sizeof_fmt(file_size))
                info['done'] = done

                infos.append(info)
            else:
                info['result'] = j['task_info'][i]['result']
                infos.append(info)

        return infos

    def _list_task(self):
        p = {
            "bdstoken": self._get_bdstoken(),
            "web": 1,
            "app_id": 250528,
            "clienttype": 0,
            "channel": "chunlei",
            "method": "list_task",
            "need_task_info": 0,
            "status": 255,
            "start": 0,
            "limit": 1000,
            "t": int(time.time()*1000),
        }

        url = 'http://pan.baidu.com/rest/2.0/services/cloud_dl'
        r = ss.get(url, params=p)
        j = r.json()
        if j.get('errno'):
            print s % (1, 91, '  !! Error at _query_task:'), j
            sys.exit(1)

        jobids = [i['task_id'].encode('utf8') for i in j['task_info']]
        return jobids

    def job(self, jobids):
        if jobids:
            infos = self._query_task(jobids)
            self._task_display(infos)
        else:
            jobids = self._list_task()
            if not jobids:
                print s % (1, 97, '  nothing')
            else:
                infos = self._query_task(jobids)
                self._task_display(infos)

    def jobdump(self):
        p = {
            "bdstoken": self._get_bdstoken(),
            "web": 1,
            "app_id": 250528,
            "clienttype": 0,
            "channel": "chunlei",
            "method": "clear_task",
            "t": int(time.time()*1000),
        }

        url = 'http://pan.baidu.com/rest/2.0/services/cloud_dl'
        ss.get(url, params=p)
        #r = ss.get(url, params=p)
        #j = r.json()
        #if j.get('total'):
            #print s % (1, 92, '  ++ success.'), 'total:', j['total']
        #else:
            #print s % (1, 92, '  ++ no task.')

    def jobclear(self, jobid):
        p = {
            "bdstoken": self._get_bdstoken(),
            "web": 1,
            "app_id": 250528,
            "clienttype": 0,
            "channel": "chunlei",
            "method": "cancel_task",
            "task_id": jobid,
            "t": int(time.time()*1000),
        }

        url = 'http://pan.baidu.com/rest/2.0/services/cloud_dl'
        r = ss.get(url, params=p)
        j = r.json()
        if j.get('error_code'):
            print s % (1, 91, '  !! Error:'), j['error_msg'], 'id: %s' % jobid

    def jobclearall(self):
        self.jobdump()
        jobids = self._list_task()
        if jobids:
            for jobid in jobids:
                self.jobclear(jobid)

    ############################################################
    # for mkdir

    def mkdir(self, paths):
        for path in paths:
            print s % (1, 97, '  ++ mkdir:'), path
            meta = self._meta([path])
            if not meta:
                result = self._make_dir(path)
                if result == ENoError:
                    print s % (1, 92, '  ++ success.')
            else:
                print s % (1, 91, '  !! Error: file exists.'), path

class panbaiducom(object):
    def get_params(self, path):
        r = ss.get(path)
        pattern = re.compile('server_filename="(.+?)";disk.util.ViewShareUtils.bdstoken="(\w+)";'
                             'disk.util.ViewShareUtils.fsId="(\d+)".+?FileUtils.share_uk="(\d+)";'
                             'FileUtils.share_id="(\d+)";.+?FileUtils.share_timestamp="(\d+)";'
                             'FileUtils.share_sign="(\w+)";')
        p = re.search(pattern, r.text)

        self.params = {
            "bdstoken": p.group(2),
            "uk": p.group(4),
            "shareid": p.group(5),
            "timestamp": p.group(6),
            "sign": p.group(7),
            "channel": "chunlei",
            "clienttype": 0,
            "web": 1,
            "channel": "chunlei",
            "clienttype": 0,
            "web": 1
        }

        self.infos.update({
            'name': p.group(1).encode('utf8'),
            'file': os.path.join(os.getcwd(), p.group(1)).encode('utf8'),
            'dir_': os.getcwd(),
            'fs_id': p.group(3).encode('utf8')
            })

    def get_infos(self):
        url = 'http://pan.baidu.com/share/download'
        data = 'fid_list=["%s"]' % self.infos['fs_id']

        while True:
            r = ss.post(url, data=data, params=self.params)
            j = r.json()
            if not j['errno']:
                self.infos['dlink'] = j['dlink'].encode('utf8')
                if args.play:
                    panbaiducom_HOME._play_do(self.infos)
                else:
                    panbaiducom_HOME._download_do(self.infos)
                break
            else:
                vcode = j['vcode']
                input_code = panbaiducom_HOME.save_img(j['img'], 'jpg')
                self.params.update({'input': input_code, 'vcode': vcode})

    def get_infos2(self, path):
        while True:
            r = ss.get(path)
            j = r.content.replace('\\', '')
            name = re.search(r'server_filename":"(.+?)"', j).group(1)
            dlink = re.search(r'dlink":"(.+?)"', j)
            if dlink:
                self.infos = {
                    'name': name,
                    'file': os.path.join(os.getcwd(), name),
                    'dir_': os.getcwd(),
                    'dlink': dlink.group(1)
                }
                if args.play:
                    panbaiducom_HOME._play_do(self.infos)
                else:
                    panbaiducom_HOME._download_do(self.infos)
                break
            else:
                print s % (1, '  !! Error at get_infos2, can\'t get dlink')

    def do(self, paths):
        for path in paths:
            self.infos = {}
            panbaiducom_HOME._secret_or_not(path)
            self.get_params(path)
            self.get_infos()

    def do2(self,paths):
        for path in paths:
            self.infos = {}
            self.get_infos2(path)

def sighandler(signum, frame):
    print s % (1, 91, "  !! Signal:"), signum
    if args.comd in ('u', 'upload'):
        px.save_upload_datas()
    #print s % (1, 91, "  !! Frame: %s" % frame)
    sys.exit(1)

def main(argv):
    signal.signal(signal.SIGBUS, sighandler)
    signal.signal(signal.SIGHUP, sighandler)
    # https://stackoverflow.com/questions/108183/how-to-prevent-sigpipes-or-handle-them-properly
    signal.signal(signal.SIGPIPE, signal.SIG_IGN)
    signal.signal(signal.SIGQUIT, sighandler)
    signal.signal(signal.SIGSYS, sighandler)

    signal.signal(signal.SIGABRT, sighandler)
    signal.signal(signal.SIGFPE, sighandler)
    signal.signal(signal.SIGILL, sighandler)
    signal.signal(signal.SIGINT, sighandler)
    signal.signal(signal.SIGSEGV, sighandler)
    signal.signal(signal.SIGTERM, sighandler)

    usage = "usage: https://github.com/PeterDing/iScript#pan.baidu.com.py"
    if len(argv) <= 1:
        print usage
        sys.exit()

    ######################################################
    # for argparse
    p = argparse.ArgumentParser(description='about pan.baidu.com.' \
        ' 用法见 https://github.com/PeterDing/iScript')
    p.add_argument('xxx', type=str, nargs='*', help='命令对象.')
    p.add_argument('-a', '--aria2c', action='store', default=None, \
        type=int, help='aria2c分段下载数量')
    p.add_argument('-p', '--play', action='store_true', help='play with mpv')
    p.add_argument('-v', '--view', action='store_true', help='view details')
    p.add_argument('-y', '--yes', action='store_true', help='yes')
    p.add_argument('-q', '--quiet', action='store_true', help='quiet for download and play')
    p.add_argument('-s', '--secret', action='store', default=None, help='提取密码')
    p.add_argument('-f', '--from_', action='store', \
        default=1, type=int, \
        help='从第几个开始下载，eg: -f 42')
    p.add_argument('-t', '--type_', action='store', \
        default='', type=str, \
        help='类型参数，eg: ls -t f (文件(f)、文件夹(d))')
    p.add_argument('-l', '--limit', action='store', \
        default=None, type=str, help='下载速度限制，eg: -l 100k')
    # for upload
    p.add_argument('-m', '--uploadmode', action='store', \
        default='c', type=str, choices=['o', 'c'], \
        help='上传模式: o --> 重传. c --> 续传 .')
    # for recurse, head, tail, include, exclude
    p.add_argument('-R', '--recursive', action='store_true', help='递归 ls')
    p.add_argument('-H', '--heads', nargs='*', default=[], \
        help='匹配开头list，不能是正则表达式, eg: -H Head1 Head2 ..')
    p.add_argument('-T', '--tails', nargs='*', default=[], \
        help='匹配结尾list，不能是正则表达式, eg: -T Tail1 Tail2 ..')
    p.add_argument('-I', '--includes', nargs='*', default=[], \
        help='不排除匹配list, 可以是正则表达式，eg: -I "*.mp3" "^[\d]+" ..')
    p.add_argument('-E', '--excludes', nargs='*', default=[], \
        help='排除匹配list, 可以是正则表达式，eg: -E "*.html" "*.temp" ..')
    p.add_argument('-c', '--ls_color', action='store', default='on', \
        choices=['on', 'off'], type=str, help='ls 颜色，默认是on')
    global args
    comd = argv[1]
    if comd == 'rnr' or comd == 'rnre':
        if len(argv[2:]) < 3:
            print s % (1, 91, "  !! 参数错误\n rnr foo bar /path/to")
            sys.exit(1)

        args = p.parse_args(argv[4:])
    else:
        args = p.parse_args(argv[2:])
    xxx = args.xxx
    args.comd = comd
    #######################################################

    if comd == 'login' or comd == 'g':
        if len(xxx) < 1:
            username = raw_input(s % (1, 97, '  username: '))
            password = getpass(s % (1, 97, '  password: '))
        elif len(xxx) == 1:
            username = xxx[0]
            password = getpass(s % (1, 97, '  password: '))
        elif len(xxx) == 2:
            username = xxx[0]
            password = xxx[1]
        else:
            print s % (1, 91, '  login\n  login username\n  login username password')

        x = panbaiducom_HOME()
        x.login(username, password)
        result = x.check_login()
        if result:
            x.save_cookies(username)
            print s % (1, 92, '  ++ login succeeds.')
        else:
            print s % (1, 91, '  login failes')

    elif comd == 'userdelete' or comd == 'ud' or \
        comd == 'userchange' or comd == 'uc' or \
        comd == 'user':
        accounts = panbaiducom_HOME._check_cookie_file()
        if accounts:
            cu = zip(range(len(accounts)), [u for u in accounts])
            for i, u in cu:
                print s % (1, 92, i+1) if accounts[u]['on'] else s % (1, 91, i+1), \
                    accounts[u]['capacity'], \
                    s % (2, 92, u) if accounts[u]['on'] else s % (2, 97, u)
            if comd == 'userdelete' or comd == 'ud': print s % (2, 97, 0), s % (2, 91, 'ALL')
            elif comd == 'user': sys.exit()

            ipts = raw_input('pick numbers: ' if comd == 'userdelete' or comd == 'ud' else 'pick a number: ')
            for ipt in ipts.split():
                if not ipt.isdigit(): sys.exit()
                u = cu[int(ipt) - 1][1] if int(ipt) else 'ALL'

                if comd == 'userdelete' or comd == 'ud':
                    if u != 'ALL':
                        if accounts[u]['on'] and len(accounts) > 1:
                            print s % (1, 91, '  !! %s is online. To delete the account, firstly changing another account' % u)
                            sys.exit()
                        del accounts[u]
                    else:
                        with open(cookie_file, 'w') as g:
                            pk.dump({}, g)
                        sys.exit()

                elif comd == 'userchange' or comd == 'uc':
                    for i in accounts:
                        if i != u:
                            accounts[i]['on'] = 0
                        else:
                            accounts[i]['on'] = 1

            with open(cookie_file, 'w') as g:
                pk.dump(accounts, g)

        else:
            print s % (1, 97, '  please login')
            sys.exit(1)

    elif comd == 'u' or comd == 'upload':
        if len(xxx) < 2:
            print s % (1, 91, '  !! 参数错误\n  upload localpath1 localpath2 .. remotepath\n' \
                '  u localpath1 localpath2 .. remotepath')
            sys.exit(1)
        global px
        px = panbaiducom_HOME()
        px.init()
        px.upload(xxx[:-1], xxx[-1])

    elif comd == 'd' or comd == 'download' \
        or comd == 'p' or comd == 'play':
        if len(xxx) < 1:
            print s % (1, 91, '  !! 参数错误\n download url1 url2 ..\n' \
                '  d url1 url2 ..')
            sys.exit(1)

        if comd == 'p' or comd == 'play': args.play = True

        paths  = xxx
        paths1 = []
        paths2 = []
        paths3 = []

        for path in paths:
            if path[0] == '/':
                paths1.append(path)
            elif '/disk/home' in path or 'path=' in path:
                paths1.append(path)
            elif 'baidu.com/pcloud/album/file' in path:
                paths2.append(path)
            elif 'yun.baidu.com' in path or 'pan.baidu.com' in path:
                path = path.replace('wap/link', 'share/link')
                paths3.append(path)
            else:
                print s % (2, 91, '  !!! url 地址不正确.'), path

        if paths1:
            x = panbaiducom_HOME()
            x.init()
            x.download(paths1)

        if paths2:
            x = panbaiducom()
            x.do2(paths2)

        if paths3:
            x = panbaiducom()
            x.do(paths3)

    elif comd == 's' or comd == 'save':
        if len(xxx) != 2:
            print s % (1, 91, '  !! 参数错误\n save url remotepath\n' \
                ' s url remotepath')
            sys.exit(1)
        x = panbaiducom_HOME()
        x.init()
        path = x._get_path(xxx[0])
        remotepath = xxx[1].decode('utf8', 'ignore')
        infos = []
        if path != '/':
            infos.append({'isdir': 1, 'path': path.decode('utf8', 'ignore'), \
            'remotepath': remotepath if remotepath[-1] != '/' else remotepath[:-1]})
        else:
            infos = None
        if '/inbox/' in xxx[0]:
            url = xxx[0]
            x.save_inbox_share(url, remotepath, infos=infos)
        else:
            url = re.search(r'(http://.+?.baidu.com/.+?)(#|$)', xxx[0]).group(1)
            x._secret_or_not(url)
            x.save_share(url, remotepath, infos=infos)

    elif comd == 'f' or comd == 'find' or comd == 'ff' \
        or comd == 'ft' or comd == 'ftt' \
        or comd == 'fs' or comd == 'fss' \
        or comd == 'fn' or comd == 'fnn':
        if len(xxx) < 1:
            print s % (1, 91, '  !! 参数错误\n find keyword1 keyword2 .. [directory]\n' \
                ' f keyword1 keyword2 .. [directory]')
            sys.exit(1)
        x = panbaiducom_HOME()
        x.init()

        iii = xxx.index('|') if '|' in xxx else -1
        fxxx = xxx[:iii] if iii != -1 else xxx
        pxxx = xxx[iii+1:] if iii != -1 else None
        directory = None
        if fxxx[-1][0] == '/':
            keywords = fxxx[:-1]
            directory = fxxx[-1]
        else:
            keywords = fxxx

        if comd == 'f' or comd == 'find':
            x.find(keywords, directory=directory, pipe=pxxx)
        elif comd == 'ff':
            x.find(keywords, directory=directory, pipe=pxxx)
        elif comd == 'ft':
            x.find(keywords, time='no_reverse', directory=directory, pipe=pxxx)
        elif comd == 'ftt':
            x.find(keywords, time='reverse', directory=directory, pipe=pxxx)
        elif comd == 'fs':
            x.find(keywords, ize='no_reverse', directory=directory, pipe=pxxx)
        elif comd == 'fss':
            x.find(keywords, size='reverse', directory=directory, pipe=pxxx)
        elif comd == 'fn':
            x.find(keywords, name='no_reverse', directory=directory, pipe=pxxx)
        elif comd == 'fnn':
            x.find(keywords, name='reverse', directory=directory, pipe=pxxx)

    elif comd == 'mv' or comd == 'move' \
        or comd == 'rm' or comd == 'remove' \
        or comd == 'cp' or comd == 'copy' \
        or comd == 'rn' or comd == 'rename' \
        or comd == 'l' or comd == 'll' \
        or comd == 'du' \
        or comd == 'ln' or comd == 'lnn'\
        or comd == 'ls' or comd == 'lss' \
        or comd == 'lt' or comd == 'ltt':
        if len(xxx) < 1:
            print s % (1, 91, '  !! 参数错误\n move path1 path2 .. /path/to/directory\n' \
                ' mv path1 path2 .. /path/to/directory\n' \
                ' remove path1 path2 ..\n' \
                ' rm path1 path2 ..\n' \
                ' rename path new_path\n' \
                ' rn path new_path\n' \
                ' rename path new_path\n' \
                ' cp path1 path2 /copy/to/directory\n' \
                ' cp path /copy/to/existed_directory/newname\n' \
                ' l path1 path2 ..\n' \
                ' ls path1 path2 ..\n')
            sys.exit(1)
        e = True if 'f' in ['f' for i in xxx if i[0] != '/'] else False
        if e:
            print s % (1, 91, '  !! path is incorrect.')
            sys.exit(1)
        x = panbaiducom_HOME()
        x.init()
        if comd == 'mv' or comd == 'move':
            x.move(xxx[:-1], xxx[-1])
        elif comd == 'rm' or comd == 'remove':
            x.remove(xxx)
        elif comd == 'cp' or comd == 'copy':
            x.copy(xxx[:-1], xxx[-1])
        elif comd == 'rn' or comd == 'rename':
            x.rename(xxx[0], xxx[1])
        elif comd == 'l' or comd == 'ln':
            x.ls('name', None, xxx)
        elif comd == 'du':
            args.type_ = 'du'
            x.ls('name', None, xxx)
        elif comd == 'll' or comd == 'lnn':
            x.ls('name', 1, xxx)
        elif comd == 'lt':
            x.ls('time', None, xxx)
        elif comd == 'ltt':
            x.ls('time', 1, xxx)
        elif comd == 'ls':
            x.ls('size', None, xxx)
        elif comd == 'lss':
            x.ls('size', 1, xxx)

    elif comd == 'rnr' or comd == 'rnre' or \
        comd == 'cpr' or comd == 'cpre' or \
        comd == 'rmr' or comd == 'rmre' or \
        comd == 'mvr' or comd == 'mvre':

        if comd == 'cpr' or comd == 'cpre' or \
            comd == 'rmr' or comd == 'rmre':
            if not (args.includes or args.excludes or args.heads or args.tails or args.type_):
                print s % (1, 91, '  !! missing -I or -E or -H or -T')
                sys.exit(1)

        if args.recursive and (not 'f' in args.type_ and not 'd' in args.type_):
            print s % (1, 91, '  !! you don\'t choose "-t f" or "-t d", it will delete all files and directorys matched.')
            ipt = raw_input(s % (1, 93, '  are your sure? [y/N] '))
            if ipt != 'y':
                print s % (1, 92, '  ++ aborted.')
                sys.exit()

        if comd == 'rnr' or comd == 'rnre':
            foo = argv[2]
            bar = argv[3]
            dirs = xxx
            e = True if 'f' in ['f' for i in dirs if i[0] != '/'] else False
            if e:
                print s % (1, 91, '  !! path is incorrect.')
                sys.exit(1)

            x = panbaiducom_HOME()
            x.init()
            x.filemanager_re('rename', dirs, foo=foo, bar=bar)

        elif comd == 'rmr' or comd == 'rmre':
            if len(xxx) < 1:
                print s % (1, 91, '  !! 参数错误\n rmr dir1 dir2 .. -I regex1 -E regex2 -H head -T tail')
                sys.exit(1)

            dirs = xxx
            e = True if 'f' in ['f' for i in dirs if i[0] != '/'] else False
            if e:
                print s % (1, 91, '  !! path is incorrect.')
                sys.exit(1)

            x = panbaiducom_HOME()
            x.init()
            x.filemanager_re('remove', dirs)

        elif comd == 'mvr' or comd == 'mvre':
            if len(xxx) < 2:
                print s % (1, 91, '  !! 参数错误\n mvr dir1 dir2 .. /path/to/dir -I regex1 -E regex2 -H head -T tail')
                sys.exit(1)

            dirs = xxx
            e = True if 'f' in ['f' for i in dirs if i[0] != '/'] else False
            if e:
                print s % (1, 91, '  !! path is incorrect.')
                sys.exit(1)

            x = panbaiducom_HOME()
            x.init()
            x.filemanager_re('move', dirs[:-1], todir=dirs[-1])

        elif comd == 'cpr' or comd == 'cpre':
            if len(xxx) < 2:
                print s % (1, 91, '  !! 参数错误\n cpr dir1 dir2 .. /path/to/dir -I regex1 -E regex2 -H head -T tail')
                sys.exit(1)

            dirs = xxx
            e = True if 'f' in ['f' for i in dirs if i[0] != '/'] else False
            if e:
                print s % (1, 91, '  !! path is incorrect.')
                sys.exit(1)

            x = panbaiducom_HOME()
            x.init()
            x.filemanager_re('copy', dirs[:-1], todir=dirs[-1])

    elif comd == 'a' or comd == 'add':
        if len(xxx) < 1:
            print s % (1, 91, '  !! 参数错误\n add url1 url2 .. [directory]\n' \
                ' a url1 url2 .. [directory]\n' \
                ' a url1 url2 .. [directory] [-t {m,d,p,a}]')
            sys.exit(1)

        args.type_ = 'm' if not args.type_ else args.type_  # default args.type_

        if xxx[-1].startswith('/') and not xxx[0].startswith('/'):
            remotepath = xxx[-1] if xxx[-1][-1] == '/' else xxx[-1] + '/'
            urls = xxx[:-1]
        else:
            remotepath = '/'
            urls = xxx

        x = panbaiducom_HOME()
        x.init()
        x.add_tasks(urls, remotepath)

    elif comd == 'md' or comd == 'mkdir':
        if len(xxx) < 1:
            print s % (1, 91, '  !! 参数错误\n mkdir path1 path2 ..\n' \
                ' md path1 path2 ..')
            sys.exit(1)
        paths = xxx
        e =  True if 'f' in ['f' for i in xxx if i[0] != '/'] else False
        if e:
            print s % (1, 91, '  !! some path is wrong')
            sys.exit(1)
        x = panbaiducom_HOME()
        x.init()
        x.mkdir(paths)

    elif comd == 'j' or comd == 'job' \
        or comd == 'jd' or comd == 'jobdump' \
        or comd == 'jc' or comd == 'jobclear' \
        or comd == 'jca' or comd == 'jobclearall':
        if xxx:
            e =  True if 'f' in ['f' for i in xxx if not i.isdigit()] else False
            if e:
                print s % (1, 91, '  !! some job_ids are not number.')
                sys.exit(1)

        jobids = xxx if xxx else None
        x = panbaiducom_HOME()
        x.init()
        if comd == 'j' or comd == 'job':
            x.job(jobids)

        elif comd == 'jd' or comd == 'jobdump':
            x.jobdump()

        elif comd == 'jc' or comd == 'jobclear':
            if jobids:
                for jobid in jobids:
                    x.jobclear(jobid)
            else:
                print s % (1, 91, '  !! missing job_ids.')

        elif comd == 'jca' or comd == 'jobclearall':
            x.jobclearall()

    else:
        print s % (2, 91, '  !! 命令错误\n')

if __name__ == '__main__':
    argv = sys.argv
    main(argv)
