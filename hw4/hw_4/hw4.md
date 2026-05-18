
## 🔹 Часть 1. Сборка с помощью Velvet(скрипт 1)

### SLURM-скрипт для запуска Velvet

```bash
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

KMERS=(11 21 31)


for K in "${KMERS[@]}"; do
    OUT_DIR="${OUT_BASE}/k${K}"

    mkdir -p "$OUT_DIR"

    $VELVETH "$OUT_DIR" "$K" -fastq -shortPaired "$READ1" "$READ2"

   $VELVETG "$OUT_DIR" "$K" -ins_length 300 -ins_length_std_dev 20 -exp_cov auto -cov_cutoff auto

done
```

### Файлы на сервере

```text
(base) [studfbmf02_17@calc hw_4]$ ls -la --time=ctime /home/STUDY/FBMF/studfbmf02_17/hw_4/velvet_bck/k31
total 23777
drwxr-xr-x. 2 studfbmf02_17 fbmf        8 May  7 11:10 .
drwxr-xr-x. 5 studfbmf02_17 fbmf        3 May  7 11:10 ..
-rw-r--r--. 1 studfbmf02_17 fbmf    71714 May  7 11:10 contigs.fa
-rw-r--r--. 1 studfbmf02_17 fbmf   235448 May  7 11:10 Graph
-rw-r--r--. 1 studfbmf02_17 fbmf   235448 May  7 11:10 LastGraph
-rw-r--r--. 1 studfbmf02_17 fbmf     1080 May  7 11:10 Log
-rw-r--r--. 1 studfbmf02_17 fbmf   718882 May  7 11:10 PreGraph
-rw-r--r--. 1 studfbmf02_17 fbmf  6501882 May  7 11:10 Roadmaps
-rw-r--r--. 1 studfbmf02_17 fbmf 16404727 May  7 11:10 Sequences
-rw-r--r--. 1 studfbmf02_17 fbmf   176344 May  7 11:10 stats.txt
```

---

## 🔹 Часть 2. Сравнение сборок (Velvet vs SPAdes) скрипт 2

Для сравнения был использован инструмент **QUAST**.

### Таблица метрик QUAST

| Assembly       | # contigs (>= 0 bp) | Total length (>= 0 bp) | Largest contig | N50     | auN       |
| :------------- | :------------------ | :--------------------- | :------------- | :------ | :-------- |
| **Velvet_k11** | 3073                | 79,010                 | 63             | 25      | 26.9      |
| **Velvet_k21** | 2060                | 133,813                | 253            | 67      | 77.4      |
| **Velvet_k31** | 541                 | 51,988                 | 414            | 104     | 114.7     |
| **SPAdes**     | **49**              | **15,064**             | **1069**       | **440** | **484.1** |
|                |                     |                        |                |         |           |

![[Pasted image 20260518211019.png]]

### Выводы по сравнению:

Сборка **SPAdes лучше**, так как она дает наименьшее число контигов при наибольшей длине N50 и Largest Contig малове количество K меров не даёт собрать геном и velvet даёт огромную общею длину генома из-за шума и повторов - пнри этом ОЧЕНЬ маленькие контиги

---

## 🔹 Часть 3. Улучшение сборок(скрипты 3 4 и 5)
### Соображения по улучшению:

1.  **Для SPAdes:**
    *   Использовал флаг `--isolate`.Он агрессивнее соединяет контиги и игнорирует редкие варианты как ошибки секвенированияувеличить N50

2.  **Для Velvet:**
    *   Так как увеличение K-мера выше 31 нельзя - не хочу перекомпилировать 
    *   Добавлены параметры `-cov_cutoff auto` (автоматическое удаление узлов с низким покрытием, т.е. ошибок) и `-min_contig_lgth 200` (исключение очень короткого мусора из финального файла).
### Сравнение 4 сборок (QUAST Report)

Ниже приведена итоговая таблица QUAST, сравнивающая старые и новые версии сборок.

| Assembly | # contigs (>= 0 bp) | Total length (>= 0 bp) | Largest contig | N50 | auN | L50 |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Velvet_k31 (Old)** | 541 | 51,988 | 414 | 104 | 114.7 | 185 |
| **Velvet_k31_imp (New)**| **14** | **3,492** | **414** | **243** | **260.0** | **7** |
| **SPAdes (Old)** | 49 | 15,064 | 1069 | 440 | 484.1 | 12 |
| **SPAdes_imp (New)** | 42 | 13,799 | 1062 | 387 | 491.3 | 11 |
![[Pasted image 20260518211503.png]]

### Анализ улучшений:

1.  **Velvet Improved:**
    *  Резко упло число контигов с 541 до **14**. Это произошло благодаря параметру `-min_contig_lgth 200` и строгой обрезке покрытия (`-cov_cutoff auto`). Отсекли весь короткий шум
    *   Вырос N50 С 104 до **243**. Сборка стала менее фрагментированной, так как остались только самые надежные части графа и сильно упала общая длина - убрали очень много мусора, но по ощущениям убрало весь геном)
2.  **SPAdes Improved:**
- почти ничего не поменялось, SPADES хорош

---

## Выводы

1.  **Velvet не может без больших K-меров.**
2.  **SPAdes превосходит Velvet блавгодаря встроенному объединению k-меров**
3.  **Параметры фильтрации важны:** Для Velvet ручная настройка `-cov_cutoff` и `-min_contig_lgth` позволяет существенно улучшить статистику (N50), удаляя артефакты сборки.

---
