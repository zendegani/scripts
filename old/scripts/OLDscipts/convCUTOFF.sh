#!/bin/bash

#--- List of K-points
ENCUT=(100 150 200 250 300 350 400 450 500 550 600)

#--- for each value of the K-points list
for a in "${ENCUT[@]}"; do
  mkdir $a
  cd $a
  cp ../POTCAR ./
  cp ../POSCAR ./
  cp ../KPOINTS ./
#--- prompt user info
  echo "-------------------------------------------------------"
  echo "  ENCUT = $a"
  echo "-------------------------------------------------------"

#--- create INCAR
  cat > INCAR << INCAReof
#---general---
   SYSTEM =   Fe2Nb: C14, NM

#---Startparameter_for_this_run---
   PREC   =   High           !Normal,Medium,High,Low
   ISTART =   0                  !WAVECAR:0-new,1-cont,2-samecut
   ICHARG =   2                  !charge:1-file,2-overlapping_atom,10-const

#---spin_calculation---
#    ISPIN  =   2                  !1-spin OFF, 2-spin ON
#    MAGMOM =   1*2.0             !initial_mag_moment
#    RWIGS  =   2.0                !radius of wigner-seitz radius

#---Electronic_Relaxation1---
   ENCUT  =   $a eV   # cutoff used throughout all calculations [eV]
#   LREAL  =   .FALSE.            !F:small_syst,T:large
   NBANDS = 72
   NSW    =  10       # number of steps for ionic upd. 
#   NELM   =   100 
#   NELMIN =   5                  !min_nb_ELM
#   NELMDL =  -5                  !nb_ELM_before_charge_update 
#   EDIFF  =   1.0E-07            !stopping-criterion_for_ELM [eV]
   EDIFFG  =   -1.0E-04
   ALGO   =   Fast
   IBRION =   2
   ISIF   =   2
  
#---DOS_related_values---
   ISMEAR =   1                  !tetrahedron,-1:fermi,0:Gaussian,N:Methfessel-Paxton(Metal)
   SIGMA  =   0.1                !smearing_width_ISMEAR

#---Write_flags---
   LWAVE  =   F                  !write_WAVECAR
   LCHARG =   T                  !write_CHGCAR
   LVTOT  =   F                  !write_LOCPOT,local_potential
   LELF   =   F                  !write_electronic_localiz_function(ELF)

   NPAR = 4

INCAReof

  qsub -l h_rt=36:0:0 -pe impi_hydra 20 /cmmc/u/alizen/scripts/G-Q2.sh
  cd ..
done


