#!/usr/bin/env python
# coding: utf-8

import toml
import subprocess

def load_cargo_version():
    with open('./Cargo.toml',  'r') as f:
        cargo = f.read()

    t = toml.loads(cargo)

    ver = t.get('workspace', {}).get('package', t.get('package', {}))['version']

    return ver

def add_git_tag(ver):
    tag = f"v{ver}"
    try:
        subprocess.run(["git", "tag", tag], check=True)
        print(f"Successfully created git tag: {tag}")
    except subprocess.CalledProcessError as e:
        print(f"Error creating git tag: {e}")
        exit(1)

if __name__ == "__main__":
    ver = load_cargo_version()
    add_git_tag(ver)



