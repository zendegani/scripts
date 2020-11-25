#!/usr/bin/python

#rev 2015-11-16

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
    #    ax1 = fig.add_subplot(111)
    [ax1.plot(phonon[:,0],phonon[:,x]) for x in range(1,len(phonon[0]))]
    plt.ylabel(r'$\omega$ (meV)')
    plt.xticks(npoints, labels)
    ax2 = ax1.twiny()
    plt.xticks(npoints, labels2)
    #    ax1Xs = ax1.get_xticks()
    #ax2.set_xticks(ax1Xs)
    plt.show()
'''
import numpy as np
a=np.loadtxt('tes')
b=(a==0)+0
c=[]
[c.append(''.join(np.array_str(i))) for i in b]
'''


