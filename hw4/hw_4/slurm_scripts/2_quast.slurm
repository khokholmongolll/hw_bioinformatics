#!/bin/bash
#SBATCH --job-name=quast_eval
#SBATCH --output=quast_%j.out
#SBATCH --error=quast_%j.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=8G
#SBATCH --partition AMD9554

QUAST="/home/STUDY/FBMF/bioinformatics/soft/bin/quast.py"
BASE_DIR="/home/STUDY/FBMF/studfbmf02_17/hw_4"

mkdir -p ${BASE_DIR}/assembly_analysis

$QUAST -o ${BASE_DIR}/assembly_analysis/report \
    -m 0 \
    --threads 5 \
    --labels "Velvet_k31,Velvet_k41,Velvet_k51,Velvet_k61,SPAdes" \
    ${BASE_DIR}/velvet/k31/contigs.fa \
    ${BASE_DIR}/velvet/k41/contigs.fa \
    ${BASE_DIR}/velvet/k51/contigs.fa \
    ${BASE_DIR}/velvet/k61/contigs.fa \
    ${BASE_DIR}/spades/scaffolds.fasta
