import torch
import matplotlib.pyplot as plt
import numpy as np
import os
from tifffile import TiffWriter
from tifffile import imread, imsave
from scipy.ndimage import zoom
import sys

sys.path.insert(0, "../utils")
from utils.predict_by_parts import predict_by_parts
from norm_percentile_nocrop import norm_percentile_nocrop
from utils.mat2gray import mat2gray
from evaluate_detections import detect


folder_name_to_evaluate = 'C:\\Data\\Vicar\\foky_final_cleaning\\DeepFoci\\data_zenodo\\part2\\NHDF\\NHDF_30min PI\\IR 0,5Gy_30min PI\\0003\\'

detection_channel = 2 # red 0, green 1, red and green 2


resized_img_size = [505, 681, 48] #image is resized to this size

normalization_percentile = 0.0001  #image is normalized into this percentile range

crop_size = [96,96]

model = torch.load('detection_model.pt')


device = torch.device("cuda:0")
model = model.to(device)

img_filename = folder_name_to_evaluate + '/data_53BP1.tif'


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


img = img.astype(np.float32)
img = np.transpose(img,(3,0,1,2)).copy()
img = torch.from_numpy(img)

img = img.to(device)


res = predict_by_parts(model,img, crop_size=crop_size)



img = img.detach().cpu().numpy()
res = res.detach().cpu().numpy()



postprocessing_params = model.postprocessing_params[detection_channel]

detected_points = detect(res[detection_channel,:,:],postprocessing_params['T'],postprocessing_params['h'],postprocessing_params['d'])
detected_points = np.array(detected_points)


plt.imshow(mat2gray(np.transpose(np.max(img,axis=3),[1,2,0])))
plt.show()

plt.imshow(np.max(res[0,:,:,:],axis=2))
plt.plot(detected_points[:,1],detected_points[:,0],'r.')
plt.show()





