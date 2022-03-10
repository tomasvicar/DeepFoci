from tifffile import imread
import numpy as np
import h5py


img_filename = r"D:\foky_final_cleaning\DeepFoci\data_zenodo\part1\nucleus_segmentation\train\data_041.tif"

mask_filename = r"D:\foky_final_cleaning\DeepFoci\data_zenodo\part1\nucleus_segmentation\train\mask_041.tif"


img = imread(img_filename)
mask = imread(mask_filename)>0

img = np.moveaxis(img,0,2)


with h5py.File("mytestfile.hdf5", "w") as f:
    
    
    dst_mask = f.create_dataset('mask/041', data=mask, chunks=(128,128,48), compression="gzip", compression_opts=2)
    
    dst_img = f.create_dataset('img/041', data=img,chunks=(128,128,48,3), compression="gzip", compression_opts=2)





