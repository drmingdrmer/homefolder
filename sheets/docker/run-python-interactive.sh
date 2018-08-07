#!/bin/sh

# run it
docker run -tid python:2.7.15 -name tt

# attach
docker exec -ti 2f734eaa4662 /bin/bash

# -t, --tty:         Allocate a pseudo-TTY
# -i, --interactive: Keep STDIN open even if not attached
# -d, --detach:      Run container in background and print container ID
