#!/bin/bash

path=`set | grep BASH_SOURCE | sed 's|.*\"\(.*\)/[^/]*\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
script=`set | grep BASH_SOURCE | sed 's|.*\".*/\([^/]*\)\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
options=$*; . $path/azfunctions.include;

hier=`pwd`
echo "$hier"
## Name your folder
folder=`ls -1d [0-9]* | sort -n`
echo $folder

arr=($folder)
#arr=(`echo ${folder}`);
m=-1
for x in ${arr[@]}; do if [ ${#x} -gt $m ];    then       m=${#x};    fi; done
mn=5
[ $m -gt 5 ] && mn=`echo $m|bc`
header="#%${mn}s  %-11s %-9s %-9s %-9s\n"
format=" %${mn}s %11.8f %10.3e %7.2e %9.6f\n"


## Creat output file 
file1=Folder_eV.dat
[ -e $file1 ] && rm $file1

OUTCAR=OUTCAR

printf "$header" Folder   eV_atom       E_p_atom   LAMBDA  A3_atom  > $file1

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

 OSZICAR=`ls -1d OSZICAR*`
 Ep_total_exp=`getE_pLast $OSZICAR`
# Ep_total=`echo ${Ep_total_exp} | sed -e 's/[eE]+*/\\*10\\^/'`
 Ep_total=`echo ${Ep_total_exp} | sed -e 's/[eE]+*/\*10\^/'`
 Ep_atom=`echo  "scale=15;$Ep_total/$numatoms"|bc `
 lambda=`zgrep -i "LAMBDA.*=" $OSZICAR | tail -n1 | awk '{print $NF}'`

 cd $hier

# echo "$i    $Energy_atom    $Ep_atom   $Volume_atom" >> $file1
 printf "$format" $i    $Energy_atom    $Ep_atom  $lambda   $Volume_atom >> $file1

done

