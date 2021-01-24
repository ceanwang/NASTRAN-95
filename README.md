# NASTRAN-95

(Under Windows 10)

# 1 Folder names explained

alt     - Alternation source

bd      - Bulk data source

bin     - Binary

demoout - demo case output

future  - source not used now

inp     - demo case file

mds     - machine depended source

mis     - machine independed source

rf      - Rigid frame

um      - user manual

utility - tools

# 2 Install

1. Download as ZIP. 
2. Unzip to C:\NASTRAN-95
3. Set C:\NASTRAN-95 into Windows 10's PATH
4. Add RFDIR variable and set its value as C:\NASTRAN-95\rf 

# 3 Run nastran.exe

For example you want to solve case C:\NASTRAN-95\inp\d01011a.inp

1. Run CMD.exe and change to C:\NASTRAN-95\inp
6. Key in 

   nastran d01011a.inp
   
# 4 tools explained

# 4.1 nasthelp.exe

Change to um folder, double click nasthelp.exe to start

# 4.2 nastplot.exe

When you put plot commands into inp file, nastran could generates plot file. 

# 4.3 ff.exe

# 4.4 chkfil.exe





# Original ReadMe

# NASTRAN-95

NASTRAN has been released under the  
[NASA Open Source Agreement version 1.3](https://github.com/nasa/NASTRAN-95/raw/master/NASA%20Open%20Source%20Agreement-NASTRAN%2095.doc).


NASTRAN is the NASA Structural Analysis System, a finite element analysis program (FEA) completed in the early 1970's. It was the first of its kind and opened the door to computer-aided engineering. Subsections of a design can be modeled and then larger groupings of these elements can again be modeled. NASTRAN can handle elastic stability analysis, complex eigenvalues for vibration and dynamic stability analysis, dynamic response for transient and steady state loads, and random excitation, and static response to concentrated and distributed loads, thermal expansion, and enforced deformations.

NOTE: There is no technical support available for this software.
