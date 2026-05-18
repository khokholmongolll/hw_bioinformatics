## 5 дз(если что отчёты multiqc лежат в папке results)
## Часть 1. Анализ исходных данных (FastQC + MultiQC)

Для анализа были выбраны 4 файла из проекта PRJEB84057 :
1. `ERR14230599_Illumina_HiSeq_4000_sequencing.fastq.gz`
2. `ERR14230600_Illumina_HiSeq_4000_sequencing.fastq.gz`
3. `ERR14230602_Illumina_HiSeq_4000_sequencing.fastq.gz`
4. `ERR14230603_Illumina_HiSeq_4000_sequencing.fastq.gz`

### Проблемы до тримминга)

На основе отчета MultiQC  выявлены следующие особенности:

1.  **Короткая длина ридов:** Средняя длина составляет всего **45–47 п.н.** . Это значительно меньше стандарта (обычно 150–250 п.н.).
2.  **Высокий процент неудачных модулей (% Failed):** Для образцов ERR14230599 и ERR14230600 показатель составляет **18%**, для остальных — **9%**. Это указывает на наличие проблем с качеством или составом последовательностей.
3.  **Отсутствие адаптеров:** нет адаптеров из-за того что на коротких ридах они не проявляются

**Таблица General Statistics из Multiqc:**

| Sample Name | % Dups | % GC | Length | % Failed | M Seqs |
| :--- | :--- | :--- | :--- | :--- | :--- |
| ERR14230599 | 18.8% | 47% | 47 | 18% | 2.0 |
| ERR14230600 | 18.2% | 46% | 47 | 18% | 2.0 |
| ERR14230602 | 15.3% | 46% | 46 | 9% | 1.8 |
| ERR14230603 | 15.2% | 46% | 45 | 9% | 1.9 |

---

## Часть 2. Мои Скрипты(запушил на гит если что)

### 1. Скрипт запуска FastQC

```bash
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

DATA_DIR="/home/STUDY/FBMF/studfbmf02_17/hw_5/data"
OUT_DIR="/home/STUDY/FBMF/studfbmf02_17/hw_5/results/fastqc"

$FASTQC -t 4 -o "$OUT_DIR" "$DATA_DIR"/*.fastq.gz
```

### 2. Скрипт MultiQC
```bash
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


$MULTIQC -o /home/STUDY/FBMF/studfbmf02_17/hw_5/results/before_trim /home/STUDY/FBMF/studfbmf02_17/hw_5/results/fastqc/*_fastqc.zip
```
### 3. Скрипт fastp
Параметры:
*   `-W 5 -M 20`: Скользящее окно 5 п.н., порог качества 20.
*   `-l 36`: Минимальная длина рида после обрезки 36 п.н.
*   `--detect_adapter_for_pe`: Автопоиск адаптеров.

```bash
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
```

### 3. Файлы после тримминга


```
(multiqc) [studfbmf02_17@calc after_trim]$ ls -la --time=ctime
total 197771
drwxr-xr-x. 3 studfbmf02_17 fbmf       14 May 18 15:59 .
drwxr-xr-x. 5 studfbmf02_17 fbmf        3 May 18 15:08 ..
-rw-r--r--. 1 studfbmf02_17 fbmf   221438 May 18 15:00 ERR14230599_Illumina_HiSeq_4000_sequencing_fastp.html
-rw-r--r--. 1 studfbmf02_17 fbmf    51049 May 18 15:00 ERR14230599_Illumina_HiSeq_4000_sequencing_fastp.json
-rw-r--r--. 1 studfbmf02_17 fbmf 52366996 May 18 15:00 ERR14230599_Illumina_HiSeq_4000_sequencing_trimmed.fastq.gz
-rw-r--r--. 1 studfbmf02_17 fbmf   221397 May 18 15:01 ERR14230600_Illumina_HiSeq_4000_sequencing_fastp.html
-rw-r--r--. 1 studfbmf02_17 fbmf    51021 May 18 15:01 ERR14230600_Illumina_HiSeq_4000_sequencing_fastp.json
-rw-r--r--. 1 studfbmf02_17 fbmf 53895540 May 18 15:01 ERR14230600_Illumina_HiSeq_4000_sequencing_trimmed.fastq.gz
-rw-r--r--. 1 studfbmf02_17 fbmf   221170 May 18 15:01 ERR14230602_Illumina_HiSeq_4000_sequencing_fastp.html
-rw-r--r--. 1 studfbmf02_17 fbmf    50803 May 18 15:01 ERR14230602_Illumina_HiSeq_4000_sequencing_fastp.json
-rw-r--r--. 1 studfbmf02_17 fbmf 46372722 May 18 15:01 ERR14230602_Illumina_HiSeq_4000_sequencing_trimmed.fastq.gz
-rw-r--r--. 1 studfbmf02_17 fbmf   221153 May 18 15:01 ERR14230603_Illumina_HiSeq_4000_sequencing_fastp.html
-rw-r--r--. 1 studfbmf02_17 fbmf    50793 May 18 15:01 ERR14230603_Illumina_HiSeq_4000_sequencing_fastp.json
-rw-r--r--. 1 studfbmf02_17 fbmf 47619076 May 18 15:01 ERR14230603_Illumina_HiSeq_4000_sequencing_trimmed.fastq.gz
drwxr-xr-x. 2 studfbmf02_17 fbmf        4 May 18 15:59 multiqc_data
-rw-r--r--. 1 studfbmf02_17 fbmf  1170849 May 18 15:59 multiqc_report.html
```
---

## Часть 3. Контроль качества после тримминга

Снова запустили FASTQC и MULTQC но уже для данных с триммингом

**Сравнение метрик до и после тримминга:**

1. **Качество данных (% Failed):** Процент неудачных тестов FastQC снизился с 18% до 9% для всех образцов. Это главное улучшение, достигнутое за счет обрезки низкокачественных концов ридов ( sliding window 5:20).
2. **Фильтрация ридов:** Общее количество прочтений уменьшилось примерно на 15-20% (с ~2.0M до ~1.7M). Это связано с жестким фильтром по минимальной длине (`-l 36`). Так как исходные риды были очень короткими (45-47 п.н.), многие из них после обрезки не достигли порога в 36 п.н. и были отброшены.
3. **Дупликации:** Уровень дупликаций (% Dups) снизился в среднем на 4-5%, что говорит об удалении технических артефактов.
4. **Адаптеры:** Контаминациb адаптерами всё так же нет


---

## Вывод

Тримминг успешно очистил данные от низкокачественных участков, ценой потери части коротких ридов. Оставшаяся выборка (~1.5-1.7 млн ридов на образец) имеет качетсво лучше.
