#!/usr/bin/python

#rev 2015-11-22

print "Importing python modules ..."
from time import time
start_time = time()
import numpy as np
import matplotlib.pyplot as plt
#from itertools import cycle
import sys
import os
print("--- done in %s seconds ---" % (time() - start_time))

phonon =np.loadtxt(sys.argv[1])
npoints=np.loadtxt(sys.argv[2])
file_label=sys.argv[3]
file_qpath=np.loadtxt(sys.argv[4])
title=' '.join(sys.argv[5:])

labels =open(file_label,'r').read().splitlines()
for i in range(1,len(npoints)):
    npoints[i]+=npoints[i-1]


qpath=(file_qpath>0)+0   #should find a better way!
labels2=[]
[labels2.append(''.join(np.array_str(i))) for i in qpath]

print "Plotting the dispersion "

if os.fork():
    print 'fork passed'
    pass
else:
    fig, ax1 = plt.subplots()
    [ax1.plot(phonon[:,0],phonon[:,x]) for x in range(1,len(phonon[0]))]
    plt.title(title, y=1.06)
    plt.ylabel(r'$\omega$ (meV)')
    plt.xticks(npoints, labels)     #prints the name of q-points
    [plt.axvline(x=coords, ymin=0, ymax=1, linewidth=1, color = '.8') for coords in npoints[1:-1]]
    ax2 = ax1.twiny()
    plt.xticks(npoints, labels2)    #prints the direction of q-points on top of the graph
    plt.show()
