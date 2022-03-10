import numpy as np

def norm_percentile_nocrop(data,perc):
    
    norm = [np.percentile(data,perc*100),np.percentile(data,100-perc*100)]
    data = (data - norm[0])/(norm[1] - norm[0]) - 0.5;
    
    
    return data
    