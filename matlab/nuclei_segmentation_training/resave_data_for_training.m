clc;clear all;close all force;
addpath('../utils')


%% setup
src_path = '../../data_zenodo/part1/nucleus_segmentation';
dst_paht = '../../data_zenodo/part1_resaved/nucleus_segmentation';


% load filenames of data
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


resized_img_size = [505  681   48]; %image is resized to this size

normalization_percentile = 0.0001;  %image is normalized into this percentile range

mask_erosion=[14 14 5]; % amount of mask erosion (elipsoid)
minimal_nuclei_size = 6000;

%% resaving 
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

    data = cat(4,data{:});
    
    output_filename = filename_img;
    output_filename = replace(output_filename,'.tif','.mat');
    output_filename = replace(norm_path(output_filename),norm_path(src_path),norm_path(dst_paht));

    mkdir(fileparts(output_filename))

    save(output_filename,'data','-v7.3')


    mask = imread(filename_mask);

    mask = imresize3(mask,resized_img_size,'nearest');

    [X,Y,Z] = meshgrid(linspace(-1,1,mask_erosion(1)),linspace(-1,1,mask_erosion(2)),linspace(-1,1,mask_erosion(3)));
    sphere=sqrt(X.^2+Y.^2+Z.^2)<1;
    

    % preprocess masks - nuclei contains values 1-4 
    mask_erroded = false(size(mask));
    for nuclei_value = 1:4
        mask_current = mask == nuclei_value;

        mask_current = imerode(imclose(mask_current,sphere),sphere); %close to make smooth border
        mask_current = bwareaopen(mask_current,minimal_nuclei_size);

        mask_erroded(mask_current) = true;
    end

    data = mask_erroded;

    output_filename = filename_mask;
    output_filename = replace(output_filename,'.tif','.mat');
    output_filename = replace(norm_path(output_filename),norm_path(src_path),norm_path(dst_paht));

    mkdir(fileparts(output_filename))

    save(output_filename,'data','-v7.3')

end