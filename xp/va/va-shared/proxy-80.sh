#!/bin/sh

sshport=$1

ssh -p $sshport -gNfL 80:localhost:80 vagrant@127.0.0.1 \
    -i ./.vagrant/machines/default/virtualbox/private_key
