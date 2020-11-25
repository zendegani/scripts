import ase.io.vasp
import random

cell = ase.io.vasp.read_vasp('POSCAR')
for i in range(len(cell)):
  for j in range(3):
   cell.positions[i,j]=cell.positions[i,j]+(random.random()/100*10-.05)
ase.io.vasp.write_vasp('PPOSCAR',cell,label="perturbedcell",direct=True)

