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



for img_num=1:170
    
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
    
    
    
    
    load(save_manual_label)
    
    load(save_features)
    
    
    
    
    features_new=features(:,[1,2,3,4]);
    
%     features_new=[features_new,features(:,35:46)];

    
%     
%     features_new = addvars(features_new,features.MaxIntensitya./features.mediana,'NewVariableNames','MaxDMedA');
%     features_new = addvars(features_new,features.MaxIntensityb./features.medianb,'NewVariableNames','MaxDMedB');
%     features_new = addvars(features_new,features.MaxIntensityab./features.medianab,'NewVariableNames','MaxDMedAB');
%      
%     
%     features_new = addvars(features_new,features.MeanIntensitya./features.mediana,'NewVariableNames','MeanDMedA');
%     features_new = addvars(features_new,features.MeanIntensityb./features.medianb,'NewVariableNames','MeanDMedB');
%     features_new = addvars(features_new,features.MeanIntensityab./features.medianab,'NewVariableNames','MeanDMedAB');

% 
% 
%     features_new = addvars(features_new,features.MaxIntensitya./features.percentile99a,'NewVariableNames','MaxDpercentileA');
%     features_new = addvars(features_new,features.MaxIntensityb./features.percentile99b,'NewVariableNames','MaxDpercentileB');
%     features_new = addvars(features_new,features.MaxIntensityab./features.percentile99ab,'NewVariableNames','MaxDpercentileAB');
% 
% 
%     features_new = addvars(features_new,features.MeanIntensitya./features.percentile99a,'NewVariableNames','MeanDpercentileA');
%     features_new = addvars(features_new,features.MeanIntensityb./features.percentile99b,'NewVariableNames','MeanDpercentileB');
%     features_new = addvars(features_new,features.MeanIntensityab./features.percentile99ab,'NewVariableNames','MeanDpercentileAB');    





%      sigmas=[6,9,15,25];
%      for sigma = sigmas
%   
%          features_new = addvars(features_new,features.(['CentroidValueaG' num2str(sigma)])./features.CentroidValuea,'NewVariableNames',['CentroidValueaG' num2str(sigma) 'DCentroidValue']);
%          features_new = addvars(features_new,features.(['CentroidValuebG' num2str(sigma)])./features.CentroidValueb,'NewVariableNames',['CentroidValuebG' num2str(sigma) 'DCentroidValue']);
%          features_new = addvars(features_new,features.(['CentroidValueabG' num2str(sigma)])./features.CentroidValueab,'NewVariableNames',['CentroidValueabG' num2str(sigma) 'DCentroidValue']);
%  
%      end
     
     
%      sigmas=[6,9,15,25];
%      for sigma = sigmas
%   
%          features_new = addvars(features_new,features.(['CentroidValueaG' num2str(sigma)])-features.CentroidValuea,'NewVariableNames',['CentroidValueaG' num2str(sigma) 'MCentroidValue']);
%          features_new = addvars(features_new,features.(['CentroidValuebG' num2str(sigma)])-features.CentroidValueb,'NewVariableNames',['CentroidValuebG' num2str(sigma) 'MCentroidValue']);
%          features_new = addvars(features_new,features.(['CentroidValueabG' num2str(sigma)])-features.CentroidValueab,'NewVariableNames',['CentroidValueabG' num2str(sigma) 'MCentroidValue']);
%  
%      end     
     



%      sigmas=[6,9,15,25];
%      for sigma = sigmas
%   
%          features_new = addvars(features_new,features.(['CentroidValueaMin' num2str(sigma)])./features.CentroidValuea,'NewVariableNames',['CentroidValueaMin' num2str(sigma) 'DCentroidValue']);
%          features_new = addvars(features_new,features.(['CentroidValuebMin' num2str(sigma)])./features.CentroidValueb,'NewVariableNames',['CentroidValuebMin' num2str(sigma) 'DCentroidValue']);
%          features_new = addvars(features_new,features.(['CentroidValueabMin' num2str(sigma)])./features.CentroidValueab,'NewVariableNames',['CentroidValueabMin' num2str(sigma) 'DCentroidValue']);
%  
%      end
    

%      sigmas=[6,9,15,25];
%      for sigma = sigmas
%   
%          features_new = addvars(features_new,(features.CentroidValuea-features.(['CentroidValueaMin' num2str(sigma)]))./features.CentroidValuea,'NewVariableNames',['CentroidValueaMin' num2str(sigma) 'MDCentroidValue']);
%          features_new = addvars(features_new,(features.CentroidValueb-features.(['CentroidValuebMin' num2str(sigma)]))./features.CentroidValueb,'NewVariableNames',['CentroidValuebMin' num2str(sigma) 'MDCentroidValue']);
%          features_new = addvars(features_new,(features.CentroidValueab-features.(['CentroidValueabMin' num2str(sigma)]))./features.CentroidValueab,'NewVariableNames',['CentroidValueabMin' num2str(sigma) 'MDCentroidValue']);
%  
%      end


    
    features=features_new;
    
    if img_num<120
        
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














