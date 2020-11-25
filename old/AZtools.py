# from __future__ import division
import numpy as np
from os import path as op
import gzip
import bz2
import glob
import json
import traceback  # ,itertools
from ase.io import vasp as pv
# remove nested list by list(chain.from_iterable(list_of_lists))
from itertools import chain
import itertools as itr
from math import atan2,degrees


__author__ = "Ali Zendegani"

_conv = {  # CONVERSION table
    "THzh__meV": 4.1356675,
    "eV__hart": 0.0367493,  # eV to hartree
    "hart__ev": 27.211385,  # hartree to eV
    "angst__bohr": 1.8897261,  # angstrom to bohrradius
    "bohr__angst": 0.5291772,  # bohrradius to angstrom
    "angst3__bohr3": 6.7483345,  # angstrom^3 to bohrradius^3
    "bohr3__angst3": 0.1481847,  # bohrradius^3 to angstrom^3
    "meV__J_mol": 96.485336,  # meV to J mol
    "kK_meV": 0.086173323,  # k_B K to meV
    "meV_ang2__mJ_m2": 16.021766,  # meV/angstrom^2 to mJ/m^2  SFE
    "meV_nm2__mJ_m2": 0.16021766,  # meV/nm^2 to mJ/m^2  SFE
    "GPa__hart_bohr3": 3.3989312e-05,
    "hart_bohr3__GPa": 29421.01  # Hartree / Bohr^3 = 29421.01 GPa
}

_flag_OUTCAR = {  # flags which help extracting data from OUTCAR
    "energy": "energy  without entropy",
    "ionsNum": "ions per type",
    "ionsName": "TITEL",
    "ionsName2": "VRHFIN",
    "volume": "volume of cell :"
}

_flag_OSZICAR = {                  # flags which help extracting data from OSZICAR
    "penalty": "E_p",
    "lambda": "lambda",
}




def savefig(fig, fig_name, path, dpi_hq=300, dpi_lq=72, fmt='png'):
    ''' save figure with high and low resolution
    '''
    from os import path as op
    fig.tight_layout()
    filename = op.join(path,fig_name+'.'+fmt)
    fig.savefig(filename,format=fmt, dpi=dpi_hq);
    filename = op.join(path,fig_name+'_LQ'+'.'+fmt)
    fig.savefig(filename,format=fmt, dpi=dpi_lq);

#Label line with line2D label data
def labelLine(line,x,label=None,align=True,**kwargs):

    ax = line.axes
    xdata = line.get_xdata()
    ydata = line.get_ydata()

    if (x < xdata[0]) or (x > xdata[-1]):
        print('x label location is outside data range!')
        return

    #Find corresponding y co-ordinate and angle of the line
    ip = 1
    for i in range(len(xdata)):
        if x < xdata[i]:
            ip = i
            break

    y = ydata[ip-1] + (ydata[ip]-ydata[ip-1])*(x-xdata[ip-1])/(xdata[ip]-xdata[ip-1])

    if not label:
        label = line.get_label()

    if align:
        #Compute the slope
        dx = xdata[ip] - xdata[ip-1]
        dy = ydata[ip] - ydata[ip-1]
        ang = degrees(atan2(dy,dx))

        #Transform to screen co-ordinates
        pt = np.array([x,y]).reshape((1,2))
        trans_angle = ax.transData.transform_angles(np.array((ang,)),pt)[0]

    else:
        trans_angle = 0

    #Set a bunch of keyword arguments
    if 'color' not in kwargs:
        kwargs['color'] = line.get_color()

    if ('horizontalalignment' not in kwargs) and ('ha' not in kwargs):
        kwargs['ha'] = 'center'

    if ('verticalalignment' not in kwargs) and ('va' not in kwargs):
        kwargs['va'] = 'center'

    if 'backgroundcolor' not in kwargs:
        kwargs['backgroundcolor'] = ax.get_facecolor()

    if 'clip_on' not in kwargs:
        kwargs['clip_on'] = True

    if 'zorder' not in kwargs:
        kwargs['zorder'] = 2.5

    ax.text(x,y,label,rotation=trans_angle,**kwargs)

    
def labelLines(lines,align=True,xvals=None,**kwargs):
    ax = lines[0].axes
    labLines = []
    labels = []

    #Take only the lines which have labels other than the default ones
    for line in lines:
        label = line.get_label()
        if "_line" not in label:
            labLines.append(line)
            labels.append(label)

    if xvals is None:
        xmin,xmax = ax.get_xlim()
        xvals = np.linspace(xmin,xmax,len(labLines)+2)[1:-1]

    for line,x,label in zip(labLines,xvals,labels):
        labelLine(line,x,label,align,**kwargs)
        
        

def repListList(a, b):
    ''' Repeat each elements of list 'a' by corresponding number mentioned in list 'b'
    '''
    return list(itr.chain(*(itr.repeat(elem, n) for elem, n in zip(a, b))))


def permute(item_list, length):
    ''' Premutes items in the list for given length
    '''
    return ["".join(el) for el in itr.product(item_list, repeat=length)]


def dZ(number):
    return " 0. 0. " + str(number) + " "

def dZlist(mags):
    return '0. 0. '+'  0. 0. '.join(str(i) for i in mags)

def dZlistFmt(mags,n):
    ''' n: floating point decimal precision 
    '''
    return '0. 0. '+'  0. 0. '.join('{1:-1.{0}f}'.format(n,i) for i in mags)

def func2deg(x, a, b, c):
    return a * x**2 + b * x + c


def func3deg(x, a, b, c, d):
    return a * x**3 + b * x**2 + c * x + d


def func5deg(x, a, b, c, d, e, f):
    return a * x**5 + b * x**4 + c * x**3 + d * x**2 + e * x + f


def rough_comparison(value, target, tol_percent):
    ''' check if the given value is within the given tolerance of the target
    '''
    return (abs(value) <= abs(target * (100 + tol_percent) / 100)) & (
        abs(value) >= abs(target * (100 - tol_percent) / 100)) & (
            (value < 0) == (target < 0))


def murnFit(v, e0, v0, b0, b0p):
    ''' Calc E at given V provided e0,v0,b0,b0p using Murnaghan EOS (from Wikipedia)
    '''
    return e0 + b0 * v / (b0p * (b0p - 1)) * (b0p * (1 - v0 / v) +
                                              (v0 / v)**b0p - 1)


def murnFitSPHINX(v, e0, v0, b0, b0p):
    ''' Calc E at given V provided e0,v0,b0,b0p using Murnaghan EOS (from SPHINX website)
    '''
    return e0 + b0 * v / b0p * (1 + (v0 / v)**b0p /
                                (b0p - 1)) - (b0 * v0) / (b0p - 1)


def minEnV(murnData):
    ''' Return lowest E and its corresponding V from set of data
    '''
    return list(
        chain.from_iterable(
            murnData[np.nonzero(murnData == (min(murnData[:, 1])))[0], :]))


def data_extractor_murn(murn_file):
    ''' Extract e0,v0,b0, and b0' from murn.dat of SPHINX
    '''
    with open(murn_file) as fp:
        for i, line in enumerate(fp):
            if i == 1:
                murnB0 = float(line.split()[-2])
            elif i == 2:
                murnB0p = float(line.split()[-1])
            elif i == 3:
                murnE0hartree = float(line.split()[-1])  # hartree
                murnE0eV = murnE0hartree * _conv['hart__ev']
            elif i == 4:
                # bohrradius^3
                murnV0bohr = float(line.split()[-1])
                murnV0angst = murnV0bohr * _conv['bohr3__angst3']
            elif i > 5:
                break
    return murnE0hartree, murnV0bohr, murnB0, murnB0p


def formE(E_tot, E_elms, n_elms):
    ''' Calc formation Energy
    Parameters
    ----------
    e_tot    : Total energy of compound per atom
    e_elms   : list of total energies per atom of constituents
    n_elms   : list of number of atoms of each constituents
    '''
    n_tot = np.sum(n_elms)
    E_tot_elms = np.sum(np.array(E_elms) * np.array(n_elms))
    return (n_tot * E_tot - E_tot_elms) / n_tot


# def formE(E,n_Fe,n_Nb):
#     n_tot = n_Fe + n_Nb
#     return (n_tot*E-(n_Fe*Etot_Fe_ea+n_Nb*Etot_Nb_NM_ea))/n_tot


def fitPol(data, degree):
    ''' fit a polynomial function of given degree to data
    '''
    return np.poly1d(np.polyfit(data[:, 0], data[:, 1], degree))


def SFE_chu(E_C14, E_C15, a_C14):
    ''' Calc energy of SF with Chu approach
    Parameters
    ----------
    E_C14,E_C15 : Energy (meV per atom)
    a_C14       : Lattice parameter of C14 (Angstrom) in basal plane

    Returns
    -------
    Energy of SF in mJ/m2 for Chu method
    '''
    Edelta_15_14 = E_C15 - E_C14
    return [
        24 * Edelta_15_14 / (3**.5 * a_C14**2) * _conv['meV_ang2__mJ_m2'],
        Edelta_15_14
    ]


def SFE_SC(E_C14, E_SC, A, n_atoms):
    ''' Calc energy of SF with Supercell approach
    Parameters
    ----------
    E_C14,E_SC : Energy (meV per atom)
    A          : Area of fault in supercell (Angstrom^2) 
    n_atoms    : Number of atoms in Supercell approach

    Returns
    -------
    Energy of SF in mJ/m2 for Supercell method 
    '''
    Edelta_SC_14 = E_SC - E_C14
    return [
        Edelta_SC_14 * n_atoms / A * _conv['meV_ang2__mJ_m2'],
        Edelta_SC_14 * n_atoms
    ]


def vec_a_hex(vol,c_a):
    ''' Return a_vector of a hexagonal cell given the vol and c/a ratio
    Parameters
    ----------
    vol        : Vol of hexagonal cell (Angstrom^3)
    c_a        : c/a ratio of hexagonal cell
    
    Returns
    -------
    vec a      : a_vector of hexagonal cell (Angstrom) 
    '''
    return (vol/(np.sin(np.radians(120))*c_a))**(1/3)

def area_hex_basal(vol,c_a):
    ''' Return basal area of a hexagonal cell given the vol and c/a ratio
    Parameters
    ----------
    vol        : Vol of hexagonal cell (Angstrom^3)
    c_a        : c/a ratio of hexagonal cell
    
    Returns
    -------
    area       : Basal area of hexagonal cell (Angstrom^2) 
    '''
    vec_a = (vol/(np.sin(np.radians(120))*c_a))**(1/3)
    return vec_a**2 * np.sin(np.radians(120))


class projects_path_keeper():
    '''manage (show,add,remove,save,load) the path information for each project 
    and a little comment for each
    '''
    def __init__(self, work_directory, database_filename):
        self.wk_dir = op.join(work_directory, '')
        self.db_filename = database_filename
        self.data = {}
        if op.isdir(self.wk_dir):
            self.db_load()
        else:
            print("Working directory not found!")

    def db_create(self):
        if op.isfile(op.join(self.wk_dir, self.db_filename)):
            print("Databse already exist! Load with .db_load()")
        else:
            _ = {}
            json.dump(_, open(op.join(self.wk_dir, self.db_filename), 'w'))
            print("Empty database created. Add project data by .prj_add()")

    def db_load(self):
        try:
            self.data = json.load(open(op.join(self.wk_dir, self.db_filename)))
        except (IOError, e):
            print(("Database not found! Create a new one with .db_create()",
                  e.message))
        else:
            print("database of projects' path loaded.")

    def db_save(self):
        json.dump(self.data,
                  open(op.join(self.wk_dir, self.db_filename), 'w'),
                  sort_keys=True)

    def db_show(self):
        #assert self.data != {}, "No data is available!"
        return list(self.data.keys())

    def prj_add(self, project_name, project_path_data):
        if project_name not in self.data:
            self.data[project_name] = project_path_data
        else:
            print((
                project_name +
                " is already in database, to modify it use .prj_modify command"
            ))

    def prj_modify(self, project_name, project_tag, new_value):
        if project_name in self.data:
            self.data[project_name][project_tag] = new_value
        else:
            print((project_name +
                  " is not in the database, to add it use .prj_add command"))

    def prj_remove(self, project_name):
        if project_name in self.data:
            self.data.pop(project_name)
            print((project_name + " removed"))
        else:
            print((
                project_name +
                " is not in the database, use .db_show() command to see list of projects"
            ))

    def prj_show(self, project_name):
        if project_name in self.data:
            return self.data[project_name]
        else:
            print((
                project_name +
                " is not in the database, use .db_show() command to see list of projects"
            ))


class MatPhaseObj():
    ''' this is the main object for each phase
    it will contain e.g. composition, structure, Birch-Murnaghan E-V curve,
    vibration contribution, 
    '''
    def __init__(self, name, project_dict, def_name=None):
        if def_name == None:
            (filename, line_number, function_name,
             text) = traceback.extract_stack()[-2]
            def_name = text[:text.find('=')].strip()
        self.defined_name = def_name

        self.name = name
        self.project_dict = project_dict
        self.data = project_dict
        self.magnetic_calc = False
        # get as input not static
        self.path_dbs = op.join(op.expanduser('~') + "/Git/AZscripts/db", "")
        self._conv = json.load(open(self.path_dbs + "_conv.txt"))
        self._flag_OUTCAR = json.load(open(self.path_dbs + "_flag_OUTCAR.txt"))
        self._flag_OSZICAR = json.load(
            open(self.path_dbs + "_flag_OSZICAR.txt"))

        self._file_name = {
            "Harmonic": 'thermo.out',
            "Murn": 'murn.dat',
            "EV": 'Bohr3-Hartree.dat',
            "OUTCAR": 'OUTCAR',
            "OSZICAR": 'OSZICAR',
            "vasprun": 'vasprun.xml',
        }
        self._folder_name = {
            "thermo": 'thermo/',
            "background": 'forces_background/',
        }
        self._file_exist = {
            "Harmonic":
            False,  # the file thermo.out which contains harmonic free energy
            "background": False,
            "Murn": False,
            "EV": False,
            "staticOUT": False,
        }
        self._folder_exist = {
            "harmonic":
            False,  # the main folder contains displaced structures and forces_background
            "thermo": False,
            "background": False,
            "Murn": False,
            "static": False,
        }

        self._status = {
            "input_verification": False,
            "data_loaded": False,
        }

    def __str__(self):
        return str([
            'Phase:', self.name, 'Status:', self._status, 'Folders:',
            self._folder_exist, 'Files:', self._file_exist
        ])

    @staticmethod
    def file_type(filename):
        magic_dict = {
            "\x1f\x8b\x08": "gz",
            "\x42\x5a\x68": "bz2",
            "\x50\x4b\x03\x04": "zip",
        }

        max_len = max(len(x) for x in magic_dict)
        with open(filename) as f:
            file_start = f.read(max_len)
        for magic, filetype in list(magic_dict.items()):
            if file_start.startswith(magic):
                return filetype
        return "no match"

    @staticmethod
    def getFileName(path, pattern):
        _ = glob.glob(op.join(path, pattern) + "*")
        if not _:
            print(("Error: File " + pattern + " not found"))
            return 0
        elif len(_) > 1:
            print(("Error: more than one file found starting wiht", pattern,
                  [i.split('/')[-1] for i in _]))
            return 0
        else:
            return _[0]

    @staticmethod
    def openFile(inputFile):
        if op.isfile(inputFile):
            checkType = MatPhaseObj.file_type(inputFile)
            if checkType == "gz":
                outputFile = gzip.open(inputFile, "rb").readlines()
            if checkType == "bz2":
                outputFile = bz2.BZ2File(inputFile, "rb").readlines()
            elif checkType == "no match":
                outputFile = open(inputFile, "r").readlines()
            return outputFile
        else:
            print("Error: File not found")
            return

    def data_extractor_vasprun(self, vasprun_path):
        self.vasprun = pv.Vasprun(vasprun_path)
        print((self.name, " vasprun data extracted."))

    def data_extractor_OSZICAR(self, OSZICAR_path):
        penalty, Lambda = 0.0, 0.0
        _fileOSZICAR = MatPhaseObj.getFileName(OSZICAR_path,
                                               self._file_name["OSZICAR"])
        if _fileOSZICAR:
            _ = MatPhaseObj.openFile(_fileOSZICAR)
            for line in _:
                if self._flag_OSZICAR["penalty"] in line:
                    penalty = float(line.split()[2])  # eV per cell
                    Lambda = float(line.split()[-1])
            if penalty:
                return penalty, Lambda
            return 0.0, 0.0

        else:
            print("Error: File not found")
        return

    def data_extractor_murn(self):
        if self._file_exist["EV"]:
            self.Ene_Vol = np.loadtxt(self._fileEV)
        if self._file_exist["Murn"]:
            self.murnEV = np.loadtxt(self._fileMurn)
            fp = open(self._fileMurn)
            for i, line in enumerate(fp):
                if i == 1:
                    self.murnB0 = float(line.split()[-2])
                elif i == 2:
                    self.murnB0p = float(line.split()[-1])
                elif i == 3:
                    self.murnE0hartree = float(line.split()[-1])  # hartree
                    self.murnE0eV = self.murnE0hartree * self._conv["hart2ev"]
                elif i == 4:
                    # bohrradius^3
                    self.murnV0bohr = float(line.split()[-1])
                    self.murnV0angst = self.murnV0bohr * \
                        self._conv["vol_bohr2angst"]
                elif i > 5:
                    break
            fp.close()

    def data_extractor_harmonic(self):
        if self._file_exist["Harmonic"]:
            self.Ene_harmonic = np.loadtxt(self._fileTherm)

    def data_extractor_OUTCAR(self, OUTCARfile):
        output = {}
        output['atoms'] = []
        _ = MatPhaseObj.openFile(OUTCARfile)
        for line in _:
            if self._flag_OUTCAR["energy"] in line:
                output['E_Sigma0_perCell_eV'] = float(
                    line.split()[-1])  # eV per cell
            if self._flag_OUTCAR["ionsNum"] in line:
                output['atomNum'] = list(map(int, line.split("=")[-1].split()))
            if self._flag_OUTCAR["ionsName"] in line:
                output['atoms'].append(line.split()[-2])
            if self._flag_OUTCAR["volume"] in line:
                output['vol'] = float(line.split()[-1])
        output['AtomTotalNum'] = sum(output['atomNum'])
        output['Atom_Num'] = {}
        output['Atom_Type_Num'] = len(output['atoms'])
        for i in range(output['Atom_Type_Num']):
            output['Atom_Num'][output['atoms'][i]] = output['atomNum'][i]

        output['vol_atom'] = output['vol'] / output['AtomTotalNum']
        output['E_Sigma0_perAtom_eV'] = output['E_Sigma0_perCell_eV'] / \
            output['AtomTotalNum']  # eV per atom

        counter = 0
        output['MagX'] = np.zeros((output['AtomTotalNum'], 5))
        output['MagY'] = np.zeros((output['AtomTotalNum'], 5))
        output['MagZ'] = np.zeros((output['AtomTotalNum'], 5))
        for line in reversed(_):
            if "magnetization (x)" in line:
                is_ymag = 'magnetization (y)' in _[-counter - 1 +
                                                   output['AtomTotalNum'] + 9]
                is_zmag = 'magnetization (z)' in _[
                    -counter - 1 + 2 * (output['AtomTotalNum'] + 9)]
                for i in range(output['AtomTotalNum']):
                    output['MagX'][i] = np.asarray(
                        list(map(float, _[-counter - 1 + 4 + i].split())))  # x
                    if is_ymag:
                        output['MagY'][i] = np.asarray(
                            list(map(
                                float,
                                _[-counter - 1 + 4 + i +
                                  output['AtomTotalNum'] + 9].split())))  # y
                    if is_zmag:
                        output['MagZ'][i] = np.asarray(
                            list(map(
                                float,
                                _[-counter - 1 + 4 + i + 2 *
                                  (output['AtomTotalNum'] + 9)].split())))  # z
                break
            counter += 1
        if np.sum(np.nonzero(np.array(output['MagX'][:, -1]) != 0)) > 1 or\
                np.sum(np.nonzero(np.array(output['MagY'][:, -1]) != 0)) > 1 or \
                np.sum(np.nonzero(np.array(output['MagZ'][:, -1]) != 0)) > 1:
            self.magnetic_calc = True

        return output

    def loadData(self):
        self._status['data_loaded'] = True
        self.data_extractor_harmonic()
        self.data_extractor_murn()
        if self._file_exist["staticOUT"]:
            self.static = self.data_extractor_OUTCAR(self._fileOUTCAR)
            self.static['penalty'], self.static[
                'Lambda'] = self.data_extractor_OSZICAR(
                    self.project_dict['static']['path'])
        if self._file_exist["background"]:
            self.background = self.data_extractor_OUTCAR(
                self._fileOUTCARbackground)
            self.background['penalty'], self.background[
                'Lambda'] = self.data_extractor_OSZICAR(
                    op.join(self.project_dict['harmonic']['path'],
                            self._folder_name["background"]))


#        self.data={}  why it is here???
        try:
            self.d_tot_ene_per_atom_eV, self.d_tot_penalty_ene_eV, self.d_lambda,\
                self.d_tot_vol_atom_ang3, self.d_tot_atom_num,\
                self.d_MagX, self.d_MagY, self.d_MagZ =\
                self.static['E_Sigma0_perAtom_eV'], self.static['penalty'],\
                self.static['Lambda'], self.static['vol_atom'], self.static['AtomTotalNum'],\
                self.static['MagX'], self.static['MagY'], self.static['MagZ']
        except:
            try:
                self.d_tot_ene_per_atom_eV, self.d_tot_penalty_ene_eV, self.d_lambda,\
                    self.d_tot_vol_atom_ang3, self.d_tot_atom_num,\
                    self.d_MagX, self.d_MagY, self.d_MagZ =\
                    self.background['E_Sigma0_perAtom_eV'], self.background['penalty'],\
                    self.background['Lambda'], self.background['vol_atom'],\
                    self.background['AtomTotalNum'], self.background['MagX'],\
                    self.background['MagY'], self.background['MagZ']
            except:
                try:
                    self.d_tot_ene_per_atom_eV, self.d_tot_penalty_ene_eV, self.d_lambda,\
                        self.d_tot_vol_atom_ang3, self.d_tot_atom_num =\
                        self.murnE0eV, np.NaN, np.NaN, self.murnV0angst, np.NaN
                except:
                    print((
                        "At least provide one of the background, murn or static data! ",
                        self.defined_name))

    def verifyInput(self):
        self._status['input_verification'] = True
        if self.project_dict['harmonic']['path']:
            self.project_dict['harmonic']['path'] =\
                op.join(self.project_dict['harmonic']['path'], '')
            if op.isdir(self.project_dict['harmonic']['path']):
                self._folder_exist["harmonic"] = True
                if op.isdir(self.project_dict['harmonic']['path'] +
                            self._folder_name["thermo"]):
                    self._folder_exist["thermo"] = True
                if op.isdir(self.project_dict['harmonic']['path'] +
                            self._folder_name["background"]):
                    self._folder_exist["background"] = True

                self._fileTherm = self.project_dict['harmonic']['path']\
                    + self._folder_name["thermo"]+self._file_name["Harmonic"]
                if op.isfile(self._fileTherm):
                    self._file_exist["Harmonic"] = True

                self._fileOUTCARbackground = MatPhaseObj.getFileName(
                    self.project_dict['harmonic']['path'] +
                    self._folder_name["background"], self._file_name["OUTCAR"])
                if op.isfile(self._fileOUTCARbackground):
                    self._file_exist["background"] = True

        if self.project_dict['murn']['path']:
            self.project_dict['murn']['path'] = op.join(
                self.project_dict['murn']['path'], '')
            if op.isdir(self.project_dict['murn']['path']):
                self._folder_exist["Murn"] = True
                self._fileMurn = self.project_dict['murn']['path'] + \
                    self._file_name["Murn"]
                if op.isfile(self._fileMurn):
                    self._file_exist["Murn"] = True
                self._fileEV = self.project_dict['murn']['path'] + \
                    self._file_name["EV"]
                if op.isfile(self._fileEV):
                    self._file_exist["EV"] = True

        try:
            if self.project_dict['static']['path']:
                # will add the trailing slash if it's not already there
                self.project_dict['static']['path'] = op.join(
                    self.project_dict['static']['path'], '')
                if op.isdir(self.project_dict['static']['path']):
                    self._folder_exist["static"] = True
                    self._fileOUTCAR = MatPhaseObj.getFileName(
                        self.project_dict['static']['path'],
                        self._file_name["OUTCAR"])
                    if op.isfile(self._fileOUTCAR):
                        self._file_exist["staticOUT"] = True
        except:
            pass