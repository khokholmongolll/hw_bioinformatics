#!/bin/bash
#SBATCH --job-name=stringtie
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --time=01:00:00
#SBATCH --partition AMD9554
#SBATCH --output=stringtie_%j.out

source /home/STUDY/FBMF/bioinformatics/anaconda3/etc/profile.d/conda.sh
conda activate base

BAM="/home/STUDY/FBMF/studfbmf02_17/hw_6/results/star/RNA_Aligned.sortedByCoord.out.bam"
OUTDIR="/home/STUDY/FBMF/studfbmf02_17/hw_6/results/stringtie"

stringtie "$BAM" -o "$OUTDIR/transcripts.gtf" -p 4

