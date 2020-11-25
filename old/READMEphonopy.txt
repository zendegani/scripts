******************* Frozen-Phonon:

phonopy -d --dim="2 2 3"
run vasp
phonopy -f disp-{001..003}/vasprun.xml

==> mesh.conf <==
ATOM_NAME = Na Cl
DIM = 2 2 2
MP = 8 8 8
==> mesh.conf <==

phonopy -p mesh.conf

==> pdos.conf <==
ATOM_NAME = Na Cl
DIM = 2 2 2
MP = 8 8 8
PDOS = 1 2 3 4 ,5 6 7 8          
==> pdos.conf <==

phonopy -p pdos.conf








******************* DFPT:

##### Prepare a perfect supercell structure from POSCAR-unitcell:
phonopy -d --dim="2 2 2" -c POSCAR-unitcell
mv SPOSCAR POSCAR

##### Calculate force constants of the perfect supercell by running VASP with:
  NPAR      =  number of cores
  LREAL     =  False  # real-space projection, False or True
  PREC      =  Accurate
  ADDGRID   =  .TRUE.
  NSW       =  1   # number of steps for IOM
  IBRION    =  8   # ionic relax: 0-MD 1-quasi-New 2-CG
  NFREE     =  2   #or 4 but not 1

run vasp

##### create FORCE_CONSTANTS:
phonopy --fc vasprun.xml


##### 

==> mesh.conf <==
ATOM_NAME = Na Cl
DIM = 2 2 2
MP = 8 8 8
FORCE_CONSTANTS = READ
==> mesh.conf <==

phonopy -c POSCAR-unitcell -p mesh.conf



##### 

==> pdos.conf <==
ATOM_NAME = Na Cl
DIM = 2 2 2
MP = 8 8 8
PDOS = 1 2 3 4 ,5 6 7 8 
FORCE_CONSTANTS = READ
==> pdos.conf <==

phonopy -c POSCAR-unitcell -p pdos.conf

##### 

==> band.conf <==
ATOM_NAME = Na Cl
DIM = 2 2 2
PRIMITIVE_AXIS = 0.0 0.5 0.5  0.5 0.0 0.5  0.5 0.5 0.0
BAND = 0.0 0.0 0.0  0.5 0.0 0.0  0.5 0.5 0.0  0.0 0.0 0.0  0.5 0.5 0.5
FORCE_CONSTANTS = READ
==> band.conf <==

phonopy -c POSCAR-unitcell -p band.conf

##### 
phonopy -v -f disp-0{0{1..9},{10..17}}/vasprun.xml
