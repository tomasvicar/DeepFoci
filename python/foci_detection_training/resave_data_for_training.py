from glob import glob
import numpy as np
from tifffile import imread
import h5py
from os.path import split
import os
from scipy.ndimage import zoom
from scipy.ndimage import binary_dilation
from scipy.ndimage import binary_erosion
from scipy.ndimage import binary_closing
from skimage.morphology import area_opening
from skimage.morphology import remove_small_objects
import matplotlib.pyplot as plt
import sys
import json

sys.path.insert(0, "../utils")
from norm_percentile_nocrop import norm_percentile_nocrop
from utils.check_outsiders import check_outsiders
from utils.get_overlaped_points import get_overlaped_points





src_path = '../../data_zenodo/part2'
dst_hdf5_file = '../../data_zenodo/part2_resaved/foci_detection.hdf5'




img_filenames = glob(src_path + '/**/data_53BP1.tif', recursive=True)


resized_img_size = [505, 681, 48] #image is resized to this size

normalization_percentile = 0.0001  #image is normalized into this percentile range





if not os.path.exists(split(dst_hdf5_file)[0]):
    os.makedirs(split(dst_hdf5_file)[0])
    
    
    
with h5py.File(dst_hdf5_file, "w") as hdf5:
    
    for file_num,img_filename in enumerate(img_filenames):
        
        print(str(file_num) + ' / ' + str(len(img_filenames)))
        
        # if file_num<47:
        #     continue
        
        
        img = []
        img.append(imread(img_filename))
        img.append(imread(img_filename.replace('53BP1','gH2AX')))
        img.append(imread(img_filename.replace('53BP1','DAPI')))
        
        
        img = np.stack(img,axis=3)

        
        img_orig_size = img.shape[:3]
        factor =  np.array(resized_img_size) / np.array(img_orig_size)


        tmp_size = resized_img_size.copy()
        tmp_size.append(img.shape[3])
        img_resized = np.zeros(tmp_size,dtype=np.float32)
        for channel in range(img.shape[3]):
            
            
            data_one_channel = img[...,channel]
            
            data_one_channel = zoom(data_one_channel,factor,order=1)
            data_one_channel = norm_percentile_nocrop(data_one_channel,normalization_percentile);
        
            img_resized[...,channel] = data_one_channel
            
        img = img_resized
            
            
        

        with open(img_filename.replace('data_53BP1.tif','labels.json'), 'r') as f:
            lbls = json.load(f)
        
        
        lbls['points_53BP1_gH2AX_overlap'] = get_overlaped_points(lbls['points_53BP1'],lbls['points_gH2AX']);
        
        
        mask_resize_faktor = np.array(img_orig_size) / np.array(resized_img_size)

        mask = []

        for key in lbls.keys():
            mask_tmp = np.zeros(resized_img_size ,dtype=bool)
            points = np.array(lbls[key]) - 1
            points = points[:,[1,0,2]]
    
            points = np.round(points / mask_resize_faktor).astype(np.int32)
            points = check_outsiders(points,resized_img_size)
            
            mask_tmp[tuple(points.T)] = True
            mask.append(mask_tmp)
        

        mask = np.stack(mask, axis=3)
         
        
        
        name = os.path.normpath(img_filename).replace(os.path.normpath(src_path),'').replace('data_53BP1.tif','')
        
        
        
        
        hdf5.create_dataset(name + 'mask', data=mask, chunks=(128,128,48,3), compression="gzip", compression_opts=2)
        hdf5.create_dataset(name + 'data', data=img, chunks=(128,128,48,3), compression="gzip", compression_opts=2)
        
        
        
        
        
        
        
    
    
    
    
    



