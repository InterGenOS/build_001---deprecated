#!/bin/bash
###  InterGenOS InitialSetup.sh - Put sources and variables in place to build the Temporary System
###  Written by Christopher 'InterGen' Cork <chris@intergenstudios.com>
###  2/19/2015

#############################################################################################
##****!!!!  Please note that the user 'igos' is being given the pass 'intergenos'  !!!!****##
#############################################################################################

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

mkdir -v $IGos/sources

chmod -v a+wt $IGos/sources

wget http://intergenstudios.com/Downloads/intergen_os_sources.tar.gz &&

tar xf intergen_os_sources.tar.gz &&

mv intergen_os_sources/* $IGos/sources/ &&

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

chmod +x $IGos/SetEnv.sh

chmod +x $IGos/Build1stPass.sh

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