#---Date 2015-05-30 16:32

import itertools
import numpy as np
import matplotlib.lines as mlines
import matplotlib.pyplot as plt

PATHNAS='/nas/zendegani/Projects/Q/Calculations/9_imaginary/Q-TC/'
PATHLAP='/Users/firebird/Documents/Education/Projects/Q/9_imaginary/Q-TC/'
PATHcurrent=PATHLAP

T298=np.loadtxt(PATHcurrent+'Q21-0K/THREMO_298K_PBE_Qz');
T298=T298[T298[:,0].argsort()];
T900=np.loadtxt(PATHcurrent+'Q21-0K/THREMO_900K_PBE_Qz');
T900=T900[T900[:,0].argsort()];
T0=np.loadtxt(PATHcurrent+'xJfomula.txt');
T0=T0[T0[:,0].argsort()];

T298AR=np.loadtxt(PATHcurrent+'Q21-ActualRef/THREMO_298K_PBE_Qz');
T298AR=T298AR[T298AR[:,0].argsort()];
T900AR=np.loadtxt(PATHcurrent+'Q21-ActualRef/THREMO_900K_PBE_Qz');
T900AR=T900AR[T900AR[:,0].argsort()];


T298FR298=np.loadtxt(PATHcurrent+'Q21-Fixed298/THREMO_298K_PBE_Qz');
T298FR298=T298FR298[T298FR298[:,0].argsort()];
T900FR298=np.loadtxt(PATHcurrent+'Q21-Fixed298/THREMO_900K_PBE_Qz');
T900FR298=T900FR298[T900FR298[:,0].argsort()];

fig = plt.figure()
ax = fig.add_subplot(1,1,1)
plt.ion();

xmax=.572;
ymin=-1000;
ymax=200;
plt.xlim([0,xmax]);
plt.ylim([ymin,ymax]);
plt.xlabel('Al mole fraction');
plt.ylabel('Energies (kJ/per mole of formula)');
ax.xaxis.set_tick_params(width=3)
ax.yaxis.set_tick_params(width=3)
plt.grid(True)
font = {'family' : 'serif', 'weight' : 'bold', 'size' : 16}
plt.rc('font', **font)

#p0=ax.plot(T0[:,0],T0[:,1]/1000,'kv',mfc='None' , label="0K", markersize=10);
#p298=ax.plot(T298[:,0],T298[:,1]/1000,'k', label="298K");
#p900=ax.plot(T900[:,0],T900[:,1]/1000,'r', label="900K");

p0=ax.plot(T0[:,0],T0[:,1]/1000,'ro', label="0K DFT", markersize=10);

p298=ax.plot(T298[:,0],T298[:,1]/1000,'b', label="298K DFT+CEF", linewidth=3);
p298fr298=ax.plot(T298FR298[:,0],T298FR298[:,1]/1000,'g', label="298K Vib+CEF",linewidth=3);
#p298ar=ax.plot(T298AR[:,0],T298AR[:,1]/1000,'--k', label="298K (vib. FR)",linewidth=2);

p900=ax.plot(T900[:,0],T900[:,1]/1000,'k', label="900K DFT+CEF",linewidth=3);
p900fr298=ax.plot(T900FR298[:,0],T900FR298[:,1]/1000,'r', label="900K Vib+CEF",linewidth=3);
#p900ar=ax.plot(T900AR[:,0],T900AR[:,1]/1000,'k', label="900K (vib. FR)",linewidth=2);

ax.legend()
params = {'legend.fontsize': 'small'} #, 'legend.linewidth': 2}
ax.legend(loc='lower right')
plt.rcParams.update(params)

plt.show();


#name='CEF-0K'
#name='CEF-AR'
#name='CEF-FR298'

name='CEF-ene6'
plt.savefig(name+'.jpg', dpi=200, facecolor='w', edgecolor='w', transparent=False, orientation='landscape',format='jpg' )
plt.savefig(name+'.png', facecolor='none', edgecolor='w', transparent=True, orientation='landscape',format='png' )
plt.savefig(name+'.eps', facecolor='w', edgecolor='w', transparent=False, orientation='portrait',format='eps' )

'''
font={'Serif'}


matplotlib.rcParams.update({'font.size': 22})


ax.lines[2].remove()
ax.redraw_in_frame
plt.draw()

plt.xlabel('Volume $\AA^{3}$');
plt.xlabel('Distance $\AA$');
plt.title('Energy vs Volume');

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