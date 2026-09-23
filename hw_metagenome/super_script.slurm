#!/bin/bash
#SBATCH --job-name=qiime_mice
#SBATCH --output=qiime_mice_%j.out
#SBATCH --error=qiime_mice_%j.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=20        # максимум из всех шагов (dada2)
#SBATCH --mem=60G                 # максимум из всех шагов (classify/barplot/core-metrics)
#SBATCH --time=01:00:00           # суммарно пайплайн дольше 1 часа
#SBATCH --partition IXG6154-AI-common

set -euo pipefail

# ============================================================
#  КОНФИГУРАЦИЯ
# ============================================================
source /home/STUDY/FBMF/bioinformatics/anaconda3/etc/profile.d/conda.sh
conda activate base

export MG=/home/STUDY/FBMF/studfbmf02_17/sem_metagenome
RAW=/home/STUDY/FBMF/bioinformatics/metagenomes/mice
SIF=/home/STUDY/FBMF/studfbmf02_17/qiime2-amplicon-2024.10.sif

MANIFEST=$RAW/metadata_for_input.tsv          # манифест для tools import
METADATA=$RAW/metadata.tsv                    # метаданные образцов (diversity/barplot)
CLASSIFIER=$RAW/2022.10.backbone.v4.nb.sklearn-1.4.2.qza
# альтернативный классификатор, если понадобится:
# CLASSIFIER=$RAW/gg-13-8-99-515-806-nb-classifier.qza

MODE=paired
THREADS=20
SAMPLING_DEPTH=1400   # ПОТОМ проверь по мин. частоте в таблице ASV!

# параметры DADA2
TRIM_LEFT_F=20;  TRIM_LEFT_R=20    # ~длина праймеров (515F=19, 806R=20); можно оставить 25 как раньше
TRUNC_LEN_F=230; TRUNC_LEN_R=150   # обрезаем ровно там, где начинает падать качество
TRIM_LEFT=20;    TRUNC_LEN=230     # fallback для single: только R1, обрезанный
mkdir -p $MG/.q2cli $MG/qza $MG/qzv
export HOME=$MG

Q2="singularity exec --bind /home/STUDY --bind $MG:/home/qiime2 $SIF"

# ============================================================
#  1. ИМПОРТ ЧТЕНИЙ
# ============================================================
echo "=== [1/8] tools import ($MODE) ==="
if [ "$MODE" = "paired" ]; then
  $Q2 qiime tools import \
    --type 'SampleData[PairedEndSequencesWithQuality]' \
    --input-path $MANIFEST \
    --output-path $MG/qza/mice_reads.qza \
    --input-format PairedEndFastqManifestPhred33V2
else
  $Q2 qiime tools import \
    --type 'SampleData[SequencesWithQuality]' \
    --input-path $MANIFEST \
    --output-path $MG/qza/mice_reads.qza \
    --input-format SingleEndFastqManifestPhred33V2
fi

# ============================================================
#  2. DADA2 ДENOISING
# ============================================================
echo "=== [2/8] dada2 denoise ==="
if [ "$MODE" = "paired" ]; then
  $Q2 qiime dada2 denoise-paired \
  --i-demultiplexed-seqs $MG/qza/mice_reads.qza \
  --p-trim-left-f $TRIM_LEFT_F \
  --p-trim-left-r $TRIM_LEFT_R \
  --p-trunc-len-f $TRUNC_LEN_F \
  --p-trunc-len-r $TRUNC_LEN_R \
  --p-max-ee-f 3 \
  --p-max-ee-r 3 \
  --p-min-overlap 12 \
  --p-n-threads $THREADS \
  --p-pooling-method "pseudo" \
  --p-chimera-method "consensus" \
  --p-min-fold-parent-over-abundance 4 \
  --o-table $MG/qza/mice_ASV_table.qza \
  --o-representative-sequences $MG/qza/mice_rep_seq.qza \
  --o-denoising-stats $MG/qza/mice_reads.dada2.stats.qza
else
  $Q2 qiime dada2 denoise-single \
    --i-demultiplexed-seqs $MG/qza/mice_reads.qza \
    --p-trim-left $TRIM_LEFT \
    --p-trunc-len $TRUNC_LEN \
    --p-max-ee 3 \
    --p-n-threads $THREADS \
    --p-pooling-method "pseudo" \
    --p-chimera-method "consensus" \
    --p-min-fold-parent-over-abundance 4 \
    --o-table $MG/qza/mice_ASV_table.qza \
    --o-representative-sequences $MG/qza/mice_rep_seq.qza \
    --o-denoising-stats $MG/qza/mice_reads.dada2.stats.qza
fi

# ============================================================
#  3. СТАТИСТИКА DADA2 (визуализация)
# ============================================================
echo "=== [3/8] metadata tabulate (dada2 stats) ==="
$Q2 qiime metadata tabulate \
  --m-input-file $MG/qza/mice_reads.dada2.stats.qza \
  --o-visualization $MG/qzv/mice_reads.dada2.stats.qzv

# ============================================================
#  4. ТАКСОНОМИЯ (classify-sklearn)
# ============================================================
echo "=== [4/8] feature-classifier classify-sklearn ==="
$Q2 qiime feature-classifier classify-sklearn \
  --i-classifier $CLASSIFIER \
  --i-reads $MG/qza/mice_rep_seq.qza \
  --o-classification $MG/qza/mice_taxonomy.qza \
  --p-n-jobs $THREADS

# ============================================================
#  5. БАРПЛОТ ТАКСОНОМИИ
# ============================================================
echo "=== [5/8] taxa barplot ==="
$Q2 qiime taxa barplot \
  --i-table $MG/qza/mice_ASV_table.qza \
  --i-taxonomy $MG/qza/mice_taxonomy.qza \
  --m-metadata-file $METADATA \
  --o-visualization $MG/qzv/mice_taxonomy_barplot.qzv

# ============================================================
#  6. ФИЛОГЕНИЯ (MAFFT + FastTree)
# ============================================================
echo "=== [6/8] phylogeny align-to-tree-mafft-fasttree ==="
$Q2 qiime phylogeny align-to-tree-mafft-fasttree \
  --i-sequences $MG/qza/mice_rep_seq.qza \
  --o-alignment $MG/qza/aligned_mice_rep_seq.qza \
  --o-masked-alignment $MG/qza/masked_aligned_mice_rep_seq.qza \
  --o-tree $MG/qza/mice_unrooted_tree.qza \
  --o-rooted-tree $MG/qza/mice_rooted_tree.qza

# ============================================================
#  7. CORE METRICS (альфа + бета разнообразие)
# ============================================================
echo "=== [7/8] diversity core-metrics-phylogenetic ==="
$Q2 qiime diversity core-metrics-phylogenetic \
  --i-phylogeny $MG/qza/mice_rooted_tree.qza \
  --i-table $MG/qza/mice_ASV_table.qza \
  --p-sampling-depth $SAMPLING_DEPTH \
  --m-metadata-file $METADATA \
  --output-dir $MG/mice_core_metrics_results

# ============================================================
#  8. СТАТИСТИКА АЛЬФА-РАЗНООБРАЗИЯ ПО ГРУППАМ
# ============================================================
echo "=== [8/8] diversity alpha-group-significance (Shannon) ==="
$Q2 qiime diversity alpha-group-significance \
  --i-alpha-diversity $MG/mice_core_metrics_results/shannon_vector.qza \
  --m-metadata-file $METADATA \
  --o-visualization $MG/mice_core_metrics_results/mice_shannon_significance.qzv

echo "=== ALL DONE ==="
