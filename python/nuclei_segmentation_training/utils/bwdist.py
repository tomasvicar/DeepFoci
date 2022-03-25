import skfmm
import numpy as np


def bwdist(mask, diminsion_weights = None, out2zero=True):

    
    m = -1*np.ones_like(mask,dtype=np.float32)
    m[mask > 0] = 1;
    
    
    
    if diminsion_weights:
        distance = skfmm.distance(m,dx=1/np.array(diminsion_weights))
    else:
        distance = skfmm.distance(m)
    
    
    if out2zero:
        distance[distance < 0] = 0

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


    distance = bwdist(mask,diminsion_weights=[1,2])
    


    plt.imshow(distance)
    plt.show()