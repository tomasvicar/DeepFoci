from scipy.ndimage import binary_dilation
from utils.bwdistgeodesic import bwdistgeodesic
from skimage.segmentation import watershed
from scipy.ndimage import label

import matplotlib.pyplot as plt
import numpy as np

def balloon(mask,strel):
    
    
    
    mask_conected = binary_dilation(mask,strel);

    D = bwdistgeodesic(mask,mask_conected,diminsion_weights=[1,1,3]);
    
    
    labeled_seeds = label(mask)[0]
    
    labels = watershed(D, labeled_seeds, mask=mask_conected,watershed_line=True)
    
    
    return labels