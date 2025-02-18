#!/bin/bash
#SBATCH --export=ALL
#SBATCH --ntasks=1
#SBATCH --time=00:10:00
#SBATCH --nodes=1
#SBATCH --partition=short.q
#SBATCH --job-name=sims
#SBATCH --mail-type=END,FAIL --mail-user=dpillay@mpifr-bonn.mpg.de
#SBATCH --output=sims_%j.out
#SBATCH --error=sims_%j.err

module load gcc/11 impi/2021.5
module load boost-mpi/1.79
source TN.bashrc
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/mpcdf/soft/CentOS_7/packages/x86_64/r_anaconda/4.0.3/lib/
export TEMPO2_CLOCK_DIR="/scratch/vkrishna/clock"

touch $2
BASENAME=$(basename "$1" .tim)
TIM_FILES=($(ls "${BASENAME}"_*.tim))
TIM="${TIM_FILES[$SLURM_ARRAY_TASK_ID - 1]}"

RESULTS=$(tempo2 -f $3 -nobs 90000 $TIM)
OMDOT=$(echo "$RESULTS" | grep "OMDOT" | awk '{print $4, $5}')
PBDOT=$(echo "$RESULTS" | grep "PBDOT" | awk '{print $3, $4}')
MJD=$(echo "$RESULTS" | grep "FINISH (MJD)" | awk '{print $4}')
CHISQ=$(echo "$RESULTS" | grep "Chisqr" | awk '{print $9}' )

# Save the output to a .csv file
echo -e "$TIM, $OMDOT, $PBDOT, $MJD, $CHISQ" >> "$2"
