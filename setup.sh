#!/bin/bash
###  InterGenOS setup.sh - Put sources and variables in place to build the Temporary System
###  Written by Christopher 'InterGen' Cork <chris@intergenstudios.com>
###  2/19/2015

#############################################################################################
##****!!!!  Please note that the user 'igos' is being given the pass 'intergenos'  !!!!****##
#############################################################################################

### Make sure setup.sh is being run as user 'root'
if [[ $EUID -ne 0 ]]; then
   echo " "
   echo " "
   echo "WARNING ****************************************"
   echo " "
   echo "   setup.sh must be run as user 'root'. Exiting." 1>&2
   echo " "
   echo "WARNING ****************************************"
   echo " "
   echo " "
   exit 1
fi

### Color variables
red="$(echo -e "\033[0;31m")"
green="$(echo -e "\033[0;32m")"
lblue="$(echo -e "\033[1;34m")"
NC="$(echo -e "\033[0m")"

### Python heading
function print_heading {
python - <<END
### Python variables
import time
import sys
### Python functions
def delay_print(s):
    for c in s:
        sys.stdout.write( '%s' % c )
        sys.stdout.flush()
        time.sleep(0.003)
def delay_print2(s):
    for c in s:
        sys.stdout.write( '%s' % c )
        sys.stdout.flush()
        time.sleep(0.4)
print(" ")
print(" ")
delay_print('${lblue}*************************************************************${NC}')
print(" ")
delay_print("${lblue}|                                                           |${NC}")
print(" ")
delay_print("${lblue}|${NC}           ${green}Welcome to ${NC}Inter${lblue}Gen${NC}OS ${green}Initial Setup${NC}             ${lblue}|${NC}")
print(" ")
delay_print("${lblue}|                                                           |${NC}")
print(" ")
delay_print("${lblue}|${NC}                       ${green}Build${NC}_${green}001${NC}                           ${lblue}|${NC}")
print(" ")
delay_print("${lblue}|                                                           |${NC}")
print(" ")
delay_print("${lblue}*************************************************************${NC}")
print(" ")
END
}

clear

print_heading

echo " "
echo " "
echo " "
echo " "
echo " "
echo "${green}Please enter the ${NC}Partition ID ${green}where you'd like to build ${NC}Inter${lblue}Gen${NC}OS"
echo " "
read -p "${green}Set it up for you in /dev/${NC}?${green}:${NC} "
echo " "
echo "${green}Ok, target build ${NC}Partition ID ${green}is /dev/${NC}$REPLY"
echo " "
read -p "${green}Ready to begin${NC}? [y/n] ${green}:${NC} " opt

if [ $opt = y ]; then
    echo " "
    echo -e "${green}Thank you, the build will now proceed${NC}"
    sleep 1
    echo " "
    echo -e "${green}You will be prompted for manual entries when needed.${NC}"
    sleep 1
    echo " "
    echo -e "${green}We appreciate your participation in the InterGenOS project.${NC}"
    sleep 1
    echo " "
    echo " "
    mkdir -pv $IGos
    mount -v -t ext4 /dev/$REPLY $IGos
    echo "export IGosPart=/dev/$REPLY" >> ~/.bash_profile
else
    echo " "
    echo -e "${red}Oh,${NC}"
    sleep 1
    echo " "
    echo -e "${red}snap,${NC}"
    sleep 1
    echo " "
    echo -e "${green}Well, then let's make sure we've got your ${NC}Build Partition ID ${green}set right, ok?${NC}"
    echo " "
    read -p "${green}Which ${NC}Partition ID ${green}did you want it set up on- /dev/${NC}?${green}:${NC} " REPLY2
    echo " "
    echo " "
    echo -e "${green}Alright, target build ${NC}Partition ID ${green}is set to /dev/${NC}$REPLY2"
    echo " "
    read -p "${green}Ready to begin${NC}? [y/n] ${green}:${NC} " opt2
    if [ $opt2 = y ]; then
        echo " "
        echo -e "${green}Thank you, the build will now proceed${NC}"
        sleep 1
        echo " "
        echo -e "${green}You will be prompted for manual entries when needed.${NC}"
        sleep 1
        echo " "
        echo -e "${green}We appreciate your participation in the InterGenOS project.${NC}"
        sleep 1
        echo " "
        echo " "
        mkdir -pv $IGos
        mount -v -t ext4 /dev/$REPLY2 $IGos
        echo "export IGosPart=/dev/$REPLY2" >> ~/.bash_profile
    else
        echo " "
        echo -e "${red}Oh,${NC}"
        sleep 1
        echo " "
        echo -e "${red}snap,${NC}"
        sleep 1
        echo " "
        echo -e "${NC}Hmmm...${lblue}Ok, you should double check your ${NC}Build Partition ID ${lblue}and then run the ${NC}Initial Setup ${lblue}again.${NC}"
        sleep 1
        echo " "
        echo -e "${green}We'll hang out right here 'till you get back.  ${NC}:) "
        sleep 1
        echo " "
        exit 0
    fi
fi


### Create and set permissions on source directory

mkdir -v $IGos/sources

chmod -v a+wt $IGos/sources

### Get and unpack sources

wget http://intergenstudios.com/Downloads/InterGenOS/build001/Core/build001_Core_Sources.tar.gz &&

tar xf intergen_os_sources.tar.gz &&

mv intergen_os_sources/* $IGos/sources/ &&

rm -rf intergen_os_sources intergen_os_sources.tar.gz &&

### Create and link tools directory

mkdir -v $IGos/tools

ln -sv $IGos/tools /

### Create the 'igos' group and user

groupadd igos

useradd -s /bin/bash -g igos -m -k /dev/null igos

echo "igos:intergenos" | chpasswd &&

### Change ownership of tools and sources directories to user 'igos'

chown -v igos $IGos/tools

chown -v igos $IGos/sources

### Download Temp System build script, set ownership, and make it executable

wget https://raw.githubusercontent.com/InterGenOS/build_001/master/build_temp_sys.sh -P $IGos

chmod +x $IGos/build_temp_sys.sh

chown -v igos $IGos/build_temp_sys.sh

### Set .bash_profile and .bashrc for user 'igos'

cat > /home/igos/.bash_profile << "EOF"
exec env -i HOME=$HOME TERM=$TERM PS1='\u:\w\$ ' /bin/bash
EOF

cat > /home/igos/.bashrc << "EOF"
set +h
umask 022
IGos=/mnt/igos
LC_ALL=POSIX
IGos_TGT=$(uname -m)-igos-linux-gnu
PATH=/tools/bin:/bin:/usr/bin
export IGos LC_ALL IGos_TGT PATH
cd $IGos
./build_temp_sys.sh
EOF

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
echo "|    Preparing for build_temp_sys.sh     |"
echo "|                                        |"
echo "|         This may take awhile...        |"
echo "|                                        |"
echo "=========================================="
echo " "
function SleepTimer() {
	Count=5
	while [ $Count -gt 0 ]; do
	echo Starting in: $Count
	sleep 1
	clearLine
	let Count=Count-1
done
}
SleepTimer
clearLine
echo " "
echo " "
echo " "
echo "Reticulating Splines - Switching shells..."
sleep 2
clearLine
echo "Go grab yourself a stimulating beverage..."
sleep 1
echo "This will take a little while..."
echo " "
echo " "
echo " "
sleep 2
su - igos
