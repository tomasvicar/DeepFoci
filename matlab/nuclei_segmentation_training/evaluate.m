clc;clear all; close all;
addpath('../utils')

src_path = '../../data_zenodo/part1/nucleus_segmentation/test';

resized_img_size = [505  681   48];

normalization_percentile = 0.0001;



filenames_imgs = subdir([src_path '/data_*.tif']);
filenames_imgs = {filenames_imgs(:).name};

filenames_masks = {};
for file_num = 1:length(filenames_imgs)
    filename_img = filenames_imgs{file_num};
    [filepath,name,ext] = fileparts(filename_img);
    name(1:4) = 'mask';
    filename_mask = [filepath, '/',name, ext];
    filenames_masks = [filenames_masks filename_mask];
end


load('tmp4.mat','dlnet')

dlnet.I




for img_num = 1:length(filenames_imgs)


    filename_img = filenames_imgs{img_num};
    filename_mask = filenames_masks{img_num};

    data_all_channels = imread_4D_tif(filename_img);
    
    data = {};
    %% data_preprocessing
    for channel_num = 1:size(data_all_channels,4)

        data_one_channel = data_all_channels(:,:,:,channel_num);

        data_one_channel = imresize3(data_one_channel,resized_img_size);

        data_one_channel = norm_percentile_nocrop(data_one_channel,normalization_percentile);

        data_one_channel = single(data_one_channel);

        data = [data,data_one_channel];
    end

    data = single(cat(4,data{:}));

    mask_predicted = predict_by_parts(data,out_layers,dlnet,patchSize);
    

    drawnow;



end