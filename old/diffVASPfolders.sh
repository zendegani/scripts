#!/bin/bash
#Garch ver 2017.08.08

path=`set | grep BASH_SOURCE | sed 's|.*\"\(.*\)/[^/]*\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
script=`set | grep BASH_SOURCE | sed 's|.*\".*/\([^/]*\)\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
options=$*; . $path/azfunctions.include;


echoblue "BEGIN"
echogreen "Diff INCAR"
diff $1/INCAR $2/INCAR

echogreen "Diff KPOINTS"
diff $1/KPOINTS $2/KPOINTS

echogreen "Diff POSCAR"
diff $1/POSCAR $2/POSCAR

echogreen "Diff POTCAR"
zgrep -h .* $1/POTCAR* | head -10 > _pot_1
zgrep -h .* $2/POTCAR* | head -10 > _pot_2 
diff _pot_1 _pot_2
rm _pot_1 _pot_2

echoblue "END"
