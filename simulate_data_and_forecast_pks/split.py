#Script to split a tim file adding increments of "--increment"
import numpy as np
import argparse
import sys

parser = argparse.ArgumentParser(description="Split concatenated tim file into n number of files, by adding --no_lines number of lines to the original base .tim file. Saves the output to {basename}_{no.of_lines}.tim")
parser.add_argument("--i", type=str, required=True, help="Input concatenated.tim file that has original base data and simulated data. eg. 3.tim")
parser.add_argument("--s", type=int, default= -1, help="Number of lines of original base .tim file. Default -1 is the line number of the first occurence of the word fake - 1.")
parser.add_argument("--increment", type=int, help="Number of lines you want to add at a time to the base .tim file", default=1000)
args = parser.parse_args()

input_file = args.i
base_name = input_file.split(".")[0]
start_lines = args.s
increment = args.increment

with open(input_file, "r") as f:
    lines = f.readlines()

if start_lines==-1:
    base_lines = next((i for i, line in enumerate(lines, start=1) if "fake" in line), -1) + start_lines
    if base_lines<0:
        sys.exit("There are no simulated/fake data")
else:
    base_lines = start_lines

total_lines = len(lines)
arr_ = np.arange(base_lines,total_lines, increment)
arr_ = np.append(arr_, total_lines)

for i in arr_:
    output_file = f"{base_name}_{i}.tim"
    with open(output_file, "w") as f:
        f.writelines(lines[:i])
    print(f"Created {output_file} with {i} lines")