clc;clear all;close all force;
% dbstop if error
% dbclear if error
addpath('../utils')
addpath('../3DNucleiSegmentation_training')

% load('../names_foci_sample.mat')
% names_orig=names;

% names=subdir('../..\example_folder\*3D_*.tif');
% names=subdir('Z:\CELL_MUNI\foky\new_foci_detection\example_folder\*3D_*.tif');
% names=subdir('E:\foky_tmp\example_folder\*3D_*.tif');
% names=subdir('F:\example_folder\*3D_*.tif');
names=subdir('E:\foky_tmp\man_nahodny_vzorek_tif\*data_*.tif');
names={names(:).name};


gpu=1;

load('test3_value_aug_mult.mat')


for img_num=1:100
    
    img_num
    
    name=names{img_num};
    
    name_orig=names_orig{img_num};
    
    name_mask=strrep(name,'data_','mask_');
    mask_name_split=strrep(name,'data_','mask_split');
    
    
    name_mask_foci=strrep(name,'data_','mask_foci_');
    
    
    save_control_seg=strrep(name,'data_','control_seg_foci');
    save_control_seg=strrep(save_control_seg,'.tif','');
    
    save_manual_label=strrep(name,'data_','manual_label_');
    save_manual_label=strrep(save_manual_label,'.tif','.mat');
    
    
%     save_features=strrep(name,'data_','features_window_');
    save_features=strrep(name,'data_','features_window2_');
    save_features=strrep(save_features,'.tif','.mat');


    save_features_for_celnum=strrep(name,'data_','features_cellnum_');
    save_features_for_celnum=strrep(save_features_for_celnum,'.tif','.mat');
    
    
    save_unet_foci_detection_mask=strrep(name,'data_','unet_foci_detection_mask');
    save_unet_foci_detection_mask=strrep(save_unet_foci_detection_mask,'.tif','.mat');
    
    
    save_unet_foci_detection_data=strrep(name,'data_','unet_foci_detection_data');
    save_unet_foci_detection_data=strrep(save_unet_foci_detection_data,'.tif','.mat');
    
    
    save_unet_foci_detection_res=strrep(name,'data_','unet_foci_detection_res');
    save_unet_foci_detection_res=strrep(save_unet_foci_detection_res,'.tif','.mat');
    

    if img_num<240
        
    else
    
        [a,b,c]=read_3d_rgb_tif(name);
         
        a=a(:,:,[2,4:end]);
        b=b(:,:,[2,4:end]);
        c=c(:,:,[2,4:end]);

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


        mask_points_foci2=imgaussfilt3(single(mask_points_foci),[2,2,1])*59.5238*10;

        vys=predict_by_parts_detection(a,b,c,net);

        save(save_unet_foci_detection_res,'vys','mask_points_foci')
        
        

    end
    
end