#!/bin/bash
#SBATCH --job-name=feature-counts

### Math setting
#SBATCH -n 1
#SBATCH --cpus-per-task=8
#SBATCH --account=math
#SBATCH --qos=math_unlim
#SBATCH --time=00-12:00:00
#SBATCH --mem=50gb
##SBATCH --partition=math
#SBATCH --partition=Intel6240,Intel6248,math


### added dependency on samtools running
#SBATCH --dependency=afterok:470301 

#SBATCH --error=%x-%j.err
#SBATCH --output=%x-%j.out

module load subread-2.0.2-gcc-10.2.0

### define paths
BAM_INPUT_DIR="../itcga_leukemia_with_arrays/bam"
COUNTS_OUTPUT_DIR="../itcga_leukemia_with_arrays/feature_counts"
ANNOTATION_FILE="/itcgastorage/data01/itcga_workshops/aug2024_genomics/Genome/hg38/Homo_sapiens.GRCh38.111.gtf"


OUTPUT_COUNTS_FILE="${COUNTS_OUTPUT_DIR}/gene_counts_arrays.txt"


### -p for pair ended because of R1, R2...
### dont know the strandedness, going to guess -s 2 and hope it's very wrong if that's incorrect

featureCounts -T "${SLURM_CPUS_PER_TASK}" -a "${ANNOTATION_FILE}" -o "${OUTPUT_COUNTS_FILE}" -F GTF -t exon -g gene_id -s 2 --primary -p  "${BAM_INPUT_DIR}"/*.sorted.bam
