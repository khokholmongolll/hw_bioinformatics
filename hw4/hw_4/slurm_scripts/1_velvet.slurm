#!/bin/bash
#SBATCH --job-name=velvet_kmers
#SBATCH --output=velvet_kmers_%j.out
#SBATCH --error=velvet_kmers_%j.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --time=02:00:00
#SBATCH --partition AMD9554
VELVETH="/home/STUDY/FBMF/bioinformatics/soft/velvet/velveth"
VELVETG="/home/STUDY/FBMF/bioinformatics/soft/velvet/velvetg"

READ1="/home/STUDY/FBMF/studfbmf02_17/hw_4/genome_de_novo/7_S4_L001_R1_001.fastq"
READ2="/home/STUDY/FBMF/studfbmf02_17/hw_4/genome_de_novo/7_S4_L001_R2_001.fastq"

OUT_BASE="/home/STUDY/FBMF/studfbmf02_17/hw_4/velvet"

KMERS=(31 41 51 61)


for K in "${KMERS[@]}"; do
    OUT_DIR="${OUT_BASE}/k${K}"
    
    mkdir -p "$OUT_DIR"
    
    $VELVETH "$OUT_DIR" "$K" -fastq -shortPaired "$READ1" "$READ2"
    
   $VELVETG "$OUT_DIR" "$K" -ins_length 300 -ins_length_std_dev 20 -exp_cov auto -cov_cutoff auto
     
done

echo "сборка завершена"
