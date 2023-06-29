# OpenFOAM
OpenFOAM (for "Open-source Field Operation And Manipulation") is a C++ toolbox for the development of customized numerical solvers, and pre-/post-processing utilities for the solution of continuum mechanics problems, most prominently including computational fluid dynamics (CFD).

The OpenFOAM software is used in research organisations, academic institutes and across many types of industries, for example, automotive, manufacturing, process engineering and environmental engineering. 

Source1 : https://www.openfoam.com/

Source2 : https://en.wikipedia.org/wiki/OpenFOAM

## To build OpenFOAM on Altra

## Step 1 : Pre-recs
```
sudo apt-get install build-essential cmake git ca-certificates flex libfl-dev bison zlib1g-dev libboost-system-dev \ 
libboost-thread-dev libopenmpi-dev openmpi-bin gnuplot libreadline-dev libncurses-dev libxt-dev libqt5x11extras5-dev \ 
libxt-dev qt5-default qttools5-dev curl
```

## Step 2 : Downloading Source Code
```
git clone https://github.com/OpenFOAM/OpenFOAM-10.git
git clone https://github.com/OpenFOAM/ThirdParty-10.git
```

## Step 3 : Setting Environment

For standard location installation
```
source $HOME/OpenFOAM/OpenFOAM-dev/etc/bashrc
```
For non-standard install location, change $HOME to appropriate folder. Test this by executing
```
echo $ParaView_VERSION
```

## Step 4 : Installing Third Party Software
```
#Change to the ThirdParty-10 directory and execute -
./Allwmake
./makeParaView
wmRefresh
```

## Step 5 : Compiling OpenFOAM
```
#Change to OpenFOAM-10 directory and execute -
./Allwmake -j
```

## Performance
