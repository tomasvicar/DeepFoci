from skimage.feature import peak_local_max
from skimage.morphology import h_maxima
from utils.dice_points import dice_points
from tifffile import imread
import numpy as np
from multiprocessing import Pool
import itertools





def detect(img, T, h, d):
    
    p1 = peak_local_max(img, min_distance=int(np.round(d)), threshold_abs=T)
    p2 = np.stack(np.nonzero(h_maxima(img, h)), axis=1)
    
    p1 = set([tuple(x) for x in p1.tolist()])
    p2 = set([tuple(x) for x in p2.tolist()])
    
    detections = list(p1.intersection(p2))

    return detections

    



def evaluate_detections_all(T, h, d, filenames_masks, filenames_results, evaluate_index):
    
    
    dices = []
    for file_num, (filename_result, filename_mask) in enumerate(zip(filenames_results,filenames_masks)):
    
        res = imread(filename_result,key = slice(None))[:,evaluate_index,:,:]
        gt = imread(filename_mask,key = slice(None))[:,evaluate_index,:,:]
        
        res = np.transpose(res,[1, 2, 0])
        gt = np.transpose(gt,[1, 2, 0])
        
        
        gt_points = detect(gt,0.5,0.1,2);
        res_points = detect(res,T,h,d);
        
        dice = dice_points(gt_points,res_points)
    
        dices.append(dice)
        if file_num == 5:
            if np.nanmean(dices) == 0:
                return 0

        
        
    
    return np.nanmean(dices)


        

class WrapperEvaluateDetections(object):
    def __init__(self, filenames_masks, filenames_results, evaluate_index):
        self.filenames_masks = filenames_masks
        self.filenames_results = filenames_results
        self.evaluate_index =  evaluate_index

    def __call__(self, **params):
        return evaluate_detections_all(params['T'],params['h'],params['d'], self.filenames_masks, self.filenames_results, self.evaluate_index)