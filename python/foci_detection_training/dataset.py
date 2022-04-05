import numpy as np
from torch.utils import data
import torch
import matplotlib.pyplot as plt
import h5py
from utils.utils import mat2gray_nocrop
from config import Config
import os
import random
from scipy.ndimage import gaussian_filter


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
    def __init__(self, hdf5_filename, filenames, split, crop_size):
        
        self.hdf5_filename = hdf5_filename
        self.split = split
        self.crop_size = crop_size
        self.filenames = filenames
            
        self.h5data = None
        
        
    def __len__(self):
        return len(self.filenames)
    
    
    def __getitem__(self, idx):
        
        if self.h5data is None:
            self.h5data = h5py.File(self.hdf5_filename, 'r')
            
        filename = self.filenames[idx]
        
        img = self.h5data[filename + 'data']
        mask = self.h5data[filename + 'mask']
        
        
        if not self.split == 'test':
            in_size = img.shape
            out_size = self.crop_size
    
            r = [torch_randint(in_size[x]-out_size[x]) for x in range(2)]
            img = img[r[0]:r[0]+out_size[0], r[1]:r[1]+out_size[1], :, :]
            mask = mask[r[0]:r[0]+out_size[0], r[1]:r[1]+out_size[1], :, :]
            
        else:
            img = img[...]
            mask = mask[...]
            
        
        if self.split == 'train':
            img , mask = augmentation(img, mask)
        
        
        img = img.astype(np.float32)
        img = np.transpose(img,(3,0,1,2)).copy()
        img = torch.from_numpy(img)
        
        mask = mask.astype(np.float32)
        for k in range(mask.shape[3]):
            mask[:,:,:,k] = gaussian_filter(mask[:,:,:,k],sigma=[2,2,1])*59.5238*10       
        mask = np.transpose(mask,(3,0,1,2)).copy()
        mask = torch.from_numpy(mask)
        
        
        return img, mask, filename
    
    
    
    
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
                break
        if used == 0:
            tmp_filenames.append(filename)
        
    valid_ind = random.sample(range(len(tmp_filenames)), int(len(tmp_filenames)/10))
    valid_bool = np.zeros(len(tmp_filenames),dtype=bool)
    valid_bool[valid_ind] = True
    valid_filenames = [filename for x,filename in zip(valid_bool,tmp_filenames) if x]
    train_filenames = [filename for x,filename in zip(valid_bool,tmp_filenames) if not x]
    
    
    loader = Dataset(hdf5_filename=config.hdf5_filename, filenames=train_filenames, split='train', crop_size=config.crop_size)
    trainloader= data.DataLoader(loader, batch_size=config.train_batch_size, num_workers=config.train_num_workers, shuffle=True,drop_last=True)
    
    
    for i,(img,mask,filenames) in enumerate(trainloader):
        
        img_np=img.detach().cpu().numpy()
        mask_np=mask.detach().cpu().numpy()
        
        plt.imshow(np.max(img_np[0,0,:,:,:],axis=2))
        plt.show()
        plt.imshow(np.max(img_np[0,1,:,:,:],axis=2))
        plt.show()
        plt.imshow(np.max(mask_np[0,0,:,:,:],axis=2))
        plt.show()
        plt.imshow(np.max(mask_np[0,1,:,:,:],axis=2))
        plt.show()
        plt.imshow(np.max(mask_np[0,2,:,:,:],axis=2))
        plt.show()

        
        
        break