#!/bin/bash
#SBATCH --job-name=samtools

### Math setting
#SBATCH -n 1 ### nodes
#SBATCH --cpus-per-task=4 ### cpus under node 
#SBATCH --account=math
#SBATCH --qos=math_unlim
#SBATCH --time=00-04:00:00
#SBATCH --mem=50gb
##SBATCH --partition=Intel6326
#SBATCH --partition=Intel6240,Intel6248,math   
#SBATCH --mail-user=molly.sullivan004@umb.edu

#SBATCH --error=%x-%A_%a.err
#SBATCH --output=%x-%A_%a.out


#### Array job
#SBATCH --array=1-12

##SBATCH --export=NONE
##. /etc/profile
### https://hpc.nih.gov/docs/job_dependencies.html 
#SBATCH --dependency=afterok:470283



module load samtools-1.10-gcc-9.3.0-flukja5



SAM_INPUT="../itcga_leukemia_with_arrays/sam"
BAM_OUTPUT="../itcga_leukemia_with_arrays/bam"

### use prefix, since each job will be associated with two files from R1 and R2 
SAMPLE_LIST="../itcga_leukemia_with_arrays/fastq/sample_list.txt"
SAMPLE_PREFIX=$(sed -n "${SLURM_ARRAY_TASK_ID}p" "${SAMPLE_LIST}")

sam_file="${SAM_INPUT}/${SAMPLE_PREFIX}.sam"
unsorted_bam_file="${BAM_OUTPUT}/${SAMPLE_PREFIX}.bam"
sorted_bam_file="${BAM_OUTPUT}/${SAMPLE_PREFIX}.sorted.bam"



### STEP 1:takes sam file, provides binary output (bam file)
samtools view -bS --threads "${SLURM_CPUS_PER_TASK}" "${sam_file}" > "${unsorted_bam_file}"


### if exit code not 0
if [ $? -ne 0 ]; then
    echo "samtools view failed for ${SAMPLE_PREFIX}.sam"
    exit 1
fi

### STEP 2: like rearranging data by different column in excel-
### each read is already aligned to the reference genome
### but not sorted as such, and this sorts by the reference genome
samtools sort --threads "${SLURM_CPUS_PER_TASK}" -o "${sorted_bam_file}" "${unsorted_bam_file}"

if [ $? -ne 0 ]; then 
    echo "Error in processing samtools sort:  ${name}"
    exit 1
fi


### returns .bam.bai files --> can be used in tools like IGV
### sequential process --> does not benefit from parallelization
samtools index "${sorted_bam_file}"


rm "${unsorted_bam_file}"
