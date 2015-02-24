#********************************************************************************************************#
#*** Until the installer has been completed, the initial setup for the builds has to be done manually ***#
#*** The scripts provided make the core system build fairly automated, and scripts are being written  ***#
#*** to automate the extended packages as well.  Keep checking back for updated scripts.              ***#
#********************************************************************************************************#

#!/bin/bash
for lib in lib{gmp,mpfr,mpc}.la; do
  echo $lib: $(if find /usr/lib* -name $lib|
               grep -q $lib;then :;else echo not;fi) found
done
unset lib
