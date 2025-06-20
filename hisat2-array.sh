#!/bin/bash
#SBATCH --job-name=hisat2

### Math setting
#SBATCH -n 1 ### nodes
#SBATCH --cpus-per-task=4 ### cpus under node 
#SBATCH --account=math
#SBATCH --qos=math_unlim
#SBATCH --time=00-04:00:00
#SBATCH --mem=20gb
##SBATCH --partition=Intel6326
#SBATCH --partition=Intel6240,Intel6248,math   

#SBATCH --error=%x-%A_%a.err
#SBATCH --output=%x-%A_%a.out


#### Array job
#SBATCH --array=1-12

##SBATCH --export=NONE
##. /etc/profile



### modules to load
module load gcc-10.2.0-gcc-9.3.0-f3oaqv7
module load python-3.8.12-gcc-10.2.0-oe4tgov
module load hisat2-2.1.0-gcc-9.3.0-u7zbyow


### paths 
HISAT2_PATH="/itcgastorage/data01/itcga_workshops/aug2024_genomics/Genome/hg38/hg38"
FILTERED_FASTQ="../itcga_leukemia_with_arrays/filtered_fastq"
SAM_OUTPUT="../itcga_leukemia_with_arrays/sam"


### use prefix, since each job will be associated with two files from R1 and R2 
SAMPLE_LIST="../itcga_leukemia_with_arrays/fastq/sample_list.txt"
SAMPLE_PREFIX=$(sed -n "${SLURM_ARRAY_TASK_ID}p" "${SAMPLE_LIST}")


### directly define file names 
R1_fastq="${FILTERED_FASTQ}/${SAMPLE_PREFIX}_R1_filtered.fastq"
R2_fastq="${FILTERED_FASTQ}/${SAMPLE_PREFIX}_R2_filtered.fastq"
output="${SAM_OUTPUT}/${SAMPLE_PREFIX}.sam"


hisat2 -x "${HISAT2_PATH}" -1 "${R1_fastq}" -2 "${R2_fastq}" -S "${output}" --threads "${SLURM_CPUS_PER_TASK}"
