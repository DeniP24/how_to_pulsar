# Global settings
unset I_MPI_HYDRA_BOOTSTRAP
unset I_MPI_PMI_LIBRARY
export mdata=/hercules/results/kliu
export PYTHONPATH=$HOME/Soft/lib/python3.8/site-packages
module purge
module load anaconda/3/2021.05
module load intel/19.1.3
module load mkl/2021.3
module load impi/2019.9
module load gcc/10

# Library dependency
export APHOME=/u/aparthas
export KHOME=/u/kliu
export MLAPACK=$APHOME/MPLAPACK

# T2 dependency
export PSRHOME=$KHOME/Soft
export PATH=$PATH:$KHOME/Soft/bin

export TEMPO2_CLOCK_DIR=/hercules/scratch/vkrishna/clock

export TEMPO2=$KHOME/Soft/tempo2/T2runtime



export LD_LIBRARY_PATH=$MKLROOT/lib/intel64/:$I_MPI_ROOT/intel64/lib:$KHOME/Soft/MultiNest_v3.10:$APHOME/software/PolyChordLite/lib/:$KHOME/Soft/lib:$KHOME/Soft
