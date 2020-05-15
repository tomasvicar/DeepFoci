clc;clear all;close all force;
% dbstop if error
% dbclear if error
addpath('../utils')
addpath('../3DNucleiSegmentation_training')

load('../names_foci_sample.mat')
names_orig=names;

names=subdir('../..\example_folder\*3D_*.tif');
% names=subdir('Z:\CELL_MUNI\foky\new_foci_detection\example_folder\*3D_*.tif');
% names=subdir('E:\foky_tmp\example_folder\*3D_*.tif');
% names=subdir('F:\example_folder\*3D_*.tif');
names={names(:).name};


gpu=1;

load('test3_value_aug_mult.mat')


for img_num=1:300
    
    img_num
    
    name=names{img_num};
    
    name_orig=names_orig{img_num};
    
    name_mask=strrep(name,'3D_','mask_');
    mask_name_split=strrep(name,'3D_','mask_split');
    
    
    name_mask_foci=strrep(name,'3D_','mask_foci_');
    
    
    save_control_seg=strrep(name,'3D_','control_seg_foci');
    save_control_seg=strrep(save_control_seg,'.tif','');
    
    save_manual_label=strrep(name,'3D_','manual_label_');
    save_manual_label=strrep(save_manual_label,'.tif','.mat');
    
    
%     save_features=strrep(name,'3D_','features_window_');
    save_features=strrep(name,'3D_','features_window2_');
    save_features=strrep(save_features,'.tif','.mat');


    save_features_for_celnum=strrep(name,'3D_','features_cellnum_');
    save_features_for_celnum=strrep(save_features_for_celnum,'.tif','.mat');
    
    
    save_unet_foci_detection_mask=strrep(name,'3D_','unet_foci_detection_mask');
    save_unet_foci_detection_mask=strrep(save_unet_foci_detection_mask,'.tif','.mat');
    
    
    save_unet_foci_detection_data=strrep(name,'3D_','unet_foci_detection_data');
    save_unet_foci_detection_data=strrep(save_unet_foci_detection_data,'.tif','.mat');
    
    
    [a,b,c]=read_3d_rgb_tif(name);


    [a,b,c]=preprocess_filters(a,b,c,gpu);

    shape_old=size(a);
    [a,b,c]=preprocess_norm_resize_foci(a,b,c);
    shape_new=size(a);
    
    factor=shape_new./shape_old;
    
    load(save_manual_label);
    
    
    positions_resize=round(positions.*repmat(factor,[size(positions,1),1]));
    
    mask_points_foci=false(shape_new);
    
    
    
    use=labels>0;
    positions_linear=sub2ind(shape_new,positions_resize(use,2),positions_resize(use,1),positions_resize(use,3));
    mask_points_foci(positions_linear)=true;
    
    
    mask_points_foci2=imgaussfilt3(single(mask_points_foci),[2,2,1]);
    
    vys=predict_by_parts_detection(a,b,c,net);
    
    drawnow;
    
    
    
    
end