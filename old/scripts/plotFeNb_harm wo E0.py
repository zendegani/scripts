# 2015.09.15

import numpy as np
import matplotlib.pyplot as plt


#------------------------ Path and loading Heat Capacities ------------------------

pathNAS='/nas/zendegani/Projects/FeNb/calc/'
path=pathNAS

pathUUDmin=path+'FM/C14WadaStrc/C14.UUDsym/21-finiteEDIFF6/thermo/thermo.out'
UUDmin=np.loadtxt(pathUUDmin)

pathDUDmin=path+'FM/C14WadaStrc/C14.DUD/20-finiteVol155.51/thermo/thermo.out'
pathDUD157=path+'FM/C14WadaStrc/C14.DUD/22-finiteVol157.32/thermo/thermo.out'
DUDmin=np.loadtxt(pathDUDmin)
DUD157=np.loadtxt(pathDUD157)

pathNMmin=path+'NM/C14WadaStrc/3-newFinite/2x2x1/1.00/thermo/thermo.out'
pathNM157=path+'NM/C14WadaStrc/30-finiteVol157.32/thermo/thermo.out'
NMmin=np.loadtxt(pathNMmin)
NM157=np.loadtxt(pathNM157)



#CvCEF3=CvCEF3[CvCEF3[:,0].argsort()];


#---------------- $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ ---------------------


meV2J = 96.490


# vol 157.32 angstrom^3
# 88.470667 bohrradius^3

Veq = 157.32

# UUD
# optimal volume V0 = 88.472203
# minimum energy E0 = -0.331973

UUDE0 = -9033.4446 # meV
# 88.483	-0.33197279
#-9033.4389 meV

# DUD
# optimal volume V0 = 87.456784
# minimum energy E0 = -0.332182

DUDV0 = 155.51
DUDE0 = -9039.1318 #meV
# 88.424	-0.33214636

DUDE157 = -9038.162 #meV

# NM
# optimal volume V0 = 86.213374
# minimum energy E0 = -0.331532

NMV0 = 153.30
NME0 = -9021.4444 #meV
# 88.468	-0.33129603

NME157 = -9015.0233 #meV


shift=UUDmin[0,1]+UUDE0
#------------------- Plotting ---------------
fig, ax = plt.subplots()
plt.title('$\mathrm{C14\ Fe}_2\mathrm{Nb}$')
plt.xlabel('T/K')
plt.ylabel('total free energy (hamonic) meV')
ax.grid(True)

plt.plot(NMmin[:,0]  ,NMmin[:,1], '--k', lw=1, label=r'$\mathrm{NM}\ V_{min}='+format(str(NMV0))+'\ \AA^3$')
plt.plot(DUDmin[:,0] ,DUDmin[:,1], '--r', lw=1, label=r'$\mathrm{DUD}\ V_{min}='+format(str(DUDV0))+'\ \AA^3$')
plt.plot(UUDmin[:,0] ,UUDmin[:,1], '-b', lw=2, label=r'$\mathrm{UUD}\ V_{min}='+format(str(Veq))+'\ \AA^3$')
plt.plot(NM157[:,0] ,NM157[:,1], '-k', lw=2, label=r'$\mathrm{NM}\ V='+format(str(Veq))+'\ \AA^3$')
plt.plot(DUD157[:,0],DUD157[:,1], '-r', lw=2, label=r'$\mathrm{DUD}\ V='+format(str(Veq))+'\ \AA^3$')


plt.ion()
plt.show()
plt.legend()

