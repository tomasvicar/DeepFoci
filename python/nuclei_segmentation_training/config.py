import numpy as np

class Config:
    
    tmp_save_dir='../../data_zenodo/tmp_segmentation_model'
    
    # train_num_workers=6
    # test_num_workers=3
    
    train_num_workers=0
    test_num_workers=0
    
    
    hdf5_filename = '../../data_zenodo/part1_resaved/nucleus_segmentation.hdf5'
    
    
    model_name='segmentation_model_1'
    
    
    # train_batch_size = 12
    # test_batch_size = 4
    
    train_batch_size = 4
    test_batch_size = 2
    
    
    # lr_changes_list = np.cumsum([10,5])
    lr_changes_list = np.cumsum([100,50,10,5])
    # lr_changes_list = np.cumsum([30,10,5,5])
    max_epochs = lr_changes_list[-1]
    gamma = 0.1
    init_lr = 0.001
    
    
    
    # filters = [16, 32, 64, 128]
    filters = [4, 8, 16, 32]
    input_size = 3
    output_size = 1
    
    # crop_size = [96,96]
    crop_size = [64,64]
    
    
    