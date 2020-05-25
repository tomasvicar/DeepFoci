clc;clear all;close all force;
addpath('utils')
addpath('3DNucleiSegmentation_training')

load('names_foci_sample.mat')
names_orig=names;

% names=subdir('..\example_folder\*3D_*.tif');
% names=subdir('Z:\CELL_MUNI\foky\new_foci_detection\example_folder\*3D_*.tif');
% names=subdir('E:\foky_tmp\example_folder\*3D_*.tif');
% names=subdir('F:\example_folder\*3D_*.tif');
names=subdir('Z:\999992-nanobiomed\Konfokal\18-11-19 - gH2AX jadra\data_vsichni_pacienti\example_folder_used\*3D_*.tif');
names={names(:).name};

gpu=1;


% load('foci_classification_training/fix_velke_aug_norm_net_checkpoint__8360__2020_01_14__17_52_49.mat');
% load('foci_classification_training/fix_velke_aug_nonorm_net_checkpoint__19000__2020_01_15__13_39_47.mat');

load('foci_classification_training/global_norm_net_small_grow_add.mat')

res=[];
gt=[];
cels_nums=[];
cumul=0;

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
    
    
    save_features=strrep(name,'3D_','features_window_');
%     save_features=strrep(name,'3D_','features_window2_');
    save_features=strrep(save_features,'.tif','.mat');


    save_features_for_celnum=strrep(name,'3D_','features_cellnum_');
    save_features_for_celnum=strrep(save_features_for_celnum,'.tif','.mat');
    
    
    features_norm_vals=strrep(name,'3D_','features_norm_vals_');
    features_norm_vals=strrep(features_norm_vals,'.tif','.mat');

    if img_num<240
        

    else
        load(save_manual_label)
    
        load(save_features)
        
        load(features_norm_vals)
        
        load(save_features_for_celnum)
        nums=table2array(cell_num)+cumul;
        
        if ~isempty(nums)
            cumul=max(nums);
        else
            cumul = cumul;
        end
        for k=1:length(widnowa)
            
            normA=norm_vals.globalA(k);
            normB=norm_vals.globalB(k);
            normA=normA{1};
            normB=normB{1};
            
            wa=(widnowa{k}-normA(1))/(normA(2)-normA(1));
            
            wb=(widnowb{k}-normB(1))/(normB(2)-normB(1));
            
            
            window_k=cat(4,wa,wb);
            

            window_k=window_k(4:end-4,4:end-4,2:end-2,:);
    
    
            window_k=single(mat2gray(window_k,[0,1]));


            YPred = predict(net,window_k);
            
            binaryResuslt=double(YPred(2));
            
            
            res=[res,binaryResuslt];
            gt=[gt,labels(k)];
            cels_nums=[cels_nums,nums(k)];
        end
        
        drawnow;
        
        sum((res>0.5)==gt)/numel(gt)
    end
    
    
end

avg_acc=[];
for k = 1:max(cels_nums)
    
    tmp_res=res(cels_nums==k);
    tmp_gt=gt(cels_nums==k);
    avg_acc=[avg_acc,sum((tmp_res>0.5)==tmp_gt)/numel(tmp_gt)];
    
end

nanmean(avg_acc)