#!/bin/bash
#2016-11-02

# following 3 lines must always be present
path=`set | grep BASH_SOURCE | sed 's|.*\"\(.*\)/[^/]*\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
script=`set | grep BASH_SOURCE | sed 's|.*\".*/\([^/]*\)\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
options=$*; . $path/azfunctions.include;

read -p "Enter supercell dimension, e.g. 2x2x3: " supercel_dim
supercel_dim="${supercel_dim:-'1x1x1'}"
echored $supercel_dim

read -p "Enter the name of input structure, e.g. POSCAR: " input_strc
input_strc=${input_strc:-"POSCAR"}
echored  $input_strc

echo 'convert POSCAR to strcut'
sxstructprint --vasp -i $input_strc > struct.sx

echo 'generating supercell'
sxstructrep -r $supercel_dim -i struct.sx -o Sstruct.sx > sxstructrep.log

echo 'convert Supercell to POSCAR'
sx2poscar -i Sstruct.sx -o SPOSCAR > sx2poscar.log
