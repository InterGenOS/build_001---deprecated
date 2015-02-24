#!/bin/bash

#############################################################################################
##****!!!!  Please note that the user 'igos' is being given the pass 'intergenos'  !!!!****##
#############################################################################################

echo "Welcome to InterGenOS Initial Setup."
echo " "
echo "Please enter the partition identifier where you'd like to build InterGenOS"
echo " "
read -p "We should set it up for you in /dev/: "
echo " "
read -p "Awesome, we'll set up the build for you in /dev/$REPLY, is that alright? [y/n] : " opt
        if [ $opt != y ]; then
                echo " "
                echo "Oh," 
                sleep 1
                echo "snap,"
                sleep 1
                echo "Well, then let's make sure we've got your build partition set right, ok?"
                echo " "
                read -p "You want it set up on /dev/: " REPLY2
                echo " "
                read -p "I think we've go it now- you want it set up in /dev/$REPLY2, right? [y/n] : " opt2
                        if [ $opt2 != y ]; then
                                echo " "
                                echo "Hmmm...Ok, you should double check your build partition info and then run the Initial Setup again."
                                sleep 1
                                echo " "
                                echo "We'll hang out right here 'till you get back.  :) "
                                sleep 1
                                echo " "
                                exit 0
                        else
                                echo "Thank you, the build will now proceed"
                        fi
        else
                echo "Thank you, the build will now proceed"
        fi
sleep 1
echo "You will be prompted for manual entries when needed."
sleep 1
echo "We appreciate your participation in the InterGenOS project."
echo " "
echo " "

mkdir -pv $IGos

if [ $opt = y ]; then
    mount -v -t ext4 /dev/$REPLY $IGos &&
else
    mount -v -t ext4 /dev/$REPLY2 $IGos &&
fi

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

chmod +x $IGos/SetEnv.sh

chmod +x $IGos/Build1stPass.sh

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
echo "|       Please do 'cd /mnt/igos'         |"
echo "|    and run './SetEnv.sh' when the      |"
echo "|             shell starts               |"
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
