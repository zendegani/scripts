#!/bin/bash
module load intel/19.0.5
module load impi/2019.5
#module load vasp/5.4.4
module load vasp/5.4.4-buildFeb20

if [ $(hostname) == 'cmti001' ];
then
        unset I_MPI_HYDRA_BOOTSTRAP; 
        unset I_MPI_PMI_LIBRARY;
        mpiexec -n $1 vasp_std
else
        srun -n $1 vasp_std
fi

