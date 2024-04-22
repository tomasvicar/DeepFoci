
from glob import glob
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import h5py


data_path = r"C:\Data\Vicar\foci_rad51_retrain\data\NANOREP"
tmp_results_path = data_path + '_tmp_results'


order_typenames = [
    ("53BP1 + gH2AX/FB_Control_Early", "53BP1 FB control-early"),
    ("53BP1 + gH2AX/FB_Control", "53BP1 FB control"),
    ("53BP1 + gH2AX/FB_1,2Gy_10st_2h PI", "53BP1 FB 2h"),
    ("53BP1 + gH2AX/FB_1,2Gy_10st_24h PI", "53BP1 FB 24h"),
    ("53BP1 + gH2AX/U87_Control_Early", "53BP1 U87 control-early"),
    ("53BP1 + gH2AX/U87_Control_Late", "53BP1 U87 control-late"),
    ("53BP1 + gH2AX/U87_1.2Gy_10st_2hPI", "53BP1 U87 2h"),
    ("53BP1 + gH2AX/U87_1.2Gy_10st_24hPI", "53BP1 U87 24h"),
    ("RAD51 + gH2AX/FB_control", "RAD51 FB control"),
    ("RAD51 + gH2AX/FB_1.25 Gy_2h PI pěkné", "RAD51 FB 2h"),
    ("RAD51 + gH2AX/FB_1,25 Gy_24h PI pěkné", "RAD51 FB 24h"),
    ("RAD51 + gH2AX/U87_1.25Gy_Control", "RAD51 U87 control"),
    ("RAD51 + gH2AX/U87_1.25Gy_2hPI", "RAD51 U87 2h"),
    ("RAD51 + gH2AX/U87_1.25Gy_24hPI", "RAD51 U87 24h")
]



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
    table_names = ['foci_features', 'foci_features_points_channelpoints_53BP1_gH2AX_overlap', 'foci_features_points_channelpoints_RAD51', 'foci_features_points_channelpoints_gH2AX']
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
groups = []
for fname, data in all_data.items():

    for order_typename, typename in order_typenames:
        if order_typename in fname:
            group = typename
            break

    for ind in range(data['foci_features'].shape[0]):
        counts_r.append(data['foci_features_points_channelpoints_gH2AX'].iloc[ind]['foci_count'])
        counts_g.append(data['foci_features_points_channelpoints_RAD51'].iloc[ind]['foci_count'])
        counts_rg.append(data['foci_features_points_channelpoints_53BP1_gH2AX_overlap'].iloc[ind]['foci_count'])


    


    
