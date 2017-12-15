#!/bin/sh

VBoxManage showvminfo $(cat .vagrant/machines/default/virtualbox/id) | less
