#!/usr/bin/python

import subprocess

magstr=subprocess.check_output("grep MAG INCAR", shell=True, stderr=subprocess.STDOUT).split("=")[1].split()

outstr=""
for i in magstr:
    if float(i) != 0.:
        if float(i) < 0.: outstr+='D'
        else: outstr+='U'

print outstr

