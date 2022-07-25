#!/bin/bash -l
#SBATCH --job-name=viral
#SBATCH --account=
#SBATCH --output=errout/outputr%j.txt
#SBATCH --error=errout/errors_%j.txt
#SBATCH --partition=small
#SBATCH --time=16:00:00
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --cpus-per-task=40
#SBATCH --mem-per-cpu=4000


# load job configuration
cd $SLURM_SUBMIT_DIR
source config_scripts/config.sh

# load environment
source $CONDA/etc/profile.d/conda.sh
conda activate viral 

# echo for log
echo "job started"; hostname; date

# Get sample ID
export ASS=`head -n +${SLURM_ARRAY_TASK_ID} $IN_LIST | tail -n 1`

# create output directories
VS_OUT="$OUT_DIR1/${ASS%%_megahit.fa}"

cd $IN_DIR
virsorter run -w $VS_OUT -i $ASS --min-length 1500 -j 8 all

cp $VS_OUT/final-viral-score.tsv $OUT_DIR1/${ASS%%_megahit.fa}_VS2-viral-score.tsv
cp $VS_OUT/final-viral-combined.fa $OUT_DIR1/${ASS%%_megahit.fa}_VS2-viral.fa
rm -r $VS_OUT

# echo for log
echo "job done"; date

