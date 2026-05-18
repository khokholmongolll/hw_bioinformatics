#!/bin/bash
#SBATCH --job-name=fastp_trim
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=8G
#SBATCH --time=02:00:00
#SBATCH --output=fastp_%j.out
#SBATCH --partition AMD9554

DATA_DIR="/home/STUDY/FBMF/studfbmf02_17/hw_5/data"
OUT_DIR="/home/STUDY/FBMF/studfbmf02_17/hw_5/results/after_trim"

source /home/STUDY/FBMF/bioinformatics/anaconda3/etc/profile.d/conda.sh

conda activate multiqc

FASTP="/home/STUDY/FBMF/studfbmf02_17/.conda/envs/multiqc/bin/fastp"


for READ in "$DATA_DIR"/*.fastq.gz; do
    BASE=$(basename "$READ" .fastq.gz)
    

    $FASTP \
        -i "$READ" \
        -o "${OUT_DIR}/${BASE}_trimmed.fastq.gz" \
        -W 5 -M 20 \
        -l 36 \
        -h "${OUT_DIR}/${BASE}_fastp.html" \
        -j "${OUT_DIR}/${BASE}_fastp.json" \
        -w 4 \
        --detect_adapter_for_pe \
        --thread 4

done
