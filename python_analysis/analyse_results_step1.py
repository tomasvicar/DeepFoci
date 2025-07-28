
from glob import glob
import matplotlib.pyplot as plt
import numpy as np
from imageio.v2 import imread
from scipy.ndimage import zoom
import h5py
import napari
from scipy.ndimage import label, zoom
from skimage.measure import regionprops_table
import pandas as pd
from scipy.stats import pearsonr, spearmanr
import os
from scipy.ndimage import gaussian_filter


from read_ics_file import read_ics_file_ordered
from read_detections import read_detections


resized_img_size = [505, 681, 48]
voxel_size_um = [0.1650,0.1650,0.3]
z_resize_faktor = voxel_size_um[2] / voxel_size_um[0]
output_detection_channels = ['points_53BP1','points_gH2AX','points_53BP1_gH2AX_overlap']

data_path = r"C:\Data\Vicar\foci_rad51_retrain\data\NANOREP"
positive_negative_label_path = r"C:\Data\Vicar\foci_rad51_retrain\RAD51 positive nuclei_Labelled MF\labeled"

detection_path = data_path + '_net_results_rad51'
cellseg_path = data_path + '_net_results_oldseg'
fociseg_path = data_path + '_fociseg_rad51'
tmp_results_path = data_path + '_tmp_results3'


fnames = glob(data_path + '/**/01.ics', recursive=True)

for fnum, fname in enumerate(fnames):
    print(f'{fnum+1}/{len(fnames)}: {fname}')
    # if fnum % 5 != 0:
    #     continue
    if (fnum + 1)  < 648:
        continue

    try:
    # if True:
        if fnum == 377:
            continue
        if fnum == 378:
            continue
        if fnum == 542:
            continue
        if fnum == 626:
            continue
        if fnum == 648:
            continue


        fname_detection = fname.replace(data_path, detection_path).replace('01.ics', 'detections.json')
        fname_cellseg = fname.replace(data_path, cellseg_path).replace('01.ics', 'nuclei_semgentaton.tif')
        fname_fociseg = fname.replace(data_path, fociseg_path).replace('01.ics', 'foci_semgentaton.tif')
        fname_tmp_results = fname.replace(data_path, tmp_results_path).replace('01.ics', 'res')
        fname_positive_negative_label = positive_negative_label_path + '/' + f'img_and_mask_{str(fnum+1).zfill(3)}_label.h5'

        data, channel_names = read_ics_file_ordered(fname, get_channel_names=True)



        segmentation = imread(fname_cellseg) > 0.5
        segmentation, segmentation_num = label(segmentation, np.ones((3, 3, 3)))
        zoom_factors = [n / o for n, o in zip(data.shape[:-1], segmentation.shape)]
        segmentation = zoom(segmentation, zoom_factors, order=0)

        fociseg = imread(fname_fociseg)
        fociseg, fociseg_num = label(fociseg, np.ones((3, 3, 3)))
        zoom_factors = [n / o for n, o in zip(data.shape[:-1], fociseg.shape)]
        fociseg = zoom(fociseg, zoom_factors, order=0)

        fociseg_resize = zoom(fociseg, [1, 1, z_resize_faktor], order=0)
        segmentation_resize = zoom(segmentation, (1, 1, z_resize_faktor), order=0)


        detections, binary_detections = read_detections(fname_detection, data.shape[:-1], output_detection_channels, resized_img_size)

        with h5py.File(fname_positive_negative_label, 'r') as file:
            positive_negative_mask_tmp = file['mask_final'][:].T

        # positive_negative_mask_tmp = np.transpose(positive_negative_mask_tmp, [1, 0])
        positive_negative_mask = np.zeros_like(positive_negative_mask_tmp)
        positive_negative_mask[positive_negative_mask_tmp > 0] = 1
        positive_negative_mask[positive_negative_mask_tmp > 100] = 2

        # from skimage.morphology import binary_dilation
        # from skimage.morphology import disk
        # plt.imshow(binary_dilation(np.max(binary_detections['points_RAD51'], axis=2), disk(5)))
        # plt.show()

        # f = lambda x: (np.percentile(x, 1e-6), np.percentile(x, 100 - 1e-2))
        # contrast_limits = [f(data[:,:,:,i]) for i in range(3)]
        # plt.imshow(data[:,:,25,0], vmin=contrast_limits[0][0], vmax=contrast_limits[0][1])
        # plt.show()

        # gdfgdfgdg

        # print(data.shape)
        # viewer = napari.Viewer()
        # color_maps = ['red', 'green', 'blue']  # Standard RGB colors
        # f = lambda x: (np.percentile(x, 1e-6), np.percentile(x, 100 - 1e-2))
        # contrast_limits = [f(data[:,:,:,i]) for i in range(3)] 
        # image_layer = viewer.add_image(data, channel_axis=3, colormap=color_maps, contrast_limits=contrast_limits)
        # for channel_index, (channel, points) in enumerate(detections.items()):
        #     points = points[:, [1, 0, 2]]
        #     if points.size > 0:  # Check if there are any points
        #         viewer.add_points(points, name=channel, size=10, face_color=color_maps[channel_index])
        # viewer.add_labels(segmentation, name='Nuclei Segmentation', color={'0': 'transparent', '1': 'magenta'})
        # viewer.add_labels(fociseg, name='Foci Segmentation', color={'0': 'transparent', '1': 'yellow'})
        # napari.run()

        # plt.imshow(positive_negative_mask)
        # plt.show()


        # print(np.unique(segmentation))
        # plt.imshow(np.max(segmentation, axis=2))
        # plt.show()
        
        # print(np.unique(fociseg))
        # plt.imshow(np.max(fociseg, axis=2))
        # plt.show()


        def calculate_properties(label_image, intensity_image, extra_columns):
            properties = regionprops_table(label_image, intensity_image, properties=['max_intensity', 'mean_intensity'])
            df = pd.DataFrame(properties)
            df.rename(columns={'max_intensity': f'max_intensity_{extra_columns}', 'mean_intensity': f'mean_intensity_{extra_columns}'}, inplace=True)
            return df

        # Calculate properties for different channels
        r_table = calculate_properties(fociseg, data[:,:,:,0], 'r')
        g_table = calculate_properties(fociseg, data[:,:,:,1], 'g')
        b_table = calculate_properties(fociseg, data[:,:,:,2], 'b')
        rg_table = calculate_properties(fociseg, data[:,:,:,0] * data[:,:,:,1], 'rg')

        # Nuclei number per region
        nuc_num_table = calculate_properties(fociseg, segmentation, 'nuc_num')

        
        # Calculate shape properties for resized labels
        shape_properties = regionprops_table(fociseg_resize, properties=['area', 'solidity', 'axis_major_length', 'axis_minor_length', 'equivalent_diameter'])
        shape_table = pd.DataFrame(shape_properties)
        shape_table.rename(columns={'area': 'volume'}, inplace=True)

        shape_table["volume_um"] = shape_table["volume"] * (voxel_size_um[0]**3)
        shape_table["axis_major_length_um"] = shape_table["axis_major_length"] * voxel_size_um[0]
        shape_table["axis_minor_length_um"] = shape_table["axis_minor_length"] * voxel_size_um[0]
        shape_table["equivalent_diameter_um"] = shape_table["equivalent_diameter"] * voxel_size_um[0]


        N = np.max(fociseg)  # Get the maximum label number
        correlation = np.zeros(N)
        correlation_spearman = np.zeros(N)

        # Calculate correlations for each label
        for k in range(1, N+1):
            tmp_r = data[:,:,:,0][fociseg == k]
            tmp_g = data[:,:,:,1][fociseg == k]

            # Check if arrays are non-empty and have more than one unique value
            if len(tmp_r) > 1 and len(np.unique(tmp_r)) > 1 and len(np.unique(tmp_g)) > 1:
                correlation[k-1], _ = pearsonr(tmp_r, tmp_g)
                correlation_spearman[k-1], _ = spearmanr(tmp_r, tmp_g)
            else:
                correlation[k-1] = np.nan  # Assign NaN if not enough data for correlation
                correlation_spearman[k-1] = np.nan

        # Assuming 'rg_table' is already defined as a DataFrame containing the region properties
        rg_table['correlation'] = correlation
        rg_table['correlation_spearman'] = correlation_spearman



        foci_features = pd.concat([r_table, g_table, b_table, rg_table, shape_table, nuc_num_table], axis=1)

        N = np.max(segmentation)

        variable_names = [
        'median_r', 'median_g', 'median_b', 'median_rg',
        'percentile99_r', 'percentile99_g', 'percentile99_b', 'percentile99_rg',
        'correlation', 'correlation_spearman', 'volume', 'volume_um',
    ]
        nuc_features = {name: np.zeros(N) for name in variable_names}


        for cell_num in range(1, N + 1):

            mask3d = segmentation == cell_num
            masked_a = data[:,:,:,0][mask3d].flatten()
            masked_b = data[:,:,:,1][mask3d].flatten()
            masked_c = data[:,:,:,2][mask3d].flatten()
            masked_ab = (data[:,:,:,0] * data[:,:,:,1])[mask3d].flatten()

            percentile_99 = lambda x: np.percentile(x, 99)
            nuc_features['median_r'][cell_num - 1] = np.median(masked_a)
            nuc_features['median_g'][cell_num - 1] = np.median(masked_b)
            nuc_features['median_b'][cell_num - 1] = np.median(masked_c)
            nuc_features['median_rg'][cell_num - 1] = np.median(masked_ab)

            nuc_features['percentile99_r'][cell_num - 1] = percentile_99(masked_a)
            nuc_features['percentile99_g'][cell_num - 1] = percentile_99(masked_b)
            nuc_features['percentile99_b'][cell_num - 1] = percentile_99(masked_c)
            nuc_features['percentile99_rg'][cell_num - 1] = percentile_99(masked_ab)


            if len(masked_a) > 1:  # Ensure there are at least two elements to compute correlation
                nuc_features['correlation'][cell_num - 1], _ = pearsonr(masked_a, masked_b)
                nuc_features['correlation_spearman'][cell_num - 1], _ = spearmanr(masked_a, masked_b)
            else:
                nuc_features['correlation'][cell_num - 1] = np.nan
                nuc_features['correlation_spearman'][cell_num - 1] = np.nan

            nuc_features['volume'][cell_num - 1] = np.sum(mask3d)
            nuc_features['volume_um'][cell_num - 1] = np.sum(mask3d) * (voxel_size_um[0] * voxel_size_um[1] * voxel_size_um[2])


        for name in variable_names:
            nuc_features[name + '_nuc'] = nuc_features.pop(name)
        nuc_features = pd.DataFrame(nuc_features)


        a = gaussian_filter(data[:, :, :, 0].astype(np.float32), sigma=[2, 2, 1])
        b = gaussian_filter(data[:, :, :, 1].astype(np.float32), sigma=[2, 2, 1])
        c = gaussian_filter(data[:, :, :, 2].astype(np.float32), sigma=[2, 2, 1])

        foci_features_points = dict()

        channels = output_detection_channels

        for channel in channels:
            labeled_image = label(binary_detections[channel])[0]

            r_table = pd.DataFrame(regionprops_table(labeled_image, a, properties=['max_intensity']))
            r_table.rename(columns={'max_intensity': 'max_intensity_r'}, inplace=True)
            
            g_table = pd.DataFrame(regionprops_table(labeled_image, b, properties=['max_intensity']))
            g_table.rename(columns={'max_intensity': 'max_intensity_g'}, inplace=True)
            
            b_table = pd.DataFrame(regionprops_table(labeled_image, c, properties=['max_intensity']))
            b_table.rename(columns={'max_intensity': 'max_intensity_b'}, inplace=True)
            
            # Assuming ab is computed as a*b element-wise
            ab = a * b
            rg_table = pd.DataFrame(regionprops_table(labeled_image, ab, properties=['max_intensity']))
            rg_table.rename(columns={'max_intensity': 'max_intensity_rg'}, inplace=True)
            
            # Compute properties for nuc_num_table
            nuc_num_table = pd.DataFrame(regionprops_table(labeled_image, segmentation, properties=['max_intensity']))
            nuc_num_table.rename(columns={'max_intensity': 'nuc_num'}, inplace=True)
            
            # Combine all tables into one DataFrame for the current channel
            combined_table = pd.concat([r_table, g_table, b_table, rg_table, nuc_num_table], axis=1)
            foci_features_points[channel] = combined_table



        def median_intensity(regionmask, intensity_image):
            return np.median(intensity_image[regionmask])

        positive_negative_mask_replicate = np.repeat(positive_negative_mask[:, :, np.newaxis], data.shape[2], axis=2) > 1.5
        nuc_use = pd.DataFrame(regionprops_table(segmentation, positive_negative_mask_replicate, properties=[], extra_properties=[median_intensity, ]))
        nuc_use.rename(columns={'median_intensity': 'nuc_use'}, inplace=True)
        


        # save_name_nuc = fname_tmp_results + '_nuc_features.csv'
        # os.makedirs(os.path.dirname(save_name_nuc), exist_ok=True)
        # nuc_features.to_csv(save_name_nuc, index=False)

        # save_name_foci = fname_tmp_results + '_foci_features.csv'
        # os.makedirs(os.path.dirname(save_name_foci), exist_ok=True)
        # foci_features.to_csv(save_name_foci, index=False)

        save_name = fname_tmp_results + '_features.h5'
        os.makedirs(os.path.dirname(save_name), exist_ok=True)
        nuc_features.to_hdf(save_name, key='nuc_features', mode='w')
        foci_features.to_hdf(save_name, key='foci_features', mode='a')
        for channel in channels:
            foci_features_points[channel].to_hdf(save_name, key='foci_features_points_channel' + channel, mode='a')

        nuc_use.to_hdf(save_name, key='nuc_use', mode='a')

        


    except Exception as e:
        print(f'Error: {e}')
        with open(tmp_results_path + str(fnum).zfill(5) +  '_error.txt', 'w') as file:
            file.write(str(e))
    

    # break
    
# fname = r"C:\Data\Vicar\foci_rad51_retrain\data\NANOREP_tmp_results\gamma-IR_NHDF_RAD51+gH2AX_2021_6_8 (Acquiarium)\IR 1Gy\IR1Gy_0,5hPI\rawdata\0001\res_features.h5"
# nuc_features = pd.read_hdf(fname, 'nuc_features')
# foci_features = pd.read_hdf(fname, 'foci_features')

# foci_features_points = dict()
# for channel in channels:
#     foci_features_points[channel] = pd.read_hdf(save_name, key='foci_features_points_channel' + channel)
# nuc_use = pd.read_hdf(save_name, 'nuc_use')



    
    
















