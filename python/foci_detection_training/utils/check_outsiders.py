import numpy as np



def check_outsiders(points, img_size):
    
    
    
    for dim, dim_size in enumerate(img_size):
        
        
        remove = (points[:,dim] < 0) | (points[:,dim] >= dim_size)

        points = points[remove==0,:]
        

    return points



    