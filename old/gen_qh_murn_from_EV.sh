#!/bin/bash
#2016-11-02

# following 3 lines must always be present
path=`set | grep BASH_SOURCE | sed 's|.*\"\(.*\)/[^/]*\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
script=`set | grep BASH_SOURCE | sed 's|.*\".*/\([^/]*\)\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
options=$*; . $path/azfunctions.include;

#read -p "Enter supercell dimension, e.g. 2x2x3: " supercel_dim
#supercel_dim="${supercel_dim:-'1x1x1'}"

filename="qh_murn.dat"
file2="Hartree_Bohr3.dat"

cat > $filename << EOF

format murn;

murndata {
   volumes = [
EOF

line=`awk -vORS=, '{print $1}' $file2  | sed 's/,$/\n/'`
echo $line >> $filename
echo "];   energies = [" >> $filename
line=`awk -vORS=, '{print $2}' $file2  | sed 's/,$/\n/'`
echo $line >> $filename  
echo "]; }"  >> $filename


