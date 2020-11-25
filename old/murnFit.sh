#!/bin/bash
#2020.02.28

hier=`pwd`
echo "$hier"
folder=`ls -1d [0-9]*`
echo $folder
## Creat output file 
file1=eV_Ang3.dat
file2=Hartree_Bohr3.dat
file3=eV_latUnivesal.dat
file4=raw_Hartree_Bohr3.dat

[ -e $file1 ] && rm $file1
[ -e $file2 ] && rm $file2
[ -e $file3 ] && rm $file3
[ -e $file4 ] && rm $file4

for i in $folder;do
	cd $i
	echo "$i"
	## path to OUTCAR
	if [[ ! -e "OUTCAR" && ! -e "OUTCAR.gz" ]]; then 
		echo couldnt find OUTCAR 
	else
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

		echo "$Volume_atom" "$Energy_atom"  >> ../$file1
		[[ -z "$Energy" ]] || echo "$Volume_Bohr" "$Energy_Hartree" >> ../$file2
		echo "$i" "$Energy_atom"  >> ../$file3
                echo "$Volume_Bohr" "$Energy_Hartree" >> ../$file4

	fi
	cd $hier
done

[ -e $file2 ] && sxmurn -i $file2

