#!/bin/bash

#####################################################################
# This example script installs and runs the HEP-Benchmark-Suite
#
# The Suite configuration file
#       bmkrun_config.yml
# is included in the script itself.
#
# The configuration script sets the benchmarks to run and
# defines some meta-parameters, including tags as the SITE name.
#
# The only requirements to run are
# git python3-pip singularity
#####################################################################


while getopts ':c:k:iprs:wd:n:' OPTION; do

  case "$OPTION" in
    c)
      cert="$OPTARG"
      echo "Setting Certificate to $cert"
      ;;

    k)
      key="$OPTARG"
      echo "Option b used with: $key"
      ;;

    i)
      install_only=true
      echo "Install only do not run"
      ;;
    r)
      run_only=true
      echo "Run only do not install"
      ;;
    p)
      publish=true
      echo "Publish results?"
      ;;
    s)
      site="$OPTARG"
      echo "Setting site to $site"
      ;;
    w)
      install_from_wheels=true
      echo "Installing the suite from wheels"
      ;;
    d)
      workdir="$(realpath $OPTARG)"
      echo "Setting the working directory to $workdir"
      ;;
    n)
      ncores="$OPTARG"
      if [ $ncores -gt `nproc` ] || [ $(echo "$ncores%4" | bc) -ne 0 ]; then
          echo -e "[ERROR] -n can be used only to reduce the number of server's cores 
          targetted by the benchmark.
          Please select an argument value in the range 4 < value < `nproc` and multiple of 4"
          exit 1
      else
          echo "Limiting the execution to $ncores cores of the server"
      fi
      ;;

    ?)
      echo "
Usage: $(basename $0) [OPTIONS]

Options:
  -c path       Path to the certificate to use to authenticate to AMQ
  -k path       Path to the key of the certificate used for AMQ
  -i            Install only, don't run the suite
  -r            Run only, skip installation
  -p            Publish the results to AMQ
  -s site       Site name to tag the results with
  -w            Install the suite from wheels rather than the repository
  -n            Max number of cores of the server that will be used by the benchmark"
      exit 1
      ;;
  esac

done

#--------------[Start of user editable section]----------------------
SITE="${site}"  # Replace somesite with a meaningful site name
PUBLISH="${publish:-false}"  # Set to true in order to publish results in AMQ
CERTIFKEY="${key:-PATH_TO_CERT_KEY}"
CERTIFCRT="${cert:-PATH_TO_CERT}"
INSTALL_ONLY="${install_only:-false}"
RUN_ONLY="${run_only:-false}"
INSTALL_FROM_WHEELS="${install_from_wheels:-false}"
WORKDIR="${workdir:-$(pwd)/workdir}"
NCORES="${ncores:-`nproc`}"
#--------------[End of user editable section]-------------------------

# AMQ
SERVER=dashb-mb.cern.ch
PORT=61123
TOPIC=/topic/vm.spec

SCRIPT_VERSION="1.2"
HEPSCORE_VERSION="v1.5"
SUITE_VERSION="v2.2-rc7" # Use "latest" for the latest stable release

RUNDIR=$WORKDIR/suite_results
MYENV="env_bmk"        # Define the name of the python environment
LOGFILE=$WORKDIR/output.txt
SUITE_CONFIG_FILE=bmkrun_config.yml
HEPSCORE_CONFIG_FILE=hepscore_config.yml
GiB_PER_CORE=1

SUPPORTED_PY_VERSIONS=(py36 py38 py39)
DEFAULT_PY_VERSION="py36"

# Colors
GREEN='\033[0;32m'
CYAN='\033[0;36m'
ORANGE='\033[1;33m'
NC='\033[0m' # No Color

echo "Running script: $0 - version: $SCRIPT_VERSION"
cd $( dirname $0)

create_python_venv(){
    cd $WORKDIR
    python3 -m venv $MYENV        # Create a directory with the virtual environment
    source $MYENV/bin/activate    # Activate the environment
}

validate_params(){
    validate_site
    validate_publish
}

validate_site(){
    if [ -z "$SITE" ]; then
        echo "The site name is not set. Please use the -s SITE option or set the SITE variable in the script."
        exit 1
    fi
}

validate_publish(){
    if [ $PUBLISH == true ]; then
        if [ $CERTIFKEY == 'PATH_TO_CERT_KEY' ]; then
            echo "The certificate key is not set. Please set the CERTIFKEY variable in the script."
            exit 1
        fi

        if [ $CERTIFCRT == 'PATH_TO_CERT' ]; then
            echo "The certificate is not set. Please set the CERTIFCRT variable in the script."
            exit 1
        fi
    fi
}

hepscore_install(){

    echo "Creating the WORKDIR $WORKDIR"
    mkdir -p $WORKDIR
    chmod a+rw -R $WORKDIR

    validate_params
    create_python_venv
    install_suite

    NCOPIES_1THREADS=$NCORES
    NCOPIES_4THREADS=$(echo "$NCORES/4" | bc)
    cat > $WORKDIR/$HEPSCORE_CONFIG_FILE <<EOF
hepscore_benchmark:
  benchmarks:
    atlas-gen_sherpa-ma-bmk:
      results_file: atlas-gen_sherpa-ma_summary.json
      ref_scores:
        gen: 38.58
      weight: 1.0
      version: v2.0
      args:
        threads: 1
        events: 200
        copies: ${NCOPIES_1THREADS}
    atlas-reco_mt-ma-bmk:
      results_file: atlas-reco_mt-ma_summary.json
      ref_scores:
        reco: 9.062
      weight: 1.0
      version: v2.0
      args:
        threads: 4
        events: 100
        copies: ${NCOPIES_4THREADS}
    cms-gen-sim-run3-ma-bmk:
      results_file: cms-gen-sim-run3-ma_summary.json
      ref_scores:
        gen-sim: 2.665
      weight: 1.0
      version: v1.0
      args:
        threads: 4
        events: 20
        copies: ${NCOPIES_4THREADS}
    cms-reco-run3-ma-bmk:
      results_file: cms-reco-run3-ma_summary.json
      ref_scores:
        reco: 4.814
      weight: 1.0
      version: v1.1
      args:
        threads: 4
        events: 50
        copies: ${NCOPIES_4THREADS}
    lhcb-sim-run3-ma-bmk:
      results_file: lhcb-sim-run3-ma_summary.json
      ref_scores:
        sim: 1950
      weight: 1.0
      version: v1.0
      args:
        threads: 1
        events: 10
        copies: ${NCOPIES_1THREADS}
    belle2-gen-sim-reco-ma-bmk:
      results_file: belle2-gen-sim-reco-ma_summary.json
      ref_scores:
        gen-sim-reco: 15.4
      weight: 1.0
      version: v2.0
      args:
        threads: 1
        events: 50
        copies: ${NCOPIES_1THREADS}
    alice-digi-reco-core-run3-ma-bmk:
      results_file: alice-digi-reco-core-run3-ma_summary.json
      ref_scores:
        digi-reco: 0.762
      weight: 1.0
      version: v2.1
      args:
        threads: 4
        events: 10
        copies: ${NCOPIES_4THREADS}
  settings:
    name: HEPscore23Beta
    reference_machine: "E423521X1B04810-B Gold 6326 CPU @ 2.90GHz - 64 cores SMT ON"
    registry: oras://gitlab-registry.cern.ch/hep-benchmarks/hep-workloads-sif
    addarch: true
    method: geometric_mean
    repetitions: 1
    retries: 1
    scaling: 1018
    container_exec: singularity
EOF



    # CONFIG_FILE_CREATION
    cat > $WORKDIR/$SUITE_CONFIG_FILE <<EOF2
activemq:
  server: $SERVER
  topic: $TOPIC
  port: $PORT
  ## include the certificate full path (see documentation)
  key: $CERTIFKEY
  cert: $CERTIFCRT

global:
  benchmarks:
  - hepscore
  mode: singularity
  publish: $PUBLISH
  rundir: $RUNDIR
  show: true
  tags:
    site: $SITE
    ncores: $NCORES

hepscore:
  version: $HEPSCORE_VERSION
  config: $WORKDIR/$HEPSCORE_CONFIG_FILE
  options:
      userns: True
      clean: True
EOF2

    if [ -f $WORKDIR/$HEPSCORE_CONFIG_FILE ]; then
        cat $WORKDIR/$HEPSCORE_CONFIG_FILE
    fi
}

install_suite(){
    if [ $SUITE_VERSION = "latest" ];  then
        SUITE_VERSION=$(curl --silent https://hep-benchmarks.web.cern.ch/hep-benchmark-suite/releases/latest)
        echo "Latest suite release selected: ${SUITE_VERSION}."
    fi
    
    if [ $INSTALL_FROM_WHEELS == true ]; then
        install_suite_from_wheels
    else
        install_suite_from_repo
    fi
}

install_suite_from_repo(){
    pip3 install --upgrade pip
    pip3 install git+https://gitlab.cern.ch/hep-benchmarks/hep-score.git@$HEPSCORE_VERSION
    pip3 install git+https://gitlab.cern.ch/hep-benchmarks/hep-benchmark-suite.git@$SUITE_VERSION
}

install_suite_from_wheels() {
    # Try to get system's default python3 and see if it's one of the supported version; fallback to the default otherwise
    PY_VERSION=$(python3 -V | awk '{split($2, version, "."); print "py"version[1] version[2]}')

    if [[ ! "$PY_VERSION" =~ ^py3[0-9]{1,2}$ ]] || [[ ! " ${SUPPORTED_PY_VERSIONS[*]} " =~ " ${PY_VERSION} " ]]; then
        echo "Your default python3 version (${PY_VERSION}) isn't supported. Falling back to ${DEFAULT_PY_VERSION}."
        PY_VERSION=$DEFAULT_PY_VERSION
    fi

    # Set suite version to install. Use "latest" for the latest stable release
    if [ $SUITE_VERSION = "latest" ];  then
       echo "Latest release selected."
       SUITE_VERSION=$(curl --silent https://hep-benchmarks.web.cern.ch/hep-benchmark-suite/releases/latest)
    fi

    # Download and extract the wheels
    ARCH=$(uname -m)
    wheels_version="hep-benchmark-suite-wheels-${PY_VERSION}-${ARCH}-${SUITE_VERSION}.tar"
    echo -e "-> Downloading wheel: $wheels_version \n"    
    curl -O "https://hep-benchmarks.web.cern.ch/hep-benchmark-suite/releases/${SUITE_VERSION}/${wheels_version}"
    tar xvf ${wheels_version}

    # Update pip before installing any other wheel
    if ls suite_wheels/pip* 1> /dev/null 2>&1; then
        python3 -m pip install suite_wheels/pip*.whl
    fi

    python3 -m pip install suite_wheels/*.whl
}

ensure_suite_is_not_running() {
    PS_AUX_BMKRUN=$(ps aux | grep -c bmkrun)
    if (( PS_AUX_BMKRUN > 1 )); then
        echo -e "${ORANGE}Another instance of the HEP Benchmark Suite is already running. Please wait for it to finish before running the suite again.${NC}"
        exit 1
    fi
}

create_tarball() {
    # Create tarball to be sent to the admins if the suite failed but still produced data
    if [ $SUITE_SUCCESSFUL -ne 0 ] && [ $RUNDIR_DATE ] ;
    then
        LOG_TAR="${SITE}_${RUNDIR_DATE}.tar"
        find $RUNDIR/$RUNDIR_DATE/ \( -name archive_processes_logs.tgz -o -name hep-benchmark-suite.log -o -name HEPscore*.log \) -exec tar -rf $LOG_TAR {} &>/dev/null \;
            echo -e "${ORANGE}\nThe suite has run into errors. If you need help from the administrators, please contact them by email and attach ${WORKDIR}/${LOG_TAR} to it ${NC}"
    fi
}

print_amq_send_command() {
    # Print command to send results if they were produced but not sent
    if [ $RESULTS ] && { [ $PUBLISH == false ] || [ $AMQ_SUCCESSFUL -ne 0 ] ; }; then
        echo -e "${GREEN}\nThe results were not sent to AMQ. In order to send them, you can run (--dryrun option available):"
        echo -e "${WORKDIR}/${MYENV}/bin/bmksend -c ${WORKDIR}/${SUITE_CONFIG_FILE} ${RUNDIR} ${NC}"
    fi
}

check_memory_difference() {
    # Print warning message in case of memory increase
    MEM_DIFF=$(($MEM_AFTER - $MEM_BEFORE))
    if (( MEM_DIFF > 1048576 )); then
      echo -e "${ORANGE}The memory usage has increased by more than 1 GiB since the start of the script. Please check there are no zombie processes in the machine before running the script again.${NC}"
    fi
}

check_workdir_space() {
    # Check if there is enough space in the workdir
    workdir_space=$(df -k $WORKDIR | awk 'NR==2 {print $4}')
    minimum_space=$((GiB_PER_CORE * 1024 * 1024 * $(nproc)))
    if (( workdir_space < minimum_space )); then
        echo -e "${ORANGE}There is less than $((minimum_space/1024/1024))GiB of space left in the workdir ($((workdir_space/1024/1024))GiB). Please free some space before running the script again.${NC}"
        exit 1
    fi
}

hepscore_run(){

    if [[ -d $WORKDIR && -f $WORKDIR/$MYENV/bin/activate ]]; then 
	    create_python_venv
    else
	    echo "The suite installation cannot be found; please run $0 to install and run it or $0 -i to install it only"
    fi

    ensure_suite_is_not_running
    check_workdir_space

    MEM_BEFORE=$(awk '/MemAvailable/ {print $2}' /proc/meminfo)
    bmkrun -c $SUITE_CONFIG_FILE | tee -i $LOGFILE
    MEM_AFTER=$(awk '/MemAvailable/ {print $2}' /proc/meminfo)

    RESULTS=$(awk '/Full results can be found in.*/ {print $(NF-1)}' $LOGFILE)
    RUNDIR_DATE=$(perl -n -e'/^.*(run_2[0-9]{3}-[0-9]{2}-[0-9]{2}_[0-9]{4}).*$/ && print $1; last if $1' $LOGFILE)
    SUITE_SUCCESSFUL=$(! grep -q ERROR $LOGFILE; echo $?)
    AMQ_SUCCESSFUL=$(grep -q "Results sent to AMQ topic" $LOGFILE; echo $?)
    rm -f $LOGFILE

    create_tarball
    print_amq_send_command
    check_memory_difference
}

if [[ $INSTALL_ONLY == false && $RUN_ONLY == false ]] ; then

    hepscore_install
    hepscore_run

elif [[ $INSTALL_ONLY == true  && $RUN_ONLY == false ]] ; then
    hepscore_install

elif [[ $RUN_ONLY == true && $INSTALL_ONLY == false ]] ; then 
    hepscore_run

else 
    echo "You can't use -i and -r together."

fi
