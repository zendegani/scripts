#!/bin/bash


## Name your folder
folder=`ls -1d [0-9]*`
## echo $folder

## Creat output file 
file=ENCUT-volume.dat
##file=Ene-kpoints.dat

for i in $folder;do
  cd $i
  echo "$i"
##  rm -fr workDir
##  gunzip OUTCAR.gz
  OUTCAR=OUTCAR.gz
  INCAR=INCAR
##  KPOINTS=KPOINTS

  Energy=`zgrep --text "energy  without entropy" $OUTCAR | tail -1 | awk '{print $7}'`
  Volume=`zgrep --text "volume of cell :" $OUTCAR | tail -1 | awk '{print $5}'`
  numatoms=`zgrep -a --text "number of ions     NIONS = " $OUTCAR | awk '{print $12}'`

  Energy_atom=` echo "scale=8;$Energy/$numatoms"|bc `
  Volume_atom=` echo "scale=8;$Volume/$numatoms"|bc `
  
  ENCUT=`grep --text "ENCUT" $INCAR | tail -1 | awk '{print $3}'`
#  KP=`tail -2 KPOINTS | head -1 | awk '{print $1*$2*$3}'`
  
  cd ..
##  echo "$Volume_atom" "$Energy_atom"  >> $file
  echo "$ENCUT" "$Energy_atom"  >> $file
##  echo "$KP" "$Energy_atom"  >> $file
  

done

##--- remove stuff of previous calculation 
##rm CHG CHGCAR IBZKPT WAVECAR vasprun.xml XDATCAR
