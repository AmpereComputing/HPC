# SpecFem3D
SPECFEM3D_Cartesian simulates acoustic (fluid), elastic (solid), coupled acoustic/elastic, poroelastic or seismic wave propagation in any type of conforming mesh of hexahedra (structured or not.)

It can, for instance, model seismic waves propagating in sedimentary basins or any other regional geological model following earthquakes. It can also be used for non-destructive testing or for ocean acoustics

SPECFEM3D was founded by Dimitri Komatitsch and Jeroen Tromp, and is now being developed by a large, collaborative, and inclusive community. A complete list of authors can be found at https://specfem3d.readthedocs.io/en/latest/authors/

# To Build SpecFem3D on AltraMax

## Prerequisites:
System Config :

OS : Ubuntu 20.04

GCC : 12.2.0

Kernel : 5.4.0-148-generic

To ensure a seamless build process, both, the math libraries and the benchmark are built inside the /opt directory.

## 1 Download Sources
```
git clone --recursive --branch devel https://github.com/SPECFEM/specfem3d.git
```

## 2 Build
```
cd specfem3d/
./configure FC=gfortran CC=gcc MPIFC=mpifort CFLAGS="-Ofast -mcpu=native -march=native" --with-mpi --enable-vectorization FCFLAGS="-Ofast"
make -j
```

## 3 Run a sample program on 4 processes
```
cd EXAMPLES/meshfem3D_examples/simple_model
./run_this_example.sh
```
