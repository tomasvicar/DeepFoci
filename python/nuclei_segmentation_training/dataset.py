import numpy as np
from torch.utils import data
import torch
import matplotlib.pyplot as plt
import h5py


def torch_randint(max_v):
    return torch.randint(max_v,(1,1)).view(-1).numpy()[0]


class Dataset(data.Dataset):
    def __init__(self, hdf5_filename, split, crop_size):
        
        self.hdf5_filename = hdf5_filename
        self.split = split
        self.crop_size = crop_size
        
        with h5py.File(self.hdf5_filename, 'r') as h5data:
            self.filenames = list(h5data[self.split + '/img'].keys())
            
        self.h5data = None
        
        
    def __len__(self):
        return len(self.filenames)
    
    
    def __getitem__(self, idx):
        
        if self.h5data is None:
            self.h5data = h5py.File(self.hdf5_filename, 'r')
            
        filename = self.filenames[idx]
        
        img = self.h5data[self.split + '/img/' + filename]
        mask = self.h5data[self.split + '/mask/' + filename]
        
        in_size = img.shape
        out_size = self.crop_size
            
        r = [torch_randint(in_size[x]-out_size[x]) for x in range(2)]
        img = img[r[0]:r[0]+out_size[0], r[1]:r[1]+out_size[1], :, :]
        mask = mask[r[0]:r[0]+out_size[0], r[1]:r[1]+out_size[1], :, :]
        
        
        img,mask = augmentation(img,mask)
        
        return img
    
    
    
    
if __name__ == '__main__':
    
    loader = Dataset(hdf5_filename=r'../../data_zenodo\part1_resaved\nucleus_segmentation.hdf5', split='train', crop_size=[96, 96, 48])
    trainloader= data.DataLoader(loader, batch_size=2, num_workers=0, shuffle=True,drop_last=True)
    
    
    for i,(img,mask) in enumerate(trainloader):
        
        img_np=img.detach().cpu().numpy()
        mask_np=mask.detach().cpu().numpy()
        
        plt.imshow(np.max(img_np[0,0,:,:,:],axis=0))
        plt.show()
        plt.imshow(np.max(mask_np[0,0,:,:,:],axis=0))
        plt.show()

        
        
        break