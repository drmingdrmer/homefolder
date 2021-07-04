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
                elts = url.split('/')
                if len(elts) == 2:
                    elts = [self.default_host]  + elts

                url = '/'.join(elts)

                self.groups[cate][url] = True
                self.by_url[url] = True

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
            urls = list(self.groups[k].keys())
            rst[k] = sorted(urls)


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


