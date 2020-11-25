#2017-01-16
import ase.io.vasp
import random
from os import path as op

tmpfolder="."
cell = ase.io.vasp.read_vasp(op.join(tmpfolder,'POSCAR'))
print "Total atom number is: ",  cell.get_number_of_atoms()
print "Lattice vectors:"
print cell.cell

numberStrct = int(raw_input('How many perturbed structures do you need [10]? ') or '10')
perturbMaxAmp = float(raw_input('Enter the perturbation MAX amplitude in Cartesian mode [0.2] Angstrom: ') or 0.2)
perturbMinAmp = float(raw_input('Enter the perturbation MIN amplitude in Cartesian mode [0.1] Angstrom: ') or 0.1)
#rndAmplitude=1/(2*perturbAmplitude)
perturbMode = raw_input('Would you like to perturb all atoms or specific ones ([a]:all/s:specific)? ').upper() or "A"
perturbDirec = raw_input('Would you like to perturb atoms in all directions or specific ones ([a]:all/x,y,z)? ').upper() or "A"
if perturbDirec=="A":
    directions=[0,1,2]
    perturbDirec="XYZ"
elif perturbDirec=="X":
    directions=[0]
elif perturbDirec=="Y":
    directions=[1]
elif perturbDirec=="Z":
    directions=[2]
else: print "wrong input!"


def perturbRND(min,max):
    rndGen = random.random()*2*(max-min)-(max-min)
    if rndGen > 0:
        return rndGen+min
    else:
        return rndGen-min

_=0
if perturbMode=="A":
    for n in range(numberStrct):
        cell = ase.io.vasp.read_vasp(op.join(tmpfolder,'POSCAR'))
        for i in range(len(cell)):
            for j in directions:
                cell.positions[i,j]=cell.positions[i,j]+perturbRND(perturbMinAmp,perturbMaxAmp)
        ase.io.vasp.write_vasp(op.join(tmpfolder,'DPOSCAR'+str(_)),cell,label=
                               "perturbed cell, min: "+str(perturbMinAmp)+" A, max: "+str(perturbMaxAmp)+" A, Directions: "+str(perturbDirec)+", Perturbed atoms: All",direct=True)
        _+=1
elif perturbMode=="S":
    print "The cell formula is: ",cell.get_chemical_formula(), "it is sorted alphabetically! (but the atoms positions are the same as in POSCAR)"
    print cell.get_scaled_positions()
    #     perturbAtoms = map(int,raw_input('Enter the row number of the atoms separated by space').split())
    #    perturbAtoms = [27]
    perturbAtoms = map(int, raw_input('Enter the row number of the atoms separated by space (count from 1 not 0): ').split())
    perturbAtoms = [i-1 for i in perturbAtoms] # i-1 is for counting from 0
    print "Original positions:"
    print cell.positions[perturbAtoms]
    print "Perturbed positions:"
#    print cell.positions[perturbAtoms]
    for n in range(numberStrct):
        cell = ase.io.vasp.read_vasp(op.join(tmpfolder,'POSCAR'))
        for i in perturbAtoms:
            for j in directions:
                cell.positions[i,j]=cell.positions[i,j]+perturbRND(perturbMinAmp,perturbMaxAmp)
        print cell.positions[perturbAtoms]
        ase.io.vasp.write_vasp(op.join(tmpfolder,'DPOSCAR'+str(_)),cell,label=\
                               "perturbed cell, min: "+str(perturbMinAmp)+" A, max: "+str(perturbMaxAmp)+" A, Directions: "+str(perturbDirec)+", Perturbed atoms: "+str(perturbAtoms),direct=True)
        _+=1


print "########################################################"
print "Perturbation min: ",perturbMinAmp, "angstrom,  max: ",perturbMaxAmp," angstrom"
print "Directions All/X/Y/Z: ",perturbDirec
if perturbMode=="A":
    print "All atoms perturbed."
else:
    print "Perturbed atoms#: ", perturbAtoms
print "########################################################"
