import numpy as np
from torch.utils import data
import torch
import matplotlib.pyplot as plt
import h5py
from utils.utils import mat2gray_nocrop


def torch_randint(max_v):
    return torch.randint(max_v,(1,1)).view(-1).numpy()[0]

def torch_rand(size=1):
    return torch.rand(size).numpy()


def augmentation(img,mask):
    
    r = [torch_randint(2),torch_randint(2),torch_randint(4)]
    if r[0]:
        img = np.fliplr(img)
        mask = np.fliplr(mask)
    if r[1]:
        img = np.flipud(img)
        mask = np.flipud(mask) 
    img = np.rot90(img,k=r[2]) 
    mask = np.rot90(mask,k=r[2])    
    
    
    min_v = (torch_rand() * 0.96) - 0.48;
    max_v = 1 + (torch_rand() * 0.96)  - 0.48;
    
    for k in range(img.shape[3]):
        
        img[:,:,:,k] = mat2gray_nocrop(img[:,:,:,k],[min_v,max_v]) - 0.5;
    
    
    
    
    return img, mask



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
        
        
        if not self.split == 'test':
            in_size = img.shape
            out_size = self.crop_size
    
            r = [torch_randint(in_size[x]-out_size[x]) for x in range(2)]
            img = img[r[0]:r[0]+out_size[0], r[1]:r[1]+out_size[1], :, :]
            mask = mask[r[0]:r[0]+out_size[0], r[1]:r[1]+out_size[1], :]
            
        else:
            img = img[...]
            mask = mask[...]
            
        
        if self.split == 'train':
            img , mask = augmentation(img, mask)
        
        
        img = img.astype(np.float32)
        img = np.transpose(img,(3,0,1,2)).copy()
        img = torch.from_numpy(img)
        
        mask = mask.astype(np.float32)
        mask = np.expand_dims(mask, axis=0).copy()
        mask = torch.from_numpy(mask)
        
        
        return img, mask, filename
    
    
    
    
if __name__ == '__main__':
    
    loader = Dataset(hdf5_filename=r'../../data_zenodo\part1_resaved\nucleus_segmentation.hdf5', split='train', crop_size=[96, 96, 48])
    trainloader= data.DataLoader(loader, batch_size=2, num_workers=0, shuffle=True,drop_last=True)
    
    
    for i,(img,mask) in enumerate(trainloader):
        
        img_np=img.detach().cpu().numpy()
        mask_np=mask.detach().cpu().numpy()
        
        plt.imshow(np.max(img_np[0,0,:,:,:],axis=2))
        plt.show()
        plt.imshow(np.max(mask_np[0,0,:,:,:],axis=2))
        plt.show()

        
        
        break