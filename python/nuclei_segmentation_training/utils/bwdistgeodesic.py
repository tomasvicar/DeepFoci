import skfmm
import numpy as np


def bwdistgeodesic(seeds, mask, bakround_value=np.Inf, seed2zero=True, diminsion_weights = None):
    """

    Parameters
    ----------
    seeds : bool ndarray 
        True at seed positions.
    mask : bool ndarray
        True at foregorund.
    bakround_value : number, optional
        value that is put on backgroud (mask false positions). The default is -1.
    seed2zero : bool, optional
        if True, values inside seeds are put to zero; negative values of distance otherwise. The default is True.
    diminsion_weights : list of ints of dimensind size, optional
        weghts for individual dimensions. The default is None - ones.


    Returns
    -------
    distance : array
        geodesic distance tranform - image of distances from seeds when walking on mask only.

    """
    
    
    
    m = np.ones_like(seeds,dtype=np.float32)
    m[seeds > 0] = -1;
    
    
    m = np.ma.masked_array(m, mask==0)
    
    if diminsion_weights:
        distance = skfmm.distance(m,dx=1/np.array(diminsion_weights))
    else:
        distance = skfmm.distance(m)
    
    distance = distance.data
    
    if seed2zero:
        distance[distance < 0] = 0
    
    distance[mask == 0] = bakround_value

    return distance    
    
    
    
if __name__ == "__main__":
    
    import matplotlib.pyplot as plt
    import numpy as np


    l = 100
    x, y = np.indices((l, l))
    center1 = (50, 20)
    center2 = (28, 24)
    center3 = (30, 50)
    center4 = (60,48)
    radius1, radius2, radius3, radius4 = 15, 12, 19, 12
    circle1 = (x - center1[0])**2 + (y - center1[1])**2 < radius1**2
    circle2 = (x - center2[0])**2 + (y - center2[1])**2 < radius2**2
    circle3 = (x - center3[0])**2 + (y - center3[1])**2 < radius3**2
    circle4 = (x - center4[0])**2 + (y - center4[1])**2 < radius4**2
    # 3 circles
    img = circle1 + circle2 + circle3 + circle4
    mask = img.astype(bool)
    img = img.astype(float)


    m = np.zeros_like(img)

    m[center1] = 1

    distance = bwdistgeodesic(m,mask)
    


    plt.imshow(distance)
    plt.show()
