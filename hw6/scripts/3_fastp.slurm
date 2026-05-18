#!/bin/bash
#SBATCH --job-name=fastp_trim
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=8G
#SBATCH --time=02:00:00
#SBATCH --output=fastp_%j.out
#SBATCH --partition AMD9554

source /home/STUDY/FBMF/bioinformatics/anaconda3/etc/profile.d/conda.sh

conda activate multiqc

FASTP="/home/STUDY/FBMF/studfbmf02_17/.conda/envs/multiqc/bin/fastp"

DATA_DIR="/home/STUDY/FBMF/bioinformatics/rnaseq_map_star/raw_data"
OUT_DIR="/home/STUDY/FBMF/studfbmf02_17/hw_6/results/qc_after"

R1="$DATA_DIR/Eg_Treg_S71_R1_001.fastq.gz"
R2="$DATA_DIR/Eg_Treg_S71_R2_001.fastq.gz"

BASE="Eg_Treg_S71"


$FASTP  \
    -i "$R1" -I "$R2" \
    -o "${OUT_DIR}/${BASE}_R1_trimmed.fastq.gz" \
    -O "${OUT_DIR}/${BASE}_R2_trimmed.fastq.gz" \
    -h "${OUT_DIR}/fastp_report.html" \
    -j "${OUT_DIR}/fastp_report.json" \
    -W 5 -M 20 \
    -l 25 \
    --detect_adapter_for_pe \
    --thread 4 \
    --verbose


