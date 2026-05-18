import pandas as pd
import matplotlib.pyplot as plt
import numpy as np

# Пути к файлам (измени, если твои пути отличаются)
star_file = 'RNA_ReadsPerGene.out.tab'
htseq_file = 'htseq_counts.txt'

# 1. Чтение STAR (пропускаем первые 4 строки заголовка)
# Колонки: GeneID, col1, col2(unstranded), col3
star_df = pd.read_csv(star_file, sep='\t', header=None, skiprows=4, usecols=[0, 2])
star_df.columns = ['GeneID', 'STAR_Counts']
star_df.set_index('GeneID', inplace=True)

# 2. Чтение HTSeq
htseq_df = pd.read_csv(htseq_file, sep='\t', header=None)
htseq_df.columns = ['GeneID', 'HTSeq_Counts']
# Убираем служебные строки (__no_feature и т.д.)
htseq_df = htseq_df[~htseq_df['GeneID'].str.startswith('__')]
htseq_df.set_index('GeneID', inplace=True)

# 3. Объединение таблиц по индексу (GeneID)
combined = pd.concat([star_df, htseq_df], axis=1).dropna()

# 4. Логарифмирование для лучшего вида графика (log2(x + 1))
combined['STAR_Log'] = np.log2(combined['STAR_Counts'] + 1)
combined['HTSeq_Log'] = np.log2(combined['HTSeq_Counts'] + 1)

# 5. Построение графика
plt.figure(figsize=(10, 10))
plt.scatter(combined['STAR_Log'], combined['HTSeq_Log'], s=10, alpha=0.5, color='blue')
plt.xlabel('STAR Log2 Counts (Unstranded)')
plt.ylabel('HTSeq-Count Log2 Counts')
plt.title('Correlation: STAR vs HTSeq-count')
plt.grid(True, linestyle='--', alpha=0.6)

# Добавление линии тренда (y=x)
max_val = max(combined['STAR_Log'].max(), combined['HTSeq_Log'].max())
plt.plot([0, max_val], [0, max_val], 'r--', label='y=x')
plt.legend()

# Сохранение
plt.savefig('scatter_plot_star_vs_htseq.png', dpi=300)
print("График сохранен как scatter_plot_star_vs_htseq.png")

# Расчет корреляции Пирсона
corr = combined['STAR_Counts'].corr(combined['HTSeq_Counts'])
print(f"Pearson Correlation Coefficient: {corr:.4f}")