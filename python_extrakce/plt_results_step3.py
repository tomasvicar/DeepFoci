import seaborn as sns
import pandas as pd
import matplotlib.pyplot as plt

# Features to plot; adjust these based on the actual features in your DataFrame
feature_columns = ['counts_r', 'counts_g', 'counts_rg', 'volume_fraction', 'foci_volume', 'correlation',
                   'correlation_spearman', 'percentile99_r', 'percentile99_g', 'median_r']

data_path = r"C:\Data\Vicar\foci_rad51_retrain\data\NANOREP" + '_tmp_results3'
df = pd.read_excel(data_path + '/results.xlsx')


df = df[df['selected_cells'] == 1]
# df['time'][df['time'] == 'control'] = '0,5h'

sns.boxplot(x='gy', y='counts_rg', hue='time', data=df, palette='Set3', showfliers=False)

