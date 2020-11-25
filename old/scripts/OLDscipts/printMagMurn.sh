#!/bin/bash
# ver 2015-11-06

# following 3 lines must always be present
path=`set | grep BASH_SOURCE | sed 's|.*\"\(.*\)/[^/]*\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
script=`set | grep BASH_SOURCE | sed 's|.*\".*/\([^/]*\)\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
options=$*; . $path/azfunctions.include;

magDirec=${1:-'z'}
folders=`ls -1d [0-9].*`
OUTCAR=OUTCAR
here=`pwd`
c=0
for i in $folders;do
    let c++
    echo "############### $i ##################"
    cd $i
    result[$c]=`printMagnetizationTable $magDirec $OUTCAR`
#    echo "${result[$c]}"
    echo "${result[$c]}" | parseMagnetizationTable2 > tmpOUT
    parseINCARmag INCAR > tmpINC
    cd $here
done

echo
echo "Spins along $magDirec axis ..."

cd $here
c=0
for i in $folders;do
    let c++
    cd $i
    echo "############### $i ##################"
    compareTwoStringCbyC tmpINC tmpOUT
    diff tmpOUT tmpINC  > /dev/null 2>&1
    if [ $? -eq 0 ] ;
        then  echogreen "Spins are in the same directions as initialised" ;
        else  echored   "WARNING: Spins fliped!"
    fi
    zgrep E_p OSZICAR | tail -1
    rm tmpOUT tmpINC
    cd $here
done
