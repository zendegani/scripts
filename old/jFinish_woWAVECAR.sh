#!/bin/bash

rm DOSCAR EIGENVAL PROCAR PCDAT IBZKPT CHG* WAVECAR* CHGCAR*
bzip2 POTCAR 2>/dev/null
bzip2 std.log  err.log
bzip2 -f vasprun.xml OSZICAR
gzip -f OUTCAR

