#!/bin/csh
#$ -cwd
#$ -j y
#$ -S /bin/csh
module load vasp/serial/4.6-tdi
mkdir workDir 
cp * workDir/ 
cd workDir 
vasp
gzip OUTCAR 
gzip vasprun.xml 
mv vasprun.xml.gz CONTCAR OSZICAR OUTCAR.gz ../ 
cd ../ 
gzip POTCAR 
rm -fr workDir 
