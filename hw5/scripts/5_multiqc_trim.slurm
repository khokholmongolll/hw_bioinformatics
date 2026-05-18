#!/bin/bash
#SBATCH --job-name=multiqc_all
#SBATCH --output=mqc_%j.out
#SBATCH --error=mqc_%j.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --time=01:00:00
#SBATCH --partition AMD9554

source /home/STUDY/FBMF/bioinformatics/anaconda3/etc/profile.d/conda.sh

conda activate multiqc

MULTIQC="/home/STUDY/FBMF/studfbmf02_17/.conda/envs/multiqc/bin/multiqc"


$MULTIQC -o /home/STUDY/FBMF/studfbmf02_17/hw_5/results/after_trim /home/STUDY/FBMF/studfbmf02_17/hw_5/results/fastqc/*trimmed_fastqc.zip
