#$ -S /bin/bash
#$ -j y
#$ -cwd
#$ -m n
#$ -N meinjob
#$ -l h_rt=259199
#$ -pe impi_hydra 20
date
ulimit -aH
module load impi
module load vasp/5.3.5
mkdir workDir 
cp INCAR POSCAR POTCAR KPOINTS workDir/ 
cd workDir 
mpiexec -n $NSLOTS vasp
gzip vasprun.xml 
mv vasprun.xml.gz CONTCAR OSZICAR OUTCAR ../ 
cd ../ 
gzip POTCAR 
rm -fr workDir 

