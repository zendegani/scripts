#!/bin/bash

pattern="${1:-'./'}"
echo "$pattern"
folders=`eval find "${pattern}" -name WAVE* | rev | cut -d/ -f2- | rev`
echo ""
echo $folders
echo ""
for f in $folders; do
 rm -i $f/WAVE* $f/CHGCAR* $f/vasprun.xml*
done
