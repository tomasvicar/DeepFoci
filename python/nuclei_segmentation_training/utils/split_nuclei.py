from skimage.segmentation import watershed
from skimage.morphology import h_maxima
from scipy.ndimage import label
from skimage.morphology import remove_small_objects
from skimage.morphology import remove_small_holes
from scipy.ndimage import binary_closing
from scipy.ndimage import binary_erosion
from scipy.ndimage import binary_dilation
from scipy.ndimage import center_of_mass
from utils.bwdist import bwdist
from skimage.feature import peak_local_max
from utils.bwdistgeodesic import bwdistgeodesic

import matplotlib.pyplot as plt
import numpy as np


def split_nuclei(mask,minimal_nuclei_size,h,sphere,min_dist):
    
    # mask_erosion = [8, 8, 5]
    # X,Y,Z = np.meshgrid(np.linspace(-1,1,mask_erosion[0]),np.linspace(-1,1,mask_erosion[1]),np.linspace(-1,1,mask_erosion[2]))
    # sphere = np.sqrt(X**2 + Y**2 + Z**2) < 1
    
    # mask = binary_closing(mask,sphere)
    
    mask = remove_small_objects(mask,minimal_nuclei_size)
    mask = remove_small_holes(mask,minimal_nuclei_size)
    
    D = bwdist(mask, diminsion_weights=(1,1,1))
    
    
    
    
    
    
    maxima2 = h_maxima(D,h)
    
    
    # centroids, num = label(maxima2)
    # centroids = np.array(center_of_mass(maxima2, centroids, range(1,1+num))).astype(np.int32)
    # tmp = np.zeros_like(D)
    # tmp[tuple(centroids.T)] = D[tuple(centroids.T)]
    

    peak_idx = peak_local_max(D, min_distance=min_dist,exclude_border=False)
    maxima1 = np.zeros_like(D, dtype=bool)
    maxima1[tuple(peak_idx.T)] = True
    
    
    # plt.imshow(np.max(binary_dilation(maxima1 & maxima2,sphere),axis=2))
    # plt.show()
    
    labeled_maxima,num = label(maxima1 & maxima2)
    
    
    
    labels = watershed(-D, labeled_maxima, mask=mask,watershed_line=True)
    
    
    seeds = remove_small_objects(labels>0,30000)
    

        
    seeds = binary_erosion(seeds)
    DD = bwdistgeodesic(seeds,mask,diminsion_weights=[1,1,1]);
    
    
    
    labeled_seeds,num = label(seeds)
    
    labelss = watershed(DD, labeled_seeds, mask=mask,watershed_line=True)
    
    # plt.imshow(labels[:,:,35])
    # plt.show()

    return labelss
    
    