#!/bin/sh

# > vagrant ssh-config
# Host default
#   HostName 127.0.0.1
#   User vagrant
#   Port 2322
#   UserKnownHostsFile /dev/null
#   StrictHostKeyChecking no
#   PasswordAuthentication no
#   IdentityFile "/Users/drdrxp/xp/va/centos7/.vagrant/machines/default/virtualbox/private_key"
#   IdentitiesOnly yes
#   LogLevel FATAL
port=$(vagrant ssh-config  | grep Port | { read a b; echo $b; })

# forward port 80 through ssh
ssh -p $port -gNfL 80:localhost:80 vagrant@127.0.0.1 -i ./.vagrant/machines/default/virtualbox/private_key
