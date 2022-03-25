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

sys.path.insert(0, "../utils")
from norm_percentile_nocrop import norm_percentile_nocrop






src_path = '../../data_zenodo/part1/nucleus_segmentation'
dst_hdf5_file = '../../data_zenodo/part1_resaved/nucleus_segmentation.hdf5'



img_filenames = glob(src_path + '/**/data_*.tif', recursive=True)
masks_filenames = [ split(x)[0] + '/' + split(x)[1].replace('data_','mask_') for x in img_filenames]
img_numbers = [ split(x)[1].replace('data_','').replace('.tif','') for x in img_filenames]


resized_img_size = [505, 681, 48] #image is resized to this size

normalization_percentile = 0.0001  #image is normalized into this percentile range

mask_erosion=[14, 14, 5] # amount of mask erosion (elipsoid)
minimal_nuclei_size = 6000


X,Y,Z = np.meshgrid(np.linspace(-1,1,mask_erosion[0]),np.linspace(-1,1,mask_erosion[1]),np.linspace(-1,1,mask_erosion[2]))
sphere = np.sqrt(X**2 + Y**2 + Z**2) < 1



if not os.path.exists(split(dst_hdf5_file)[0]):
    os.makedirs(split(dst_hdf5_file)[0])
    
    
with h5py.File(dst_hdf5_file, "w") as f:
    
    for file_num,(img_filename,mask_filename,img_number) in enumerate(zip(img_filenames,masks_filenames,img_numbers)):
        
        print(str(file_num) + ' / ' + str(len(img_filenames)))
        
        if  file_num == 77:
            continue
        
        
        img = imread(img_filename)  
        img = np.moveaxis(img,0,2)

        mask = imread(mask_filename)
        
        
        factor =  np.array(resized_img_size) / np.array(mask.shape)
        mask = zoom(mask,factor,order=0)
        
        
        tmp_size = resized_img_size.copy()
        tmp_size.append(img.shape[3])
        img_resized = np.zeros(tmp_size,dtype=np.float32)
        for channel in range(img.shape[3]):
            
            
            data_one_channel = img[...,channel]
            
            data_one_channel = zoom(data_one_channel,factor,order=1)
            data_one_channel = norm_percentile_nocrop(data_one_channel,normalization_percentile);
        
            img_resized[...,channel] = data_one_channel
            
        img = img_resized
            
            
        
        mask_erroded = np.zeros(mask.shape,dtype=bool);
        for nuclei_value in range(1,5):
            
            print(nuclei_value)
            
            mask_current = mask == nuclei_value;
    
            mask_current = binary_erosion(binary_closing(mask_current,sphere),sphere)
    
            mask_erroded[mask_current] = True


        mask_erroded = remove_small_objects(mask_erroded,minimal_nuclei_size)     
        
        
        
        img_filename = os.path.normpath(img_filename)
        train_valid_test_str = img_filename.split(os.sep)[-2]
        
        
        f.create_dataset(train_valid_test_str + '/mask/' + img_number, data=mask_erroded, chunks=(128,128,48), compression="gzip", compression_opts=2)
        
        f.create_dataset(train_valid_test_str + '/img/' + img_number, data=img_resized,chunks=(128,128,48,3), compression="gzip", compression_opts=2)
        
        
        
        
        
        
        
    
    
    
    
    



