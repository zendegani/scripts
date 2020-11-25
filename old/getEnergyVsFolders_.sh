#!/bin/bash

path=`set | grep BASH_SOURCE | sed 's|.*\"\(.*\)/[^/]*\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
script=`set | grep BASH_SOURCE | sed 's|.*\".*/\([^/]*\)\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
options=$*; . $path/azfunctions.include;

hier=`pwd`
echo "$hier"
## Name your folder
folder=`ls -1d _*`
echo $folder
## Creat output file 
file1=Folder_eV.dat

OUTCAR=OUTCAR

echo "#Folder   eV_atom     A3_atom "  > $file1

for i in $folder;do
 cd $i
 echo "$i"
## path to OUTCAR
##[[ ! -e "OUTCAR" && ! -e "OUTCAR.gz" ]] && echo couldnt find OUTCAR && exit -1
##[ ! -e "$OUTCAR" ] && echo "OUTCAR does not exist in `pwd`" && exit

 Energy=`zgrep --text "energy  without entropy" $OUTCAR | tail -1 | awk '{print $7}'`
 Volume=`zgrep --text "volume of cell :" $OUTCAR | tail -1 | awk '{print $5}'`
 numatoms=`zgrep -a --text "number of ions     NIONS = " $OUTCAR | awk '{print $12}'`

 Energy_atom=` echo "scale=8;$Energy/$numatoms"|bc `
 Volume_atom=` echo "scale=8;$Volume/$numatoms"|bc `

 cd $hier

 echo "$i    $Energy_atom    $Volume_atom" >> $file1
done

