
from glob import glob
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import h5py
import os


data_path = r"C:\Data\Vicar\foci_rad51_retrain\data\NANOREP"
tmp_results_path = data_path + '_tmp_results'


# order_typenames = [
#     ("gamma-IR_NHDF_RAD51+gH2AX_2021_6_8 (Acquiarium)\\non-IR control 1", "NHDF CTRL1"),
#     ("gamma-IR_NHDF_RAD51+gH2AX_2021_6_8 (Acquiarium)\\non-IR control 2", "NHDF CTRL2"),
#     ("gamma-IR_NHDF_RAD51+gH2AX_2021_6_8 (Acquiarium)\\IR 1Gy", "NHDF 1Gy"),
#     ("gamma-IR_NHDF_RAD51+gH2AX_2021_6_8 (Acquiarium)\\IR 2Gy", "NHDF 2Gy"),
#     ("gamma-IR_NHDF_RAD51+gH2AX_2021_6_8 (Acquiarium)\\IR 4Gy", "NHDF 4Gy"),
#     ("gamma-IR_U87_RAD51+gH2AX_2021_6_8  (Acquiarium)\\U87_non IR control", "U87 CTRL"),
#     ("gamma-IR_U87_RAD51+gH2AX_2021_6_8  (Acquiarium)\\U87_IR 1Gy", "U87 1Gy"),
#     ("gamma-IR_U87_RAD51+gH2AX_2021_6_8  (Acquiarium)\\U87_IR 2Gy", "U87 2Gy"),
#     ("gamma-IR_U87_RAD51+gH2AX_2021_6_8  (Acquiarium)\\U87_IR 4Gy", "U87 4Gy"),
# ]



fnames = glob(tmp_results_path + '/**/*_features.h5', recursive=True)



all_data = dict()
for fname in fnames:
    data_tmp = dict()
    with h5py.File(fname, 'r') as f:
        keys  = list(f.keys())
           
    for key in keys:
        df = pd.read_hdf(fname, key=key)
        data_tmp[key] = df

    data = dict()
    data['nuc_features'] = data_tmp['nuc_features']
    data['nuc_use'] = data_tmp['nuc_use']

    # get nuc average for foci features
    num_of_nuc = data_tmp['nuc_features'].shape[0]
    table_names = ['foci_features', 'foci_features_points_channelpoints_RAD51_gH2AX_overlap', 'foci_features_points_channelpoints_RAD51', 'foci_features_points_channelpoints_gH2AX']
    for table_name in table_names:
        df = data_tmp[table_name]
        if 'max_intensity_nuc_num' in df.columns:
            tmp_name = 'max_intensity_nuc_num'
        elif 'nuc_num' in df.columns:
            tmp_name = 'nuc_num'
        tmp = df.groupby(tmp_name).count()
        df = df.groupby(tmp_name).mean()
        df['foci_count'] = tmp.iloc[:, 0]
        df = df.reset_index()
        data[table_name] = df

    all_data[fname] = data

# foci counts
counts_r = []
counts_g = []
counts_rg = []
volume_fractions = []
foci_volumes = []
correlations_spearman = []
correlations = []
percentile_r_nuc_intensities = []
percentile_g_nuc_intensities = []
median_r_intensities = []
median_g_intensities = []
max_r_intensities = []
max_g_intensities = []
mean_r_intensities = []
mean_g_intensities = []

selected_cells = []




cell_types = []
gys = []
times = []
folders = []
groups = []
for fname, data in all_data.items():

    if 'NHDF' in fname:
        cell_type = 'NHDF'
    elif 'U87' in fname:
        cell_type = 'U87'
    else:
        raise ValueError('cell type not found')

    if '1Gy' in fname.replace(' ', ''):
        gy = '1'
    elif '2Gy' in fname.replace(' ', ''):
        gy = '2'
    elif '4Gy' in fname.replace(' ', ''):
        gy = '4'
    elif 'control' in fname:
        gy = 'control'
    else:
        raise ValueError('gy not found')
    
    if '0,5h' in fname.replace(' ', ''):
        time = '0,5h'
    elif '1h' in fname.replace(' ', ''):
        time = '1h'
    elif '2h' in fname.replace(' ', ''):
        time = '2h'
    elif '4h' in fname.replace(' ', ''):
        time = '4h'
    elif '8h' in fname.replace(' ', ''):
        time = '8h'
    elif '24h' in fname.replace(' ', ''):
        time = '24h'
    elif 'control' in fname:
        time = 'control'
    else:
        raise ValueError('time not found')
    

    folder = os.path.normpath(fname).split(os.sep)[-4]

    group = f'{cell_type} {gy} {time}'


    for ind in range(data['foci_features'].shape[0]):
        counts_r.append(data['foci_features_points_channelpoints_gH2AX'].iloc[ind]['foci_count'])
        counts_g.append(data['foci_features_points_channelpoints_RAD51'].iloc[ind]['foci_count'])
        counts_rg.append(data['foci_features_points_channelpoints_RAD51_gH2AX_overlap'].iloc[ind]['foci_count'])
        tmp = data['foci_features'].iloc[ind]['volume_um'] * data['foci_features'].iloc[ind]['foci_count'] / data['nuc_features'].iloc[ind]['volume_um_nuc']
        volume_fractions.append(tmp)
        tmp = data['foci_features'].iloc[ind]['volume_um'] * data['foci_features'].iloc[ind]['foci_count']
        foci_volumes.append(tmp)
        tmp = data['nuc_features'].iloc[ind]['correlation_nuc']
        correlations.append(tmp)
        tmp = data['nuc_features'].iloc[ind]['correlation_spearman_nuc']
        correlations_spearman.append(tmp)
        tmp = data['nuc_features'].iloc[ind]['percentile99_r_nuc']
        percentile_r_nuc_intensities.append(tmp)
        tmp = data['nuc_features'].iloc[ind]['percentile99_g_nuc']
        percentile_g_nuc_intensities.append(tmp)
        tmp = data['nuc_features'].iloc[ind]['median_r_nuc']
        median_r_intensities.append(tmp)
        tmp = data['nuc_features'].iloc[ind]['median_g_nuc']
        median_g_intensities.append(tmp)
        tmp = data['foci_features'].iloc[ind]['max_intensity_r']
        max_r_intensities.append(tmp)
        tmp = data['foci_features'].iloc[ind]['max_intensity_g']
        max_g_intensities.append(tmp)
        tmp = data['foci_features'].iloc[ind]['mean_intensity_r']
        mean_r_intensities.append(tmp)
        tmp = data['foci_features'].iloc[ind]['mean_intensity_g']
        mean_g_intensities.append(tmp)
        tmp = data['nuc_use'].iloc[ind]['nuc_use']
        selected_cells.append(tmp)



        groups.append(group)
        times.append(time)
        gys.append(gy)
        cell_types.append(cell_type)
        folders.append(folder)


df = pd.DataFrame({'counts_r': counts_r, 'counts_g': counts_g, 'counts_rg': counts_rg,
                    'volume_fraction': volume_fractions, 'foci_volume': foci_volumes,
                    'correlation': correlations, 'correlation_spearman': correlations_spearman,
                    'percentile99_r': percentile_r_nuc_intensities, 'percentile99_g': percentile_g_nuc_intensities,
                    'median_r': median_r_intensities, 'median_g': median_g_intensities,
                    'max_r': max_r_intensities, 'max_g': max_g_intensities,
                    'mean_r': mean_r_intensities, 'mean_g': mean_g_intensities,
                    'selected_cells': selected_cells, 
                    'time': times, 'gy': gys, 'cell_type': cell_types,
                    'folder': folders, 'group': groups,})

df.to_excel(tmp_results_path + 'results.xlsx', index=False, engine='openpyxl')





    
