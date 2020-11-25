#!/bin/bash
#2017.05.17

path=`set | grep BASH_SOURCE | sed 's|.*\"\(.*\)/[^/]*\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
script=`set | grep BASH_SOURCE | sed 's|.*\".*/\([^/]*\)\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
options=$*; . $path/azfunctions.include;

hier=`pwd`
echo "$hier"
folder=`ls -1d [0-9]*`
echo $folder
## Creat output file 
file1=eV_Ang3.dat
file2=Hartree_Bohr3.dat
file3=eV_latUnivesal.dat
file4=Hartree_Ep_Bohr3.dat

[ -e $file1 ] && rm $file1
[ -e $file2 ] && rm $file2
[ -e $file3 ] && rm $file3
[ -e $file4 ] && rm $file4

for i in $folder;do
    cd $i
    echo "$i"
    OUTCAR=OUTCAR

    Energy=`zgrep --text "energy  without entropy" $OUTCAR | tail -1 | awk '{print $7}'`
    Volume=`zgrep --text "volume of cell :" $OUTCAR | tail -1 | awk '{print $5}'`
    numatoms=`zgrep -a --text "number of ions     NIONS = " $OUTCAR | awk '{print $12}'`

    Energy_atom=` echo "scale=8;$Energy/$numatoms"|bc `
    Volume_atom=` echo "scale=8;$Volume/$numatoms"|bc `

    #Volume_tot=` echo "scale=5;$numatoms*$Volume_peratom"|bc ` 
    Volume_Bohr=` echo "scale=8;6.74833304162*$Volume_atom"|bc `
    Energy_Hartree=` echo "scale=8;0.036749309*$Energy_atom"|bc `

    OSZICAR=`ls -1d OSZICAR*`
    Ep_total_exp=`getE_pLast $OSZICAR`
    Ep_total=` echo ${Ep_total_exp} | sed -e 's/[eE]+*/\\*10\\^/'`
    Ep_atom=` echo  "scale=8;$Ep_total/$numatoms"|bc `
    Ep_atom_Hartree=` echo "scale=8;0.036749309*$Ep_atom"|bc `
    Energy_Hartree_Ep=` echo "scale=8;$Energy_Hartree+$Ep_atom_Hartree"|bc `
    cd $hier

    echo "$Volume_atom" "$Energy_atom"  >> $file1
    echo "$Volume_Bohr" "$Energy_Hartree" >> $file2
    echo "$i" "$Energy_atom"  >> $file3
    echo "$Volume_Bohr" "$Energy_Hartree_Ep" >> $file4


done

sxmurn -i $file4
mv murn.dat murn_Ep.dat

sxmurn -i $file2

