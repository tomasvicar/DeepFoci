clc;clear all;close all;
addpath('utils')
addpath('3DNucleiSegmentation_training')

gpu=1;

% path='Z:\999992-nanobiomed\Konfokal\18-11-19 - gH2AX jadra\data_vsichni_pacienti\tif_4times';
path='D:\Users\vicar\foci_part';




load('rf_all_06860.mat');

% load('rf_half_06778.mat');

% load('rf_norm_06883.mat');





folders=dir(path);
folders_new={};
for k=3:length(folders)
    folders_new=[folders_new [path '/' folders(k).name]];
end
folders=folders_new;

folders=sort(folders);


for folder_num=1:50
    
    folder=folders{folder_num};
    
    disp([num2str(folder_num) '/' num2str(length(folders))])

    disp(folder)


    names=subdir([folder '/*3D*.tif']);
    names={names(:).name};

    for img_num=1:length(names)

        img_num

        name=names{img_num};


        name_mask=strrep(name,'3D_','mask_');
        mask_name_split=strrep(name,'3D_','mask_split');
        
        
        name_2D=strrep(name,'3D_','2D_');
        
        name_2D_nice=strrep(name,'3D_','2D_nice_');


        name_mask_foci=strrep(name,'3D_','mask_foci_');


        save_control_seg=strrep(name,'3D_','control_seg_foci');
        save_control_seg=strrep(save_control_seg,'.tif','');

        save_manual_label=strrep(name,'3D_','manual_label_');
        save_manual_label=strrep(save_manual_label,'.tif','.mat');


        save_features=strrep(name,'3D_','features_');
        save_features=strrep(save_features,'.tif','.mat');

        save_features_cellnum=strrep(name,'3D_','features_cellnum_');
        save_features_cellnum=strrep(save_features_cellnum,'.tif','.mat');
        
        
        save_features_window=strrep(name,'3D_','features_window_');
        save_features_widnow=strrep(save_features_window,'.tif','.mat');
        
        save_features_window2=strrep(name,'3D_','features_window2_');
        save_features_widnow2=strrep(save_features_window2,'.tif','.mat');
        
        
        save_control_final=strrep(name,'3D_','control_final_rf_fall_');
%         save_control_final=strrep(name,'3D_','control_final_rf_fhalf_');
%         save_control_final=strrep(name,'3D_','control_final_rf_fnrom_');
%         save_control_final=strrep(name,'3D_','control_final_net_norm_');
%         save_control_final=strrep(name,'3D_','control_final_net_nonorm_');
        save_control_final=strrep(save_control_final,'.tif','');
        
        
        save_results_final=strrep(save_control_final,'control_','results_');
        save_results_final=[save_results_final '.mat'];
        

     
        
        [a,b,c]=read_3d_rgb_tif(name);

        [a,b,c]=preprocess_filters(a,b,c,0);

        rgb_2d=cat(3,norm_percentile(mean(a,3),0.001),norm_percentile(mean(b,3),0.001),norm_percentile(mean(c,3),0.001));


        
        imwrite_single(single(rgb_2d),name_2D_nice);
        

    end
    
end