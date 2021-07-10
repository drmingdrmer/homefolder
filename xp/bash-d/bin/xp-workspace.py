#!/usr/bin/env python
# coding: utf-8

import argparse
import yaml
import os
from k3handy import *
import k3git
import k3jobq
import k3thread
import queue
import time
from rich.console import Console

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

        A trailing ``f`` indicate a favorite

            f github.com/user/repo
            f user/repo

        """
        itm = itm.strip()

        elts = itm.split()
        if len(elts) >= 2:
            fav, url = elts[:2]
        else:
            fav, url = '.', elts[0]

        elts = url.split('/')
        if len(elts) == 2:
            #  url without host: user/repo
            #  use default host
            elts = [self.default_host]  + elts

        url = '/'.join(elts)

        return url, fav

    def encode_item(self, obj):
        res = obj['url']

        if obj['fav'] is not None:
            res = obj['fav'] + " " + res
        else:
            res = ". " + res

        return res


    def import_repos(self):

        links, rlinks = self.find_links()

        base = 'github.com'
        users = os.listdir(base)
        for user in users:
            p = pjoin(base, user)
            repos = os.listdir(p)
            for repo in repos:
                path  = pjoin(base, user, repo)
                if not self.is_git_repo(path):
                    continue

                if path not in self.by_url:
                    fav = None
                    if path in rlinks:
                        fav = 'f'
                    self.groups['other'][path] = {
                            'url': path,
                            'fav': fav,
                    }
                else:
                    fav = None
                    if path in rlinks:
                        fav = 'f'
                    self.by_url[path]['fav'] = fav



    def find_links(self):
        favorites = {}
        rfavorites = {}

        base = "."
        links = os.listdir(base)
        for link in links:
            p = pjoin(base, link)
            if not os.path.islink(p):
                continue

            repo_path = os.readlink(p)
            if self.is_git_repo(repo_path):
                favorites[link] = repo_path
                rfavorites[repo_path] = link

        return favorites, rfavorites

    def is_git_repo(self, *path):
        return os.path.exists(pjoin(*path, '.git'))


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


    def clone(self):
        base = "."
        q = queue.Queue()

        def clone_repo(args):
            obj = args

            url = obj['url']
            flag = obj['fav']

            q.put(('start', url))

            path = pjoin(base, url)

            if not self.is_git_repo(path):
                sshurl = k3git.GitUrl.parse(url).fmt('ssh')
                res = cmdf('git', 'clone', sshurl, path, flag='')
                if res[0] != 0:
                    return (url, ) + res

            if 'f' in flag:
                repo = url.split('/')[-1]
                if not os.path.islink(pjoin(base, repo)):
                    os.symlink(url, repo, target_is_directory=True)

            return (url, 0, )

        results = []
        def collect(args):
            url = args[0]
            q.put(('stop', url))

        def st():
            tasks = {}
            console = Console()
            console.print()
            with console.status("") as status:
                while True:
                    itm = q.get()
                    act, url = itm
                    repo = url.split('/')[-1]
                    if act == 'start':
                        tasks[url] = True
                    else:
                        console.log('Done: ' + url)
                        del tasks[url]

                    t = sorted(list(tasks.keys()))
                    t = [x.split('/')[-1] for x in t]
                    t = ','.join(t)
                    t = 'cloning: ' + t
                    status.update(status=t)

        k3thread.daemon(st)

        k3jobq.run(self.by_url.values(), [
                (clone_repo, 8),
                collect,
        ])


if __name__ == "__main__":

    parser = argparse.ArgumentParser(
        description='Convert markdown to zhihu compatible')

    #  TODO cmd: init: initialize all repos
    parser.add_argument('cmd', type=str,
                        nargs=1,
                        choices=["import", "clone"],
                        help='')


    args = parser.parse_args()
    w = WorkSpace()
    if args.cmd[0] == 'import':
        w.import_repos()
        w.dump()
    elif args.cmd[0] == 'clone':
        w.clone()
    else:
        raise ValueError("unknown cmd:" + args.cmd[0])


