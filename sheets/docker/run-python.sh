#!/bin/sh

# run it
docker run -tid python:2.7.15 -name tt

# attach
docker exec -ti 2f734eaa4662 /bin/bash
