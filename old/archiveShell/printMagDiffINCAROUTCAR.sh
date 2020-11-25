#!/bin/sh

ax=${1:-'z'}
printMAG2.sh $ax
echo
echo "Spins along $ax axis ..."
printMAG2.sh $ax | tail -1 > tmpOUT
printMagINCAR.py > tmpINC
#cat tmpOUT tmpINC

awk 'FNR==NR{var1=$1;next}{var2=$1}{
print var1 "  INCAR"
print var2 "  OUTCAR"
for (i=1; i<=length; i++) {
if (substr(var1, i, 1) == substr(var2, i, 1)) printf "%c", "-"; else printf "%c", "*";
}
}
END {printf "\n"}' tmpINC tmpOUT

diff tmpOUT tmpINC > /dev/null 2>&1
if [ $? -eq 0 ] ; then  echo "Spins are in the same directions as initialised" ; fi
rm tmpOUT tmpINC
zgrep E_p OSZICAR | tail -1

