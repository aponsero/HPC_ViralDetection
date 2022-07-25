#!/bin/bash -l
#SBATCH --job-name=viral
#SBATCH --account=
#SBATCH --output=errout/outputr%j.txt
#SBATCH --error=errout/errors_%j.txt
#SBATCH --partition=small
#SBATCH --time=06:00:00
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --cpus-per-task=10
#SBATCH --mem-per-cpu=4000


# load job configuration
cd $SLURM_SUBMIT_DIR
source config_scripts/config.sh

# load environment
source $CONDA/etc/profile.d/conda.sh
conda activate viral 

# echo for log
echo "job started"; hostname; date

# export variable for env
export CHECKVDB=$CHECKVDB

# Get sample ID
export ASS=`head -n +${SLURM_ARRAY_TASK_ID} $IN_LIST | tail -n 1`

# run checkV on VS2 output
FILE="$OUT_DIR1/${ASS%%_megahit.fa}_VS2-viral.fa"

MY_CH_OUT1="$OUT_DIR1/${ASS%%_megahit.fa}_VS2_CheckV"
checkv end_to_end $FILE $MY_CH_OUT1 -t 10

rm -r $MY_CH_OUT1/tmp

# run checkV on DVF
FILE="$OUT_DIR2/${ASS%%_megahit.fa}_dvf-viral.fa"

MY_CH_OUT2="$OUT_DIR2/${ASS%%_megahit.fa}_DVF_CheckV"
checkv end_to_end $FILE $MY_CH_OUT2 -t 10

rm -r $MY_CH_OUT2/tmp

#################### MERGING RESULTS ############################
# Load r-env-singularity
module load r-env-singularity

# Clean up .Renviron file in home directory
if test -f ~/.Renviron; then
    sed -i '/TMPDIR/d' ~/.Renviron
    sed -i '/OMP_NUM_THREADS/d' ~/.Renviron
fi

# Specify a temp folder path
echo "TMPDIR=/scratch/<project>" >> ~/.Renviron

# get coverage
COV="$COV_DIR/${ASS%%_megahit.fa}_cov.txt"

# Run the filtering script

cd $FINAL

if [ ! -d $FINAL ]; then
  mkdir -p $FINAL;
fi

srun singularity_wrapper exec Rscript --no-save $SLURM_SUBMIT_DIR/config_scripts/FilterViral.R $MY_CH_OUT2/quality_summary.tsv $MY_CH_OUT1/quality_summary.tsv $COV ${ASS%%_megahit.fa} 

################## get final fasta ###############################
RECAP="$FINAL/${ASS%%_megahit.fa}_selection1.csv"

if [ ! -d $FINAL/fasta ]; then
  mkdir -p $FINAL/fasta;
fi

python $SLURM_SUBMIT_DIR/config_scripts/get_selection_viral.py -f $RECAP -a $IN_DIR/$ASS -c1 $MY_CH_OUT1 -c2 $MY_CH_OUT2 -n ${ASS%%_megahit.fa} -o $FINAL/fasta

# echo for log
echo "job done"; date

