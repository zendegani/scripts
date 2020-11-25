#!/usr/bin/python

#rev 2015-11-12

print "Importing python modules ..."
from time import time
start_time = time()
from numpy import loadtxt
print("--- numpy %s seconds ---" % (time() - start_time))

import matplotlib.pyplot as plt
print("--- matplotlib %s seconds ---" % (time() - start_time))
from itertools import cycle
print("--- itertools %s seconds ---" % (time() - start_time))
#from os import fork
from sys import argv
print("--- sys %s seconds ---" % (time() - start_time))
from os import fork
print("--- os %s seconds ---" % (time() - start_time))
print "done!"

#for arg in sys.argv:
#    print arg
#plt.ion()

#import matplotlib
#matplotlib.interactive(False)

file=loadtxt(argv[1])
natoms=argv[2].split()

sample=file
bins=int((sample[:,1].max()-sample[:,1].min())/.05)

print "Plotting the histogram "

if fork():
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


