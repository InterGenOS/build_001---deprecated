#!/bin/bash

#############################################################################################
##******!!!!        Make sure to set your '/dev/sdX' in the script below         !!!!******##
##******!!!! Also note that the user 'igos' is being given the pass 'intergenos' !!!!******##
#############################################################################################

mkdir -pv $IGos

mount -v -t ext4 /dev/sdX $IGos &&

mkdir -v $IGos/sources

chmod -v a+wt $IGos/sources

wget http://intergenstudios.com/Downloads/intergen_os_sources.tar.gz &&

tar xf intergen_os_sources.tar.gz &&

mv intergen_os_sources/* sources/ &&

rm -rf intergen_os_sources intergen_os_sources.tar.gz &&

mkdir -v $IGos/tools

ln -sv $IGos/tools /

groupadd igos

useradd -s /bin/bash -g igos -m -k /dev/null igos

echo "igos:intergenos" | chpasswd &&

chown -v igos $IGos/tools

chown -v igos $IGos/sources

wget http://intergenstudios.com/Downloads/SetEnv.sh -P $IGos

wget http://intergenstudios.com/Downloads/Build1stPass.sh -P $IGos

chown -v igos $IGos/SetEnv.sh

chown -v igos $IGos/Build1stPass.sh

function clearLine() {
        tput cuu 1 && tput el
}
echo " "
echo " "
echo "=========================================="
echo "|                                        |"
echo "|      Switching to shell for user       |"
echo "|                'igos'                  |"
echo "|             in 5 seconds               |"
echo "|                                        |"
echo "|     run 'SetEnv.sh' when the shell     |"
echo "|                starts                  |"
echo "|                                        |"
echo "=========================================="
echo " "
echo "In:     5"
sleep 1
clearLine
echo "In:    4"
sleep 1
clearLine
echo "In:   3"
sleep 1
clearLine
echo "In:  2"
sleep 1
clearLine
echo "In: 1"
sleep 1
clearLine
echo "Switching shells..."
sleep 3
clearLine
su - igos
