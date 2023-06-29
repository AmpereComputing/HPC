# GROMACS
GROMACS is a versatile package to perform molecular dynamics, i.e. simulate the Newtonian equations of motion for systems with hundreds to millions of particles and is a community-driven project.
It is primarily designed for biochemical molecules like proteins, lipids and nucleic acids that have a lot of complicated bonded interactions, but since GROMACS is extremely fast at calculating the nonbonded interactions (that usually dominate simulations) many groups are also using it for research on non-biological systems, e.g. polymers and fluid dynamics.

Source : https://www.gromacs.org/about.html

## Building GROMACS on Altra

## Step 1 : Download Sources
```
wget https://ftp.gromacs.org/gromacs/gromacs-2023.1.tar.gz
```

## Step 2 : Install GROMACS
```
tar xfz gromacs-2023.1.tar.gz
cd gromacs-2023.1
mkdir build
cd build
cmake .. -DGMX_BUILD_OWN_FFTW=ON
make
make check
sudo make install
source /usr/local/gromacs/bin/GMXRC
```

## Step 3 : Run GROMACS
```
. . .
. . .
```

## Performance

