#!/bin/bash

# following 3 lines must always be present
path=`set | grep BASH_SOURCE | sed 's|.*\"\(.*\)/[^/]*\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
script=`set | grep BASH_SOURCE | sed 's|.*\".*/\([^/]*\)\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
options=$*; . $path/azfunctions.include;

magDirec=${1:-'z'}
OUTCAR=OUTCAR
result=`printMagnetizationTable $magDirec`
echo  "$result"
echo
echo Spins along $magDirec axis ...
echo  "$result" | parseMagnetizationTable2
echo
