import numpy as np
import json
import matplotlib.pyplot as plt


def read_detections(filename, data_shape, output_detection_channels, resized_img_size):
    resized_img_size = np.array(resized_img_size)
    resize_factor = data_shape / resized_img_size


    with open(filename, 'r') as file:
        detections_tmp = json.load(file)

    detections = {}
    binary_detections = {}

    for channel in output_detection_channels:
        detected_points = np.array(detections_tmp[channel])

        if detected_points.size == 0:
            detected_points = np.zeros((0, 3), dtype=int)
        elif detected_points.size == 3:
            detected_points = detected_points.reshape((1, 3))

        # Apply resize factors
        detected_points = np.round(detected_points * resize_factor).astype(int) 
        detected_points = detected_points - 1

        detections[channel] = detected_points
        
        # Create binary detection image
        binary_image = np.zeros(data_shape, dtype=bool)
        if detected_points.size != 0:
            # detected_points = np.clip(detected_points, [0, 0, 0], np.array(data_shape) - 1)
            indices = np.ravel_multi_index((detected_points[:, 1], detected_points[:, 0], detected_points[:, 2]), dims=data_shape)
            binary_image.flat[indices] = True

        binary_detections[channel] = binary_image

    return detections, binary_detections



if __name__ == '__main__':
    fname = r"C:\Data\Vicar\foci_rad51_retrain\data\NANOREP_net_results_rad51\gamma-IR_NHDF_RAD51+gH2AX_2021_6_8 (Acquiarium)\IR 1Gy\IR1Gy_0,5hPI\rawdata\0002\detections.json"
    data_shape = [1040, 1392, 50]
    output_detection_channels = ['points_RAD51','points_gH2AX','points_53BP1_gH2AX_overlap']
    resized_img_size = [505, 681, 48]

    detections, binary_detections = read_detections(fname, data_shape, output_detection_channels, resized_img_size)
    
    from skimage.morphology import binary_dilation
    from skimage.morphology import disk
    plt.imshow(binary_dilation(np.max(binary_detections['points_RAD51'], axis=2), disk(5)))
    plt.show()

