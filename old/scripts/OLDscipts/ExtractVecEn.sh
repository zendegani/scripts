#!/bin/bash

root=`pwd`
echo "$root"

file1=e-v.dat
file2=E-V.dat
file3=E-a.dat

perm=`ls -1d DP* | sed 's/DPOSCAR//'`
#perm=`ls -1d DP*`
for j in $perm;do
  echo "$j"
  cd DPOSCAR$j
#  rm E-a.dat
#  rm e-v.dat
#  rm E-V.dat

  ## path to OUTCAR
  ##[[ ! -e "OUTCAR" && ! -e "OUTCAR.gz" ]] && echo couldnt find OUTCAR && exit -1
  OUTCAR=OUTCAR
  ##[ ! -e "$OUTCAR" ] && echo "OUTCAR does not exist in `pwd`" && exit

  Energy=`zgrep --text "energy  without entropy" $OUTCAR | tail -1 | awk '{print $7}'`
  Volume=`zgrep --text "volume of cell :" $OUTCAR | tail -1 | awk '{print $5}'`
  numatoms=`zgrep -a --text "number of ions     NIONS = " $OUTCAR | awk '{print $12}'`

  Energy_atom=` echo "scale=8;$Energy/$numatoms"|bc `
  Volume_atom=` echo "scale=8;$Volume/$numatoms"|bc `

  cd $root
  echo "$Volume_atom" "$Energy_atom"  >> $file1
#  i= `echo $j | sed 's/DPOSCAR//'`
  echo "$j" "$Energy_atom"  >> $file3

done

