#!/usr/bin/python

#rev 2015-10-27

import numpy as np
import matplotlib.pyplot as plt
import sys
from itertools import cycle
import os

#for arg in sys.argv:
#    print arg
#plt.ion()

import matplotlib
matplotlib.interactive(False)

file=np.loadtxt(sys.argv[1])
natoms=sys.argv[2].split()

sample=file
bins=int((sample[:,1].max()-sample[:,1].min())/.05)

if os.fork():
    print 'fork passed'
    pass
else:
    f, (ax1, ax2) = plt.subplots(1,2, sharey=True)
    lines = ["*b","or","^k",">p","<b"]
    linecycler = cycle(lines)
    m=0
    for i in natoms:
        i=int(i)
        ax1.plot(sample[m:m+i,0],sample[m:m+i,1],next(linecycler))
        m+=i
    ax1.set_title('Atoms magnetic moments')
    ax1.axhline(y=0)
    ax2.hist(sample[:,1], bins=bins, orientation="horizontal");
    ax2.xaxis.set_ticks_position('top')
    f.subplots_adjust(wspace=0)
    plt.show()




