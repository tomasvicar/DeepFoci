from scipy.ndimage import label
import numpy as np

def seg_3d(data,gt):
    
    data = data > 0;
    gt = gt > 0;
    
    counter = -1
    
    ll, N_ll = label(data)
    l, N_l = label(gt)
    
    
    
    seg_all = np.zeros(N_l);
    for k in range(1, N_l + 1):
        counter = counter + 1
        b = k == l
        bb = ll[b]
        qq = np.unique(bb[bb>0])
        seg_all[counter] = 0;
        for q in qq:
            cell = ll == q
            if (np.sum(b) * 0.5) < np.sum(b & cell):
                ll[cell] = 0
                seg_all[counter] = np.sum(b & cell) / np.sum(b | cell)
                

    return np.mean(seg_all)