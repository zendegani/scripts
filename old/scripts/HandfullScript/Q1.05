#!/bin/csh 
# 
#$ -cwd 
#$ -j y 
#$ -R y 
#$ -S /bin/csh 
#setenv TMPDIR /scratch/zendegani 
limit stacksize unlimited 
module load vasp/parallel/4.6-tdi 
mkdir workDir 
cp * workDir/ 
cd workDir 
mpirun -x PATH vasp 
#gzip OUTCAR 
gzip vasprun.xml 
mv vasprun.xml.gz CONTCAR OSZICAR OUTCAR ../ 
cd ../ 
gzip POTCAR 
rm -fr workDir 
