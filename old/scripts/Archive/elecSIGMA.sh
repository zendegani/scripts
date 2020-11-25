#!/bin/sh

#--- List of SIGMAs
for i in $(seq 0.01 .01 .1)
do
#  n1=`echo "scale=0;($i-0.1)*170+95" | bc`
#  n=`printf %0.f $n1`
  n=95
  echo "-------------------------------------------------------"
  echo "               SIGMA = $i "
  echo "                     NBANDS= $n "
  echo "-------------------------------------------------------"
  mkdir $i
  cd $i
  cp ../POTCAR ./
  cp ../POSCAR ./
  cp ../KPOINTS ./

#--- create INCAR
  cat > INCAR << INCAReof
#---general---
  SYSTEM =   Q Joachim electronic supercell 1x1x2
  ENCUT  =   350 eV   # cutoff used throughout all calculations [eV]
  NBANDS =   $n
  ISMEAR =   -1    # 1-Methfessel-Paxton -4-tet -1-fermi 0-gaus
  SIGMA  =   $i    smearing scale-factor
  
 ADDGRID=.TRUE. ! High accuracy important for phonons!!!
 PREC   =   Accurate  
 ISTART =      0  
 ICHARG =      2  
   
 ALGO   = Normal
 LWAVE  =      F    !write_WAVECAR
 LCHARG =      F    !write_CHGCAR
 LVTOT  =      F    !write_LOCPOT,local_potential
 LELF   =      F    !write_electronic_localiz_function(ELF)

 LREAL= .FALSE.
 NPAR   =  4
 EDIFF  =  1E-06

INCAReof

  qsub -l h_rt=36:0:0 -pe impi_hydra 20 /cmmc/u/alizen/scripts/G-Q2.sh
  cd ..
done


