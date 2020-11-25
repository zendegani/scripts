#!/bin/bash
folder=${1:-"dupWithWAVE"}
here=`pwd`
mkdir $folder
cp -t $folder INCAR POSCAR KPOINTS WAVE* CHG*
cd $folder
gunzip *
ln -s $here/POTCAR
ls
pwd

