#!/bin/bash

# Command line handling

MODE=""
INPUT_FILE=""
S=-1
INCREMENT=1000
RESULTS_CSV="results.txt"
OUTPUT_PLOT="results.pdf"
OUTPUT_PROCESS="results.txt"
SCRIPT_DIR="/hercules/u/pdeni/how_to_pulsar/simulate_data_and_forecast_pks/"
PAR=""

# Help function
show_help() {
    echo "Usage: wrap.sh --i --par --mode <mode> [options]"
    echo ""
    echo "  --i <str>            Input concatenated .tim file containing original base and simulated data."
    echo "Modes:"
    echo "  --mode full          Full mode runs split, process and plot"
    echo "    --par <str>        Ephemeris file."
    echo "     --exec            Execution mode: 'loop' for sequential processing," 
    echo "                       'parallel' for Slurm-based parallel execution."
    echo ""
    echo "  --mode split         Split the data"
    echo "     --s <int>         Number of lines of original base .tim file."
    echo "                       Default: first occurrence of 'fake' - 1 in .tim file"
    echo "     --increment <int> Number of lines to add at a time to the base .tim file (default: 1000)."
    echo "     --o <str>         Output file name."
    echo "                       Default: {basename of input tim file}_{no.of_lines}.tim"
    echo ""
    echo "  --mode process       Process data with tempo2"
    echo "     --exec            Execution mode: 'loop' for sequential processing," 
    echo "                       'parallel' for Slurm-based parallel execution."
    echo "     --par <str>       Ephemeris file."
    echo "     --o_process       Output filename for processing."
    echo ""
    echo "  --mode plot          Enable plot option."
    echo "     --results <str>   Input results CSV from tempo2_grep_loop.sh with omdot, pbdot, errors, mjd, and chisq."
    echo "     --o_plot <str>    Output plot file name"
    echo ""
    echo "  --help               Show this help message and exit."
    echo ""
    exit 0
}

# Parse arguments
OPTS=$(getopt -o h --long mode:,i:,s:,increment:,o:,o_plot:,results:,par:,exec:,o_process:,help -n "$0" -- "$@")
eval set -- "$OPTS"

while true; do
  case "$1" in
    --mode ) MODE="$2"; shift 2 ;;
    --i ) INPUT_FILE="$2"; shift 2 ;;
    --s ) S="$2"; shift 2 ;;
    --increment ) INCREMENT="$2"; shift 2 ;;
    --o ) OUTPUT_NAME="$2"; shift 2 ;;
    --results ) RESULTS_CSV="$2"; shift 2 ;;
    --exec ) EXEC_MODE="$2"; shift 2 ;;
    --par ) PAR="$2"; shift 2;;
    --o_plot ) OUTPUT_PLOT="$2"; shift 2;;
    --o_process ) OUTPUT_PROCESS="$2"; shift 2;;
    --help ) show_help ;;
    -- ) shift; break ;;
    * ) break ;;
  esac
done

# Check that --mode is provided
if [[ -z "$MODE" ]]; then
    echo "Error: --mode is required. Use --help for usage."
    exit 1
fi

case "$MODE" in
  full)
    if [[ -z "$INPUT_FILE" ]]; then
      echo "Error: --i (input file) is required"
      show_help
    fi
    if [[ -z "$PAR" ]]; then
      echo "Error: --par is required"
      show_help
    fi

    echo "Running full script with input file: $INPUT_FILE"
    echo "Splitting data..."
    $SCRIPT_DIR/split.py --i $INPUT_FILE --s $S --increment $INCREMENT
    echo "Splitting done!"
    if [[ "$EXEC_MODE" != "loop" && "$EXEC_MODE" != "parallel" ]]; then
      echo "Error: Invalid --exec mode '$EXEC_MODE'. Must be 'loop' or 'parallel'."
      show_help
    fi
    > $OUTPUT_PROCESS
    if [[ "$EXEC_MODE" == "loop" ]]; then
        echo "Processing files sequentially..."
        $SCRIPT_DIR/tempo2_grep_loop.sh $INPUT_FILE $OUTPUT_PROCESS $PAR
    elif [[ "$EXEC_MODE" == "parallel" ]]; then
        echo "Processing files in parallel"
        BASENAME=$(basename "$INPUT_FILE" .tim)
        FILE_COUNT=$(ls "$BASENAME"_*.tim 2>/dev/null | wc -l)
        sbatch --array=1-$FILE_COUNT $SCRIPT_DIR/tempo2_grep_parallel.sh $INPUT_FILE $OUTPUT_PROCESS $PAR
    fi
    while squeue -u $USER | grep -q 'sims'; do
        sleep 60
    done
    chmod +x "$OUTPUT_PROCESS"
    awk 'NF' "$OUTPUT_PROCESS" > temp && mv temp "$OUTPUT_PROCESS"
    awk 'NR%2{printf "%s", $0; next} {print " " $0}' "$OUTPUT_PROCESS" > temp_file && mv temp_file "$OUTPUT_PROCESS"
    rm *.err *.out
    module purge
    module load gcc/11 impi/2021.5
    module load boost-mpi/1.79
    source TN.bashrc
    echo "Plotting graph..."
    $SCRIPT_DIR/plot.py --i $RESULTS_CSV --o $OUTPUT_PLOT
    echo "Plotting done"
    ;;
  
  split)
    if [[ -z "$INPUT_FILE" ]]; then
      echo "Error: --i (input file) is required"
      show_help
    fi
    echo "Splitting data..."
    $SCRIPT_DIR/split.py --i $INPUT_FILE --s $S --increment $INCREMENT
    echo "Splitting done!"
    ;;
  process)
    if [[ -z "$INPUT_FILE" ]]; then
      echo "Error: --i (input file) is required"
      show_help
    fi
    if [[ -z "$PAR" ]]; then
      echo "Error: --par is required"
      show_help
    fi
    if [[ "$EXEC_MODE" != "loop" && "$EXEC_MODE" != "parallel" ]]; then
      echo "Error: Invalid --exec mode '$EXEC_MODE'. Must be 'loop' or 'parallel'."
      show_help
    fi
    > $OUTPUT_PROCESS
    if [[ "$EXEC_MODE" == "loop" ]]; then
        echo "Processing files sequentially..."
        $SCRIPT_DIR/tempo2_grep_loop.sh $INPUT_FILE $OUTPUT_PROCESS $PAR
    elif [[ "$EXEC_MODE" == "parallel" ]]; then
        BASENAME=$(basename "$INPUT_FILE" .tim)
        FILE_COUNT=$(ls "$BASENAME"_*.tim 2>/dev/null | wc -l)
        sbatch --array=1-"$FILE_COUNT" $SCRIPT_DIR/tempo2_grep_parallel.sh $INPUT_FILE $OUTPUT_PROCESS $PAR
    fi
    while squeue -u $USER | grep -q 'sims'; do
        sleep 60  # Check every 60 seconds
    done
    chmod +x "$OUTPUT_PROCESS"
    awk 'NF' "$OUTPUT_PROCESS" > temp && mv temp "$OUTPUT_PROCESS"
    awk 'NR%2{printf "%s", $0; next} {print " " $0}' "$OUTPUT_PROCESS" > temp_file && mv temp_file "$OUTPUT_PROCESS"
    rm *.err *.out
    ;;
  plot)
    if [[ -z "$RESULTS_CSV" ]]; then
      echo "Error: --results (input file) is required"
      show_help
    fi
    module purge
    module load gcc/11 impi/2021.5
    module load boost-mpi/1.79
    source TN.bashrc
    echo "Plotting graph..."
    $SCRIPT_DIR/plot.py --i $RESULTS_CSV --o $OUTPUT_PLOT
    echo "Plotting done"
    ;;
  *)
    echo "Error: Unknown mode or no mode specified. Use --help for usage."
    exit 1
    ;;
esac
