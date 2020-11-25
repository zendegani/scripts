import numpy as np
import matplotlib.pyplot as plt
import scipy.optimize as optimization


path='/nas/zendegani/Projects/Q/Calculations/9_imaginary/DATA/FreeEneHarmonic/F_J_FixRef298.13'
#path='thermo.out'

f = np.loadtxt(path)
meV2J = 96.490
R=8.314
#f[:,1]=f[:,1]*meV2J

# G  = A + B*T + C*T*LN(T) + D*T^2 + E*T^3  + F*T^-1
# Cp =         - C         - 2D*T  - 6E*T^2 - 2F*T^-2

def funG(T, A, B, C, D, E, F):
    return  A + B*T + C*T*np.log(T) + D*T**2 + E*T**3  + F*T**-1

def funCp(T,C,D,E,F):
    return          - C             -2*D*T   -6*E*T**2 -2*F*T**-2

def funG3(T, A, B, C, D, F):
    return  A + B*T + C*T*np.log(T) + D*T**2 + F*T**-1

def funCp3(T,C,D,F):
    return          - C             -2*D*T   -2*F*T**-2

xdata=f[100:,0]
ydata=f[100:,1]

popt, pcov= optimization.curve_fit(funG, xdata, ydata)
A, B, C, D, E, F = popt

popt, pcov= optimization.curve_fit(funG3, xdata, ydata)
A, B, C, D, F = popt

T=f[:,0]
fittingDeg=15;
fit=np.poly1d(np.polyfit(T,f[:,1],fittingDeg))
fitDer=-T*np.polyder(fit,2)(T)

plt.ion()
plt.figure()
plt.plot(f[:,0],f[:,1],'*b', lw=2)
plt.plot(xdata,funG(xdata,A,B,C,D,E,F), '-r')
plt.plot(xdata,funG3(xdata,A,B,C,D,F), '--k')
plt.plot(f[:,0],fit(f[:,0]), '.g')

plt.figure()
plt.plot(f[:,0],f[:,2]*R,'*b', lw=2)
plt.plot(xdata,funCp(xdata,C,D,E,F), '-r')
plt.plot(xdata,funCp3(xdata,C,D,F), '--k')
plt.plot(T,fitDer, '.g')
plt.show()




