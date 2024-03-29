from scipy.optimize import linear_sum_assignment
from scipy.spatial.distance import cdist
import numpy as np


def get_overlaped_points(poits1, poits2):
    
    z_scale_factor = 2
    distance_limit = 20
    
    poits1 = np.array(poits1)
    poits2 = np.array(poits2)
    
    poits1[:,2] = poits1[:,2] * z_scale_factor
    poits2[:,2] = poits2[:,2] * z_scale_factor
    
    
    D = cdist(poits1,poits2)
    
    D[D > distance_limit] = 9999999
    
    row_ind, col_ind = linear_sum_assignment(D)
    
    remove = D[row_ind,col_ind] == 9999999
    
    row_ind = row_ind[remove == 0]
    col_ind = col_ind[remove == 0]
    
    
    poits_out = (poits1[row_ind,:] + poits2[col_ind,:]) / 2
    
    
    
    poits_out[:,2] = poits_out[:,2] / z_scale_factor
    
    return poits_out.tolist()


if __name__ == "__main__":
    poits1 = [[680, 241, 22], [693, 252, 22], [749, 244, 21], [725, 265, 23], [787, 304, 22], [771, 243, 23], [772, 327, 23], [844, 239, 25], [749, 185, 25], [892, 314, 26], [901, 340, 26], [907, 276, 25], [810, 328, 26], [858, 255, 26], [868, 294, 26], [944, 305, 26], [842, 309, 27], [780, 325, 25], [904, 284, 24], [905, 333, 26], [700, 237, 22], [708, 884, 18], [708, 922, 19], [635, 865, 23], [680, 942, 22], [680, 966, 24], [665, 953, 25], [715, 879, 24], [738, 953, 24], [742, 872, 25], [712, 960, 26], [746, 927, 27], [753, 825, 27], [623, 898, 27], [716, 932, 28], [732, 820, 28], [743, 853, 27], [623, 857, 29], [738, 838, 26], [650, 891, 26], [734, 878, 26], [726, 834, 27], [713, 954, 22], [628, 875, 27], [725, 899, 19], [715, 783, 27], [393, 389, 23], [456, 379, 23], [502, 327, 25], [347, 396, 27], [487, 266, 27], [381, 255, 27], [417, 274, 28], [441, 393, 28], [449, 266, 27], [461, 298, 27], [472, 352, 27], [484, 286, 27], [509, 344, 28], [515, 334, 28], [482, 258, 26], [444, 264, 27], [441, 388, 27], [489, 283, 27], [815, 711, 23], [873, 789, 23], [758, 741, 25], [781, 757, 25], [811, 798, 25], [915, 758, 25], [831, 708, 26], [789, 735, 29], [882, 753, 29], [357, 485, 25], [362, 519, 26], [376, 527, 26], [509, 583, 25], [495, 599, 26]]
    poits2 = [[693, 252, 21], [749, 245, 21], [787, 304, 22], [771, 245, 23], [771, 326, 24], [907, 276, 25], [810, 228, 26], [810, 328, 26], [844, 239, 27], [891, 314, 26], [944, 305, 26], [843, 308, 28], [858, 255, 27], [865, 357, 28], [867, 294, 27], [779, 324, 25], [899, 282, 26], [707, 883, 17], [683, 903, 19], [653, 897, 24], [635, 864, 23], [681, 970, 24], [642, 932, 25], [716, 879, 25], [737, 951, 25], [740, 871, 25], [738, 839, 25], [712, 958, 27], [744, 852, 27], [745, 926, 27], [716, 929, 28], [624, 855, 29], [699, 847, 30], [660, 950, 27], [726, 836, 29], [735, 877, 26], [646, 880, 25], [686, 909, 26], [725, 897, 25], [754, 837, 26], [745, 816, 25], [719, 805, 29], [693, 803, 24], [669, 815, 27], [682, 830, 25], [697, 839, 25], [714, 950, 17], [653, 877, 23], [732, 943, 21], [700, 922, 18], [672, 924, 23], [735, 936, 21], [707, 866, 26], [632, 849, 24], [668, 830, 23], [669, 889, 19], [683, 920, 28], [340, 387, 23], [395, 390, 23], [456, 379, 23], [366, 254, 27], [395, 297, 26], [413, 386, 26], [503, 328, 26], [407, 298, 26], [348, 396, 27], [382, 256, 27], [450, 267, 27], [454, 283, 28], [488, 267, 27], [487, 286, 28], [418, 275, 28], [443, 395, 28], [462, 300, 28], [474, 353, 28], [489, 373, 29], [509, 345, 28], [513, 334, 28], [484, 261, 27], [445, 266, 28], [442, 388, 28], [451, 280, 27], [490, 281, 27], [525, 349, 26], [480, 284, 28], [795, 676, 23], [827, 733, 21], [785, 719, 22], [794, 728, 22], [834, 788, 22], [853, 776, 22], [869, 750, 22], [906, 790, 22], [858, 807, 23], [868, 824, 23], [890, 842, 23], [900, 734, 23], [785, 662, 26], [814, 710, 24], [830, 797, 24], [873, 788, 24], [878, 773, 24], [878, 811, 24], [803, 784, 24], [911, 822, 24], [939, 766, 25], [939, 782, 26], [757, 739, 25], [761, 706, 26], [780, 755, 25], [785, 694, 26], [807, 763, 26], [811, 796, 25], [829, 773, 25], [886, 718, 26], [892, 781, 25], [915, 758, 26], [933, 846, 26], [966, 858, 25], [807, 652, 26], [807, 745, 27], [853, 660, 26], [861, 698, 27], [883, 830, 27], [915, 737, 27], [933, 807, 26], [770, 683, 28], [788, 649, 28], [831, 708, 27], [836, 759, 28], [891, 740, 28], [897, 806, 28], [899, 841, 27], [962, 808, 28], [960, 838, 27], [818, 751, 28], [829, 742, 30], [906, 775, 28], [789, 734, 29], [882, 752, 29], [901, 856, 26], [924, 851, 25], [953, 859, 24], [941, 852, 28], [969, 837, 25], [960, 826, 25], [956, 827, 26], [945, 828, 28], [942, 821, 27], [940, 814, 27], [942, 810, 24], [936, 802, 26], [929, 812, 25], [934, 785, 26], [917, 769, 24], [912, 772, 24], [895, 769, 27], [892, 769, 28], [892, 757, 23], [877, 728, 25], [881, 724, 25], [894, 850, 22], [941, 835, 26], [925, 752, 26], [827, 724, 28], [794, 746, 27], [799, 741, 26], [773, 730, 23], [777, 728, 26], [783, 724, 27], [789, 718, 22], [822, 705, 26], [841, 683, 25], [844, 675, 24], [846, 657, 27], [802, 681, 21], [797, 684, 22], [807, 696, 26], [827, 686, 27], [822, 681, 25], [818, 674, 27], [821, 671, 23], [825, 674, 22], [796, 655, 25], [790, 646, 27], [766, 690, 26], [853, 683, 26], [853, 677, 24], [881, 672, 24], [894, 707, 26], [899, 737, 22], [902, 811, 26], [904, 805, 28], [900, 803, 27], [891, 799, 23], [896, 795, 28], [902, 794, 29], [883, 792, 26], [863, 783, 22], [855, 792, 26], [850, 801, 25], [857, 799, 22], [868, 820, 22], [869, 812, 26], [884, 810, 23], [881, 815, 24], [873, 836, 27], [907, 841, 25], [914, 841, 23], [930, 857, 23], [868, 768, 24], [845, 774, 22], [858, 774, 22], [804, 731, 24], [802, 736, 28], [824, 792, 22], [818, 783, 26], [815, 697, 24], [801, 713, 23], [785, 730, 29], [792, 740, 29], [765, 684, 25], [910, 803, 23], [923, 800, 25], [922, 779, 25], [923, 772, 29], [940, 775, 28], [809, 775, 23], [846, 667, 29], [813, 670, 23], [814, 758, 29], [848, 672, 27], [962, 841, 27], [828, 753, 24], [829, 748, 23], [857, 815, 23], [408, 498, 22], [416, 577, 22], [421, 526, 24], [471, 581, 25], [357, 485, 24], [388, 508, 25], [509, 581, 25], [364, 557, 26], [389, 572, 27], [410, 475, 26], [465, 537, 29], [410, 566, 25], [421, 584, 22], [411, 587, 26], [443, 603, 28], [471, 563, 24], [490, 557, 26], [422, 545, 24], [443, 497, 26], [435, 492, 23], [413, 487, 24], [403, 508, 26], [367, 519, 27], [468, 511, 26], [483, 539, 26], [441, 525, 24], [438, 544, 25], [422, 561, 25], [439, 582, 25], [429, 599, 24], [500, 582, 25], [397, 545, 28], [361, 523, 24], [493, 601, 28]]


    points3 = get_overlaped_points(poits1, poits2)

    


