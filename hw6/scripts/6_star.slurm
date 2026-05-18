#!/bin/bash
#SBATCH --job-name=star_map
#SBATCH --cpus-per-task=16  # STAR любит много потоков
#SBATCH --mem=64G
#SBATCH --time=01:00:00
#SBATCH --partition AMD9554
#SBATCH --output=star_%j.out

source /home/STUDY/FBMF/bioinformatics/anaconda3/etc/profile.d/conda.sh

conda activate base

GENOME_DIR="/home/STUDY/FBMF/bioinformatics/GRCh38/"    
READS1="/home/STUDY/FBMF/studfbmf02_17/hw_6/results/qc_after/Eg_Treg_S71_R1_trimmed.fastq.gz"   
READS2="/home/STUDY/FBMF/studfbmf02_17/hw_6/results/qc_after/Eg_Treg_S71_R2_trimmed.fastq.gz"	 
OUTPUT_DIR="/home/STUDY/FBMF/studfbmf02_17/hw_6/results/star"

STAR \
  --runThreadN 16 \
  --runMode alignReads \
  --genomeDir $GENOME_DIR \
  --readFilesIn $READS1 $READS2 \
  --readFilesCommand zcat \
  --outFileNamePrefix ${OUTPUT_DIR}/RNA_ \
  --outSAMtype BAM SortedByCoordinate \
  --quantMode GeneCounts

