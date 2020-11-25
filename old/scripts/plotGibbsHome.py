#---Date 2015-09-01

import itertools
import numpy as np
from scipy.integrate import simps, trapz, cumtrapz
import matplotlib.lines as mlines
import matplotlib.pyplot as plt
import scipy.constants as sc


#------------------------ Path and loading Heat Capacities ------------------------
#/nas/zendegani/Projects/Q/Calculations/7-CP-Q-experimental/

PATHNAS='/nas/zendegani/Projects/Q/Calculations/9_imaginary/Q-TC/'
PATHLAP='/Users/firebird/Documents/Education/Projects/Q/9_imaginary/Q-TC/'
PATHcurrent=PATHNAS

path7cp='/Users/firebird/Documents/Education/Projects/Q/7-CP-Q-experimental/'
path9imag='/Users/firebird/Documents/Education/Projects/Q/9_imaginary/'
path7cp='/nas/zendegani/Projects/Q/Calculations/7-CP-Q-experimental/'
path9imag='/nas/zendegani/Projects/Q/Calculations/9_imaginary/'

pathPhononPre =path9imag+'DATA/Q-Al-Mg/'
templatePhonon='#[1-16]'
pathPhononPost='/finite/thermo/thermo.out'

pathCEFCV='/nas/zendegani/Projects/Q/Calculations/9_imaginary/Q-TC/CP-SO-Q21-Fixed298/'
templateCEFCV='Q_PBE_FixedRef298_CP_Al__#[.1-9]'

pathh=path7cp+"Electronic/q/output_0.0001GPa/heat_capacity_isochoric"
pathqh=path7cp+"Electronic/q/output_0.0001GPa/heat_capacity_isobaric"
pathqe=path7cp+"Electronic/qe/output_0.0001GPa/heat_capacity_isobaric"
pathExp=path7cp+"MeasuredCp"
pathCEF3=PATHcurrent+"CP-SO-Q21-Fixed298-1000/Q_PBE_FixedRef298_CP_Al__3"
#pathCEF3=PATHcurrent+"CP-SO-Q21-Fixed298/Q_PBE_FixedRef298_CP_Al__3"

pathCEF0K3=path9imag+"Q-TC/CP-SO-Q21-0K/Q_PBE_0K_CP_Al3"

CV13to16=np.loadtxt(PATHcurrent+'Cp13to16vsFull/13to16')
CV13to16=CV13to16[CV13to16[:,0].argsort()];
CVleft=np.loadtxt(PATHcurrent+'Cp13to16vsFull/left')
CVleft=CVleft[CVleft[:,0].argsort()];
plt.plot(CV13to16[:,0],CV13to16[:,1])
plt.plot(CVleft[:,0],CVleft[:,1])

CVQ2=np.loadtxt(pathh)
CPQ2=np.loadtxt(pathqh)
CeQ2=np.loadtxt(pathqe)
CpEXP=np.loadtxt(pathExp)
CvCEF3=np.loadtxt(pathCEF3)
CvCEF3=CvCEF3[CvCEF3[:,0].argsort()];
plt.plot(CvCEF3[:,0],CvCEF3[:,1])
cut=np.nonzero(CvCEF3==1000)[0][0]
CvCEF3=CvCEF3[:cut+1]
CvCEF0K3=np.loadtxt(pathCEF0K3)
CvCEF0K3=CvCEF0K3[CvCEF0K3[:,0].argsort()];

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


#------------------------ $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ ------------------------


meV2J = 96.490

elements=['al','cu','mg','si']

elCoef=[7,4,19,12]

elG0=[-3698.27826710396,
      -3689.27900239502,
      -1511.21885995564,
      -5365.002840347482]

elGRT=[-3739.51699764907,
       -3742.0071426626 ,
       -1560.61599337307,
       -5391.168332853127]

PathGq=path7cp+"Electronic/q/output_0.0001GPa/Gibbs_energy"
Gq=np.loadtxt(PathGq)
plt.plot(Gq[:,0],Gq[:,1]-Gq[0,1])
#plt.plot(Gq[:,0],Gq[:,1])


PathGqe=path7cp+"Electronic/qe/output_0.0001GPa/Gibbs_energy"
Gqe=np.loadtxt(PathGqe)
plt.plot(Gqe[:,0],Gqe[:,1]-Gqe[0,1])
#plt.plot(Gqe[:,0],Gqe[:,1])

#------------------- Gibbs Q13 vs CEF(al=3) ----------- Configurational contribution ----

PathGcef3=path7cp+"G-Q21-Fixed298/Q_PBE_G_Al3-cleaned"
Gcef3=np.loadtxt(PathGcef3)
Gcef3=Gcef3[Gcef3[:,0].argsort()];
plt.figure()
plt.plot(Gcef3[:,0],Gcef3[:,1]/1000)

PathGQ13=path9imag+"DATA/FreeEneHarmonic/F_J_FixRef_Formula298.13"
GQ13=np.loadtxt(PathGQ13)
plt.plot(GQ13[:,0],GQ13[:,1]/21./1000.)

#------------------------ Fitting Q13 -------Harmonic Ene-----------------
plt.figure()
fittingDeg=15;
filename=PathGQ13
dat = np.loadtxt(filename);
fit=np.poly1d(np.polyfit(dat[:, 0], dat[:, 1]/21,fittingDeg))
Trange=1000
t=range(Trange)
GQ13fit=np.zeros((Trange,2));
GQ13fit[:,0]=range(len(GQ13fit));
GQ13fit[:,1]=fit(t)

Qdat=[]
Qfit=[]
Qpath=[]
QGfit=[]
for j in range(16):
    i=j
    Qpath.append(path9imag+"DATA/FreeEneHarmonic/F_J_FixRef_Formula298."+str(j+1))
    Qdat.append(np.loadtxt(Qpath[i]))
    Qfit.append(np.poly1d(np.polyfit(Qdat[i][:, 0], Qdat[i][:, 1]/21,fittingDeg)))
    QGfit.append(np.zeros((Trange,2)))
    QGfit[i][:,0]=range(len(QGfit[i]))
    QGfit[i][:,1]=Qfit[i](t)
    plt.plot(QGfit[i][:,0],QGfit[i][:,1]/1000.)

plt.plot(GQ13fit[:,0],GQ13fit[:,1]/1000.)

#------------------------ Fitting Q13 --------Cv---- Derivative of Energy------------
plt.figure()
CvQ13fit=-np.polyder(fit,2)(t)*t
plt.plot(t,CvQ13fit)

QCvfit=[]
for i in range(16):
   QCvfit.append(-np.polyder(Qfit[i],2)(t)*t)
   plt.plot(t,QCvfit[i]+i)
#------------------------ Fitting Q13 --------Energy ---- Integration of Cv------------

d1=-cumtrapz(CvQ13fit[1:]/t[1:],t[1:])
plt.plot(t[1:-1],d1)
d2=cumtrapz(d1,t[2:])
plt.plot(t[2:-1],(d2+GQ13fit[0,1])/1000)
d22=cumtrapz(d1,t[1:-1])
plt.plot(t[1:-2],(d22+GQ13fit[0,1])/1000)

#------------------------ Gibbs delta --------- Configurational contribution ---------------

GdeltaConf=np.zeros((len(Gcef3),2))
for i in range(len(Gcef3)):
  GdeltaConf[i,0]=Gcef3[i,0]
  GdeltaConf[i,1]=Gcef3[i,1]-GQ13fit[np.nonzero(GQ13fit[:,0]==Gcef3[i,0]),1]

ax.plot(GdeltaConf[:,0],GdeltaConf[:,1]/1000,'r',label='Configurational contribution')

#ConfDer2=-np.diff(GdeltaConf[:,1],2)*GdeltaConf[2:,0]
#plt.plot(GdeltaConf[2:,0],ConfDer2)

plt.title('Contributions of Gibbs energy')


lGeq=len(Gqe)
GdeltaElec=np.zeros((lGeq,2))
for i in range(lGeq):
  GdeltaElec[i,0]=Gqe[i,0]
  GdeltaElec[i,1]=Gqe[i,1]-Gq[np.nonzero(Gq[:,0]==Gqe[i,0]),1]

GdeltaElec[:,1]*=meV2J
ax.plot(GdeltaElec[:,0],GdeltaElec[:,1]/1000,'k',label='Electronic contribution')


#------------------- Fixed Ref ---------------
TCutoff=901
GqFxRef0=Gq[:TCutoff].copy()
GqFxRef0[:,1]=(GqFxRef0[:,1]*sum(elCoef)-sum(elG0[el]*elCoef[el] for el in range(len(elements))))/float(sum(elCoef))
GqFxRef0[:,1]=GqFxRef0[:,1]*meV2J

GqFxRefR=Gq[:TCutoff].copy()
GqFxRefR[:,1]=(GqFxRefR[:,1]*sum(elCoef)-sum(elGRT[el]*elCoef[el] for el in range(len(elements))))/float(sum(elCoef))
GqFxRefR[:,1]=GqFxRefR[:,1]*meV2J


GqeFxRef0=Gqe[:TCutoff].copy()
GqeFxRef0[:,1]=(GqeFxRef0[:,1]*sum(elCoef)-sum(elG0[el]*elCoef[el] for el in range(len(elements))))/float(sum(elCoef))
GqeFxRef0[:,1]=GqeFxRef0[:,1]*meV2J

GqeFxRefR=Gqe[:TCutoff].copy()
GqeFxRefR[:,1]=(GqeFxRefR[:,1]*sum(elCoef)-sum(elGRT[el]*elCoef[el] for el in range(len(elements))))/float(sum(elCoef))
GqeFxRefR[:,1]=GqeFxRefR[:,1]*meV2J

#plt.plot(GqFxRef0[:,0],GqFxRef0[:,1]/1000.)
#plt.plot(GqFxRefR[:,0],GqFxRefR[:,1]/1000.)
#plt.plot(GqeFxRefR[:,0],GqeFxRefR[:,1]/1000.)
#plt.plot(GqeFxRef0[:,0],GqeFxRef0[:,1]/1000.)


#------------------- Actual Ref ---------------

Trange=1000;
GacRef=np.zeros((Trange,2));
GacRef[:,0]=range(len(GacRef));
i=0
for T in range(Trange):
    if T in Gq[:,0]:
        if all(T in G[:,0] for G in elG):
            GacRef[T,1]=Gq[np.nonzero(Gq[:,0]==T),1]*sum(elCoef)
            tmp=0
            for el in range(len(elements)):
                tmp+=elG[el][np.nonzero(elG[el][:,0]==T),1]*elCoef[el]
        #            print GacRef[T,1], tmp
        
            GacRef[T,1]-=tmp
            #   print GacRef[T,1]
            
            GacRef[T,1]/=float(sum(elCoef))

GacRef[:,1]*=meV2J
GacRefNEW=GacRef[GacRef[:,1] != 0].copy()


#------------------------ Delta Heat capacity------------------------
plt.figure()
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
for T in range(TrangeDelta-2):
  CDelQH[T,1]=CPQ2[T+Ts,1]-CVQ2[T+Ts,1]
  CDelElec[T,1]=CeQ2[T+Ts,1]-CPQ2[T+Ts,1]
  CDelConf[T,1]=CvCEF3[T,1]-CvQ13fit[T+Ts]
  Ctotal[T,1]=CeQ2[T+Ts,1]*sc.R+CDelConf[T,1]

QCpDeltaConf=[]
for j in range(12,16):
    i=j-12
    QCpDeltaConf.append(np.zeros((TrangeDelta,2)))
    QCpDeltaConf[i][:,0]=CvCEF3[:,0]
    for T in range(TrangeDelta-2):
        QCpDeltaConf[i][T,1]=CvCEF3[T,1]-QCvfit[j][T+Ts]
    plt.plot(QCpDeltaConf[i][:,0],QCpDeltaConf[i][:,1])


#-----------------------------Energy ---- Integration of Delat Cv------------

Detlad1=-cumtrapz(CDelConf[:,1]/CDelConf[:,0],CDelConf[:,0])
plt.plot(CDelConf[1:,0],Detlad1)
Detlad2=cumtrapz(Detlad1,CDelConf[1:,0])
plt.plot(CDelConf[1:-1,0],Detlad2/1000)



#------------------- Gibbs total (FixedRef298 + Configurational) ---------------

Gtotal=np.zeros((len(GqFxRefR),2))
Gtotal[:,0]=GqFxRefR[:,0]
for T in range(len(GqFxRefR)):
  if T in GdeltaConf[:,0]:
    Gtotal[T,1]=GqFxRefR[T,1]+GdeltaConf[np.nonzero(GdeltaConf[:,0]==T),1]
  else:
      Gtotal[T,1]=GqFxRefR[T,1]


Gtotal2=np.zeros((len(Gtotal[1:,1]),2))
Gtotal2[:,0]=Gtotal[1:,0]
Gtotal2[:,1]=Gtotal[1:,1]+GdeltaElec[:900,1]

np.savetxt('GibbsTotal2.txt',Gtotal2)


Gtotalqe=np.zeros((len(GqeFxRefR),2))
Gtotalqe[:,0]=GqeFxRefR[:,0]
for T in range(len(GqeFxRefR)):
    if T in GdeltaConf[:,0]:
      Gtotalqe[T,1]=GqeFxRefR[T,1]+GdeltaConf[np.nonzero(GdeltaConf[:,0]==T),1]
    else:
            Gtotalqe[T,1]=GqeFxRefR[T,1]



#------------------- Plotting Fixed & Actual & Total ---------------

#plt.plot(GQ13fit[:,0],(GQ13fit[:,1]-(GQ13fit[0,1]-GqFxRefR[0,1]))/1000)

plt.plot(GqFxRefR[:,0],GqFxRefR[:,1]/1000.)
ax.plot(Gtotal[:,0],Gtotal[:,1]/1000.,'k',label='Gibbs energy')
ax.plot(GacRefNEW[:,0],GacRefNEW[:,1]/1000.,'r',label='Free energy of formation')
plt.axis([0,900,-40,-5])
plt.title('$Al_7Cu_4Mg_{19}Si_{12}$ at.')
  
np.savetxt('GibbsTotal.txt',Gtotal)
np.savetxt('Formation.txt',GacRefNEW)

#------------------- G function 2015 ---------------

def GexpFun(T):
  return -24940+(134.1431294*T)-(23.7764600*T*np.log(T))-(0.0021276593*T**2)+(72407.3715*T**-1)-(7.89463389e-9*T**3)

T=np.linspace(423,673,673-423+1)
Gexp=GexpFun(T)
plt.plot(T,Gexp/1000,label='CALPHAD $Al_{17}Cu_9Mg_{45}Si_{29}$ wt.%')
delta=Gexp[0]-Gq[int(T[0])-1][1]


#------------------- G function 2012 ---------------

RHS=sum(elGRT[el]*elCoef[el] for el in range(len(elements)))*meV2J/float(sum(elCoef))
def GexpFun2012(T):
    return -45380+(23.6*T)-RHS

GexpFun2012=GexpFun2012(T)
plt.plot(T,GexpFun2012/1000,label='CALPHAD 2012 $Al_{17}Cu_9Mg_{45}Si_{29}$ wt.%')


#------------------- Plotting ---------------

fig = plt.figure()
ax = fig.add_subplot(1,1,1)
plt.ion()
plt.xlabel('T (K)');
plt.ylabel('Energy kJ/mole');
plt.title('Reference energies for Ab initio are taken at T=298K \n Ab initio result shifted to compare slopes')

plt.grid(False)
font = {'family' : 'serif', 'weight' : 'normal', 'size' : 14}
plt.rc('font', **font)

pGcalphad=ax.plot(T,Gexp/1000, 'k',label='CALPHAD $Al_{17}Cu_9Mg_{45}Si_{29}$ wt.%')
pGqDFT  =ax.plot(Gq[:,0],Gq[:,1]/1000, 'b',label='qH $Al_7Cu_4Mg_{19}Si_{12}$ at.')
pGqeDFT =ax.plot(Gqe[:,0],Gqe[:,1]/1000, 'r',label='qH+e $Al_7Cu_4Mg_{19}Si_{12}$ at.')
pGqDFT =ax.plot(Gq[:,0],(Gq[:,1]+delta)/1000, 'b',label='$quasi-Harmonic\ Al_7Cu_4Mg_{19}Si_{12}$ at.')
pGqeDFT=ax.plot(Gqe[:,0],(Gqe[:,1]+delta)/1000, 'r',label='$qH + electronic\ Al_7Cu_4Mg_{19}Si_{12}$ at.')

ax.legend()
params = {'legend.fontsize': 'xx-small'} #, 'legend.linewidth': 2}
ax.legend(loc='best')
params = {'mathtext.default': 'regular' }          
plt.rcParams.update(params)

plt.show()

name='GibbsEnergyShifted'
plt.savefig(name+'.jpg', dpi=150, facecolor='w', edgecolor='w', transparent=False, orientation='landscape',format='jpg' )

name='FreeEnergyOfFormation'


plt.title('Reference energies for Ab initio are taken at T=298K \n Ab initio result shifted to compare slopes')
#plt.title('Reference energies are taken at T=298K')
