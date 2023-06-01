To Build Quantum Espresso on Altra Max

#1 Pre-recs
For open source install OS available libopenblas and fftw3 using apt/dnf/yum

#2 Download
Source Code
wget https://github.com/QEF/q-e/archive/refs/tags/qe-7.0.tar.gz
Datasets
git clone https://github.com/QEF/benchmarks.git

#3 Install
cd q-e-qe-7.0/

./configure --prefix=/opt/QuantumEspress

# For a non-standard install : ./configure LIBDIRS="/opt/MyBlisDir/lib/altramax"\
# edit make.inc file to include under LAPACK_LIBS : -L/opt/MyBlisDir/lib/altramax -lblis 

make -j20 all
make install
