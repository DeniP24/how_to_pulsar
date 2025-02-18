#!/usr/bin/env python3
import matplotlib
matplotlib.use('Agg') 
import matplotlib.pyplot as plt
import numpy as np
from matplotlib.ticker import MaxNLocator
from datetime import datetime, timedelta
import argparse

parser = argparse.ArgumentParser(description="Plot the pk parameter predictions.")
parser.add_argument("--i", type=str, required=True, help="Input results csv from tempo2_grep_loop.sh with omdot, pbdot, errors, mjd and chisq")
parser.add_argument("--o", type=str, help="Output filename")
args = parser.parse_args() 
input_file = args.i
output_file = args.o

omdot = []
pbdot = []
mjd = []

omdot_err = []
pbdot_err = []
chisq_val =[]

with open(input_file, "r") as file:
    lines = file.readlines()[:-1] 
    for line in lines:
        parts = line.split(',')
        omdot_val, omdot_err_val = map(float, parts[1].split())
        pbdot_val, pbdot_err_val = map(float, parts[2].split())
        mjd_val = float(parts[3].strip())
        chisq_val = float(parts[4].strip())
        omdot.append(omdot_val)
        omdot_err.append(omdot_err_val)
        pbdot.append(pbdot_val)
        pbdot_err.append(pbdot_err_val)
        mjd.append(mjd_val)

mjd = np.array(mjd)
pbdot = np.array(pbdot)
pbdot_err = np.array(pbdot_err)
omdot = np.array(omdot)
omdot_err = np.array(omdot_err)

def mjd_to_decimal_year(mjd):
    jd = mjd + 2400000.5 
    date = datetime(1858, 11, 17) + timedelta(days=mjd)  # MJD epoch
    year = date.year
    start_of_year = datetime(year, 1, 1)
    days_in_year = 366 if (year % 4 == 0 and (year % 100 != 0 or year % 400 == 0)) else 365
    day_of_year = (date - start_of_year).days + 1

    return year + (day_of_year - 1) / days_in_year

years_sorted = np.sort(np.array([mjd_to_decimal_year(m) for m in mjd]))

# Compute fractional errors
fractional_error_pbdot = np.abs(pbdot_err / pbdot)
fractional_error_omdot = np.abs(omdot_err / omdot)

# Plot the data
plt.figure(figsize=(10, 6))
plt.plot(years_sorted, fractional_error_pbdot, label=r'$\Delta \dot{P}_b / P_b$', color='#4C4CFFFF')
plt.plot(years_sorted, fractional_error_omdot, label =r'$\Delta \dot{\omega} / \omega$', color = '#23B4DCFF')

plt.axvline(x=2024 + 6/12, linestyle='--', color='black')  # MeerKAT Start
plt.axvline(x=2025 + 12/12, linestyle='--', color='black')  # MeerKAT+ Start
plt.axvline(x=2026 + 12/12, linestyle='--', color='black')  # SKA 1-mid Start

plt.axhline(y = 1/10, linestyle='--', color = 'gray')
plt.text(2025, 0.11, r'$10\sigma$', color='black', ha='center')

plt.axhline(y = 1/3, linestyle='--', color = 'gray')
plt.text(2025, 0.34, r'$3\sigma$', color='black', ha='center')

plt.axhline(y = 1/5, linestyle='--', color = 'gray')
plt.text(2025, 0.21, r'$5\sigma$', color='black', ha='center')

# Annotate regions
plt.text(2025.25, 4.5, 'MeerKAT', fontsize=9, color='black', rotation=90, ha='center')
plt.text(2025.95, 4.5, 'MeerKAT+', fontsize=9, color='black', rotation=90, ha='center')
plt.text(2027, 4.5, 'SKA 1-mid', fontsize=9, color='black', rotation=90, ha='center')

# Labels, legend, and title
plt.xlabel('Time (Years)', fontsize=13)
plt.yscale('log')
plt.ylim(1e-5,50)
plt.tick_params(axis='both', labelsize=13)
plt.legend(fontsize=13)
plt.gca().xaxis.set_major_locator(MaxNLocator(integer=True))
plt.ylabel(r'Fractional Error ($\sigma^{-1}$)', fontsize=13) 
plt.savefig(output_file, format='pdf',dpi=300)
plt.close()
