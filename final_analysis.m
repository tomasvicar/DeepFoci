clc;clear all;close all;
addpath('utils')
addpath('3DNucleiSegmentation_training')

gpu=1;

path='Z:\999992-nanobiomed\Konfokal\18-11-19 - gH2AX jadra\data_vsichni_pacienti\tif_4times';
% path='D:\Users\vicar\foci_part';



table_paths=readtable('excel_files/vkladani_cest.xlsx');



folders=table_paths.foci_2Gy_mix;

pac_num=table_paths.na_e__slov_n_;

res_struc = struct('path',{},'pac_num',{},'t_noIR',{},'t_30m',{},'t_8h',{},'t_24h',{});
for k=1:length(pac_num)
    res_struc(k).path=folders{k};
    res_struc(k).pac_num=pac_num(k);
    
    res_struc(k).t_noIR=[];
    res_struc(k).t_30m=[];
    res_struc(k).t_8h=[];
    res_struc(k).t_24h=[];
    
end



for folder_num=1:ength(folders)
    
    folder=folders{folder_num};
    
    disp([num2str(folder_num) '/' num2str(length(folders))])

    disp(folder)
    
    
    sub_folders=dir(path);
    sub_folders={sub_folders(3:end).name};
    
    
    
    for sub_folder_num=1:length(sub_folders)
    
    sub_folder=sub_folders{ub_folder_num};

    names=subdir([folder '/' sub_folder '/*3D*.tif']);
    names={names(:).name};

%     for img_num=1:length(names)
% 
%         img_num
% 
%         name=names{img_num};
% 
% 
%         name_mask=strrep(name,'3D_','mask_');
%         mask_name_split=strrep(name,'3D_','mask_split');
%         
%         
%         name_2D=strrep(name,'3D_','2D_');
% 
% 
%         name_mask_foci=strrep(name,'3D_','mask_foci_');
% 
% 
%         save_control_seg=strrep(name,'3D_','control_seg_foci');
%         save_control_seg=strrep(save_control_seg,'.tif','');
% 
%         save_manual_label=strrep(name,'3D_','manual_label_');
%         save_manual_label=strrep(save_manual_label,'.tif','.mat');
% 
% 
%         save_features=strrep(name,'3D_','features_');
%         save_features=strrep(save_features,'.tif','.mat');
% 
%         save_features_cellnum=strrep(name,'3D_','features_cellnum_');
%         save_features_cellnum=strrep(save_features_cellnum,'.tif','.mat');
%         
%         
%         save_features_window=strrep(name,'3D_','features_window_');
%         save_features_widnow=strrep(save_features_window,'.tif','.mat');
%         
%         save_features_window2=strrep(name,'3D_','features_window2_');
%         save_features_widnow2=strrep(save_features_window2,'.tif','.mat');
%         
%         
%         save_control_final=strrep(name,'3D_','control_final_rf_fall_');
% %         save_control_final=strrep(name,'3D_','control_final_rf_fhalf_');
% %         save_control_final=strrep(name,'3D_','control_final_rf_fnrom_');
% %         save_control_final=strrep(name,'3D_','control_final_net_norm_');
% %         save_control_final=strrep(name,'3D_','control_final_net_nonorm_');
%         save_control_final=strrep(save_control_final,'.tif','');
%         
%         
%         save_results_final=strrep(save_control_final,'control_','results_');
%         save_results_final=[save_results_final '.mat'];
%         
% 
%         
%         load(save_results_final)
%         
%     end
    
    if contains(sub_folder,'8h')
    
    elseif contains(sub_folder,'24h')
        
    elseif contains(sub_folder,'30m')||contains(sub_folder,'30PI')
        
    elseif contains(sub_folder,'nonIR')||contains(sub_folder,'KO')
        
    
    else
        error('neobsahuje nic')
        
    end
    end
end