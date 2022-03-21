clc;clear all; close all;
addpath('../utils')

src_path = '../../data_zenodo/part1/nucleus_segmentation/test';

%preprocessing params same as for training
resized_img_size = [505  681   48];
normalization_percentile = 0.0001;


%posproccessing prarams can be adjusted
minimal_nuclei_size=6000;
for h = 1:10
    mask_dilatation=[14 14 5];
    
    
    
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
    
    patchSize = dlnet.Layers(1).InputSize;
    out_layers = dlnet.Layers(48).NumOutputs;
    
    segs = [];
    for img_num = 1:length(filenames_imgs)
%         disp(['evaluation valid  '  num2str(img_num)  '/' num2str(length(filenames_imgs))])
    
        filename_img = filenames_imgs{img_num};
        filename_mask = filenames_masks{img_num};
    
    
        data_all_channels = imread_4D_tif(filename_img);
    
        output_resize = [size(data_all_channels,1),size(data_all_channels,2),size(data_all_channels,3)];
        
        data = {};
        for channel_num = 1:size(data_all_channels,4)
    
            data_one_channel = data_all_channels(:,:,:,channel_num);
    
            data_one_channel = imresize3(data_one_channel,resized_img_size);
    
            data_one_channel = norm_percentile_nocrop(data_one_channel,normalization_percentile);
    
            data_one_channel = single(data_one_channel);
    
            data = [data,data_one_channel];
        end
    
        data = single(cat(4,data{:}));
    
        mask_predicted = predict_by_parts(data,out_layers,dlnet,patchSize);
        
        mask_split = split_nuclei(mask_predicted>0.5,minimal_nuclei_size,h);
        
        mask_label_dilated = balloon(mask_split,mask_dilatation);
    
        mask_final = imresize3(mask_label_dilated,output_resize,'nearest');
    
    
    
    
        mask = imread(filename_mask);
    
        mask = imresize3(mask,resized_img_size,'nearest');
    
        [X,Y,Z] = meshgrid(linspace(-1,1,mask_dilatation(1)),linspace(-1,1,mask_dilatation(2)),linspace(-1,1,mask_dilatation(3)));
        my_sphere=sqrt(X.^2+Y.^2+Z.^2)<1;
    
        mask_erroded = false(size(mask));
        for nuclei_value = 1:4
            mask_current = mask == nuclei_value;
    
            mask_current = imerode(imclose(mask_current,my_sphere),my_sphere); %close to make smooth border
    
            mask_current = bwareaopen(mask_current,minimal_nuclei_size);
    
            mask_erroded(mask_current) = true;
        end
    
    
        mask = balloon(mask_erroded,mask_dilatation);
    
        mask = imresize3(mask,output_resize,'nearest');
    
    
    
        
        seg = seg_3d(mask,mask_final);
    
        segs = [segs,seg];
    
    end
    h
    median(segs)


end