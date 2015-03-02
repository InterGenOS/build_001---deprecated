#!/bin/bash
### IGosChroot.sh - Drop into IGos Chroot Environment
### Written by Christopher 'InterGen' Cork <chris@intergenstudios.com>
### 3/2/2015

### Swap ownership of tools dir to root
chown -R root:root $IGos/tools


### Create working filesystem
mkdir -pv $IGos/{dev,proc,sys,run}
mknod -m 600 $IGos/dev/console c 5 1
mknod -m 666 $IGos/dev/null c 1 3
mount -v --bind /dev $IGos/dev
mount -vt devpts devpts $IGos/dev/pts -o gid=5,mode=620
mount -vt proc proc $IGos/proc
mount -vt sysfs sysfs $IGos/sys
mount -vt tmpfs tmpfs $IGos/run
if [ -h $IGos/dev/shm ]; then
  mkdir -pv $IGos/$(readlink $IGos/dev/shm)
fi

cat > /mnt/igos/root/.profile << "EOF"
./BuildInterGenOS.sh
EOF

### Enter Chroot 
chroot "$IGos" /tools/bin/env -i \
    HOME=/root                   \
    TERM="$TERM"                 \
    PS1='\u:\w\$ '               \
    PATH=/bin:/usr/bin:/sbin:/usr/sbin:/tools/bin \
    /tools/bin/bash --login +h
