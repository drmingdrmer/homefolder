
### list tree

```
lsblk
NAME            MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda               8:0    0   40G  0 disk
├─sda1            8:1    0  500M  0 part /boot
└─sda2            8:2    0  9.3G  0 part
  ├─centos-root 253:0    0  8.3G  0 lvm  /
  └─centos-swap 253:1    0 1000M  0 lvm  [SWAP]
```

### lvdisplay

```
--- Logical volume ---
LV Path                /dev/centos/swap
LV Name                swap
VG Name                centos
LV UUID                9MaLfH-JceZ-38ob-rUdK-mdXH-B1A3-vw032K
LV Write Access        read/write
LV Creation host, time localhost, 2016-01-27 20:42:01 +0800
LV Status              available
# open                 2
LV Size                1000.00 MiB
Current LE             250
Segments               1
Allocation             inherit
Read ahead sectors     auto
- currently set to     8192
Block device           253:1

--- Logical volume ---
LV Path                /dev/centos/root
LV Name                root
VG Name                centos
LV UUID                VCc56G-pTp2-gGUm-10e6-u24w-wcDI-mebDim
LV Write Access        read/write
LV Creation host, time localhost, 2016-01-27 20:42:01 +0800
LV Status              available
# open                 1
LV Size                <8.26 GiB
Current LE             2114
Segments               1
Allocation             inherit
Read ahead sectors     auto
- currently set to     8192
Block device           253:0
```
