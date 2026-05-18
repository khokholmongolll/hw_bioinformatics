#!/bin/bash
#SBATCH --job-name=fastqc_all
#SBATCH --output=fastqc_%j.out
#SBATCH --error=fastqc_%j.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --time=01:00:00
#SBATCH --partition AMD9554

source /home/STUDY/FBMF/bioinformatics/anaconda3/etc/profile.d/conda.sh

conda activate base

FASTQC="/home/STUDY/FBMF/bioinformatics/anaconda3/bin/fastqc" 

DATA_DIR="/home/STUDY/FBMF/bioinformatics/rnaseq_map_star/raw_data"
OUT_DIR="/home/STUDY/FBMF/studfbmf02_17/hw_6/results/qc_before"

$FASTQC -t 4 -o "$OUT_DIR" "$DATA_DIR"/*.fastq.gz
