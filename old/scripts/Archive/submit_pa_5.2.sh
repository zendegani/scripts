#!/bin/csh 
# 
#$ -cwd 
#$ -j y 
#$ -R y 
#$ -S /bin/csh 
#setenv TMPDIR /scratch/zendegani 
limit stacksize unlimited 
module load vasp/parallel/5.2.12 
mpirun -x PATH vasp 

rm DOSCAR EIGENVAL PROCAR PCDAT IBZKPT CHG WAVECAR CHGCAR
gzip vasprun.xml OUTCAR POTCAR OSZICAR 

