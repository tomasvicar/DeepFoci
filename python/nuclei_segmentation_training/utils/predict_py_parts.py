from scipy.ndimage import convolve
import numpy as np
import torch

def predict_py_parts(model, data, crop_size):
    
    
    border=16


    img_size = list(data.shape)
    out_layers = model.out_size
    
    
    final = np.zeros([out_layers] + img_size[1:4])
    
    divide = np.zeros([out_layers] + img_size[1:4])
    
    
    W = 2 * np.ones(crop_size);
    ones = np.ones([2 * border + 1, 2 * border + 1])
    ones = ones / np.sum(ones)
    W = convolve(W, ones, mode='constant')           
    W = W - 1
    W[W < 0.01] = 0.01
    W = np.expand_dims(W, 0)
    W = np.expand_dims(W, 3)
    W = np.repeat(W, out_layers, axis=0)
    W = np.repeat(W, img_size[3], axis=3)
    
    
    img_size = img_size[1:3]
    patch_size = crop_size[0]
    
    corners=[]
    cx=0
    while cx<img_size[0]-patch_size: 
        cy=0
        while cy<img_size[1]-patch_size:
            
            corners.append([cx,cy])
            
            cy=cy+patch_size-border
        cx=cx+patch_size-border
       
        
    cx=0
    while cx<img_size[0]-patch_size:
        corners.append([cx,img_size[1]-patch_size])
        cx=cx+patch_size-border
        
    cy=0
    while cy<img_size[1]-patch_size:
        corners.append([img_size[0]-patch_size,cy])
        cy=cy+patch_size-border   
        
    corners.append([img_size[0]-patch_size,img_size[1]-patch_size])
        
    for corner in corners:
        img_patch = data[:,corner[0]:corner[0]+patch_size,corner[1]:corner[1]+patch_size,:]
        
        img_patch = torch.unsqueeze(img_patch, 0)
        res = model(img_patch)
        res = res[0,:,:,:,:]
        
        res = res.detach().cpu().numpy()
        
        
        final[:,corner[0]:corner[0]+patch_size,corner[1]:corner[1]+patch_size,:] = final[:,corner[0]:corner[0]+patch_size,corner[1]:corner[1]+patch_size,:] + res * W
        
        divide[:,corner[0]:corner[0]+patch_size,corner[1]:corner[1]+patch_size,:] = divide[:,corner[0]:corner[0]+patch_size,corner[1]:corner[1]+patch_size,:] + W
        
        
    final = final / divide
        
    return torch.from_numpy(final)
        
    
    