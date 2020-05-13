clc;clear all;close all;
addpath('../utils')

load('../names_foci_sample.mat')
names_orig=names;

% names=subdir('..\example_folder\*3D_*.tif');
% names=subdir('Z:\CELL_MUNI\foky\new_foci_detection\example_folder\*3D_*.tif');
names=subdir('E:\foky_tmp\example_folder\*3D_*.tif');
% names=subdir('F:\example_folder\*3D_*.tif');
names={names(:).name};

gpu=1;


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
    
    
    save_features=strrep(name,'3D_','features_norm_vals_');
    save_features=strrep(save_features,'.tif','.mat');
    
    
    save_unet_foci_detection_data=strrep(name,'3D_','unet_foci_detection_data');
    save_unet_foci_detection_data=strrep(save_unet_foci_detection_data,'.tif','.mat');
    
    [a,b,c]=read_3d_rgb_tif(name);


    [a,b,c]=preprocess_filters(a,b,c,gpu);

    mask_foci=imread(name_mask_foci)>0;

    lbl_foci=bwlabeln(mask_foci);
    
    
    global_mean_a=mean(a(:));
    global_std_a=std(a(:));
    global_mean_b=mean(b(:));
    global_std_b=std(b(:));
    global_mean_c=mean(c(:));
    global_std_c=std(c(:));
    
    
    p=
    
    global_pup_a=mean(a(:));
    global_pdown_a=std(a(:));
    global_pup_b=mean(a(:));
    global_pdown_b=std(a(:));
    global_pup_c=mean(a(:));
    global_pdown_c=std(a(:));
    
        
    mask=imread(mask_name_split);

    mask_foci=imread(name_mask_foci)>0;

    lbl_foci=bwlabeln(mask_foci);

     
    clear mask_foci

    lbl_mask=bwlabeln(mask);
    
    tmp_cell_means_a=[];
    tmp_cell_std_a=[];
    tmp_cell_means_b=[];
    tmp_cell_std_b=[];
    tmp_cell_means_c=[];
    tmp_cell_std_c=[];
    for k=1:max(lbl_mask)
        tmp_cell_means_a=[tmp_cell_means_a];
        tmp_cell_std_a=[tmp_cell_std_a];
        tmp_cell_means_b=[tmp_cell_means_b];
        tmp_cell_std_b=[tmp_cell_std_b];
        tmp_cell_means_c=[tmp_cell_means_c];
        tmp_cell_std_c=[tmp_cell_std_c];
    end
    norm_vals = regionprops3(lbl_foci,lbl_mask,'MaxIntensity');
    norm_vas.Properties.VariableNames={'cellNum'};
    
    cell_num
    
end
    