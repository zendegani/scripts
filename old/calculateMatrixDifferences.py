#!/usr/bin/python

#rev 2015-11-20

print "Importing python modules ..."
from time import time
start_time = time()
import numpy as np
#from itertools import cycle
import sys
import os
print("--- done in %s seconds ---" % (time() - start_time))

folderBase=sys.argv[1]
folders=sys.argv[2:]
print folderBase
print folders
forceArrayFile='/forces-last-ARRAY.dat'
forcesBase=np.loadtxt(folderBase+forceArrayFile)
forces=[]
for path in folders:
    forces.append(np.loadtxt(path+forceArrayFile))

forceMaxIndex=np.max(abs(forcesBase))==abs(forcesBase)
forceMinIndex=np.min(abs(forcesBase))==abs(forcesBase)
print '# sumDiff   max     maxDiff   min      minDiff'
sum=[]; max=[]; maxDiff=[]; min=[]; minDiff=[];
for matrix in forces:
    sum.append(np.sum(abs(forcesBase-matrix)))
    max.append(matrix[forceMaxIndex][0])
    min.append(matrix[forceMinIndex][0])
    maxDiff.append(forcesBase[forceMaxIndex][0]-matrix[forceMaxIndex][0])
    minDiff.append(forcesBase[forceMinIndex][0]-matrix[forceMinIndex][0])

#print sum, max, maxDiff, min, minDiff

outstring=zip(sum, max, maxDiff, min, minDiff)
f = open('Forces.dat', 'w')
for line in outstring:
    f.write(" ".join(str(x) for x in line) + "\n")

#f.write('# sumDiff   max     maxDiff   min      minDiff\n')

f.close()


'''
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
import numpy as np
a=np.loadtxt('tes')
b=(a==0)+0
c=[]
[c.append(''.join(np.array_str(i))) for i in b]
'''


