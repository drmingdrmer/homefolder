#!/usr/bin/env python
# coding: utf-8

import argparse
import yaml
import os
from k3handy import *

class WorkSpace(object):
    def __init__(self):
        self.conffn = 'repos.yml'
        self.by_url = {}

        cont = fread(self.conffn)

        self.conf = yaml.safe_load(cont)

        self.default_host = 'github.com'

        self.groups = {'other':{}}
        self.parse_conf()


    def parse_conf(self):
        for cate, urls in self.conf.items():
            if cate not in self.groups:
                self.groups[cate] = {}

            for url in urls:
                url, fav = self.parse_item(url)

                o = { "url": url, 
                      "fav": fav,
                }
                self.groups[cate][url] = o
                self.by_url[url] = o

    def parse_item(self, itm):
        """
        Parse an item:
            
            github.com/user/repo
            user/repo

        A trailing ``*`` indicate a favorite

            github.com/user/repo *
            user/repo *

        """
        elts = itm.split()
        if len(elts) >= 2:
            url, fav = elts[:2]
        else:
            url, fav = elts[0], None

        elts = url.split('/')
        if len(elts) == 2:
            #  url without host: user/repo
            #  use default host
            elts = [self.default_host]  + elts

        url = '/'.join(elts)

        return url, fav

    def encode_item(self, obj):
        if obj['fav'] is not None:
            return '{url} {fav}'.format(**obj)
        else:
            return url


    def import_repos(self):
        base = 'github.com'
        users = os.listdir(base)
        for user in users:
            p = pjoin(base, user)
            repos = os.listdir(p)
            for repo in repos:
                path  = pjoin(base, user, repo)
                if not os.path.exists(pjoin(path, '.git')):
                    continue

                if path not in self.by_url:
                    self.groups['other'][path] = True

    def dump(self):
        head = '#!/usr/bin/env xp-workspace.py'

        rst = {}
        ks = list(self.groups.keys())

        #  move 'other' to last
        ks = [x for x in ks if x!='other'] + ['other']
        for k in ks:
            g = self.groups[k]
            urls = list(g.keys())
            urls = sorted(urls)
            urls = [self.encode_item(g[x]) for x in urls]
            rst[k] = urls

        s = yaml.dump(rst)
        fwrite(self.conffn, head + "\n" + s)




if __name__ == "__main__":

    parser = argparse.ArgumentParser(
        description='Convert markdown to zhihu compatible')

    #  TODO cmd: init: initialize all repos
    parser.add_argument('cmd', type=str,
                        nargs=1,
                        choices=["import"],
                        help='')


    args = parser.parse_args()
    print(args.cmd)
    w = WorkSpace()
    if args.cmd[0] == 'import':
        w.import_repos()
        w.dump()


