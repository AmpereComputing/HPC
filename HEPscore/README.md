# CERN-HEP : High Energy Physics : HEPscore
The HEPscore application orchestrates the execution of user-configurable benchmark suites based on individual benchmark containers.It runs the specified benchmark containers in sequence, collects their results, and computes a final overall score.
HEPscore23Beta is a benchmark based on containerized HEP workloads that the HEPiX Benchmarking Working Group is targeting to eventually replace HEPSPEC06 as the standard HEPiX/WLCG benchmark.  It is currently in a proof of concept development state, and consists of the following workloads from the HEP Workloads project:
atlas-gen_sherpa-ma-bmk
atlas-reco_mt-ma-bmk
cms-gen-sim-run3-ma-bmk
cms-reco-run3-ma-bmk
lhcb-gen-sim-2021-bmk
belle2-gen-sim-reco-2021-bmk
alice-digi-reco-core-run3-bmk

Source : https://gitlab.cern.ch/hep-benchmarks/hep-score/-/tree/master/#hepscore23beta-benchmark

## Building HEPscore on Altra

## Step 1 : Prerequisites
```
#Note: To run this suite, ensure that atleast 2GB per core memory is available and atleast 20GB disk space
sudo apt-get update
sudo apt-get install -y build-essential libseccomp-dev libglib2.0-dev pkg-config squashfs-tools cryptsetup runc python3.10-venv libglib2.0-dev
```

## Step 2 : Download and install GO
```
#We will be installing in non standard locations. 

mkdir -p /opt/HEPscore
cd /opt/HEPscore
wget https://go.dev/dl/go1.21.0.linux-arm64.tar.gz
tar -xzf go1.21.0.linux-arm64.tar.gz
cd go/bin
export PATH=$PATH:`pwd`
```
## Step 3 : Download and install Singularity
```
cd /opt/HEPscore
wget https://github.com/sylabs/singularity/releases/download/v3.11.4/singularity-ce-3.11.4.tar.gz
tar -xzf singularity-ce-3.11.4.tar.gz
mv singularity-ce-3.11.4/ singularity-ce-3.11.4_installation/
cd singularity-ce-3.11.4_installation
./mconfig --prefix=/opt/HEPscore/singularity-3.11.4 --without-suid
cd /opt/HEPscore/singularity-ce-3.11.4/builddir
make -j
make -j install

cd /opt/HEPscore/singularity-3.11.4/bin
export PATH=$PATH:`pwd`
```

## Step 4 : HEPscore Installation
```
cd /opt/HEPscore/
pip3 install --user --upgrade pip
#Copy the run_HEPscore_configurable_ncores.sh provided with this repo to /opt/HEPscore
chmod +x run_HEPscore_configurable_ncores.sh
```

## Step 5 : Run benchmark.
```
./run_HEPscore_configurable_ncores.sh -s test -n 128
#Note : change -n (num_cores) to according to the core availability
```

## Performance Expectation
```
=========================================================
BENCHMARK RESULTS FOR ampere-Altramax
=========================================================
Suite start: 2023-09-07T11:18:36Z
Suite end:   2023-09-07T13:24:01Z
Machine CPU Model: Neoverse-N1
HEPSCORE Benchmark = 1569.68 over benchmarks dict_keys(['atlas-gen_sherpa-ma-bmk', 'atlas-reco_mt-ma-bmk', 'cms-gen-sim-run3-ma-bmk', 'cms-reco-run3-ma-bmk', 'lhcb-sim-run3-ma-bmk', 'belle2-gen-sim-reco-ma-bmk', 'alice-digi-reco-core-run3-ma-bmk'])
```
