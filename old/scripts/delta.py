#!/usr/bin/env python

#-- Date 2015.10.13

import itertools
import numpy as np
from scipy.integrate import simps, trapz, cumtrapz
import matplotlib.lines as mlines
import matplotlib.pyplot as plt
import scipy.constants as sc
import scipy.optimize as optimization
from matplotlib.ticker import AutoMinorLocator

plt.ion()

# G  = A + B*T + C*T*LN(T) + D*T^2 + E*T^3  + F*T^-1
# Cp =         - C         - 2D*T  - 6E*T^2 - 2F*T^-2

def funG(T, A, B, C, D, E, F):
    return  A +B*T +C*T*np.log(T) +D*T**2 +E*T**3  +F*T**-1

def funCp(T, C, D, E, F):
    return         -C             -2*D*T  -6*E*T**2 -2*F*T**-2

def funG3(T, A, B, C, D, F):
    return  A + B*T + C*T*np.log(T) + D*T**2 + F*T**-1

def funCp3(T,C,D,F):
    return          - C             -2*D*T   -2*F*T**-2


PATHNAS='/nas/zendegani/Projects/Q/Calculations/9_imaginary/'

##--------------- CALPHAD

FJ13=np.loadtxt(PATHNAS+'DATA/FreeEneHarmonic/F_J_FixRef298.13')
FJ13=FJ13[FJ13[:,0].argsort()];
xdata=FJ13[200:,0]
ydata=FJ13[200:,1]
popt, pcov= optimization.curve_fit(funG3, xdata, ydata)
A, B, C, D, F = popt

CEFnew=np.loadtxt(PATHNAS+'Q-TC/Cp-CALPHAD/CP')
CEFnew=CEFnew[CEFnew[:,0].argsort()];

Trange=len(xdata)
deltaConfNew=np.zeros((Trange,2))
for i in range(Trange):
    deltaConfNew[i,0]=CEFnew[i,0]
    deltaConfNew[i,1]=CEFnew[i,1]-funCp3(CEFnew[i,0],C,D,F)

##--------------- 15 deg

fit15d13=np.poly1d(np.polyfit(FJ13[:, 0], FJ13[:, 1],15))
T=FJ13[:,0]
Cvfit15der=np.zeros((len(T),2));
Cvfit15der[:,0]=FJ13[:,0]
Cvfit15der[:,1]=-T*np.polyder(fit15d13,2)(T)

CEFold=np.loadtxt(PATHNAS+'Q-TC/CP-SO-Q21-Fixed298-1000/Q_PBE_FixedRef298_CP_Al__3')
CEFold=CEFold[CEFold[:,0].argsort()];

Tmin=int(CEFold[0,0])
Tmax=1000
Trange=Tmax-Tmin-1
deltaConfOld=np.zeros((Trange,2))
for i in range(Trange):
    deltaConfOld[i,0]=CEFold[i,0]
    deltaConfOld[i,1]=CEFold[i,1]-Cvfit15der[np.nonzero(Cvfit15der[:,0]==CEFold[i,0]),1]

#print i, i+Tmin,CEFold[i], Cvfit15der[np.nonzero(Cvfit15der[:,0]==CEFold[i,0])],CEFold[i,1]-Cvfit15der[np.nonzero(Cvfit15der[:,0]==CEFold[i,0]),1]

##--------------- Total

PATHcurrent='/nas/zendegani/Projects/Q/Calculations/'
pathh=PATHcurrent+'7-CP-Q-experimental/Electronic/q/output_0.0001GPa/heat_capacity_isochoric'
pathqh=PATHcurrent+'7-CP-Q-experimental/Electronic/q/output_0.0001GPa/heat_capacity_isobaric'
pathqe=PATHcurrent+'7-CP-Q-experimental/Electronic/qe/output_0.0001GPa/heat_capacity_isobaric'
pathExp=PATHcurrent+'7-CP-Q-experimental/MeasuredCp'
pathCalphad2012=PATHcurrent+'7-CP-Q-experimental/CalphadCp2012real.txt'

CVQ2=np.loadtxt(pathh)                  #harmonic
CPQ2=np.loadtxt(pathqh)                 #quasi-harmonic
CeQ2=np.loadtxt(pathqe)                 #electronic
CpEXP=np.loadtxt(pathExp)               #experimental
CpCalphad=np.loadtxt(pathCalphad2012)   #Calphad 2012

path2000='/nas/zendegani/Projects/Q/Report/Paper/Re_paper_Q-Phase/Qupto2000.txt'
Cp2k=np.loadtxt(path2000,skiprows=1)




##--------------- Calculate new Total

TrangeTotal=len(CeQ2)
Ctotal=np.zeros((TrangeTotal,2))
Ctotal[:,0]=CeQ2[:,0]

for i in range(TrangeTotal):
    if i in deltaConfNew:
        Ctotal[i,1]=CeQ2[i,1]*sc.R+deltaConfNew[np.nonzero(deltaConfNew[:,0]==i),1]
    else:
        Ctotal[i,1]=CeQ2[i,1]*sc.R

#print i, Ctotal[i], CeQ2[i,0], CeQ2[i,1]*sc.R, deltaConfNew[np.nonzero(deltaConfNew[:,0]==i)]


CtotalOLD=np.zeros((TrangeTotal,2))
CtotalOLD[:,0]=CeQ2[:,0]

for i in range(TrangeTotal):
    if i in deltaConfOld:
        CtotalOLD[i,1]=CeQ2[i,1]*sc.R+deltaConfOld[np.nonzero(deltaConfOld[:,0]==i),1]
    else:
        CtotalOLD[i,1]=CeQ2[i,1]*sc.R
#print i, CtotalOLD[i], CeQ2[i,0], CeQ2[i,1]*sc.R, deltaConfOld[np.nonzero(deltaConfOld[:,0]==i)]



CtotalMid=np.loadtxt('/nas/zendegani/Projects/Q/Calculations/7-CP-Q-experimental/TotalnewConf20150702.txt')

##--------------- Plot Total

plt.figure()
plt.plot(Ctotal[:,0],Ctotal[:,1], 'k', label='Total Cp via new fitting')
plt.plot(CtotalMid[:,0],CtotalMid[:,2],'--b', label='Total Cp currently in manuscript !')
plt.plot(CtotalOLD[:,0],CtotalOLD[:,1],'-.r', label='Total Cp via Fit 15th deg !')
plt.ylim([30,34])
plt.xlim([900,998])
plt.legend(loc=2)
plt.grid(True)
plt.xlabel('T (K)');
plt.ylabel('Heat capacity (J/K mole-atoms)');


##--------------- Plot CEF vs Q13

plt.figure()
plt.plot(CEFnew[:,0],CEFnew[:,1], 'k', label='CEF new')
plt.plot(xdata,funCp3(xdata,C,D,F), 'b', label='3M1 new')
plt.plot(CEFold[:,0],CEFold[:,1], 'r', label='CEF from 15th deg')
plt.plot(Cvfit15der[:,0], Cvfit15der[:,1], '--r', label='3M1 from 15th deg')

plt.plot(deltaConfOld[:,0],deltaConfOld[:,1]+funCp3(xdata,C,D,F)[:-1],'--r', lw=2,label='Q13 new + old config. contribution')

plt.legend(loc=2)
plt.xlim([200,1000])
plt.ylim([20,30])
plt.grid(True)
plt.xlabel('T (K)');
plt.ylabel('Heat capacity (J/K mole-atoms)');


##--------------- Plot Configurational contribution

plt.figure()

plt.plot(deltaConfNew[:,0],deltaConfNew[:,1],'k',label='Config. contribution via new fitting')
plt.plot(CtotalMid[:,0],CtotalMid[:,1],'--b', label='Config. contribution currently in manuscript !')
plt.plot(deltaConfOld[:,0],deltaConfOld[:,1],'-.r', lw=2, label='Config. contribution via Fit 15th deg !')
plt.ylim([0,5])
plt.xlim([0,1000])
plt.legend(loc=2)
plt.grid(True)
plt.xlabel('T (K)');
plt.ylabel('J/K mole-atoms');


np.savetxt('20151009deltaConfig15deg.txt',deltaConfOld)

name='DiffConfig'
plt.savefig(name+'.jpg', dpi=200, facecolor='w', edgecolor='w', transparent=False, orientation='landscape',format='jpg' )




##--------------- Plot

colors = itertools.cycle(['k', 'b', 'r', 'm', 'c'])
lineStyles = itertools.cycle(['-', '--', '-.'])
#lineStyles = itertools.cycle(mlines.Line2D.lineStyles)
#plt.title('$Q\ phase:\ Al_{3.5}Cu_2Mg_{9.5}Si_{6}$')

fig, ax = plt.subplots(figsize=[13,8])
plt.xlabel('T (K)');
plt.ylabel('Heat capacity (J/K mole-atoms)');
plt.axis([0,2000,0,40])
plt.axis([0,900,0,35])
plt.grid(False)
font = {'family' : 'sanserif', 'weight' : 'normal', 'size' : 16}
plt.rc('font', **font)
#fig.set_size_inches(10,20)

c1='#B4B4D9'
c2='#F7E308'
c3='#FA0526'
c4='#0521FA'

ax.fill_between(CVQ2[:900,0],0,CVQ2[:900,1]*sc.R, edgecolor='none', facecolor=c1, alpha=.4)
ax.fill_between(CVQ2[:900,0],CVQ2[:900,1]*sc.R,CPQ2[:900,1]*sc.R, edgecolor='none', facecolor=c2, alpha=.5)
ax.fill_between(CeQ2[:900,0],CPQ2[:900,1]*sc.R ,CeQ2[:900,1]*sc.R, edgecolor='none', facecolor=c3, alpha=.5)


pCVQ2=ax.plot(CVQ2[:900,0],CVQ2[:900,1]*sc.R, c1, lw=1, label='harmonic', alpha=.5) # color='0.8')
pCPQ2=ax.plot(CPQ2[:900,0],CPQ2[:900,1]*sc.R, c2, lw=1, label='quasi-harmonic', alpha=.5) #color='0.8')
pCeQ2=ax.plot(CeQ2[:900,0],CeQ2[:900,1]*sc.R, c3 , lw=1, label='qh+electronic', alpha=.5)

pCtotal=ax.plot(Ctotal[:,0],Ctotal[:,1], c4, ls='-', lw=2, label='First-principle [this work] qh+el+conf')
plt.plot(Cp2k[:,0],Cp2k[:,3], '--r', lw=4, label='Calphad [this work]') #, alpha=.7
pCpCalphad=ax.plot(CpCalphad[:,0],CpCalphad[:,1], '-k' , lw=2, label='Calphad [2012Loe]')

pCExp1=ax.plot(CpEXP[:,0],CpEXP[:,1] , '^k', markersize=11, fillstyle='full', markerfacecoloralt='white', c='white', label='1st run')
pCExp2=ax.plot(CpEXP[:,0],CpEXP[:,2] , 'vk', markersize=11, fillstyle='full', markerfacecoloralt='white', c='white', label='2nd run')

legend = ax.legend(loc='lower right', shadow=False)

legend.params = {'legend.fontsize': 'xx-small'} #, 'legend.linewidth': 2}
legend.params = {'mathtext.default': 'regular' }
plt.rcParams.update(legend.params)

size=12
ax.text(840, 20, "harmonic", ha="center", va="center", size=size)
ax.text(840, 26, "quasi-harmonic", ha="center", va="center", size=size)
ax.text(840, 27.7, "electronic", ha="center", va="center", size=size, rotation=9)
ax.text(840, 28.9, "configurational", ha="center", va="center", size=size, rotation=14)


plt.show()



##--------------- Fit new Total


minorLocator   = AutoMinorLocator()
fig, ax = plt.subplots()
plt.plot(Ctotal[:,0],Ctotal[:,1], '-k',label='Cp')
plt.ylim([0,35])
ax.yaxis.set_minor_locator(minorLocator)
plt.grid(True,which='both')
plt.tick_params(which='both', width=2)
plt.tick_params(which='major', length=7)
plt.tick_params(which='minor', length=4, color='r')

xdata=Ctotal[200:-1,0]
ydata=Ctotal[200:-1,1]
popt, pcov= optimization.curve_fit(funCp, xdata, ydata)
C, D, E, F = popt
plt.plot(xdata,funCp(xdata,C,D,E,F), '--r', lw=2, label='Fit')
ax.legend(loc='best')
plt.ylim([20,33])
plt.xlim([200,1000])
plt.xlabel('T (K)');
plt.ylabel('Heat capacity (J/K mole-atoms)');


'''
##--------------- Q13

Thermo13=np.loadtxt(PATHNAS+'DATA/Q-Al-Mg/13/finite/thermo/thermo.out')
Thermo13=Thermo13[Thermo13[:,0].argsort()];
Thermo13[:,2]=Thermo13[:,2]*8.314
plt.plot(Thermo13[:,0],Thermo13[:,2])


plt.ion()
plt.figure()
plt.plot(FJ13[:,0],FJ13[:,1],'.b', lw=1)
plt.plot(xdata,funG3(xdata,A,B,C,D,F), '--k')
'''
