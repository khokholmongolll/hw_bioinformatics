#!/bin/bash
#SBATCH --job-name=spades_imp
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --time=04:00:00
#SBATCH --partition AMD9554
#SBATCH --output=spades_imp_%j.out
#SBATCH --error=spades_imp_%j.err

READ1="/home/STUDY/FBMF/studfbmf02_17/hw_4/genome_de_novo/7_S4_L001_R1_001.fastq"
READ2="/home/STUDY/FBMF/studfbmf02_17/hw_4/genome_de_novo/7_S4_L001_R2_001.fastq"
OUT_DIR="/home/STUDY/FBMF/studfbmf02_17/hw_4/spades_improved"

python3 /home/STUDY/FBMF/bioinformatics/soft/SPAdes-4.2.0-Linux/bin/spades.py \
    -1 "$READ1" \
    -2 "$READ2" \
    -o "$OUT_DIR" \
    --isolate \
    -t 8 \
    -m 32

