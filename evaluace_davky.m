clc;clear all;close all;
addpath('utils')
addpath('3DNucleiSegmentation_training')

gpu=1;

% path='Z:\999992-nanobiomed\Konfokal\18-11-19 - gH2AX jadra\data_vsichni_pacienti\tif_4times';
% path='D:\Users\vicar\foci_part';
path='Z:\999992-nanobiomed\Konfokal\18-11-19 - gH2AX jadra\data_for_segmenttion_paper\data_ruzne_davky_tif';


% load('fix_velke_aug_norm_net_checkpoint__8360__2020_01_14__17_52_49.mat');

% load('rf_all_06860.mat');

% load('rf_half_06778.mat');

% load('rf_norm_06883.mat');



load('foci_classification_training/global_norm_net_small_grow_add.mat')


counts={};

folders=dir(path);
folders_new={};
for k=3:length(folders)
    folders_new=[folders_new [path '/' folders(k).name]];
end
folders=folders_new;

folders=sort(folders);


for folder_num=1:length(folders)
    
    folder=folders{folder_num};
    
    disp([num2str(folder_num) '/' num2str(length(folders))])

    disp(folder)


    names=subdir([folder '/*3D*.tif']);
    names={names(:).name};
    
    count=[];

    for img_num=1:length(names)

        img_num

        name=names{img_num};


        name_mask=strrep(name,'3D_','mask_');
        mask_name_split=strrep(name,'3D_','mask_split');
        
        
        name_2D=strrep(name,'3D_','2D_');


        name_mask_foci=strrep(name,'3D_','mask_foci_');


        save_control_seg=strrep(name,'3D_','control_seg_foci');
        save_control_seg=strrep(save_control_seg,'.tif','');

        save_manual_label=strrep(name,'3D_','manual_label_');
        save_manual_label=strrep(save_manual_label,'.tif','.mat');


        save_features=strrep(name,'3D_','features_');
        save_features=strrep(save_features,'.tif','.mat');

            
        save_features=strrep(name,'3D_','features_window_');
    %     save_features=strrep(name,'3D_','features_window2_');
        save_features=strrep(save_features,'.tif','.mat');


        save_features_for_celnum=strrep(name,'3D_','features_cellnum_');
        save_features_for_celnum=strrep(save_features_for_celnum,'.tif','.mat');


        features_norm_vals=strrep(name,'3D_','features_norm_vals_');
        features_norm_vals=strrep(features_norm_vals,'.tif','.mat');


        save_control_final=strrep(name,'3D_','control_final_net_');
        save_control_final=strrep(save_control_final,'.tif','');


        save_results_final=strrep(save_control_final,'control_','results_');
        save_results_final=[save_results_final '.mat'];



        load(save_results_final)
    
        load(save_features_for_celnum)
        
        tmp=binaryResuslts>0.5;
        nums=table2array(cell_num);
        for kk=1:max(nums(:))
            count=[count,sum(tmp(nums==kk))];
        end
    end
    
    counts=[counts,count];
    
    
    
    
    
end



x=[];
y=[];

for k=1:length(counts)
    
    tmp=counts{k};
    x=[x,k*ones(1,length(tmp))];
    y=[y,tmp];
    
    
end

boxplot(y,x)



