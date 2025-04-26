#!/usr/bin/env python3
# coding: utf-8

import os
import sys
import subprocess

def parse_host_user_repo(url) -> tuple[str, str, str]:
    """Parse a git@... or https://... URL into host, user, repo."""

    if url.startswith("git@"):
        # git@github.com:apache/parquet-format.git

        parts = url.split("@", 1)[1]
        host = parts.split(":", 1)[0]
        full_path = parts.split(":", 1)[1]
        if full_path.endswith(".git"):
            full_path = full_path[:-4]
        user, repo = full_path.split("/", 1)

    elif url.startswith("https://"):
        # https://github.com/apache/parquet-format.git

        stripped = url[len("https://"):]
        host = stripped.split("/", 1)[0]
        full_path = stripped.split("/", 1)[1]
        if full_path.endswith(".git"):
            full_path = full_path[:-4]
        user, repo = full_path.split("/", 1)

    else:
        raise ValueError("URL must start with git@ or https://")

    return host, user, repo


def main():
    base = "~/xp/vcs"
    real_base = os.path.expanduser(base)

    if len(sys.argv) < 2:
        print("Usage: gclone <url> [http]")
        sys.exit(1)

    url = sys.argv[1]
    mode = sys.argv[2] if len(sys.argv) >= 3 else "http"

    if mode not in ("http", "git", "print_path"):
        raise ValueError("Mode must be 'http' or 'git'")

    host, user, repo = parse_host_user_repo(url)
    dest = os.path.join(host, user, repo)

    if mode == "print_path":
        print(f"{real_base}/{dest}")
        return

    print(f"Parsed host={host}, user={user}, repo={repo}")

    print(f"URL: {url}, mode: {mode}")

    os.chdir(real_base)
    print(f"Switched working dir to `{base}`")

    print(f"Destination directory: {dest}")


    if mode == "http":
        clone_url = f"https://{host}/{user}/{repo}.git"
    else:
        clone_url = f"git@{host}:{user}/{repo}.git"

    print(f"Cloning {clone_url} into {dest}")
    subprocess.check_call(["git", "clone", clone_url, dest])
    print(f"Successfully cloned into {base}/{dest}")

    # Create a symlink in the current directory pointing to the cloned repo
    link_name = os.path.basename(dest)
    try:
        os.symlink(dest, link_name)
        print(f"Symbolic link {base}/{link_name} -> {base}/{dest} created")
    except Exception as e:
        print("Failed to create symbolic link:", e)


if __name__ == "__main__":
    main()
