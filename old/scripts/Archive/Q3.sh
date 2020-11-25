#!/bin/csh 
# 
#$ -cwd 
#$ -j y 
#$ -R y 
#$ -S /bin/csh 
#setenv TMPDIR /scratch/zendegani 
limit stacksize unlimited 
module load vasp/parallel/4.6-tdi 
mpirun -x PATH vasp 
gzip POTCAR 

