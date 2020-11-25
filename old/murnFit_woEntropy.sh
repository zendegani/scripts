#!/bin/bash
#2018.06.29

hier=`pwd`
echo "$hier"
folder=`ls -1d [0-9]*`
echo $folder
## Creat output file 
file1=eV_Ang3_woS.dat
file2=Hartree_Bohr3_woS.dat
file3=eV_latUnivesal_woS.dat

[ -e $file1 ] && rm $file1
[ -e $file2 ] && rm $file2
[ -e $file3 ] && rm $file3

for i in $folder;do
cd $i
echo "$i"
## path to OUTCAR
##[[ ! -e "OUTCAR" && ! -e "OUTCAR.gz" ]] && echo couldnt find OUTCAR && exit -1
OUTCAR=OUTCAR
##[ ! -e "$OUTCAR" ] && echo "OUTCAR does not exist in `pwd`" && exit

Energy=`zgrep --text "energy  without entropy" $OUTCAR | tail -1 | awk '{print $4}'`
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
echo "$i" "$Energy_atom"  >> $file3

done

sxmurn -i $file2

