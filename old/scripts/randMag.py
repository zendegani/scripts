#!/usr/local/bin/python
##!/opt/local/bin/python

#ver 2015-11-13
#---Date 2015-05-30 16:32

import random

zeros=' 0 0 '
fe = raw_input("Please enter number of Fe atoms [32]:") or 32
fe_min = raw_input("Please enter abs minimum moments for Fe atoms [1]:") or 1
fe_max = raw_input("Please enter abs maximum moments for Fe atoms [2]:") or 2
nb = raw_input("Please enter number of Nb atoms [16]:") or 16
nb_min = raw_input("Please enter abs minimum moments for Nb atoms [0]:") or 0
nb_max = raw_input("Please enter abs maximum moments for Nb atoms [.5]:") or .5

fe=int(fe)
nb=int(nb)
fe_min = abs(float(fe_min))
fe_max = abs(float(fe_max))
nb_min = abs(float(nb_min))
nb_max = abs(float(nb_max))
print "----------------"

while True:
    while True:
        magFe=''
        n=0
        for i in range(fe):
            sign=random.choice(['+', '-'])
            #m=random.random()*1.5
            m=fe_min +  random.random()*(abs(fe_max-fe_min))
            if sign=='+':
                n+=1
            magFe+=zeros+sign+str(m)[:5]
        print n,
        if n==fe/2:
            break
    print
    while True:
        magNb=''
        n=0
        for i in range(nb):
            sign=random.choice(['+', '-'])
            #        m=random.random()*.2
            m=nb_min+random.random()*abs(nb_max-nb_min)
            if sign=='+':
                n+=1
            magNb+=zeros+sign+str(m)[:5]
        print n,
        if n==nb/2:
            break

    print
    mag=magFe+' '+magNb+' '
    total_mag_mom = abs(sum([float(x) for x in mag.split()]))
    print "----------------"
    print "Total moments= ",total_mag_mom
    print "----------------"
    if total_mag_mom < .1: break
print "****************"
print 'Fe : ', magFe
print "----------------"
print "Total Fe moments= ",sum([float(x) for x in magFe.split()])
print "----------------"
print 'Nb : ', magNb
print "----------------"
print "Total Nb moments= ",sum([float(x) for x in magNb.split()])
print "----------------"
print fe_min,'< Fe <',fe_max,'   ',nb_min,'< Nb < ', nb_max
print "----------------"
print 'MAGMOM =', mag
print "----------------"
print "Total moments= ",total_mag_mom
