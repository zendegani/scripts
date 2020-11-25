#2015-09-15


import itertools
import numpy as np
from scipy.integrate import simps, trapz, cumtrapz
import matplotlib
import matplotlib.lines as mlines
import matplotlib.pyplot as plt
import scipy.constants as sc

from mpl_toolkits.axes_grid1.inset_locator import inset_axes, zoomed_inset_axes, mark_inset
from mpl_toolkits.axes_grid1.anchored_artists import AnchoredSizeBar


path= "/nas/zendegani/Projects/FeNb/calc/"


p_E0_NM  = "NM/C14WadaStrc/1-murn/murn.dat"
p_E0_DUD = "FM/C14WadaStrc/C14.DUD/12-murn-EDIFF4-LAMBDA5/murn.dat"
p_E0_UUD = "FM/C14WadaStrc/C14.UUDsym/10-murn/murn.dat"


p_harm_NM  = "NM/C14WadaStrc/2-finite/2x2x1/1.00/thermo/thermo.out"
p_harm_DUD = "FM/C14WadaStrc/C14.DUD/20-finiteVol155.51/thermo/thermo.out"
p_harm_UUD = "FM/C14WadaStrc/C14.UUDsym/21-finiteEDIFF6/thermo/thermo.out"


f_NM  = np.loadtxt(path+p_harm_NM)
f_DUD = np.loadtxt(path+p_harm_DUD)
f_UUD = np.loadtxt(path+p_harm_UUD) 


E0_NM = -9021.4177 #meV
# E0 NM = -0.331531

E0_DUD = -9039.1323  #meV
# E0 DUD = -0.332182

E0_UUD = -9033.4451  #meV
# E0 UUD = -0.331973

fig, ax = plt.subplots()
plt.title('$C14\ Fe_2Nb$')
ax.plot(f_NM[:,0],E0_NM+f_NM[:,1], '--k' , lw=2, label='NM')
ax.plot(f_DUD[:,0],E0_DUD+f_DUD[:,1], 'r', lw=2, label='DUD')
ax.plot(f_UUD[:,0],E0_UUD+f_UUD[:,1],'b', lw=2,  label='UUD')
plt.legend(loc=2)
plt.xlabel('T/K')
plt.ylabel('total free energy (hamonic) meV (shifted)')
ax.grid(True)

axins = zoomed_inset_axes(ax, 10, loc=3)
#plt.xticks(visible=False)
#plt.yticks(visible=False)

axins.xaxis.tick_top()
axins.yaxis.tick_right()
axins.grid(True)
x1, x2, y1, y2 = 0., 100., -9010, -8980.
axins.set_xlim(x1, x2)
axins.set_ylim(y1, y2)

axins.plot(f_NM[:,0],E0_NM+f_NM[:,1], '--k' , lw=3, label='NM')
axins.plot(f_DUD[:,0],E0_DUD+f_DUD[:,1], 'r', lw=3,  label='DUD')
axins.plot(f_UUD[:,0],E0_UUD+f_UUD[:,1], 'b',  lw=3, label='UUD')

mark_inset(ax, axins, loc1=1, loc2=3, fc="none", ec="0.5") #,  bbox_to_anchor=(100, 100),bbox_transform=ax.figure.transFigure) )


axins2 = zoomed_inset_axes(ax, 3, loc=1)
#plt.xticks(visible=False)
#plt.yticks(visible=False)

axins2.xaxis.tick_top()
axins2.yaxis.tick_right()
axins2.grid(True)
x1, x2, y1, y2 = 1800., 2000., -10140, -10000.
axins2.set_xlim(x1, x2)
axins2.set_ylim(y1, y2)

axins2.plot(f_NM[:,0],E0_NM+f_NM[:,1], '--k' , lw=2, label='NM')
axins2.plot(f_DUD[:,0],E0_DUD+f_DUD[:,1], 'r', lw=2,  label='DUD')
axins2.plot(f_UUD[:,0],E0_UUD+f_UUD[:,1], 'b',  lw=2, label='UUD')

mark_inset(ax, axins2, loc1=1, loc2=3, fc="none", ec="0.5")


ax.get_yaxis().set_major_formatter(matplotlib.ticker.FuncFormatter(lambda x, p: format(int(x), ',')))
axins.get_yaxis().set_major_formatter(matplotlib.ticker.FuncFormatter(lambda x, p: format(int(x), ',')))
axins2.get_yaxis().set_major_formatter(matplotlib.ticker.FuncFormatter(lambda x, p: format(int(x), ',')))

plt.ion()
plt.draw()
plt.show()

name='Fe2Nb-C14-freeEne.jpg'
plt.savefig(name+'.jpg', dpi=150, facecolor='w', edgecolor='w', transparent=False, orientation='landscape',format='jpg' )

