#---Date 2015-05-30 18:28

import itertools
import numpy as np
import matplotlib.lines as mlines
import matplotlib.pyplot as plt


PATHNAS='/nas/zendegani/Projects/Q/Calculations/9_imaginary/Q-TC/'
PATHLAP='/Users/firebird/Documents/Education/Projects/Q/9_imaginary/Q-TC/'
PATHcurrent=PATHLAP

T=900
PATH=PATHcurrent+'Q21-0K/'
PATHact=PATHcurrent+'Q21-ActualRef/'
PATHfr298=PATHcurrent+'Q21-Fixed298/'

Tsublat=np.loadtxt(PATH+'Q_PBE_'+str(T)+'K_SOz');
Tsublat=Tsublat[Tsublat[:,0].argsort()];

Tsublatact=np.loadtxt(PATHact+'Q_PBE_'+str(T)+'K_SOz');
Tsublatact=Tsublatact[Tsublatact[:,0].argsort()];

Tsublatfr298=np.loadtxt(PATHfr298+'Q_PBE_'+str(T)+'K_SOz');
Tsublatfr298=Tsublatfr298[Tsublatfr298[:,0].argsort()];

LABEL=['3M1', '3M2', '3M3', '3M4', '3M1 vibF', '3M2 vibF', '3M3 vibF', '3M4 vibF', '3M1 vibA', '3M2 vibA', '3M3 vibA', '3M4 vibA']
COLOR=['--k', '--r', '--g', '--b', 'k', 'r', 'g', 'b', '.k', '.r', '.g', '.b']
COLOR=[ 'k', 'r', 'g', 'b', '--k', '--r', '--g', '--b','.k', '.r', '.g', '.b']
COLOR=[ 'k', 'r', 'g', 'b', '--k', '--r', '--g', '--b','.k', '.r', '.g', '.b']

#COLOR=['k', 'r', 'g', 'b']

fig = plt.figure()
ax = fig.add_subplot(1,1,1)
plt.ion();
xmax=.572;
plt.xlim([0,xmax]);

plt.xlabel('Al mole fraction');
plt.ylabel('Al site occupancy');
ax.xaxis.set_tick_params(width=3)
ax.yaxis.set_tick_params(width=3)
plt.grid(True)
font = {'family' : 'serif', 'weight' : 'bold', 'size' : 16}
plt.rc('font', **font)
#plt.title('Sublattice occupation at T='+str(T)+'K');


for i in range(4):
  pTsublat=ax.plot(Tsublat[:,0],Tsublat[:,i+1], COLOR[i], label=LABEL[i], linewidth=3)
  pTsublatfr298=ax.plot(Tsublatfr298[:,0],Tsublatfr298[:,i+1], COLOR[i+4], label=LABEL[i+4], linewidth=3)
#  pTsublatact=ax.plot(Tsublatact[:,0],Tsublatact[:,i+1], COLOR[i+8], label=LABEL[i+8])


ax.legend()
params = {'legend.fontsize': 'small'} #, 'legend.linewidth': 2}
ax.legend(loc='lower right')
plt.rcParams.update(params)

plt.show();

p = plt.axvspan(3./21, 6./21, facecolor='g', alpha=0.5)
ax.fill_between(Tsublatfr298[:,0], Tsublatfr298[:,2], Tsublat[:,2], facecolor='blue', alpha=0.5)

name='CEFsublat-'+str(T)+'-vibAcFx'

name='FE2'
plt.savefig(name+'.jpg', dpi=200, facecolor='w', edgecolor='w', transparent=False, orientation='landscape',format='jpg' )
plt.savefig(name+'.eps', facecolor='w', edgecolor='w', transparent=False, orientation='portrait',format='eps' )

plt.savefig(name+'.png', facecolor='none', edgecolor='w', transparent=True, orientation='landscape',format='png' )


#name='CEF-0K'
#name='CEF-AR'
#name='CEF-FR298'

'''
font={'Serif'}


matplotlib.rcParams.update({'font.size': 22})


ax.lines[2].remove()
ax.redraw_in_frame
plt.draw()

plt.xlabel('Volume $\AA^{3}$');
plt.xlabel('Distance $\AA$');

quadrumers=['Linear','Square','Rhombus','Tetrahedron']
plt.legend(quadrumers);

font = {'family' : 'normal',
        'weight' : 'bold',
        'size'   : 22}

matplotlib.rc('font', **font)


'-' | '--' | '-.' | ':' | 'None' | ' ' | ''



        family: A list of font names in decreasing order of priority. The items may include a generic font family name, either ‘serif’, ‘sans-serif’, ‘cursive’, ‘fantasy’, or ‘monospace’. In that case, the actual font to be used will be looked up from the associated rcParam in matplotlibrc.
        style: Either ‘normal’, ‘italic’ or ‘oblique’.
        variant: Either ‘normal’ or ‘small-caps’.
        stretch: A numeric value in the range 0-1000 or one of ‘ultra-condensed’, ‘extra-condensed’, ‘condensed’, ‘semi-condensed’, ‘normal’, ‘semi-expanded’, ‘expanded’, ‘extra-expanded’ or ‘ultra-expanded’
        weight: A numeric value in the range 0-1000 or one of ‘ultralight’, ‘light’, ‘normal’, ‘regular’, ‘book’, ‘medium’, ‘roman’, ‘semibold’, ‘demibold’, ‘demi’, ‘bold’, ‘heavy’, ‘extra bold’, ‘black’
        size: Either an relative value of ‘xx-small’, ‘x-small’, ‘small’, ‘medium’, ‘large’, ‘x-large’, ‘xx-large’ or an absolute font size, e.g., 12

The default font property for TrueType fonts (as specified in the default matplotlibrc file) is:

sans-serif, normal, normal, normal, normal, scalable.
family = ['serif', 'sans-serif', 'cursive', 'fantasy', 'monospace']


'''