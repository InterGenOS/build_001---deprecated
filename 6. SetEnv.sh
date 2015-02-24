#!/bin/bash

#################################################
## Setting Environment Variables for the build ##
#################################################

##########################################################
## The .bash_profile will pull in our .bashrc variables ##
##########################################################

cat > ~/.bash_profile << "EOF"
exec env -i HOME=$HOME TERM=$TERM PS1='\u:\w\$ ' /bin/bash
EOF

######################################################
## Need to make sure these get set for the duration ##
## of building the temporary system                 ##
######################################################

cat > ~/.bashrc << "EOF"
set +h
umask 022
IGos=/mnt/igos
LC_ALL=POSIX
IGos_TGT=$(uname -m)-igos-linux-gnu
PATH=/tools/bin:/bin:/usr/bin
export IGos LC_ALL IGos_TGT PATH
EOF

##################################
## Basic line-clearing function ##
## Because Shuttlesworth swears ##
## "Pretty is a feature         ##
##################################

function clearLine() {
        tput cuu 1 && tput el
}

##################################
## Pass some simple commands on ##
## to the builder. Will remove  ##
## these when I figure out how  ##
## to pass variables on to a    ##
## new shell.                   ##
##################################

echo " "
echo " "
echo "=========================================="
echo "|                                        |"
echo "|        Now setting .bashrc and         |"
echo "|         .bash_profile for user         |"
echo "|                 'igos'                 |"
echo "|                                        |"
echo "|     Please run './Build1stPass.sh'     |"
echo "|             when prompted              |"
echo "|                                        |"
echo "=========================================="
echo " "
sleep 2
echo "Loading .bashrc"
sleep 2
echo "Loading .bash_profile"
sleep 3
echo "Preparing to source .bash_profile"
sleep 2
clearLine
echo "Sourcing .bash_profile now"
sleep 1
clearLine
echo ".bash_profile sourced"
sleep 1
clearLine
echo "Please run './Build1stPass.sh'"
echo " "
echo " "
sleep 1
source ~/.bash_profile
