#!/bin/sh

# must be running in a vagrant dir. There should be a `Vagrantfile` file.

guest_port=$1
host_port=${2-$guest_port}


ssh_port=$(vagrant ssh-config  | grep Port | { read a b; echo $b; })
echo ssh_port=$ssh_port
echo guest_port=$guest_port
echo host_port=$host_port

sudo ssh -p $ssh_port -gNfL $guest_port:localhost:$host_port vagrant@127.0.0.1 -i ./.vagrant/machines/default/virtualbox/private_key
