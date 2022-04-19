import torch
from torch.utils import data
import matplotlib.pyplot as plt
import numpy as np
import os
from tifffile import TiffWriter
from tifffile import imread, imsave
from bayes_opt import BayesianOptimization


from config import Config
from dataset import Dataset
from utils.predict_by_parts import predict_by_parts
from evaluate_detections import WrapperEvaluateDetections




config = Config()

device = device = torch.device("cuda:0")

model = torch.load('../../data_zenodo/tmp_detection_model/detection_model_1_424_0.00000_train_0.02178_valid_0.02446.pt')

model = model.to(device)

valid_filenames = model.valid_filenames
    
loader = Dataset(hdf5_filename=config.hdf5_filename, filenames=valid_filenames, split='test', crop_size=config.crop_size)
validLoader= data.DataLoader(loader, batch_size=1, num_workers=0, shuffle=False,drop_last=False)



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
    
    
final_params = []
best_values = []
for evaluate_index in range(3):   
    optimizer = BayesianOptimization(f=WrapperEvaluateDetections(filenames_masks, filenames_results, evaluate_index),pbounds=pbounds,random_state=42)  
    
    optimizer.maximize(init_points=5,n_iter=25)
    
    
    final_params.append(optimizer.max['params'])
    best_values.append(optimizer.max['target'])
    
    print(final_params)
    print(best_values)


model.postprocessing_params = final_params
model.best_values = best_values


torch.save(model,'detection_model.pt')

        




    

