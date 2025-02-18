## Example PBDOT and OMDOT forecasting for PSR J1455-3330
This is a step-by-step approach to simulating data with tempo2, and creating post keplerian parameter uncertainty predictions.

### 1. Simulate data
Following the SKA book and Hu et al 2020 ([text](https://arxiv.org/pdf/2007.07725)), we will simulate data for different telescope phases as follows:

| Telescope  | RMS  | Start MJD | End MJD  | Duration  | Cadence | 
|------------|------|----------|----------|-----------|---------|
| MeerKAT    | 1.138e-3 millis | 60400 | 61020 | Mid 2024 - End 2025 | 100 TOAs every 7 days|
| MeerKAT+   | 0.82e-3 millis | 61010 | 61375 | End 2025 - Start 2027 | 100 TOAs every 7 days|
| SKA-mid    | 0.32e-3 millis | 61275 | 69000 | Start 2027 - End 2035 | 100 TOAs every 14 days|

- add flags
    eg. ```awk '{print $0, "-i ska -fe ska"}' J1455-3330-.ska_try2 > J1455-3330-.ska_try2_2```
- cat the original tim file, mkt, mkt+ and ska data with flags, remove extra mode and format fields

### 2. Split concatenated tim file into `n` number of files, by adding `--increment` number of lines to the original base .tim file using `split.py`.
   - Input (-i): user specified .tim file
   - Start lines (-s): user specified number of lines in base .tim file (without simulated fake data) or default is taken as the first line "fake" occurs at minus 1 line
   - Output: {basename}_{no.of_lines}.tim

### 3. Run tempo2 on each of these tim files and save the pk param value, error, mjd, chisq to a file called results.csv. This can be done in 2 ways:
   - In parallel with tempo2_grep_slurm.sh
   - In a loop on the screen with tempo2_grep_loop.sh

### 4. Run plot.py to create the plot with mjd vs fractional uncertainty. 

The above scripts can be run seperately with wrap.sh --mode (split,process,plot) or use --mode full to run all 3 scripts.