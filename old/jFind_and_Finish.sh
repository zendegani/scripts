#!/bin/bash

here=`pwd`
list=`find $here  -name "OUTCAR" |  rev | cut -d/  -f2- |rev`
for i in $list; do
 echo $i
 cd $i
# ls
# pwd
 rm DOSCAR EIGENVAL PROCAR PCDAT IBZKPT CHG WAVECAR CHGCAR XDATCAR
 bzip2 POTCAR  std.log
 bzip2 -f vasprun.xml OSZICAR
 gzip -f OUTCAR
 cd $here
done
