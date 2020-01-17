clc;clear all;close all;
addpath('utils')
addpath('3DNucleiSegmentation_training')

load('names_foci_sample.mat')
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
    
    
    save_features=strrep(name,'3D_','features_');
    save_features=strrep(save_features,'.tif','.mat');
    
    save_features_cellnum=strrep(name,'3D_','features_cellnum_');
    save_features_cellnum=strrep(save_features_cellnum,'.tif','.mat');
    
    
    
    
    load(save_manual_label)
    
    load(save_features)
    
    load(save_features_cellnum)
    
    
  
    
    
    [features_new] = get_features_all(features,cell_num);
%     [features_new] = get_features_half(features,cell_num);
%     [features_new] = get_features_norm(features,cell_num);
    
    
    
    features=features_new;
    
    if img_num<240
        
        if ~exist('features_train','var')
        
            features_train=features;
            lbls_train=labels';
        else
        
            features_train=[features_train;features];
            lbls_train=[lbls_train;labels'];
        
        end

      
        
        
    else
        if ~exist('features_test','var')
        
            features_test=features;
            lbls_test=labels';
            
            
        else
        
        
            features_test=[features_test;features];
            lbls_test=[lbls_test;labels'];
        
        end

    end
    
    
end



Mdl = TreeBagger(100,features_train{:,:},lbls_train);

prediction = str2double(predict(Mdl,features_test{:,:}));


mean(prediction==lbls_test)














