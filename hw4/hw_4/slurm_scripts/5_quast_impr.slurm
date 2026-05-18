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

mkdir -p ${BASE_DIR}/assembly_analysis_imp

$QUAST -o ${BASE_DIR}/assembly_analysis_imp/report \
    -m 0 \
    --threads 4 \
    --labels "Velvet_k31_imp,SPAdes_imp, Velvet_k31, SPAdes" \
    ${BASE_DIR}/velvet_improved/k31/contigs.fa \
    ${BASE_DIR}/spades_improved/scaffolds.fasta\
    ${BASE_DIR}/velvet_bck/k31/contigs.fa \
    ${BASE_DIR}/spades/scaffolds.fasta
