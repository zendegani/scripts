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
mpiexec -n $NSLOTS vasp

rm CHG DOSCAR EIGENVAL CHGCAR vasprun.xml PROCAR jobId PCDAT IBZKPT WAVECAR
gzip OUTCAR POTCAR OSZICAR

