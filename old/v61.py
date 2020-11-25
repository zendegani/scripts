__author__ = 'Ali'
# rev 6.01 (2016-01-21 17:40)
''' some ideas adopted from ZenGen project'''

import numpy as np
import itertools as itr
import subprocess
import os
import sys
import fileinput
import matplotlib.pyplot as plt
from scipy.interpolate import UnivariateSpline
from scipy.optimize import curve_fit
import pprint as pp


""" unsolved issue & TODO tasks indicated by !!!!
    many space required in 1st & 6th line of POS.0 !!!! solved
    Element list contains just permuting elements !!!!
"""


# @El    : table of elements 
# @M     : table of multiplicity
# nM     : number of inequivalent sites
# nC     : number of ordered configurations
# Comb   : table of combinations

#/-- main_folder
#|
#|- this.py, INCAR, KPOINTS,
#|
#/-- POS
#|    |- POSCAR.ini, POS.header, POS.0 ... POS.n, 
#|
#/-- POT
#|    |- POTCAR_el ... el={'Al', 'Mg', 'Cu', 'Si'}
#|
#/-- FreeEneHarmonic
#|    |- Fvib_el ... el={'Al', 'Mg', 'Cu', 'Si'}
#|
#/-- Lparam
#|    |-


class SiteFrac(object):
    def __init__(self, phase, ModeVerbose='YES', ModeFile='NO', POTPATH='POT/', POSPATH='POS/'):
        self.phase = phase;
        self.POTPATH=POTPATH;
        self.POSPATH=POSPATH;
#        self.El = self.Elements[0:NvarEl];
        self.ModeVerbose = ModeVerbose;
        self.ModeFile = ModeFile;
#        self.nEl = len(self.El);
#        self.Elfixed = self.Elements[self.nElements-self.nEl:];
        self.elementListGen();
        self.nElements = len(self.elementSelected); #self.Elements);
#        self.Elements = self.elementSelected #ElementList;
        self.genM();
        self.mapElement2Wyckoff();
        self.genEndMembers();
        self.nM = len(self.M);
        self.nC = len(self.PermRep) #self.nEl ** self.nM;
#        self.ElfixedNo = ElNumber[self.nElements-self.nEl:];
        print '\n\n###################################';
        print 'Studied phase                  : ', self.phase;
        print 'Table of all elements          : ', self.elementSelected; #self.Elements
        print 'No. of inequivalent sites      = ', self.nWyckoff; #self.nM;
        print 'Table of multiplicity          : ', self.M;
#        print 'Table of elements              : ', self.El;
        print 'No. of permuting element(s)    = ', self.nElements #self.nEl;
        print 'No. of ordered configurations  = ', self.nC;
        print '################################### \n\n';
        self.name = [];
        self.GofEl = [];
        self.T0ofEl = [];
        self.GofQ = [];
        self.T0ofQ = [];
        self.compositionTab = [];
        self.Hartree2meV = 27.211385 * 1000;
        self.meV2J = 96.490
        self.GofQ4TCM = [];



    def elementListGen(self):
        """ Print list of available elemnts based on POTCARs and then USER select the elements
    """
        self.elementList=next(os.walk(self.POTPATH))[1];
        self.elementList.sort();
        for i in self.elementList: 
            print i;

        condition = True
        while condition:
            condition = False
            self.elementSelected=raw_input('Elements separated by a space [A B ...]? ').split()
            if not self.elementSelected: 
                condition = True
            else:
                for i in self.elementSelected:
                    if i not in self.elementList:
                        condition = True
                        print 'Element '+i+' is not available!'
        
        print self.elementSelected
        
        
    def genM(self):
        """ Get multiplicity of each Wyckoff site in the considered phase
    """
        self.M = [];
        command="ls -1d "+self.POSPATH+"/POS.[1-9]* | wc -l"
        #command="ls -1d POS/POS.[1-9]* | wc -l"
        self.nWyckoff = int(self.subp(command));
        for i in range(1, self.nWyckoff + 1):
            num_lines = int(self.subp('cat '+self.POSPATH+'/POS.' + str(i) + ' | wc -l'));
            #      num_lines = sum(1 for line in open('POS/'+'POS.'+str(i)));
            self.M.append(num_lines);


    def mapElement2Wyckoff(self):
        """ Determine which element on which Wyckoff position
    """
        self.ElWykList=[]
        print range(1,self.nWyckoff+1);
        print self.M
        for i in range(self.nWyckoff):
            print self.subp('head -1 '+self.POSPATH+'/POS.' + str(i+1))
            condition = True
            while condition:
                condition = False
                self.readEl2Wyk=raw_input('Elements on Wyckoff '+str(i+1)+' separated by a space [A B ...]? ').split()
                if not self.readEl2Wyk: 
                    condition = True
                else:
                    for el in self.readEl2Wyk:
                        if el not in self.elementSelected:
                            condition = True
                            print 'Element '+el+' was not chosen!'
            self.ElWykList.append(self.readEl2Wyk)


    def genEndMembers(self):
        """ Generate every ordered configuration (Permutation with Repitition)
    """
        print 'Generating every ordered configuration ... \n\n';
        self.PermRep = [el for el in itr.product(*self.ElWykList)];
        if self.ModeVerbose == 'YES': print np.array(self.PermRep), '\n\n';
        

#    def genC(self):
#        """ Generate every ordered configuration (Permutation with Repitition)
#    """
#        print 'Generating every ordered configuration ... \n\n';
#        self.PermRep = [el for el in itr.product(self.El, repeat=self.nM)];
#        if self.ModeVerbose == 'YES': print np.array(self.PermRep), '\n\n';


    def TabExt(self):
        """ Extend table size to provide space for composition
    """
        self.TabExt = [([i + 1] + [self.PermRep[i][j] for j in range(self.nM)] + [0.000 for \
                                         j in range(self.nElements)] + [0]) for i in range(self.nC)];
        if self.ModeVerbose == 'YES': print 'Extended table \n', np.array(self.TabExt), '\n\n';


    def Xcalc(self):
        """ Calculation of concentration and degenerated-concentration (block position) of each configuration
    """
        print 'Calculation of concentration ... \n\n';
        self.TabX = self.TabExt[::];            #Copy doesn't work !!!!
        self.nTot = sum(self.M);
        for el in self.elementSelected:
            for i in range(self.nC):
                x = 0.0;
                for j in range(self.nM):
                    if self.TabX[i][1 + j] == el:
                        x += self.M[j];
                        self.TabX[i][1 + self.nM + self.nElements] += self.M[j] * self.elementSelected.index(el);
                x = x / float(self.nTot);
                self.TabX[i][1 + self.nM + self.elementSelected.index(el)] = round(x, 3);
                if x != 0: self.TabX[i][1 + self.nM + self.nElements] += 100 + 10*self.elementSelected.index(el);
        if self.ModeVerbose == 'YES': print np.array(self.TabX), '\n\n';


    def sortConf(self):
        """ Sort configuration by increasing concentration, with first: uniaries, binaries, ternaries ...
    """
        print 'Sorting configuration ... \n';
        self.tab0 = [tuple(j for j in i) for i in self.TabX];
        self.dtype = [('row', 'int')] + [('Wyckf' + str(i + 1), 'S2') for i in range(self.nM)] + [
            ('con' + str(i + 1), 'float') for i in range(self.nElements)] + [('bloc', 'int')];
        self.tab1 = np.array(self.tab0, dtype=self.dtype);
        self.Comb = np.sort(self.tab1,
                            order=['bloc'] + ['con' + str(i) for i in range(self.nElements, 0, -1)] + \
                                  ['Wyckf' + str(i + 1) for i in range(self.nM)]);
        if self.ModeVerbose == 'YES':
            print '\ndtype \n', self.dtype;
            print '\ntab1 \n\n', np.array(self.tab1);
            print '\nSorted configuration \n\n', np.array(self.Comb), '\n\n';
        for i in range(self.nC):            #overwriting row number !!!!
            self.Comb[i][0] = i + 1;


    def genF(self):
        """ Build folders with configuration-corresponding name
    """
        print 'Writing folders, please wait ... \n\n';
        self.name.append(self.phase);
        self.name += self.elementSelected;
        self.name = '-'.join(i for i in self.name);
        self.subp('mkdir -p ' + self.name);
        for i in range(1, self.nC + 1):
            self.subp('mkdir -p ' + self.name + '/' + str(i));
        print 'Main folder name is ', self.name, '\n\n';


    def genSUM(self):
        """ Build a conf.out file which summarizes the Table of configurations
    """
        print 'Building summary table ...\n\n';
        f = open("conf.out", 'w');
        fmt = '%d ' + '%s ' * self.nM + '%1.3f ' * self.nElements + '%d';
        np.savetxt(f, self.Comb, fmt=fmt);
        f.close();


    def genPOS(self):
        """ Generate the POSCAR of every configuration
    """
        print 'Generating POSCARs ... \n\n';
        # preparing header
        for i in range(self.nC):
            folder = self.name + '/' + str(i + 1)
            self.subp('cp '+self.POSPATH+'/POS.header ' + folder + '/.')
            # get number of each atom
            nnl = []
            for el in self.elementSelected:
                nl = 0;
                for j in range(self.nM):
                    if self.Comb[i][j + 1] == el:
                        nl += self.M[j];
                nnl.append(nl);
            if self.ModeVerbose == 'YES': print "no. element's atoms ", nnl;
            # prepare 1st line ...
            POSheader = self.phase + '-' + str(i + 1) + '- ' + '  '.join(
                a for a in [b for b in self.Comb[i]][1:self.nM + 1]);
            data = self.file2dat(folder + '/POS.header');
            data[0] = POSheader + '\n';
            # prepare 4th line ...
            atom = '';
            atomNAME = '';
            for n in range(self.nElements):
                if nnl[n] != 0:
                    atom += '   ' + str(nnl[n]);
                    atomNAME += '   ' + str(self.elementSelected[n]);
            INCatomln=6
#            data[INCatomln-1] = atomNAME + '   ' + '   '.join(str(n) for n in self.Elfixed) + '\n';
#            data[INCatomln] = atom + '    ' + '    '.join(str(n) for n in self.ElfixedNo) + '\n';
            data[INCatomln-1] = atomNAME + '   ' + '\n';
            data[INCatomln] = atom + '    ' +  '\n';
            print "End member ",i+1,":\n",data[INCatomln], data[INCatomln-1]
            self.dat2file(folder + '/POS.header', data)
            # write header ...
            filePOShead = open(folder + '/POS.header', 'r');
            filePOSCAR = open(folder + '/POSCAR', 'w+');
            filePOSCAR.write(filePOShead.read());
            filePOShead.close();
            # append Wyckoff sites
            for el in self.elementSelected:
                for k in range(self.nM):
                    if el == self.Comb[i][k + 1]:
                        self.subp('cp '+self.POSPATH+'/POS.' + str(k + 1) + ' ' + folder + '/.')
                        self.replacestr(folder + '/POS.' + str(k + 1), 'el', el)
                        filePOSk = open(folder + '/POS.' + str(k + 1), 'r+')
                        filePOSCAR.write(filePOSk.read());
                        filePOSk.close();
                        # append fixed elements
#            self.subp('cp POS/POS.other ' + folder + '/.')
#            filePOSother = open(folder + '/POS.other', 'r+')
#            filePOSCAR.write(filePOSother.read());
#            filePOSother.close();
            filePOSCAR.close();


    def genPOT(self):
        """ Generate the POTCAR of every configuration
        based on conf.out syntax as following:
        1 Al Al Al Al 1.000 0.000 10
        2 Mg Mg Mg Mg 0.000 1.000 11
        3 Al Al Al Mg 0.750 0.250 21

    """
        print 'Generating POTCARs ... \n\n';
        fileConf = open('conf.out', 'r');
        for line in fileConf:
            folder = line.split()[0];           # 1st column as folder name
            filePOT = open(self.name + '/' + str(folder) + '/POTCAR', 'w');
            for i in range(self.nElements):
                if float(line.split()[1 + self.nM + i]) != 0.0:
                    filePOTel = open(self.POTPATH+'/POTCAR_' + self.elementSelected[i], 'r');
                    filePOT.write(filePOTel.read());
                    #filePOT.write('\n');
                    filePOTel.close();

#            for i in range(len(self.Elfixed)):
#                filePOTel = open('POT/POTCAR_'+self.Elfixed[i], 'r');
#                filePOT.write(filePOTel.read());
#                #filePOT.write('\n');
#                filePOTel.close();
            filePOT.close();
        fileConf.close();


    def subp(self, command):
        """ pass set of piped commands to shell
    """
        return subprocess.check_output(command, shell=True, stderr=subprocess.STDOUT)


    def file2dat(self, filename):
        """ convert file to array of data
        """
        with open(filename, 'r') as file: return file.readlines()


    def dat2file(self, filename, data):
        """ write array of data to file
        """
        with open(filename, 'w') as file: file.writelines(data)


    def replacestr(self, filename, old, new):
        """ replace a string in a file
        """
        for s, line in enumerate(fileinput.input(filename, inplace=1)):
            sys.stdout.write(line.replace(old, new))


    def Efit(self, filename):
        """ read file contains free energy vs temperature
        and fit a spline function to free energy
        """
        dat = np.loadtxt(filename);
        return UnivariateSpline(dat[:, 0], dat[:, 1], s=1)


    def Efit4El(self):
        """ the same as freeEfit() but does it for all elements
        """
        for el in self.Elements:   # Element list contains just permuting elements !!!!
            self.Efit('FreeEneHarmonic/Fvib_'+el)


    def EfitTDB(self, filename):
        """ read file contains free energy vs temperature
        and fit a specific function to free energy
        """
        def func(T,a,b,c,d,e,f,g,h):
            return a + b*T + c*T*np.log(T) + d*T**-1 + e*T**2 + f*T**-2 + g*T**3 + h*T**-3
        dat = np.loadtxt(filename);
        return curve_fit(func, dat[:, 0], dat[:, 1])


    def EfitPol(self,filename,degree):
        """ read file contains free energy vs temperature
        and fit a polynomial function of given degree to free energy data
        """
        dat = np.loadtxt(filename);
        return np.poly1d(np.polyfit(dat[:, 0], dat[:, 1],degree))


    def Composition(self):
        ''' Generate composition table of each structure
        '''
        for i in range(self.nC):
            # get number of each atom
            nnl = []
            for el in self.elementSelected:
                nl = 0;
                for j in range(self.nM):
                    if self.Comb[i][j + 1] == el:
                        nl += self.M[j];
                nnl.append(nl);
            nnl += self.ElfixedNo;
            self.compositionTab.append(list(self.Comb[i])[1:self.nM+1]+nnl+self.Elements);
            print(nnl)
        return


    def EofQs(self):
        ''' calculate free energy of formation based on fitted curve on free energy and composition of structures
        meV/atom
        '''
        self.T0ofEl = [];
        self.T0ofQ = [];
        fittingDeg=15;
        ntot = np.sum(self.compositionTab[0][self.nElements:self.nElements*2]);
        for el in self.Elements:
            #Total E @T0 provided in meV/atom
            self.T0ofEl.append(np.loadtxt('FreeEneHarmonic/T0_'+el));
            #Harmonic Contribution of Free Energy
            self.GofEl.append(self.EfitPol('FreeEneHarmonic/Fvib_'+el,fittingDeg));
        for i in range(self.nC):
            #Total E0 of each Q provided in eV/atom (VASP --> murn --> converted from Hartree to eV/atom)
            #1st row of sum.out is skipped by using [i+1]
            self.T0ofQ.append(1000*float(np.array(self.file2dat(self.name+'/sum.out'))[i+1].split()[self.nM+2]));
            self.GofQ.append(self.EfitPol(self.name+'/'+str(i+1)+'/finite/thermo/thermo.out',fittingDeg));
            thermomeV=open('FreeEneHarmonic/thermomeV.'+str(i+1),'w');
            thermoJ=open('FreeEneHarmonic/thermoJ.'+str(i+1),'w');
            for T in range(1000):
                G = 0;
                for j in range(self.nElements):
                    G = G - (self.GofEl[j](T)+float(self.T0ofEl[j])) * self.compositionTab[i][self.nElements+j];
                    #ntot = np.sum(self.compositionTab[i][self.nElements:self.nElements*2]);
                G = (G  + (self.GofQ[i](T)+float(self.T0ofQ[i])) * ntot) / ntot # / 21. for Q-phase for mole of atom!!!
                thermomeV.write(str(T)+'   '+str(G)+'\n');
                thermoJ.write(str(T)+'   '+str(G*self.meV2J)+'\n');
            thermomeV.close();
            thermoJ.close();
        print self.T0ofEl , '\n', self.T0ofQ;
        return


    def fit4TCM(self):
        '''prepare free energy polynomial as TCM syntax
        modified for mole of formula
        '''
        degree = 15;
        TCM = open('TCMparam.txt','w');
        ntot = np.sum(self.compositionTab[0][self.nElements:self.nElements*2]);
        for i in range(self.nC):
            file = 'FreeEneHarmonic/thermoJ.'+str(i+1);
            self.GofQ4TCM.append(self.EfitPol(file,degree));
            # PARAMETER G(LIQUID,CR;0) 2.98140E+02 +24339.955-11.420225*T+2.37615E-21*T**7
            # ent_par G(Q,AL:AL:AL:AL:CU:SI) 298.15 9234.1184
            Tstring = str(ntot*self.GofQ4TCM[i][0]);
            for d in range(degree):
	      if self.GofQ4TCM[i][d+1] < 0 :
                Tstring += str(ntot*self.GofQ4TCM[i][d+1]) + '*T**' + str(d+1)
	      else:
                Tstring += '+' + str(ntot*self.GofQ4TCM[i][d+1]) + '*T**' + str(d+1)
            Tstring = 'ent_par G('+self.phase+','+':'.join(list(self.Comb[i])[1:self.nM+1]).upper()+ \
                ':'+') 298.15  \n'+ Tstring + '\n \n6000 \nN ;,,,,,,,Q  J/mol from VASP \n \n';
#                ':'+':'.join(self.Elfixed).upper()+') 298.15  \n'+ Tstring + '\n \n6000 \nN ;,,,,,,,Q  J/mol from VASP \n \n';
	                                                      # '+ Tstring + ';,,,,,,,Q  J/mol from VASP';
            TCM.write(Tstring+'\n');
            #print(Tstring+'\n')
        TCM.close();
        return


    def EofQsFixedRef(self):
        ''' calculate free energy of formation based on fitted curve on free energy and composition of structures
        meV/atom
        for constituents only T0 energy considered 'Fixed Reference'
        '''
        self.T0ofEl = [];
        self.T0ofQ  = [];
        fittingDeg  = 15;
        ntot = 1.*np.sum(self.compositionTab[0][self.nElements:self.nElements*2]);
        for el in self.Elements:
            #Total E @T0 provided in meV/atom
            self.T0ofEl.append(np.loadtxt('FreeEneHarmonic/T0_'+el));
            #Harmonic Contribution of Free Energy
            #self.GofEl.append(self.EfitPol('FreeEneHarmonic/Fvib_'+el,fittingDeg));
        for i in range(self.nC):
            #Total E0 of each Q provided in eV/atom (VASP --> murn --> converted from Hartree to eV/atom)
            #1st row of sum.out is skipped by using [i+1]
            self.T0ofQ.append(1000*float(np.array(self.file2dat(self.name+'/sum.out'))[i+1].split()[self.nM+2]));
            self.GofQ.append(self.EfitPol(self.name+'/'+str(i+1)+'/finite/thermo/thermo.out',fittingDeg));
            F_meV_FixRef_Formula=open('FreeEneHarmonic/F_meV_FixRef_Formula.'+str(i+1),'w');
            F_J_FixRef_Formula=open('FreeEneHarmonic/F_J_FixRef_Formula.'+str(i+1),'w');
            F_meV_FixRef=open('FreeEneHarmonic/F_meV_FixRef.'+str(i+1),'w');
            F_J_FixRef=open('FreeEneHarmonic/F_J_FixRef.'+str(i+1),'w');
            for T in range(1000):
                G = 0;
                for j in range(self.nElements):
                    G = G - float(self.T0ofEl[j]) * self.compositionTab[i][self.nElements+j];
                    #ntot = np.sum(self.compositionTab[i][self.nElements:self.nElements*2]);
                G = (G  + (self.GofQ[i](T)+float(self.T0ofQ[i])) * ntot);# / ntot # / 21. for Q-phase
                F_meV_FixRef_Formula.write(str(T)+'   '+str(G)+'\n');
                F_J_FixRef_Formula.write(str(T)+'   '+str(G*self.meV2J)+'\n');
                F_meV_FixRef.write(str(T)+'   '+str(G/ntot)+'\n');  #str(G/21.)+'\n');
                F_J_FixRef.write(str(T)+'   '+str(G*self.meV2J/ntot)+'\n'); #+str(G*self.meV2J/21.)+'\n');
            F_meV_FixRef_Formula.close();
            F_J_FixRef_Formula.close();
            F_meV_FixRef.close();
            F_J_FixRef.close();
        print self.T0ofEl , '\n', self.T0ofQ;
        return


    def fit4TCMfixedRef(self):
        '''prepare free energy polynomial as TCM syntax
        modified for mole of formula
        '''
        degree = 15;
        TCM = open('TCMparamFixedRef.txt','w');
        for i in range(self.nC):
            file = 'FreeEneHarmonic/F_J_FixRef_Formula.'+str(i+1);
            self.GofQ4TCM.append(self.EfitPol(file,degree));
            # PARAMETER G(LIQUID,CR;0) 2.98140E+02 +24339.955-11.420225*T+2.37615E-21*T**7
            # ent_par G(Q,AL:AL:AL:AL:CU:SI) 298.15 9234.1184
            Tstring = str(self.GofQ4TCM[i][0]);
            for d in range(degree):
	      if self.GofQ4TCM[i][d+1] < 0 :
                Tstring += str(self.GofQ4TCM[i][d+1]) + '*T**' + str(d+1)
	      else:	
                Tstring += '+' + str(self.GofQ4TCM[i][d+1]) + '*T**' + str(d+1)
            Tstring = 'ent_par G('+self.phase+','+':'.join(list(self.Comb[i])[1:self.nM+1]).upper()+ \
                ':'+':'.join(self.Elfixed).upper()+') 298.15  \n'+ Tstring + '\n \n6000 \nN ;,,,,,,,Q  J/mol from VASP \n \n';
            TCM.write(Tstring+'\n');
            #print(Tstring+'\n')
        TCM.close();
        return

    def EofQsFixedRef298(self):
        ''' calculate free energy of formation based on fitted curve on free energy and composition of structures
        meV/atom
        for constituents only T0+vib@298 energy considered 'Fixed Reference @T=298K'
        '''
        self.T0ofEl = [];
        self.T0ofQ  = [];
        self.GofEl  = [];
        self.GofQ   = [];
        fittingDeg  = 15
        ntot = 1.*np.sum(self.compositionTab[0][self.nElements:self.nElements*2])
        for el in self.Elements:
            #Total E @T0 provided in meV/atom
            self.T0ofEl.append(np.loadtxt('FreeEneHarmonic/T0_'+el));
            #Harmonic Contribution of Free Energy
            GofEl_tmp= np.loadtxt('FreeEneHarmonic/Fvib_'+el);
            if 298 in GofEl_tmp[:,0]:   #check whether T=298K is in file or should interpolated!
                x,y=np.where(GofEl_tmp==298)
                self.GofEl.append(GofEl_tmp[x,y+1][0]) 
            else:
                self.GofEl.append(self.EfitPol('FreeEneHarmonic/Fvib_'+el,fittingDeg)(298));
        for i in range(self.nC):
            #Total E0 of each Q provided in eV/atom (VASP --> murn --> converted from Hartree to eV/atom)
            #1st row of sum.out is skipped by using [i+1]
            self.T0ofQ.append(1000*float(np.array(self.file2dat(self.name+'/sum.out'))[i+1].split()[self.nM+2]));
            self.GofQ.append(np.loadtxt(self.name+'/'+str(i+1)+'/finite/thermo/thermo.out'));
            #F_meV_FixRef_Formula298=open('FreeEneHarmonic/F_meV_FixRef_Formula298.'+str(i+1),'w');
            #F_J_FixRef_Formula298=open('FreeEneHarmonic/F_J_FixRef_Formula298.'+str(i+1),'w');
            #F_meV_FixRef298=open('FreeEneHarmonic/F_meV_FixRef298.'+str(i+1),'w');
            #F_J_FixRef298=open('FreeEneHarmonic/F_J_FixRef298.'+str(i+1),'w');
            G = 0;
            G0 = 0;
            Gcompound=self.GofQ[i][:,0:2];
            for j in range(self.nElements):
                G = G - ((float(self.T0ofEl[j])+self.GofEl[j]) * self.compositionTab[i][self.nElements+j]);
                G0 = G0 - (float(self.T0ofEl[j]) * self.compositionTab[i][self.nElements+j]);
                    #ntot = np.sum(self.compositionTab[i][self.nElements:self.nElements*2]);
            Gcompound[:,1] = (G  + (self.GofQ[i][:,1]+float(self.T0ofQ[i])) * ntot);# / multiplied by ntot (21) for Q-phase mole of formula
            #F_meV_FixRef_Formula298.write(str(Gcompound));
            np.savetxt('FreeEneHarmonic/F_meV_FixRef_Formula298.'+str(i+1),Gcompound[:,0:2])

            Gcompoundtmp=Gcompound;
            Gcompoundtmp[:,1]=Gcompound[:,1]*self.meV2J;
            #F_J_FixRef_Formula298.write(str(Gcompoundtmp));
            np.savetxt('FreeEneHarmonic/F_J_FixRef_Formula298.'+str(i+1),Gcompoundtmp[:,0:2])

            Gcompoundtmp=Gcompound;
            Gcompoundtmp[:,1]=Gcompound[:,1]/ntot;
            #F_meV_FixRef298.write(str(Gcompoundtmp));
            np.savetxt('FreeEneHarmonic/F_meV_FixRef298.'+str(i+1),Gcompoundtmp[:,0:2])

            Gcompoundtmp=Gcompound;
            Gcompoundtmp[:,1]=Gcompound[:,1]*self.meV2J/ntot;
            #F_J_FixRef298.write(str(Gcompoundtmp));
            np.savetxt('FreeEneHarmonic/F_J_FixRef298.'+str(i+1),Gcompoundtmp[:,0:2])

            #F_meV_FixRef_Formula298.close();
            #F_J_FixRef_Formula298.close();
            #F_meV_FixRef298.close();
            #F_J_FixRef298.close();
            print G, G0;
        print self.T0ofEl , '\n', self.T0ofQ, '\n', self.GofEl ;
        return

    def fit4TCMfixedRef298(self):
        '''prepare free energy polynomial as TCM syntax
        modified for mole of formula
        '''
        degree = 15;
        TCM = open('TCMparamFixedRef298.txt','w');
        for i in range(self.nC):
            file = 'FreeEneHarmonic/F_J_FixRef_Formula298.'+str(i+1);
            self.GofQ4TCM.append(self.EfitPol(file,degree));
            # PARAMETER G(LIQUID,CR;0) 2.98140E+02 +24339.955-11.420225*T+2.37615E-21*T**7
            # ent_par G(Q,AL:AL:AL:AL:CU:SI) 298.15 9234.1184
            Tstring = str(self.GofQ4TCM[i][0]);
            for d in range(degree):
	      if self.GofQ4TCM[i][d+1] < 0 :
                Tstring += str(self.GofQ4TCM[i][d+1]) + '*T**' + str(d+1)
	      else:
                Tstring += '+' + str(self.GofQ4TCM[i][d+1]) + '*T**' + str(d+1)
            Tstring = 'ent_par G('+self.phase+','+':'.join(list(self.Comb[i])[1:self.nM+1]).upper()+ \
                ':'+':'.join(self.Elfixed).upper()+') 298.15  \n'+ Tstring + '\n \n6000 \nN ;,,,,,,,Q  J/mol from VASP \n \n';
            TCM.write(Tstring+'\n');
            #print(Tstring+'\n')
        TCM.close();
        return

    def HofQs(self):
        ''' calculate Enthalpy of formation of compounds  meV/atom
        '''
        self.T0ofEl = [];
        self.T0ofQ = [];
        ntot = np.sum(self.compositionTab[0][self.nElements:self.nElements*2]);
        Hfile=open('FreeEneHarmonic/Enthalpies.out','w');
        for el in self.Elements:
            #Total E @T0 provided in meV/atom
            self.T0ofEl.append(float(np.loadtxt('FreeEneHarmonic/T0_'+el)));
        for i in range(self.nC):
            #Total E0 of each Q provided in eV/atom (VASP --> murn --> converted from Hartree to eV/atom)
            #1st row of sum.out is skipped by using [i+1]
            self.T0ofQ.append(1000.0*float(np.array(self.file2dat(self.name+'/sum.out'))[i+1].split()[self.nM+2]));
            H = 0.0;
            for j in range(self.nElements):
                H = H - float(self.T0ofEl[j]) * self.compositionTab[i][self.nElements+j];
                #ntot = np.sum(self.compositionTab[i][self.nElements:self.nElements*2]);
            H = (H  + float(self.T0ofQ[i]) * ntot); #/ ntot # mole of formula # / 21. for Q-phase
            headerOfLine = ' '.join(s for s in self.file2dat(self.name+'/sum.out')[i+1].split()[0:self.nM+3]);
            Hfile.write(headerOfLine + ' : '+str(self.compositionTab[i][self.nElements]*1./ntot)+' :   '+str(H)+'   '+str(H*self.meV2J/ntot)+'   '+str(H*self.meV2J)+'\n');
                     #Q-16- Mg Mg Mg Al : -3.4217514 : 0.142857142857 :   -1355.00090614   -6225.90654447   -130744.037434
        Hfile.write('Conf  j1 j2 k1 k2 : Total E_eV : Al mole frac  : H meV mol_formula   J mol_atom       J mol_formula \n');
        Hfile.close();
        print self.T0ofEl , '\n', self.T0ofQ;
        return


    def TCMfromH(self):
        '''prepare enthalpy as TCM syntax
        '''
        TCM = open('FreeEneHarmonic/TCMparamH.txt','w');
        file = np.array(self.file2dat('FreeEneHarmonic/Enthalpies.out'));
        for i in range(self.nC):
            hofQ4TCM = file[i].split()[-1];   #read the enthalpy of ith compound from last column of Enthalpies.out
            # PARAMETER G(LIQUID,CR;0) 2.98140E+02 +24339.955-11.420225*T+2.37615E-21*T**7
            # ent_par G(Q,AL:AL:AL:AL:CU:SI) 298.15 9234.1184
            Tstring = 'ent_par G('+self.phase+','+':'.join(list(self.Comb[i])[1:self.nM+1]).upper()+ \
                ':'+':'.join(self.Elfixed).upper()+') 298.15 '+ hofQ4TCM + ';,,,,,,,Q  J/mol from VASP'
            TCM.write(Tstring+'\n');
            #print(Tstring+'\n')
        TCM.close();
        return
      
      
    def LparamConGen(self):
        '''generate configurations of mixing on sublattices for calculation of L parameters
           only mixing on one sublattice each time
        '''
        Lname='Lparam';
        if not os.path.isdir(Lname):os.makedirs(Lname);

        for i in range(self.nC):
            for j in range(self.nM):
                if self.compositionTab[i][j] == 'Mg':
                    for x in range(self.M[j]-1):
                        fstr=str(i+1)+'-'+str(j+1)+'-'+str(x+1); # the folder name of each configurations
                        if not os.path.isdir(Lname+'/'+fstr):os.makedirs(Lname+'/'+fstr);
        return




"""
compare fittings:

sp=Q.Efit('samplethermo.out')
dat = np.loadtxt('samplethermo.out')
T=dat[:, 0]
po5=np.poly1d(np.polyfit(T, dat[:, 1],5))
po7=np.poly1d(np.polyfit(T, dat[:, 1],7))
po9=np.poly1d(np.polyfit(T, dat[:, 1],9))
po11=np.poly1d(np.polyfit(T, dat[:, 1],11))
po13=np.poly1d(np.polyfit(T, dat[:, 1],13))
po15=np.poly1d(np.polyfit(T, dat[:, 1],15))
po16=np.poly1d(np.polyfit(T, dat[:, 1],16))
po17=np.poly1d(np.polyfit(T, dat[:, 1],17))

plt.plot(T, dat[:, 1],'.',label="data")
plt.plot(T,sp(T),label="spline")
plt.plot(T,po5(T),label="5")
plt.plot(T,po7(T),label="7")
plt.plot(T,po9(T),label="9")
plt.plot(T,po11(T),label="11")
plt.plot(T,po13(T),label="13")
plt.plot(T,po15(T),label="15")
plt.plot(T,po16(T),label="16")
plt.plot(T,po16(T),label="17")


popt, pcov = Q.EfitTDB('samplethermo.out')
a,b,c,d,e,f,g,h=popt[0],popt[1],popt[2],popt[3],popt[4],popt[5],popt[6],popt[7]
plt.plot(T,a + b*T + c*T*np.log(T) + d*T**-1 + e*T**2 + f*T**-2 + g*T**3 + h*T**-3,'c',label="Gsyntax")

plt.legend()
plt.show()

plt.plot(T,-T*np.polyder(po15,2)(T))
plt.plot(T,-T*np.polyder(po16,2)(T))
plt.show()

"""

if __name__ == '__main__':
        print '\n\n';
        ModeVerbose = raw_input('Would you like verbose output on screen ([yes]/no)?').upper() or "YES"
        ModeFile = raw_input('Would you like make files after table preparation (yes/[no])?').upper() or "NO"
        POTPATH = raw_input('Enter the POTENTIAL path [/u/alizen/Thermodynamics/vasp_potentials/PAW-GGA-PBE_vasp5.2]') or "/u/alizen/Thermodynamics/vasp_potentials/PAW-GGA-PBE_vasp5.2"
        POSPATH = raw_input('Enter the POSCAR file path [POS/]') or "POS/"
        Q = SiteFrac('Q', ModeVerbose, ModeFile, POTPATH);
        
        # Generate every ordered configuration
        #Q.genC();

        # Extend table size to provide space for composition
        Q.TabExt();

        # Calculation of concentration and degenerated-concentration (blocposition) of each configuration
        Q.Xcalc();

        # Sort configuration by increasing concentration, with first: uniaries, binaries, ternaries ...
        Q.sortConf();

        # Build folders with configuration-coresponding name
        Q.genF();

        if ModeFile == 'YES':
            # Build a conf.out file which summarizes the Table of configurations
            Q.genSUM();

            # Generate the POSCAR of every configuration
            Q.genPOS();

            # Generate the POTCAR of every configuration
            Q.genPOT();

        # Generate composition table of each structure
        Q.Composition();

        # Calc free E or Enthalpy H of Qs
        ForH = raw_input('Would you like to extract Enthalpy or Free energy (H:Enthalpy/F:FreeEnergy/R:FreeE-withFixedRef0K/X:FreeE-withFixedRef298K/C:CALPHAD fit/[No]:nothing)?').upper()
        if ForH == 'F':
            Q.EofQs();
            Q.fit4TCM();
        elif ForH == 'H':
            Q.HofQs();
            Q.TCMfromH();
        elif ForH == 'R':
            Q.EofQsFixedRef();
            Q.fit4TCMfixedRef();
        elif ForH == 'X':
            Q.EofQsFixedRef298();
            Q.fit4TCMfixedRef298();
        elif ForH == 'C':
            Q.EofQsFixedRef298();
            Q.fit4TCMfixedRef298();
        elif ForH == 'NO' or ForH == '':
	        print 'done!'



        # Prepare TCM
#        Q.fit4TCM();
'''
from itertools import cycle
line_cycle = cycle(["-","-.","--"]);
fig = plt.figure();
ax = fig.add_subplot(111);
ax.set_xlabel('T(K)', fontsize=18);
ax.set_ylabel('Free energies of formation '+ur'$F^{vib}_{harm}$'+' (kJ/mole of formula)');
font = {'family' : 'serif', 'weight' : 'bold', 'size' : 16}
plt.rc('font', **font)
plt.xlim([0,900]);
plt.ylim([-1000,400]);
ax.xaxis.set_tick_params(width=3)
ax.yaxis.set_tick_params(width=3)

#ax.set_title('Q-phase 16 different site occupations');
for i in range(Q.nC):
    f=np.loadtxt('FreeEneHarmonic/F_J_FixRef_Formula298.'+str(i+1));
    plt.plot(f[:,0],f[:,1]/1000.,label=str(i+1)+str(Q.compositionTab[i][:4]),color=plt.cm.brg(i*15),linestyle= next(line_cycle));
    #plt.plot(range(1000),Q.GofQ4TCM[i](range(1000)),'-y')

#color=plt.cm.Dark2(i*15
#plt.tick_params(axis='both', which='major', labelsize=16)
plt.grid('True');
plt.legend(loc=1,prop={'size':11});
plt.show();

    
    
name='FE2'
plt.savefig(name+'.jpg', dpi=200, facecolor='w', edgecolor='w', transparent=False, orientation='landscape',format='jpg' )
plt.savefig(name+'.eps', facecolor='w', edgecolor='w', transparent=False, orientation='portrait',format='eps' )
    
'''


'''
scratch

# Preparation of execution files
#preEXE();

test[[1,0],:]=test[[0,1],:]
'''

"""
sum.out script

#!/bin/sh

here=`pwd`
echo "$here"

file=sum.out
perm=`ls -1d [0-9]* | sort -n`

echo "Conf 3j1 3j2 3k1 3k2 : Energy_eV | Volume_A^3 | Bulk modulus_GPa" >> $file
#     Q-3- Al  Al  Al  Mg  : -0.129106   121.229926   71.055986

for j in $perm;do
cd $j
echo "$j"

murn=murn.dat
POSCAR=POSCAR

B0=`grep --text "bulk modulus B0" $murn | tail -1 | awk '{print $6}'`
E0_Hartree=`grep --text "minimum energy E0" $murn | tail -1 | awk '{print $6}'`
V0_Bohr=`grep --text "optimal volume V0" $murn | tail -1 | awk '{print $6}'`

E0_eV=` echo "scale=7;$E0_Hartree/0.036749309"|bc `
V0_A3=` echo "scale=6;$V0_Bohr/6.74833304162"|bc `

phase=`head -1 $POSCAR`

cd $here
echo "$phase  : $E0_eV   $V0_A3   $B0" >> $file

done

"""

'''
run script

#!/bin/sh

folder=`ls -1d [0-9]*`
hier=`pwd`

for f in $folder; do
echo $f
cd $f

lat=(0.96 0.97 0.98 0.99 1.00 1.01 1.02 1.03 1.04)
for a in "${lat[@]}"; do


  mkdir $a
  cd $a
  
  cp ../../script.parallel.sh ./
  cp ../../INCAR ./
  cp ../../KPOINTS ./
  cp ../POTCAR ./
  cp ../POSCAR ./

#--- prompt user info
  echo "-------------------------------------------------------"
  echo "  Lat. coef. = $a"
  echo "-------------------------------------------------------"

#--- create POSCAR
  mv POSCAR POSCARtmp
  head -1 POSCARtmp >> POSCAR

  cat >> POSCAR << POSCAReof
$a
POSCAReof
  tail -27 POSCARtmp >> POSCAR
  qsub -pe 'mpi*' 24 script.parallel.sh
  cd ../
done
cd $hier
done

'''

'''
parallel script

#!/bin/csh 
# 
#$ -cwd 
#$ -j y 
#$ -R y 
#$ -S /bin/csh 
#setenv TMPDIR /scratch/zendegani 
limit stacksize unlimited 
module load vasp/parallel/4.6-tdi 
mkdir workDir 
cp * workDir/ 
cd workDir 
mpirun -x PATH vasp 
#gzip OUTCAR 
gzip vasprun.xml 
mv vasprun.xml.gz CONTCAR OSZICAR OUTCAR ../ 
cd ../ 
gzip POTCAR 
rm -fr workDir 
'''