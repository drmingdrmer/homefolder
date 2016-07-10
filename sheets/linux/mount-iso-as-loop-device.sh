#!/bin/sh

losetup /dev/loop0 example.img
mount /dev/loop0 /home/you/dir

mount -o loop -t iso9660 file.iso /mnt/test
