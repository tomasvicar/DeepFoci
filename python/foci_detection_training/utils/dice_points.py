from scipy.optimize import linear_sum_assignment
from scipy.spatial.distance import cdist
import numpy as np


def dice_points(poits_gt, poits_res):
    
    distance_limit = 10
    
    
    poits_gt = np.array(poits_gt)
    poits_res = np.array(poits_res)
    
    if poits_res.size == 0:
        return 0
    
    if poits_gt.size == 0:
        return np.nan
    
    
    D = cdist(poits_gt, poits_res)
    
    D[D > distance_limit] = 9999999
    
    row_ind, col_ind = linear_sum_assignment(D)
    
    remove = D[row_ind,col_ind] == 9999999
    
    row_ind = row_ind[remove == 0]
    col_ind = col_ind[remove == 0]
    
    tp = len(row_ind)
    fp = poits_res.shape[0] - tp
    fn = poits_gt.shape[0] - tp
    
    

    dice = (2 * tp) / (2 * tp + fp + fn)
    
    return dice