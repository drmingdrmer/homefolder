#!/bin/sh

# -q quiet
# -t alloc terminal
ssh -qt root@112.126.91.24 'ps aux | sort -nk3 | tail'

ssh root@MachineB 'bash -s' < local_script.sh
ssh root@MachineB 'bash -s' <<< 'ps aux | sort -nk3 | tail'
