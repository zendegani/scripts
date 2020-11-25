#!/bin/bash

hier=`pwd`
echo "$hier"
## Name your folder
folder=`ls -1d [0-9].*`
## Creat output file 
file1=e-v.dat
file2=E-V.dat
file3=E-a.dat

for i in $folder;do
cd $i
echo "$i"
## path to OUTCAR
##[[ ! -e "OUTCAR" && ! -e "OUTCAR.gz" ]] && echo couldnt find OUTCAR && exit -1
OUTCAR=OUTCAR
##[ ! -e "$OUTCAR" ] && echo "OUTCAR does not exist in `pwd`" && exit

Energy=`zgrep --text "energy  without entropy" $OUTCAR | tail -1 | awk '{print $7}'`
Volume=`zgrep --text "volume of cell :" $OUTCAR | tail -1 | awk '{print $5}'`
numatoms=`zgrep -a --text "number of ions     NIONS = " $OUTCAR | awk '{print $12}'`

Energy_atom=` echo "scale=8;$Energy/$numatoms"|bc `
Volume_atom=` echo "scale=8;$Volume/$numatoms"|bc `

#Volume_tot=` echo "scale=5;$numatoms*$Volume_peratom"|bc ` 
Volume_Bohr=` echo "scale=8;6.74833304162*$Volume_atom"|bc `
Energy_Hartree=` echo "scale=8;0.036749309*$Energy_atom"|bc `

cd $hier

echo "$Volume_atom" "$Energy_atom"  >> $file1
echo "$Volume_Bohr" "$Energy_Hartree" >> $file2
echo "$i" "$Energy"  >> $file3

done

sxmurn -i $file1

mv murn.dat murn-ev.dat

sxmurn -i $file2

