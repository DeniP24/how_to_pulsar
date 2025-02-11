#!/bin/bash

python3 split.py --i $1 --s $2 --increment $3
echo "Splitting done"

./tempo2_grep_loop.sh $1
echo "Processing complete. Results saved to results.csv"
awk 'NR%2{printf "%s", $0; next} {print " " $0}' results.csv > output.txt

python3 plot.py
echo "Plotting done"