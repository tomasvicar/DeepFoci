
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


from read_ics_file import read_ics_file_ordered
from read_detections import read_detections

resized_img_size = [505, 681, 48]
voxel_size_um = [0.1650,0.1650,0.3]
z_resize_faktor = 1.8182
output_detection_channels = ['points_RAD51','points_gH2AX','points_53BP1_gH2AX_overlap']

data_path = r"C:\Data\Vicar\foci_rad51_retrain\data\NANOREP"
positive_negative_label_path = r"C:\Data\Vicar\foci_rad51_retrain\RAD51 positive nuclei_Labelled MF\labeled"

detection_path = data_path + '_net_results_rad51'
cellseg_path = data_path + '_net_results_oldseg'
fociseg_path = data_path + '_fociseg_rad51'
tmp_results_path = data_path + '_tmp_results'


fnames = glob(data_path + '/**/01.ics', recursive=True)

for fnum, fname in enumerate(fnames):
    print(f'{fnum+1}/{len(fnames)}: {fname}')


    fname_detection = fname.replace(data_path, detection_path).replace('01.ics', 'detections.json')
    fname_cellseg = fname.replace(data_path, cellseg_path).replace('01.ics', 'nuclei_semgentaton.tif')
    fname_fociseg = fname.replace(data_path, fociseg_path).replace('01.ics', 'foci_semgentaton.tif')
    fname_tmp_results = fname.replace(data_path, tmp_results_path)
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
        positive_negative_mask_tmp = file['mask_final'][:]

    # positive_negative_mask_tmp = np.transpose(positive_negative_mask_tmp, [1, 0])
    positive_negative_mask = np.zeros_like(positive_negative_mask_tmp)
    positive_negative_mask[positive_negative_mask_tmp > 0] = 1
    positive_negative_mask[positive_negative_mask_tmp > 100] = 2

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

    median_r = np.zeros(N)
    median_g = np.zeros(N)
    median_b = np.zeros(N)
    median_rg = np.zeros(N)
    percentile99_r = np.zeros(N)
    percentile99_g = np.zeros(N)
    percentile99_b = np.zeros(N)
    percentile99_rg = np.zeros(N)
    correlation = np.zeros(N)
    correlation_spearman = np.zeros(N)

    for cell_num in range(1, N + 1):

        mask3d = segmentation == cell_num
        masked_a = data[:,:,:,0][mask3d].flatten()
        masked_b = data[:,:,:,1][mask3d].flatten()
        masked_c = data[:,:,:,2][mask3d].flatten()
        masked_ab = (data[:,:,:,0] * data[:,:,:,1])[mask3d].flatten()

        perc = lambda x: np.percentile(x, 99)
        median_r[cell_num - 1] = np.median(masked_a)
        median_g[cell_num - 1] = np.median(masked_b)
        median_b[cell_num - 1] = np.median(masked_c)
        median_rg[cell_num - 1] = np.median(masked_ab)

        percentile99_r[cell_num - 1] = perc(masked_a)
        percentile99_g[cell_num - 1] = perc(masked_b)
        percentile99_b[cell_num - 1] = perc(masked_c)
        percentile99_rg[cell_num - 1] = perc(masked_ab)






















