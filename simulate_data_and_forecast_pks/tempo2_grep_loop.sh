#!/bin/bash

module purge
module load gcc/11 impi/2021.5
module load boost-mpi/1.79
source TN.bashrc
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/mpcdf/soft/CentOS_7/packages/x86_64/r_anaconda/4.0.3/lib/
export TEMPO2_CLOCK_DIR="/scratch/vkrishna/clock"

BASENAME=$(basename "$1" .tim)
PARFILE=$3
for TIM in ${BASENAME}_*.tim; do
    if [[ -f "$TIM" ]]; then
        RESULTS=$(tempo2 -f $3 -nobs 90000 "$TIM")
        OMDOT=$(echo "$RESULTS" | grep "OMDOT" | awk '{print $4, $5}')
        PBDOT=$(echo "$RESULTS" | grep "PBDOT" | awk '{print $3, $4}')
        MJD=$(echo "$RESULTS" | grep "FINISH (MJD)" | awk '{print $4}')
        CHISQ=$(echo "$RESULTS" | grep "Chisqr" | awk '{print $9}')
        echo "$TIM, $OMDOT, $PBDOT, $MJD, $CHISQ" >> $2
        echo "$TIM done" 
    fi
done

echo "Processing complete. Results saved to $2"
