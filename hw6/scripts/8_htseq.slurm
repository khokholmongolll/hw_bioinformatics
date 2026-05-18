#!/bin/bash
#SBATCH --job-name=htseq
#SBATCH --cpus-per-task=2
#SBATCH --mem=8G
#SBATCH --time=01:00:00
#SBATCH --partition AMD9554
#SBATCH --output=htseq_%j.out

source /home/STUDY/FBMF/bioinformatics/anaconda3/etc/profile.d/conda.sh
conda activate htseq_env

BAM="/home/STUDY/FBMF/studfbmf02_17/hw_6/results/star/RNA_Aligned.sortedByCoord.out.bam"
GTF="/home/STUDY/FBMF/bioinformatics/GRCh38/Homo_sapiens.GRCh38.110.chr.gtf"
OUT="/home/STUDY/FBMF/studfbmf02_17/hw_6/results/htseq/htseq_counts.txt"


htseq-count --format bam \
            --order pos \
            --stranded no \
            --type exon \
            --idattr gene_id \
            "$BAM" "$GTF" > "$OUT"

