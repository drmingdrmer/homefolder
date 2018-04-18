#!/bin/sh

ipcs

# ------ Message Queues --------
# key        msqid      owner      perms      used-bytes   messages

# ------ Shared Memory Segments --------
# key        shmid      owner      perms      bytes      nattch     status
# 0x00000000 0          root       600        219056     6          dest

# ------ Semaphore Arrays --------
# key        semid      owner      perms      nsems
# 0x00000000 65536      root       600        14

ipcs -s

# ------ Semaphore Arrays --------
# key        semid      owner      perms      nsems
# 0x00000000 65536      root       600        14


# remove:
ipcrm
