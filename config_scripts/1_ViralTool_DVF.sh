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
conda activate dvf 

# echo for log
echo "job started"; hostname; date

# Get sample ID
export ASS=`head -n +${SLURM_ARRAY_TASK_ID} $IN_LIST | tail -n 1`

# Run DVF
cd $IN_DIR

if [ ! -d $OUT_DIR2 ]; then
  mkdir -p $OUT_DIR2;
fi

DVF_OUT="$OUT_DIR2/${ASS%%_megahit.fa}"
DVF_OUTFILE="$DVF_OUT/${ASS}_gt1500bp_dvfpred.txt"

rm -r /users/ponseroa/.theano
python $DVF/dvf.py -i $ASS -o $DVF_OUT -l 1500 -c 8 

python $SLURM_SUBMIT_DIR/config_scripts/parse_dvf.py -f $DVF_OUTFILE -a $ASS -n ${ASS%%_megahit.fa} -o $OUT_DIR2

mv $DVF_OUTFILE $OUT_DIR2
rm -r $DVF_OUT

# echo for log
echo "job done"; date

