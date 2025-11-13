import seaborn as sns
import pandas as pd
import matplotlib.pyplot as plt

# Features to plot; adjust these based on the actual features in your DataFrame
feature_columns = ['counts_r', 'counts_g', 'counts_rg', 'volume_fraction', 'foci_volume', 'correlation',
                   'correlation_spearman', 'percentile99_r', 'percentile99_g', 'median_r', 'median_g']

data_path = r"D:\martin_urgent\URGENT_Naoparticle Manuscript Toufar/URGENT_Naoparticle Manuscript Toufar" + '_tmp_results'
df = pd.read_excel(data_path + '/results.xlsx')


# df = df[df['selected_cells'] == 1]
# df['time'][df['time'] == 'control'] = '0,5h'


df['gy_nps'] = df['gy'].astype(str) + ' | ' + df['nps'].astype(str)


for feature in feature_columns:


    cell_types = df['cell_type'].unique()
    for cell_type in cell_types:
        df_cell = df[df['cell_type'] == cell_type]
        

        plt.figure(figsize=(12, 12))
        sns.boxplot(x='gy_nps', y=feature, hue='time', data=df_cell, palette='Set3', showfliers=False)
        plt.xticks(rotation=-90)
        plt.title(cell_type)
        plt.savefig(data_path + f'/boxplot_{feature}_{cell_type}.png', bbox_inches='tight')
        plt.show()

