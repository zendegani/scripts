#!/bin/bash

path=`set | grep BASH_SOURCE | sed 's|.*\"\(.*\)/[^/]*\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
script=`set | grep BASH_SOURCE | sed 's|.*\".*/\([^/]*\)\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
options=$*; . $path/azfunctions.include;

OUTCAR=OUTCAR

Energy=`zgrep --text "energy  without entropy" $OUTCAR | head -$1 | tail -1 | awk '{print $7}'`
Volume=`zgrep --text "volume of cell :" $OUTCAR | head -$1 | tail -1 | awk '{print $5}'`
numatoms=`zgrep -a --text "number of ions     NIONS = " $OUTCAR | awk '{print $12}'`

Energy_atom=` echo "scale=8;$Energy/$numatoms"|bc `
Volume_atom=` echo "scale=8;$Volume/$numatoms"|bc `

echo "$1    $Energy_atom    $Volume_atom" 

