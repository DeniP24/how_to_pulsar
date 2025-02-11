#!/bin/bash

touch results.csv
BASENAME=$(basename "$1" .tim)

for TIM in ${BASENAME}_*.tim; do
    if [[ -f "$TIM" ]]; then
        RESULTS=$(tempo2 -f J1455-3330-.par -nobs 90000 "$TIM")
        OMDOT=$(echo "$RESULTS" | grep "OMDOT" | awk '{print $4, $5}')
        PBDOT=$(echo "$RESULTS" | grep "PBDOT" | awk '{print $3, $4}')
        MJD=$(echo "$RESULTS" | grep "FINISH (MJD)" | awk '{print $4}')
        CHISQ=$(echo "$RESULTS" | grep "Chisqr" | awk '{print $9}')
        echo "$TIM, $OMDOT, $PBDOT, $MJD, $CHISQ" >> results.csv
        echo "$TIM done" 
    fi
done

echo "Processing complete. Results saved to results.csv"