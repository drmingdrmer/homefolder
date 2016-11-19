# dockerpull published their local repository,  so you can simply put their
# host in front of the repository this way:

docker pull daocloud.io/ubuntu:14.04

# And a more graceful way is to use registry mirror from daocloud, append below
# line to /etc/default/docker.io or /etc/default/docker

DOCKER_OPTS="$DOCKER_OPTS --registry-mirror=http://YOUR_ID.m.daocloud.io"


