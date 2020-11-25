#!/bin/bash
#2017-01-27

hier=`pwd`
echo "$hier"

## Name your folder
folder=`ls -1d [0-9]*`

## Creat output file 
file1=Mag_Bohr3.dat
file2=Mag_Angs3.dat

echo "#Volume_Bohr  TOT_mag  mag_of_every_atom" > $file1
echo "#Volume_atom  TOT_mag  mag_of_every_atom" > $file2

for i in $folder;do
    cd $i
    echo "$i"
    ## path to OUTCAR
    ##[[ ! -e "OUTCAR" && ! -e "OUTCAR.gz" ]] && echo couldnt find OUTCAR && exit -1
    OUTCAR=OUTCAR.gz
    ##[ ! -e "$OUTCAR" ] && echo "OUTCAR does not exist in `pwd`" && exit

    Energy=`zgrep --text "energy  without entropy" $OUTCAR | tail -1 | awk '{print $7}'`
    Volume=`zgrep --text "volume of cell :" $OUTCAR | tail -1 | awk '{print $5}'`
    numatoms=`zgrep -a --text "number of ions     NIONS = " $OUTCAR | awk '{print $12}'`
    Energy_atom=` echo "scale=8;$Energy/$numatoms"|bc `
    Volume_atom=` echo "scale=8;$Volume/$numatoms"|bc `
    Volume_Bohr=` echo "scale=8;6.74833304162*$Volume_atom"|bc `
    Energy_Hartree=` echo "scale=8;0.036749309*$Energy_atom"|bc `

    n=`echo $numatoms+5 | bc`
    magnetTOT=`zgrep -A $n 'magnetization (x)' $OUTCAR | tail -1 | awk '{print $5}'`

    magString=""
    for x in `seq 1 $numatoms`; do
        m=`echo $x+3 | bc`
        magCurrentAtom=`zgrep -A $m 'magnetization (x)' $OUTCAR | tail -1 | awk '{print $5}'`
        magString="$magString  $magCurrentAtom"
    done

    cd $hier

    echo "$Volume_Bohr  $magnetTOT  $magString" >> $file1
    echo "$Volume_atom  $magnetTOT  $magString" >> $file2

done
