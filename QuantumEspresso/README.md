# Quantum Espresso
Quantum ESPRESSO is an integrated suite of Open-Source computer codes for electronic-structure calculations and materials modeling at the nanoscale. It is based on density-functional theory, plane waves, and pseudopotentials.

The Quantum ESPRESSO distribution consists of a “historical” core set of components, and a set of plug-ins that perform more advanced tasks, plus a number of third-party packages designed to be inter-operable with the core components. 
Source : https://www.quantum-espresso.org/

## To Build Quantum Espresso on Altra Max

## Step 1 : Prerequisitess
For open source install OS available libopenblas and fftw3 using apt/dnf/yum

For example
```
apt install libfftw3-dev libopenblas-dev
```
## Step 2 : Download
Source Code
```
wget https://github.com/QEF/q-e/archive/refs/tags/qe-7.0.tar.gz
Datasets
git clone https://github.com/QEF/benchmarks.git
```

## Step 3 : Install
```
cd q-e-qe-7.0/
./configure --prefix=/opt/QuantumEspress
# For a non-standard install : ./configure LIBDIRS="/opt/MyBlisDir/lib/altramax"\
# edit make.inc file to include under LAPACK_LIBS : -L/opt/MyBlisDir/lib/altramax -lblis 
make -j20 all
make install
```

## Step 4 : Run
Download Input data set 

git clone https://github.com/QEF/benchmarks.git

We will be using the AUSURF benchmark input for our tests.

sed -i '28 c \    electron_maxstep = 25' ./benchmarks/AUSURF112/ausurf.in

```
mpirun -n $NCORES --map-by ppr:$NCORES:node:PE=1 ../../bin/pw.x -npool 2 -ndiag 1 -ntg 1 -inp ./benchmarks/AUSURF112/ausurf.in > ausurf.res
# Replace $NCORES with # cores on your system
```
## Performance
On Altra 1P running 512GB DDR4 3200MHz the expected performance 1513 seconds
