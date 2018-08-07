#!/bin/sh

# one line start interactive shell
docker run \
    -v /root/.ssh:$HOME/.ssh \
    -v /root/pykit:/root/pykit \
    --name tt \
    -ti \
    python:2.7.15 \
    /bin/bash

# run it
docker run -name tt -tid python:2.7.15

# attach
docker exec -ti 2f734eaa4662 /bin/bash

# -t, --tty:         Allocate a pseudo-TTY
# -i, --interactive: Keep STDIN open even if not attached
# -d, --detach:      Run container in background and print container ID
