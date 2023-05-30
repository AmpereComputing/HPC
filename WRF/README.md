# WRF

The Weather Research and Forecasting (WRF) Model is a state of the art mesoscale numerical weather prediction system designed for both atmospheric research and operational forecasting applications. It features two dynamical cores, a data assimilation system, and a software architecture supporting parallel computation and system extensibility.

For researchers, WRF can produce simulations based on actual atmospheric conditions (i.e., from observations and analyses) or idealized conditions. WRF offers operational forecasting a flexible and computationally-efficient platform, while reflecting recent advances in physics, numerics, and data assimilation contributed by developers from the expansive research community.

Source : https://www.mmm.ucar.edu/models/wrf

# To Build WRF on AltraMax

## 1 Download Sources
```
a. WRF
wget https://github.com/wrf-model/WRF/releases/download/v4.4.2/
b. NETCDF (C and Fortran)
wget https://github.com/Unidata/netcdf-c/archive/refs/tags/v4.9.0.tar.gz
wget http://mirror.archlinuxarm.org/aarch64/community/netcdf-fortran-4.6.0-1-aarch64.pkg.tar.xz
c. Install CSH
sudo apt install csh
```

## 2 Untar sources
```
tar -xzf v4.4.2 
tar -xzf v4.9.0.tar.gz
unxz -kd netcdf-fortran-4.6.0-1-aarch64.pkg.tar.xz 
tar -xf netcdf-fortran-4.6.0-1-aarch64.pkg.tar
```

## 3 Build netcdf
```cd /opt/netcdf-c-4.9.0/
./configure --prefix=/opt/usr/ --disable-hdf5
make -j && make install
```
## 4 Build WRF
```./configure
./compile em_real
```
