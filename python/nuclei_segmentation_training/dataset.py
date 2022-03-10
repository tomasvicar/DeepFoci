import numpy as np
from torch.utils import data
import torch
import matplotlib.pyplot as plt



class Dataloader_segm(data.Dataset):
    def __init__(self, hdf5_filename, split ,crop_size):
        
        
        self.filenames = ...
        
        
    def __len__(self):
        return len(self.file_names)
    
    
    def __getitem__(self, index):
        
        return img
    
    
    
    
if __name__ == '__main__':
    
    loader = Dataloader_segm(hdf5_filename=r'../../data_zenodo\part1_resaved\nucleus_segmentation.hdf5', split='train', crop_size=[96, 96, 48])
    trainloader= data.DataLoader(loader, batch_size=2, num_workers=0, shuffle=True,drop_last=True)
    
    
    for i,(img,mask) in enumerate(trainloader):
        
        img_np=img.detach().cpu().numpy()
        mask_np=mask.detach().cpu().numpy()
        
        plt.imshow(np.max(img_np[0,0,:,:,:],axis=0))
        plt.show()
        plt.imshow(np.max(mask_np[0,0,:,:,:],axis=0))
        plt.show()

        
        
        break