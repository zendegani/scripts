#!/bin/sh


pfad=`XXXCAR_link-to-basename.sh $0 $1`
[ ! -e "$pfad" ] && echo "XXCAR error: $pfad" && exit

number_atoms=`OUTCAR_number_of_atoms.sh $pfad` #   filename`
einmehr=` expr $number_atoms + 1 `
n=` expr $number_atoms + 2 `

cell=`OUTCAR_cell-last-cartesian-ARRAY.sh OUTCAR`


seq=`seq 10 100 1000`
i=0
for step in $seq;do
		
	i=` expr $i + 1 `
	echo step:$step atoms:$number_atoms
	start=`echo "$step $number_atoms" | awk '{print $1*$2-$2+1}'`
	stop=`echo "$step $number_atoms" | awk '{print $1*$2}'`
	echo start:$start
	echo stop: $stop
	rm -f OUTCAR$step
	rm -f OUTCAR$i
	echo " POSITION                                       TOTAL-FORCE (eV/Angst)" > OUTCAR$step
	echo " -----------------------------------------------------------------------------------" >> OUTCAR$step
	sed -n $start,$stop\p POSITIONs >> OUTCAR$step
	
	rm -f POSCAR$step
	rm -f POSCAR$i
	echo 22 > POSCAR$step
	echo 1 >> POSCAR$step
	echo "$cell" >> POSCAR$step
	echo $number_atoms >> POSCAR$step
	echo Cart >> POSCAR$step
	
	sed -n $start,$stop\p POSITIONs | awk '{print $1,$2,$3}' >> POSCAR$step
	mv OUTCAR$step OUTCAR$i
	mv POSCAR$step POSCAR$i
	i=` expr $i + 1 `
		
	done
