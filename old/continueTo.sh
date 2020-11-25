#!/bin/bash

here=`pwd`
mkdir $1
cp -t $1 INCAR KPOINTS
cp CONTCAR $1/POSCAR
cd $1
ln -s $here/POTCAR

