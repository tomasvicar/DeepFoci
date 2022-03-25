from glob import glob
import numpy as np
import torch
from os.path import split
from scipy.ndimage import zoom
from tifffile import imread
from scipy.ndimage import binary_dilation
from scipy.ndimage import binary_erosion
from scipy.ndimage import binary_closing
from skimage.morphology import area_opening
from skimage.morphology import remove_small_objects
import sys
import matplotlib.pyplot as plt

sys.path.insert(0, "../utils")
from norm_percentile_nocrop import norm_percentile_nocrop
from utils.predict_by_parts import predict_by_parts
from utils.split_nuclei import split_nuclei
from utils.balloon import balloon
from utils.seg_3d import seg_3d






src_path = '../../data_zenodo/part1/nucleus_segmentation'
dst_hdf5_file = '../../data_zenodo/part1_resaved/nucleus_segmentation.hdf5'



img_filenames = glob(src_path + '/test/data_*.tif', recursive=True)
masks_filenames = [ split(x)[0] + '/' + split(x)[1].replace('data_','mask_') for x in img_filenames]




resized_img_size = [505, 681, 48] #image is resized to this size

normalization_percentile = 0.0001  #image is normalized into this percentile range

mask_erosion=[14, 14, 5] # amount of mask erosion (elipsoid)
minimal_nuclei_size = 10000
h = 3
min_dist = 60

crop_size = [96, 96]

device = torch.device("cuda:0")

X,Y,Z = np.meshgrid(np.linspace(-1,1,mask_erosion[0]),np.linspace(-1,1,mask_erosion[1]),np.linspace(-1,1,mask_erosion[2]))
sphere = np.sqrt(X**2 + Y**2 + Z**2) < 1




model = torch.load('segmentation_model.pt').to(device)


segs = []


for file_num,(img_filename,mask_filename) in enumerate(zip(img_filenames,masks_filenames)):
    
    if file_num < 1 :
        continue
    
    img = imread(img_filename)  
    img = np.moveaxis(img,0,2)

    mask = imread(mask_filename)
    
    original_img_size = mask.shape
    
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
    
    img = img.astype(np.float32)
    img = np.transpose(img,(3,0,1,2)).copy()
    img = torch.from_numpy(img)
    img = img.to(device)
    
    
    mask_predicted = predict_by_parts(model,img, crop_size=crop_size)
    mask_predicted = mask_predicted.detach().cpu().numpy()[0,:,:,:]
    
    
        
    mask_split = split_nuclei(mask_predicted>0.5,minimal_nuclei_size,h,sphere,min_dist);
    
    
    mask_label_dilated = balloon(mask_split,sphere);
    

    factor =  np.array(original_img_size) / np.array(mask_label_dilated.shape)
    mask_final = zoom(mask_label_dilated,factor,order=0)


    

        
    
    mask_erroded = np.zeros(mask.shape,dtype=bool);
    for nuclei_value in range(1,5):
        
        
        mask_current = mask == nuclei_value;

        mask_current = binary_erosion(binary_closing(mask_current,sphere),sphere)

        mask_erroded[mask_current] = True


    mask_erroded = remove_small_objects(mask_erroded,minimal_nuclei_size)   


    mask = balloon(mask_erroded, sphere)
    
    factor =  np.array(original_img_size) / np.array(mask.shape)
    mask = zoom(mask,factor,order=0)
    
    
    plt.imshow(np.concatenate((np.max(mask_final,axis=2),np.max(mask,axis=2)),axis=1))
    plt.show()
    

    plt.imshow(np.max(mask_final,axis=2))
    plt.show()
    
    
    
    seg = seg_3d(mask,mask_final)
    
    print(seg)
    
    segs.append(seg)
    
    
    
    
    
    
print(np.mean(segs))
    
    


