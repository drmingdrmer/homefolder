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
from rich.console import Console
from typing import Callable, Dict, List, Optional

class Repository:
    """
    Represents a git repository in the workspace.
    """
    def __init__(self, workspace: 'WorkSpace', fav: str, url: str):
        """
        Initialize a repository.
        
        Args:
            workspace: The WorkSpace instance this repository belongs to
            fav (str): Favorite indicator ("f" for favorite, "." for normal)
            url (str): Repository URL
        """
        self.workspace = workspace
        self.fav = fav
        self.url = url
        self.remotes: Dict[str, str] = {}
        
    def encode(self) -> List[str]:
        """
        Encode this Repository object into a list of strings.
        
        Returns:
            List[str]: List of strings representing the repository
        """
        res = [self.fav + " " + self.url]
        for k, v in self.remotes.items():
            res.append(k + " " + v)

        return res

class Log(object):
    def error(self, *msg):
        print(' '.join([str(x) for x in msg]))

class WorkSpace(object):
    def __init__(self):
        self.log = Log()

        self.conffn = 'repos.yml'
        self.by_url = {}

        cont = fread(self.conffn)

        self.conf = yaml.safe_load(cont)

        self.default_host = 'github.com'

        self.groups = {'other':{}}
        self.parse_conf()

    def output(self, *msg):
        print(' '.join([str(x) for x in msg]))


    def parse_conf(self):
        for cate, urls in self.conf.items():
            if cate not in self.groups:
                self.groups[cate] = {}

            for url in urls:
                o = self.parse_item(url)

                self.groups[cate][o.url] = o
                self.by_url[o.url] = o

    def parse_item(self, itms):
        """
        Parse an item:

            - github.com/user/repo
            - user/repo

        A trailing ``f`` indicate a favorite

            - f github.com/user/repo
            - . user/repo

        Nested list indicates multi remote:
            - - f github.com/user/repo
              - . boss/repo

        """

        if isinstance(itms, str):
            itms = [itms]

        fav, url = self.parse_item_line(itms[0])

        res = Repository(self, fav, url)

        for it in itms[1:]:
            upstream, url = self.parse_item_line(it)
            res.remotes[upstream] = url

        return res

    def parse_item_line(self, itm):
        """
        Simplest:
            github.com/user/repo

        With flag(f: favorite; .: nothing):
            f github.com/user/repo
            . user/repo
        """
        itm = itm.strip()

        elts = itm.split()
        if len(elts) >= 2:
            fav, url = elts[:2]
        else:
            fav, url = '.', elts[0]

        url = self.norm_url(url)
        return fav, url

    def norm_url(self, url: str) -> str:
        """
        Normalize a repository URL by ensuring it has a host component.
        
        If the URL only contains user/repo without a host, the default host
        is prepended to the URL.
        
        Args:
            url (str): The repository URL to normalize
            
        Returns:
            str: The normalized URL in the format host/user/repo
        """
        elts = url.split('/')
        if len(elts) == 2:
            #  url without host: user/repo
            #  use default host
            elts = [self.default_host]  + elts

        url = '/'.join(elts)
        return url


    def import_repos(self):

        links, rlinks = self.find_symbolic_links()

        base = 'github.com'
        users = os.listdir(base)
        for user in users:
            if user == '.DS_Store':
                # hidden meta file on mac
                continue

            p = pjoin(base, user)
            repos = os.listdir(p)
            for repo in repos:
                path  = pjoin(base, user, repo)
                if not self.is_git_repo(path):
                    continue

                fav = "."
                if path in rlinks:
                    fav = 'f'

                if path not in self.by_url:
                    self.groups['other'][path] = Repository(self, fav, path)
                    self.by_url[path] = self.groups['other'][path]
                else:
                    self.by_url[path].fav = fav



    def find_symbolic_links(self):
        favorites = {}
        rfavorites = {}

        base = "."
        links = os.listdir(base)
        for link in links:
            full_path = pjoin(base, link)
            if not os.path.islink(full_path):
                continue

            repo_path = os.readlink(full_path)
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
            urls = [g[x].encode() for x in urls]
            rst[k] = urls

        s = yaml.dump(rst)
        fwrite(self.conffn, head + "\n" + s)


    def clone(self):
        base = "."
        q = queue.Queue()

        def clone_repo(args):
            obj = args

            url = obj.url
            flag = obj.fav

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

            for upstream, rurl in obj.remotes.items():
                sshurl = k3git.GitUrl.parse(rurl).fmt('ssh')

                g = k3git.Git(k3git.GitOpt(), cwd=path)
                rem = g.remote_get(upstream)
                if rem is None:
                    res = cmdf('git', 'remote', 'add', upstream, sshurl, cwd=path)
                    if res[0] != 0:
                        return (rurl, ) + res
                else:
                    res = cmdf('git', 'remote', 'set-url', upstream, sshurl, cwd=path)
                    if res[0] != 0:
                        return (rurl, ) + res


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
                    if itm == 'done':
                        return

                    act, url = itm
                    repo = url.split('/')[-1]
                    if act == 'start':
                        tasks[url] = True
                    elif act == 'stop':
                        console.log('Done: ' + url)
                        del tasks[url]
                    else:
                        raise

                    t = sorted(list(tasks.keys()))
                    t = [x.split('/')[-1] for x in t]
                    t = ','.join(t)
                    t = 'cloning: ' + t
                    status.update(status=t)

        h = k3thread.daemon(st)

        k3jobq.run(self.by_url.values(), [
                (clone_repo, 8),
                collect,
        ])

        q.put("done")
        h.join()

    def for_each(self, func: Callable[[str, k3git.Git, dict], None], ctx: dict) -> None:
        """
        Execute a function for each git repository in the workspace.
        
        Args:
            func: A callable that takes three arguments:
                - path (str): The path to the git repository
                - g (k3git.Git): A Git object for the repository
                - ctx (dict): A context dictionary with additional parameters
            ctx (dict): A context dictionary passed to the function for each repository.
                        This is a user-defined dictionary that can contain any
                        data needed by the function. The content and structure are
                        determined by the caller and passed to each repository function.
        """
        base = "."

        for itm in self.by_url.values():
            
            url = itm.url

            path = pjoin(base, url)

            if not self.is_git_repo(path):
                self.log.error("not a git:", path)
                continue

            g = k3git.Git(k3git.GitOpt(), cwd=path)

            func(path, g, ctx)


    def subcmd_stat(self, path, g, ctx):

        head_branch = g.head_branch(flag='')
        if head_branch is None:
            self.output(path, "no branch is found for HEAD")
            return

        upstream = g.branch_default_upstream(head_branch)
        if upstream is None:
            self.output(path, "no upstream branch is found for", head_branch)
            return

        diver = g.branch_divergency(head_branch)

        self.output(path,
                    head_branch,
                    "+", len(diver[1]),
                    "->", upstream,
                    "+", len(diver[2])
        )

    def subcmd_merge_pr(self, path, g, ctx):

        pr_branch = ctx['pr']

        self.output("try to rebase to", path, pr_branch)

        # fetch to update
        g.cmdf("fetch", '--all', flag='xp')

        if not g.worktree_is_clean():
            self.output(path, "not clean")
            return

        b = g.head_branch(flag='x')
        remote = g.branch_default_remote(b, flag='x')
        upstream = g.branch_default_upstream(b, flag='x')

        b_rev = g.rev_of(b)
        u_rev = g.rev_of(upstream)

        if b_rev != u_rev:
            self.output(b, "and", upstream, "not same:", b_rev, u_rev)
            return

        pr_rev = g.rev_of(pr_branch)
        if pr_rev is None:
            self.output("no such branch:", pr_branch)
            return

        g.cmdf("rebase", pr_branch, flag='xp')
        g.cmdf("push", remote, b, flag='xp')


if __name__ == "__main__":

    parser = argparse.ArgumentParser(
        description='Convert markdown to zhihu compatible')

    #  TODO cmd: init: initialize all repos
    parser.add_argument('cmd', type=str,
                        nargs=1,
                        choices=["import", "clone", "stat", "merge"],
                        help='')

    parser.add_argument('args', type=str,
                        nargs='*',
                        help='')


    args = parser.parse_args()
    w = WorkSpace()
    if args.cmd[0] == 'import':
        w.import_repos()
        w.dump()
    elif args.cmd[0] == 'clone':
        w.clone()
    elif args.cmd[0] == 'stat':
        w.for_each(w.subcmd_stat, {})
    elif args.cmd[0] == 'merge':
        w.for_each(w.subcmd_merge_pr, {'pr':args.args[0]})
    else:
        raise ValueError("unknown cmd:" + args.cmd[0])


