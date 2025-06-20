#!/bin/bash
#SBATCH --job-name=cutadapt

### Math setting
#SBATCH -n 1
#SBATCH --cpus-per-task=4
#SBATCH --account=math
#SBATCH --qos=math_unlim
#SBATCH --time=00-04:00:00
#SBATCH --mem=20gb
##SBATCH --partition=Intel6326
#SBATCH --partition=Intel6240,Intel6248,math   


#SBATCH --error=%x-%j.err
#SBATCH --output=%x-%j.out

#### Array job
#SBATCH --array=1-12

##SBATCH --export=NONE
##. /etc/profile


### Loading modules...

module load py-dnaio-0.4.2-gcc-10.2.0-gaqzhv4
module load py-xopen-1.1.0-gcc-10.2.0-5kpnvqq
module load py-cutadapt-2.10-gcc-10.2.0-2x2ytr5


### Defining paths 
FASTQ_FILE_PATH="..itcga_leukemia_with_arrays"
FASTQ_FILE_DIR="fastq"
OUTPUT_DIR="../itcga_leukemia_with_arrays/filtered_fastq/"



echo "using $SLURM_CPUS_ON_NODE CPUs"
echo `date`

cd ${FASTQ_FILE_PATH}/${FASTQ_FILE_DIR}/

file="../fastq/sample_list.txt"


### gets prefix from job...
SAMPLE_PREFIX=$(sed -n "${SLURM_ARRAY_TASK_ID}p" "$file")

### make sure sample name exists
if [ -z "$SAMPLE_PREFIX" ]; then
    echo "error: no sample prefix found on line ${SLURM_ARRAY_TASK_ID} of ${file}."
    exit 1
fi
 
### I/O files.... 
R1file="${FASTQ_FILE_PATH}/${FASTQ_FILE_DIR}/${SAMPLE_PREFIX}_R1.fastq"
R2file="${FASTQ_FILE_PATH}/${FASTQ_FILE_DIR}/${SAMPLE_PREFIX}_R2.fastq"

R1outfile="${SAMPLE_PREFIX}_R1_filtered.fastq"
R2outfile="${SAMPLE_PREFIX}_R2_filtered.fastq"

### changed -m 30 --> -m 15 RNA smaller, --max-n 0, filter out all N's , --trim -n trim N from ends 
cutadapt  --quality-base=33 -m 15 -q 20 --max-n 0 --cores=${SLURM_CPUS_ON_NODE} --trim-n -o ${OUTPUT_DIR}${R1outfile} -p ${OUTPUT_DIR}${R2outfile} $R1file $R2file
