from torch.utils import data
import torch
import torchvision
import matplotlib.pyplot as plt
import numpy as np
import os
import torch.nn as nn
import torch.nn.functional as F
import torch.optim as optim
import matplotlib.pyplot as plt
from tifffile import TiffWriter
from tifffile import imread, imsave
import random


from dataset import Dataset
from config import Config
from utils.utils import dice_loss
from unet3d import Unet3d
from utils.log import Log
from utils.predict_by_parts import predict_by_parts
import h5py


if __name__ == '__main__':

    device = torch.device("cuda:0")
    config = Config();
    
    try:
        os.mkdir(Config.tmp_save_dir)
    except:
        pass
    
    with h5py.File(config.hdf5_filename, 'r') as h5data:
        filenames = list(h5data.keys())
        
    filenames = [x.replace('\\data','\\') for x in filenames if x.endswith('data')]
    folder_names = np.unique(['\\'.join(x.split('\\')[:-2]) for x in filenames]).tolist()
    
    random.seed(42)
    test_folders = random.sample(folder_names,3)
    
    test_filenames = []
    tmp_filenames = []
    for filename in filenames:
        used = 0
        for test_folder in test_folders:
            if test_folder in filename:
                test_filenames.append(filename)
                used = 1
        if used == 0:
            tmp_filenames.append(filename)
        
    valid_ind = random.sample(range(len(tmp_filenames)), int(len(tmp_filenames)/10))
    valid_bool = np.zeros(len(tmp_filenames),dtype=bool)
    valid_bool[valid_ind] = True
    valid_filenames = [filename for x,filename in zip(valid_bool,tmp_filenames) if x]
    train_filenames = [filename for x,filename in zip(valid_bool,tmp_filenames) if not x]
        
    
    loader = Dataset(hdf5_filename=config.hdf5_filename, filenames=train_filenames, split='train', crop_size=config.crop_size)
    trainloader= data.DataLoader(loader, batch_size=config.train_batch_size, num_workers=config.train_num_workers, shuffle=True,drop_last=True)

    loader = Dataset(hdf5_filename=config.hdf5_filename, filenames=valid_filenames, split='valid', crop_size=config.crop_size)
    validLoader= data.DataLoader(loader, batch_size=config.test_batch_size, num_workers=config.test_num_workers, shuffle=False,drop_last=False)
    

    model = Unet3d(filters=config.filters, in_size=config.input_size, out_size=config.output_size)
    model.test_filenames = test_filenames
    model.valid_filenames = valid_filenames
    model.train_filenames = train_filenames

    model = model.to(device)


    optimizer = optim.Adam(model.parameters(),lr=Config. init_lr ,betas= (0.9, 0.999),eps=1e-8,weight_decay=1e-8)
    scheduler = optim.lr_scheduler.MultiStepLR(optimizer, config.lr_changes_list, gamma=config.gamma, last_epoch=-1)

    model.log = Log(names=['loss'])
    
    for epoch_num in range(Config.max_epochs):
        
        model.train()
        N=len(trainloader)
        for it, (batch,lbls,_) in enumerate(trainloader):
            
            if it%10==0:
                print('train ' + str(it) + '/' + str(N))
            
           
            batch=batch.to(device)
            lbls=lbls.to(device)
            
            res=model(batch)
            
            # res = torch.sigmoid(res)
            # loss = dice_loss(res,lbls)
            
            loss = torch.mean((res - lbls)**2)
            
            optimizer.zero_grad()
            loss.backward()
            optimizer.step()
            
            loss=loss.detach().cpu().numpy()
            res=res.detach().cpu().numpy()
            lbls=lbls.detach().cpu().numpy()
            
            
            model.log.append_train([loss])
            
            
        with torch.no_grad(): 
            model.eval()
            N=len(validLoader)
            for it, (batch,lbls,_) in enumerate(validLoader):
                
                if it%10==0:
                    print('valid ' + str(it) + '/' + str(N))
                
                batch=batch.to(device)
                lbls=lbls.to(device)
                
                res=model(batch)
                
                # res = torch.sigmoid(res)
                # loss = dice_loss(res,lbls)
                
                loss = torch.mean((res - lbls)**2)
                
                loss=loss.detach().cpu().numpy()
                res=res.detach().cpu().numpy()
                lbls=lbls.detach().cpu().numpy()
                
                
                model.log.append_valid([loss])
            
            
        model.log.save_and_reset()
            
        
        xstr = lambda x:"{:.5f}".format(x)
        lr=optimizer.param_groups[0]['lr']
        info= '_' + str(epoch_num) + '_' + xstr(lr)  + '_train_'  + xstr(model.log.train_log['loss'][-1]) + '_valid_' + xstr(model.log.valid_log['loss'][-1]) 
        
        print(info)
        
        model_name=config.tmp_save_dir + os.sep + config.model_name + info  + '.pt'
        
        model.log.save_log_model_name(model_name)
            
        torch.save(model,model_name)
            
        
        model.log.plot(model_name.replace('.pt','loss.png'))
        
            
        scheduler.step()
            
    # model = torch.load('../../data_zenodo/tmp_segmentation_model\\segmentation_model_1_164_0.00000_train_0.43957_valid_0.99332.pt')
    
    # model = model.to(device)
        
    # loader = Dataset(hdf5_filename=config.hdf5_filename,split='test',crop_size=config.crop_size)
    # testLoader= data.DataLoader(loader, batch_size=1, num_workers=0, shuffle=False,drop_last=False)
    # with torch.no_grad(): 
    #     model.eval()
    #     for it, (batch,lbls,filenames) in enumerate(testLoader):
            
    #         batch=batch.to(device)
    #         lbls=lbls.to(device)
            
    #         res = predict_by_parts(model,batch[0,:,:,:], crop_size=config.crop_size)
            
    #         # res = torch.sigmoid(res)
            
    #         batch = batch.detach().cpu().numpy()
    #         res = res.detach().cpu().numpy()
    #         lbls = lbls.detach().cpu().numpy()
            
            
    #         plt.imshow(np.max(batch[0,0,:,:,:],axis=2))
    #         plt.show()
    #         plt.imshow(np.max(lbls[0,0,:,:,:],axis=2))
    #         plt.show()
    #         plt.imshow(np.max(res[0,:,:,:],axis=2))
    #         plt.show()
    #         print()
            
    #         filename_saveimg = config.tmp_save_dir + os.sep + 'result_' + filenames[0]  + '.tiff'
            
    #         # res = (res > 0.5).astype(np.float32)
            
    #         res = np.transpose(res,(3,0,1,2))
            
    #         with TiffWriter(filename_saveimg,bigtiff=True) as tif:
    
    #             for k in range(res.shape[0]):
                
    #                 tif.write(res[k,:,:,:,] ,compress = 2)




    #         # res_loaded = imread(filename_saveimg,key = range(48))


    #         # print(np.sum(np.abs(res[:,0,:,:,] - res_loaded )))
        

            
            