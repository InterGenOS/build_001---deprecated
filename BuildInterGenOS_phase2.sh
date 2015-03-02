#!/bin/bash
### BuildInterGenOS_phase2.sh - Continuing core InterGenOS build
### written by Christopher 'InterGen' Cork <chris@intergenstudios.com>
### 3/2/2015


### remove build directive from /etc/profile
sed -i '/.\/BuildInterGenOS_phase2.sh/d' /etc/profile

### set logfiles
touch /var/log/{btmp,lastlog,wtmp}
chgrp -v utmp /var/log/lastlog
chmod -v 664  /var/log/lastlog
chmod -v 600  /var/log/btmp


cd /sources


#######################
## Linux API Headers ##
#######################

tar xf linux-3.18.2.tar.xz &&
cd linux-3.18.2
make mrproper &&
make INSTALL_HDR_PATH=dest headers_install
find dest/include \( -name .install -o -name ..install.cmd \) -delete
cp -rv dest/include/* /usr/include
cd /sources
rm -rf linux-3.18.2


###############
## Man Pages ##
###############


tar xf man-pages-3.72.tar.xz
cd man-pages-3.72
make install &&
cd /sources
rm -rf man-pages-3.72


###############################
