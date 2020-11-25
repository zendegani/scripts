#!/bin/bash

# following 3 lines must always be present
path=`set | grep BASH_SOURCE | sed 's|.*\"\(.*\)/[^/]*\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
script=`set | grep BASH_SOURCE | sed 's|.*\".*/\([^/]*\)\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
options=$*; . $path/azfunctions.include;

ax=${1:-'z'}
table=`printMagnetizationTable $ax OUTCAR`
echo "$table"
echo
echo "Spins along $ax axis ..."

echo "$table" | parseMagnetizationTable2 > tmpOUT
parseINCARmag INCAR > tmpINC
compareTwoStringCbyC tmpINC tmpOUT
diff tmpOUT tmpINC > /dev/null 2>&1
if [ $? -eq 0 ] ;
    then  echogreen "Spins are in the same directions as initialised" ;
    else  echored   "WARNING: Spins are flipped!"
fi
zgrep E_p OSZICAR | tail -1
rm tmpOUT tmpINC

