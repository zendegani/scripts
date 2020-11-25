#!/bin/bash

read -p "Enter supercell dimension, e.g. 2x2x3: " supercel_dim
#supercel_dim="${supercel_dim:-'1x1x1'}"

read -p "Enter input file, e.g. POSCAR, CONTCAR [POSCAR]: " FILE_INPUT
FILE_INPUT="${FILE_INPUT:-POSCAR}"
#echo $FILE_INPUT

echo 'convert $FILE_INPUT to strcut'
sxstructprint --vasp -i $FILE_INPUT > struct.sx

echo 'generating supercell'
sxstructrep -r $supercel_dim -i struct.sx -o Sstruct.sx > sxstructrep.log

echo 'convert Supercell to SPOSCAR'
sx2poscar -i Sstruct.sx -o SPOSCAR > sx2poscar.log

