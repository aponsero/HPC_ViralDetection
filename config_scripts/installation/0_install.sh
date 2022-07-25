#!/bin/bash -l
#SBATCH --job-name=install
#SBATCH --account=
#SBATCH --output=outputr%j.txt
#SBATCH --error=errors_%j.txt
#SBATCH --partition=small
#SBATCH --time=02:00:00
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=1000


# load job configuration
cd $SLURM_SUBMIT_DIR
source ../config.sh

# create environment
source $CONDA/etc/profile.d/conda.sh
#conda create -n viral -c conda-forge -c bioconda virsorter=2
#conda activate viral
#conda install -c bioconda prodigal
#conda install -c bioconda hmmer
#conda install -c conda-forge biopython
#conda install -c anaconda pandas
#conda install matplotlib
#conda install seaborn
#conda install -c anaconda numpy
#conda install scikit-learn
#conda install -c bioconda vibrant==1.2.0

# Virsorter database 
#conda activate viral
#cd /scratch/project_2001503/alise/my_data/databases
#virsorter setup -d db -j 4

# Vibrant database
#conda activate viral
#download-db.sh

# create dvf environment and install
conda create --name dvf python=3.6 numpy theano=1.0.3 keras=2.2.4 scikit-learn Biopython h5py




