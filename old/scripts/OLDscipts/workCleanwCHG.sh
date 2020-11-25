#!/bin/bash

mkdir reset
mv -t reset INCAR POSCAR POTCAR* KPOINTS CHGCA* WAVECA*
rm ./*
mv reset/* .
rm -rf reset/
gunzip POTCAR.gz CHGCAR.gz WAVECAR.gz



