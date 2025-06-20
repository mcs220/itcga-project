#!/bin/bash
#SBATCH --job-name=fastqc-array

### Math setting
#SBATCH -n 1
#SBATCH --cpus-per-task=6
#SBATCH --account=math
#SBATCH --qos=math_unlim
#SBATCH --time=00-04:00:00
#SBATCH --mem=20gb
##SBATCH --partition=Intel6326
#SBATCH --partition=Intel6240,Intel6248,math   

#SBATCH --error=%x-%A_%a.err
#SBATCH --output=%x-%A_%a.out


#### Array job
#SBATCH --array=1-24

##SBATCH --export=NONE
##. /etc/profile



module load fastqc-0.11.9-gcc-10.2.0-osi6pqc

FASTQ_DIR="../itcga_leukemia_with_arrays/filtered_fastq/"
OUTPUT_DIR="..itcga_leukemia_with_arrays/filtered_fastqc/"
SAMPLE_LIST="../itcga_leukemia_with_arrays/filtered_fastq/sample_files.txt"


FASTQ_FILE=$(sed -n "${SLURM_ARRAY_TASK_ID}p" "$SAMPLE_LIST")

fastqc -o ${OUTPUT_DIR} -t "${SLURM_CPUS_PER_TASK}" "${FASTQ_DIR}/${FASTQ_FILE}"


echo "using $SLURM_CPUS_PER_TASK CPUs"
echo `date`
