#!/bin/bash -l

# load job configuration
source config_scripts/config.sh

#
#makes sure sample file is in the right place
#
if [[ ! -f "$IN_LIST" ]]; then
    echo "$IN_LIST does not exist. Please provide the path for a list to process. Job terminated."
    exit 1
fi

if [[ ! -d "errout" ]]; then
	mkdir errout
fi

# get number of samples to process
export NUM_JOB=$(wc -l < "$IN_LIST")

# submit co_assemblies
echo "launching 2_CheckV.sh  as a job."

JOB_ID=`sbatch --job-name checkV -a 1-$NUM_JOB config_scripts/2_CheckV.sh`

