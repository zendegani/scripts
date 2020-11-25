#!/bin/bash
module purge
module load intel/19.1.0
module load impi/2019.6
module load vasp/5.4.4-buildFeb20

if [ $(hostname) == 'cmti001' ] || [ $(hostname) == 'cmti002' ];
then
        unset I_MPI_HYDRA_BOOTSTRAP; 
        unset I_MPI_PMI_LIBRARY;
        mpiexec -n $1 vasp_ncl
else
        srun -n $1 vasp_ncl
fi

