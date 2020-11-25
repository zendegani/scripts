#!/bin/bash

here=`pwd`
mkdir $1
cp -t $1 INCAR POSCAR KPOINTS
cd $1
ln -s $here/POTCAR

