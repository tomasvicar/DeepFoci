from aicsimageio import AICSImage
import matplotlib.pyplot as plt
import os
import numpy as np

def determine_channel_order(channel_names):
    # Initialize the order list with zeros
    order = [0, 0, 0]

    # Check for '53bp1' or 'rad51' in the channel names
    found = False
    for i, name in enumerate(channel_names):
        if '53bp1' in name.lower() or 'rad51' in name.lower():
            order[0] = i 
            found = True
            break
    if not found:
        raise ValueError('No 53bp1 or rad51 channel found')

    # Check for 'gh2ax' in the channel names
    found = False
    for i, name in enumerate(channel_names):
        if 'gh2ax' in name.lower():
            order[1] = i 
            found = True
            break
    if not found:
        raise ValueError('No gh2ax channel found')

    # Check for 'dapi' or 'topro' in the channel names
    found = False
    for i, name in enumerate(channel_names):
        if 'dapi' in name.lower() or 'topro' in name.lower():
            order[2] = i 
            found = True
            break
    if not found:
        raise ValueError('No DAPI or Topro channel found')

    return order


def read_ics_file_ordered(fname, get_channel_names=False):
    name_fov_file = ''
    if os.path.exists(os.path.dirname(fname) + '/fov.txt'):
        name_fov_file = os.path.dirname(fname) + '/fov.txt'
    elif os.path.exists(os.path.dirname(fname) + '/roi.txt'):
        name_fov_file = os.path.dirname(fname) + '/roi.txt'
    else:
        raise FileNotFoundError('No textfile found')
    
    channel_names = []
    with open(name_fov_file, 'r') as file:
        for line in file:
            if 'Name=' in line:
                channel_names.append(line.strip()[5:])

    order = determine_channel_order(channel_names)
    channel_names_orderd = [channel_names[i] for i in order]

    data = []
    img = AICSImage(fname) 
    data.append(img.data[0, 0, :, :, :])

    img = AICSImage(fname.replace('01.ics', '02.ics')) 
    data.append(img.data[0, 0, :, :, :])


    img = AICSImage(fname.replace('01.ics', '03.ics')) 
    data.append(img.data[0, 0, :, :, :])

    data = np.stack(data, axis=0)
    data = data[order, :, :, :]

    data = np.transpose(data, [2, 3, 1, 0])

    ######################################################### crop black border....
    data = data[:-30, :-30, :, :]

    if get_channel_names:
        return data, channel_names_orderd
    else:
        return data




if __name__ == '__main__':
    fname = r"C:\Data\Vicar\foci_rad51_retrain\data\NANOREP\gamma-IR_NHDF_RAD51+gH2AX_2021_6_8 (Acquiarium)\IR 1Gy\IR1Gy_0,5hPI\rawdata\0001\01.ics"
    data = read_ics_file_ordered(fname)
    print(data.shape)
    # plt.imshow(data[0,0,25,:,:])
    # plt.show()