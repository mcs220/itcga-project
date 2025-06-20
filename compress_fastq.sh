#!/bin/bash
#SBATCH --job-name=compressed-files

### Math setting
#SBATCH -n 1
#SBATCH --cpus-per-task=1   ### gzip single threaded, only need one cpu 
#SBATCH --account=math
#SBATCH --qos=math_unlim
#SBATCH --time=00-10:00:00
#SBATCH --mem=50gb
##SBATCH --partition=math
#SBATCH --partition=Intel6248,math

#SBATCH --error=%x-%j.err
#SBATCH --output=%x-%j.out



### fastq dir first arg 
FASTQ_DIR=$1
### output dir second arg
OUTPUT_DIR=$2


# Check if the directory argument was provided
if [[ -z "$FASTQ_DIR" || -z "$OUTPUT_DIR" ]]; then
    echo "Error: This script requires two arguments: a source directory and a destination directory." >&2
    echo "Usage: sbatch $0 /path/to/source /path/to/destination" >&2
    exit 1
fi

mkdir -p "$OUTPUT_DIR"

files=("$FASTQ_DIR"/*.fastq)
this_file="${files[$SLURM_ARRAY_TASK_ID]}"


if [[ -f "$this_file" ]]; then
    echo "Processing: $this_file"
    # basename, entire filename 
    base_filename=$(basename "$this_file")
    output_file_path="$OUTPUT_DIR/${base_filename}.gz"
    

    temp_output_file="${output_file_path}.tmp"

    if gzip -c "$this_file" > "$temp_output_file"; then
        ### gzip successful, make file
        mv "$temp_output_file" "$output_file_path"
        rm "$this_file"
        echo "Finished: $this_file"
    else
        ### gzip failed
        echo "Error: gzip command failed for $this_file." >&2
        rm -f "$temp_output_file"
        exit 1 #
    fi
    echo "done: $this_file"
else
    echo "Error: File not found for task ID $SLURM_ARRAY_TASK_ID: $this_file" >&2
    exit 1
fi
