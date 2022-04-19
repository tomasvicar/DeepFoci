import numpy as np

def mat2gray(img,min_max=None):
    
    if not min_max:
        
        min_max = [np.min(img),np.max(img)]
        
    min_ = min_max[0]
    max_ = min_max[1]
        
    img = (img-min_)/(max_-min_)
    
    img[img<0] = 0
    img[img>1] = 1
    
    return img