import torch
from torch.utils import data
import matplotlib.pyplot as plt
import numpy as np
import os
from tifffile import TiffWriter
from tifffile import imread, imsave
from bayes_opt import BayesianOptimization
from skimage.feature import peak_local_max
from skimage.morphology import h_maxima

from config import Config
from dataset import Dataset
from utils.predict_by_parts import predict_by_parts
from utils.dice_points import dice_points



config = Config()

device = device = torch.device("cuda:0")

model = torch.load('../../data_zenodo/tmp_detection_model/detection_model_1_424_0.00000_train_0.02178_valid_0.02446.pt')

model = model.to(device)

valid_filenames = model.valid_filenames
    
loader = Dataset(hdf5_filename=config.hdf5_filename, filenames=valid_filenames, split='test', crop_size=config.crop_size)
validLoader= data.DataLoader(loader, batch_size=1, num_workers=0, shuffle=False,drop_last=False)


valid_filenames

with torch.no_grad(): 
    model.eval()
    for it, (batch,lbls,filenames) in enumerate(validLoader):
        
        break##########################################################################
        
        print(str(it) + '/' + str(len(validLoader)))
        
        batch=batch.to(device)
        lbls=lbls.to(device)
        
        res = predict_by_parts(model,batch[0,:,:,:], crop_size=config.crop_size)
        
        # res = torch.sigmoid(res)
        
        batch = batch.detach().cpu().numpy()
        res = res.detach().cpu().numpy()
        lbls = lbls.detach().cpu().numpy()
        
        
        plt.imshow(np.max(batch[0,0,:,:,:],axis=2))
        plt.show()
        plt.imshow(np.max(lbls[0,0,:,:,:],axis=2))
        plt.show()
        plt.imshow(np.max(res[0,:,:,:],axis=2))
        plt.show()
        
        filename_saveimg = config.tmp_save_dir + os.sep + 'result_' + filenames[0]  + 'result.tiff'
        filename_mask = config.tmp_save_dir + os.sep + 'result_' + filenames[0]  + 'mask.tiff'
        
        folder_name = os.path.split(filename_saveimg)[0]
        if not os.path.exists(folder_name):
            os.makedirs(folder_name)
            
        
        
        # res = (res > 0.5).astype(np.float32)
        
        res = np.transpose(res,(3,0,1,2))
        
        with TiffWriter(filename_saveimg,bigtiff=True) as tif:

            for k in range(res.shape[0]):
            
                tif.write(res[k,:,:,:,] ,compress = 2)


        lbls = lbls[0,...]
        lbls = np.transpose(lbls,(3,0,1,2))
        
        with TiffWriter(filename_mask,bigtiff=True) as tif:

            for k in range(lbls.shape[0]):
            
                tif.write(lbls[k,:,:,:,] ,compress = 2)


        # res_loaded = imread(filename_saveimg,key = slice(None))

        # print(np.sum(np.abs(res - res_loaded )))
        




def detect(img, T, h, d):
    
    p1 = peak_local_max(img, min_distance=int(np.round(d)), threshold_abs=T)
    p2 = np.stack(np.nonzero(h_maxima(img, h)), axis=1)
    
    p1 = set([tuple(x) for x in p1.tolist()])
    p2 = set([tuple(x) for x in p2.tolist()])
    
    detections = list(p1.intersection(p2))

    return detections

    




def evaluate_detections(T, h, d, filenames_masks, filenames_results, evaluate_index):
    
    dices = []
    for file_num, (filenames_mask,filenames_result) in enumerate(zip(filenames_masks, filenames_results)):
        
        res = imread(filenames_result,key = slice(None))[:,evaluate_index,:,:]
        gt = imread(filenames_mask,key = slice(None))[:,evaluate_index,:,:]
        
        res = np.transpose(res,[1, 2, 0])
        gt = np.transpose(gt,[1, 2, 0])
        
        
        gt_points = detect(gt,0.5,0.1,2);
        res_points = detect(res,T,h,d);
        
        dice = dice_points(gt_points,res_points)
        
        print(dice)
        
        dices.append(dice)
        
        if file_num == 5:
            if np.nanmean(dices) == 0:
                return np.nanmean(dices)

    return np.nanmean(dices)


        

class Wrapper(object):
    def __init__(self, filenames_masks, filenames_results, evaluate_index):
        self.filenames_masks = filenames_masks
        self.filenames_results = filenames_results
        self.evaluate_index =  evaluate_index

    def __call__(self, **params):
        return evaluate_detections(params['T'],params['h'],params['d'], self.filenames_masks, self.filenames_results, self.evaluate_index)
        
      
pbounds = dict()
pbounds['T'] = [0.6, 8.5]
pbounds['h'] = [0.1,9.9]
pbounds['d'] = [2,25]
      

filenames_masks = []
filenames_results = []
for filename in valid_filenames:
    
    filename_saveimg = config.tmp_save_dir + os.sep + 'result_' + filename  + 'result.tiff'
    filename_mask = config.tmp_save_dir + os.sep + 'result_' + filename  + 'mask.tiff'
    
    filenames_masks.append(filename_mask)
    filenames_results.append(filename_saveimg)
        
        
for evaluate_index in range(1):   
    optimizer = BayesianOptimization(f=Wrapper(filenames_masks, filenames_results, evaluate_index),pbounds=pbounds,random_state=42)  
    
    optimizer.maximize(init_points=5,n_iter=5)

        


    

