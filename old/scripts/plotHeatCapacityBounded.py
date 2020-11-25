#!/usr/bin/env python

#-- Date 2015.06.30

import itertools
import numpy as np
import matplotlib.lines as mlines
import matplotlib.pyplot as plt
import scipy.constants as sc

from mpl_toolkits.axes_grid1.inset_locator import mark_inset
from mpl_toolkits.axes_grid1.inset_locator import zoomed_inset_axes

#------------------------ Path and loading ------------------------

PATHNAS='/nas/zendegani/Projects/Q/Calculations/'
PATHLAP='/Users/firebird/Documents/Education/Projects/Q/'
PATHcurrent=PATHNAS
pathPhononPre=PATHcurrent+'9_imaginary/DATA/Q-Al-Mg/'
templatePhonon='#[1-16]'
pathPhononPost='/finite/thermo/thermo.out'

pathCEFCV=PATHcurrent+'9_imaginary/Q-TC/CP-SO-Q21-Fixed298/'
templateCEFCV='Q_PBE_FixedRef298_CP_Al__#[.1-9]'

pathh=PATHcurrent+'7-CP-Q-experimental/Electronic/q/output_0.0001GPa/heat_capacity_isochoric'
pathqh=PATHcurrent+'7-CP-Q-experimental/Electronic/q/output_0.0001GPa/heat_capacity_isobaric'
pathqe=PATHcurrent+'7-CP-Q-experimental/Electronic/qe/output_0.0001GPa/heat_capacity_isobaric'
pathExp=PATHcurrent+'7-CP-Q-experimental/MeasuredCp'
pathCalphad2012=PATHcurrent+'7-CP-Q-experimental/CalphadCp2012real.txt'
#pathCEF3=PATHcurrent+'9_imaginary/Q-TC/CP-SO-Q21-Fixed298/Q_PBE_FixedRef298_CP_Al__3'

pathCEF3=PATHcurrent+'9_imaginary/Q-TC/CP-SO-Q21-Fixed298-1000/Q_PBE_FixedRef298_CP_Al__3'
pathCEF0K3=PATHcurrent+'9_imaginary/Q-TC/CP-SO-Q21-0K/Q_PBE_0K_CP_Al3'
#/nas/zendegani/Projects/Q/Calculations/7-CP-Q-experimental/cpFixedRef298.txt

CVQ2=np.loadtxt(pathh)                  #harmonic
CPQ2=np.loadtxt(pathqh)                 #quasi-harmonic
CeQ2=np.loadtxt(pathqe)                 #electronic
CpEXP=np.loadtxt(pathExp)               #experimental

CvCEF3=np.loadtxt(pathCEF3)             #CEF
CvCEF3=CvCEF3[CvCEF3[:,0].argsort()];
CvCEF0K3=np.loadtxt(pathCEF0K3)
CvCEF0K3=CvCEF0K3[CvCEF0K3[:,0].argsort()];

CpCalphad=np.loadtxt(pathCalphad2012)   #Calphad 2012

path2000='/nas/zendegani/Projects/Q/Report/Paper/Re_paper_Q-Phase/Qupto2000.txt'
Cp2k=np.loadtxt(path2000,skiprows=1)

nEndMem=16
Cv=[]
for n in range(nEndMem):
  Cv.append(np.loadtxt(pathPhononPre+str(n+1)+pathPhononPost))

Trange=len(Cv[0])
CvMin=np.zeros((Trange,2))
CvMin[:,0]=range(Trange)
CvMax=np.zeros((Trange,2))
CvMax[:,0]=range(Trange)

for T in range(Trange):
  CvMin[T,1]=min([Cv[i][T,2] for i in range(nEndMem)])
  CvMax[T,1]=max([Cv[i][T,2] for i in range(nEndMem)])



#------------------------ Fitting ------------------------

fittingDeg=15;
filename=PATHcurrent+'9_imaginary/DATA/FreeEneHarmonic/F_J_FixRef_Formula298.13'
dat = np.loadtxt(filename);
fit=np.poly1d(np.polyfit(dat[:, 0], dat[:, 1]/21,fittingDeg))
t=range(1000)
Q13=-np.polyder(fit,2)(t)*t

#------------------------ Delta ------------------------


ii=np.nonzero(CvCEF3[:,0]==1000)
CvCEF3=CvCEF3[0:ii[0][0]+1,:]

TrangeDelta=len(CvCEF3)
CDelQH=np.zeros((TrangeDelta,2))
CDelQH[:,0]=CvCEF3[:,0]
CDelElec=np.zeros((TrangeDelta,2))
CDelElec[:,0]=CvCEF3[:,0]
CDelConf=np.zeros((TrangeDelta,2))
CDelConf[:,0]=CvCEF3[:,0]
Ctotal=np.zeros((TrangeDelta,2))
Ctotal[:,0]=CvCEF3[:,0]

Ts=int(CvCEF3[0,0])
Tf=int(CvCEF3[-1,0])
for T in range(TrangeDelta-1):
  CDelQH[T,1]=CPQ2[T+Ts,1]-CVQ2[T+Ts,1]
  CDelElec[T,1]=CeQ2[T+Ts,1]-CPQ2[T+Ts,1]
  CDelConf[T,1]=CvCEF3[T,1]-Q13[T+Ts]
  Ctotal[T,1]=CeQ2[T+Ts,1]*sc.R+CDelConf[T,1]


plt.plot(range(len(Q13)),Q13)
plt.plot(CvCEF3[:,0],CvCEF3[:,1])
plt.plot(CDelConf[:,0],CDelConf[:,1])
plt.ion()
plt.show()

#------------------------ Plot ------------------------

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
ax.fill_between(Ctotal[:900,0],CeQ2[Ts:Tf+1,1]*sc.R ,Ctotal[:900,1], edgecolor='none', facecolor=c4, alpha=.5)

pCVQ2=ax.plot(CVQ2[:900,0],CVQ2[:900,1]*sc.R, c1, lw=1, label='harmonic', alpha=.5) # color='0.8')
pCPQ2=ax.plot(CPQ2[:900,0],CPQ2[:900,1]*sc.R, c2, lw=1, label='quasi-harmonic', alpha=.5) #color='0.8')
pCeQ2=ax.plot(CeQ2[:900,0],CeQ2[:900,1]*sc.R, c3 , lw=1, label='qh+electronic', alpha=.5)

pCtotal=ax.plot(Ctotal[:,0],Ctotal[:,1], c4, ls='-', lw=2, label='First-principle [this work] qh+el+conf')
plt.plot(Cp2k[:,0],Cp2k[:,3], '--r', lw=4, label='Calphad [this work]') #, alpha=.7
pCpCalphad=ax.plot(CpCalphad[:,0],CpCalphad[:,1], '-k' , lw=2, label='Calphad [2012Loe]')

ax.plot(label='test')
pCExp1=ax.plot(CpEXP[:,0],CpEXP[:,1] , '^k', markersize=11, fillstyle='full', markerfacecoloralt='white', c='white', label='1st run')
pCExp2=ax.plot(CpEXP[:,0],CpEXP[:,2] , 'vk', markersize=11, fillstyle='full', markerfacecoloralt='white', c='white', label='2nd run')
#pCExp1=ax.plot(CpEXP[:,0],CpEXP[:,1] , '-k', label='1st run')
#pCExp1=ax.plot(CpEXP[:,0],CpEXP[:,2] , '--k', label='2nd run')
#ax.plot(CvMin[:,0],CvMin[:,1]*sc.R, c='.8', ls='-', lw=3, label='Ab initio C$_v$s Min')
#ax.plot(CvMax[:,0],CvMax[:,1]*sc.R, c='.8', ls='-', lw=3, label='Ab initio C$_v$s Max')

legend = ax.legend(loc='lower right', shadow=False)
#frame = legend.get_frame()
#frame.set_facecolor('0.90')
#legend.draw_frame(False)

legend.params = {'legend.fontsize': 'xx-small'} #, 'legend.linewidth': 2}
legend.params = {'mathtext.default': 'regular' }
plt.rcParams.update(legend.params)

size=12
ax.text(840, 20, "harmonic", ha="center", va="center", size=size)
ax.text(840, 26, "quasi-harmonic", ha="center", va="center", size=size)
ax.text(840, 27.7, "electronic", ha="center", va="center", size=size, rotation=9)
ax.text(840, 28.9, "configurational", ha="center", va="center", size=size, rotation=14)

############################## ZOOM

axins = zoomed_inset_axes(ax, 2, loc=8)
axins.set_xlim(200,900)
axins.set_ylim(22,31)
axins.xaxis.tick_top()
axins.yaxis.tick_right()

axins.plot(Ctotal[:900,0],Ctotal[:900,1], 'b', lw=4, label='First-principle [this work] qH+e+conf')
axins.plot(cp[:,0],cp[:,3], 'y', lw=3, alpha=.7, label='Calphad [this work]')
axins.plot(CpCalphad[:,0],CpCalphad[:,1], '--r' , lw=3, label='Calphad [2012Loe]')
axins.plot(CpEXP[:,0],CpEXP[:,1] , '^k', markersize=11, fillstyle='full', markerfacecoloralt='white', c='white', label='1st run')
axins.plot(CpEXP[:,0],CpEXP[:,2] , 'vk', markersize=11, fillstyle='full', markerfacecoloralt='white', c='white', label='2nd run')
axins.plot(CVQ2[:900,0],CVQ2[:900,1]*sc.R, '-.y', lw=2, label='harmonic') # color='0.8')
axins.plot(CPQ2[:900,0],CPQ2[:900,1]*sc.R, '-.g', lw=2, label='quasi-harmonic') #color='0.8')
axins.plot(CeQ2[:900,0],CeQ2[:900,1]*sc.R, ',-.r' , lw=2, label='qH+electronic')

mark_inset(ax, axins, loc1=3, loc2=1, fc="none", ec="0.5")
#plt.xticks(visible=False)
#plt.yticks(visible=False)


plt.ion()
plt.show()


ax.text(840, 15, "harmonic", ha="center", va="center", size=15)
ax.text(840, 26, "quasi-harmonic", ha="center", va="center", size=15)
ax.text(840, 27.8, "electronic", ha="center", va="center", size=15, rotation=11)
ax.text(840, 28.9, "configurational", ha="center", va="center", size=15, rotation=14)

pCvCEF3=ax.plot(CvCEF3[:,0],CvCEF3[:,1], color='r', lw=3, label='$CEF-harmonic \ Al_6Cu_4Mg_{18}Si_{14}$')
pCvCEF0K3=ax.plot(CvCEF0K3[:,0],CvCEF0K3[:,1], color='b', lw=3, label='$CEF-0K \ Al_6Cu_4Mg_{18}Si_{14}$')
pCpQ13=ax.plot(t,Q13, color='k', label='Q13')
pCDelConf=ax.plot(CDelConf[:,0],CDelConf[:,1],'g' ,lw=3 ,label='Delta CEF Q13')
#pCDeltaQHCEF3=ax.plot(CvCEF3[:,0],CvCEF3[:,1]+CDelQH[:,1]*sc.R, 'k' ,lw=3 ,label='qH-Delta + CEF')
#pCDeltaQHCEF3=ax.plot(CvCEF3[:,0],CvCEF3[:,1]+(CDelQH[:,1]+CDelElec[:,1])*sc.R, 'r' ,lw=3 ,label='e-qH-Delta + CEF')

p = plt.axvspan(900, 1000, facecolor='k', edgecolor='none', alpha=0.1)
p = plt.axvspan(703+273, 707+273, facecolor='b', edgecolor='none', alpha=0.5)


name='HeatCapacityConfigurational_6'
plt.savefig(name+'.jpg', dpi=200, facecolor='w', edgecolor='w', transparent=False, orientation='landscape',format='jpg' )


np.savetxt('HeatCapacityTotal2.txt',Ctotal)



def G_Q(T):
 return -26450+150.3299070*T-26.2975036*T*np.log(T)-.0023266157*T**2+96177.2212*T**-1-1.745888853e-6*T**3

def G_Q1001(T):
 return -47422.1991+264.37234*T-40.2772*T*np.log(T)+4175000*T**-1


def G_AL(T):       #SGTE 
    return -7976.15+137.093038*T-24.3671976*T*np.log(T)-1.884662e-3*T**2-0.877664e-6*T**3+74092*T**-1
    
x=1
for n in range(nEndMem):

x=13
for n in range(4):
  color = colors.next()
  linestyle = lineStyles.next()
  ax.plot(Cv[n+x-1][:,0],Cv[n+x-1][:,2]*sc.R, c=color, ls=linestyle, label=str(n+x))













ax.legend()
params = {'legend.fontsize': 'small'} #, 'legend.linewidth': 2}
ax.legend(loc='lower right')
params = {'mathtext.default': 'regular' }          
plt.rcParams.update(params)
plt.show()

# Remove the plot frame lines. They are unnecessary chartjunk.  
ax.spines["top"].set_visible(False)  
ax.spines["bottom"].set_visible(False)  
ax.spines["right"].set_visible(False)  
ax.spines["left"].set_visible(False)

name='HeatCapacityAll'
plt.savefig(name+'.jpg', dpi=150, facecolor='w', edgecolor='w', transparent=False, orientation='landscape',format='jpg' )
plt.savefig(name+'.png', facecolor='none', edgecolor='w', transparent=True, orientation='landscape',format='png' )
plt.savefig(name+'.eps', facecolor='w', edgecolor='w', transparent=False, orientation='portrait',format='eps' )


'''
t = ax.text(0, 0, "Direction", ha="center", va="center", rotation=45,
            size=15,
            bbox=bbox_props)
ax.annotate('local max', xy=(2, 1), xytext=(3, 1.5),
            arrowprops=dict(facecolor='black', shrink=0.05),
            )


print ax.lines[0]
id(ax.lines)
#THIS REMOVES THE FIRST LINE:
ax.lines.pop(0)
ax.lines.remove()

plt.text(CpEXP[:,0],CpEXP[:,2], u'\u2B21', fontname='STIXGeneral', size=30, va='center', ha='center', clip_on=True)
u'\u25EC'
u'\u2B21'


ax.annotate('electronic', xy=(810, 27), xytext=(800, 30), ha="center", va="center", size=15, 
             arrowprops=dict(facecolor='black', width=1, shrink=.01))


'best'         : 0, (only implemented for axis legends)
'upper right'  : 1,
'upper left'   : 2,
'lower left'   : 3,
'lower right'  : 4,
'right'        : 5,
'center left'  : 6,
'center right' : 7,
'lower center' : 8,
'upper center' : 9,
'center'       : 10,
'''