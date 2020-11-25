#!/bin/sh

module load sphinx/serial/2.0.4
#run this script in main folder Q-Al-Mg

folder=`ls -1d [0-9]*`
here=`pwd`
for f in $folder; do
  echo $f
  cd $f/finite/relax
#  mv POSCAR POSCAR.arc
#  head -28 CONTCAR > POSCAR
#  rm ../POSCAR
#  cp POSCAR ../
  cd ..

### setting up structure and displacements with sphinx
# generating supercell
  echo 'convert POSCAR to strcut'
  sxstructprint --vasp -i POSCAR > struct.sx

  echo 'generating supercell'
  sxstructrep -r 1x1x1 -i struct.sx -o Sstruct.sx > sxstructrep.log

  echo 'convert Supercell to POSCAR'
  sx2poscar -i Sstruct.sx -o SPOSCAR > sx2poscar.log

# generating displacements
  echo 'generating displacements (displacement of 0.02 bohrradius usually ok)'
  sxuniqdispl -d 0.02 -i Sstruct.sx > sxuniqdispl.log

  echo 'generating displaced POSCAR'
#     sx2poscar -i input-disp-1.sx -o SPOSCAR1 
#     sx2poscar -i input-disp-2.sx -o SPOSCAR2
#     ...
  echo 'making directories and copying files'
  ndir=`ls -1d i*.* | wc -l`
  for (( i=1; i<$ndir+1; i++ )); do 
    sx2poscar -i input-disp-$i.sx -o SPOSCAR$i >> sx2poscar.log
    mkdir 1_$i
    cp SPOSCAR$i 1_$i/POSCAR
  done

  echo 'dont forget background forces (sometimes zero!)'
  mkdir forces_background
  cp -rf SPOSCAR forces_background/POSCAR
  
  cd $here
done


# computing stuff (doing VASP in all folders /1_1 ... and /background_forces)

----on top of folders:
  get_sxdynmat.sx

----make folder phonons
  sxdynmat -i sxdynmat.sx > sxdynmat.log
      #for phono use qPath in primitiv basis and for thermo use grid as input
  sxphonon -s phononSet.sx > sxphonon.log

----plot phonon.out


----make folder thermo For thermodynamics: previous command plus:
  sxthermo -T 2000 -dT 1 -p phonon.sxb > sxthermo.log


----plot thermo.out

### quasi Harmonic

# phonon.sxb obtained from grid (thermo folder)
sxthermo -m Fe.murn.dat -p folder1/phonon.sxb -p folder2/phonon.sxb -p /folder3/phonon.sxb -T 1000 -dT 2


'''

format murn;

murndata {
   volumes = [59.318, 78.112, 80.17, 82.296, 84.4555, 86.615, 88.842, 91.1025, 93.397, 95.725, 98.121, 61.0385, 100.516, 62.7935, 64.5815, 66.4035, 68.2595, 70.1825, 72.106, 74.063, 76.0875];
   energies = [-0.283673,-0.304655,-0.304285,-0.303636,-0.302814,-0.301897,-0.300773,-0.299463,-0.297959,-0.296288,-0.294487,-0.288546,-0.292567,-0.29656,-0.29605 ,-0.298808,-0.300976,-0.302577,-0.303735,-0.304447,-0.304729];
}


'''



FE bcc FM
V0 = 2*77.143694 bohrradius^3
   = 22.863032 angstrom^3
   
   a =2.8382107862


