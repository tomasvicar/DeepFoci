clc;clear all;close all force;
% dbstop if error
% dbclear if error
addpath('utils')
addpath('3DNucleiSegmentation_training')

% load('../names_foci_sample.mat')
% names_orig=names;

% names=subdir('../..\example_folder\*3D_*.tif');
% names=subdir('Z:\CELL_MUNI\foky\new_foci_detection\example_folder\*3D_*.tif');
% names=subdir('E:\foky_tmp\example_folder\*3D_*.tif');
% names=subdir('F:\example_folder\*3D_*.tif');
% names=subdir('Z:\999992-nanobiomed\Konfokal\18-11-19 - gH2AX jadra\data_vsichni_pacienti\example_folder_used\*3D_*.tif');
names=subdir('E:\foky_tmp\man_nahodny_vzorek_tif\*data_*.tif');
% names=subdir('E:\foky_tmp\man_nahodny_vzorek_tif2\*data_*.tif');

names={names(:).name};


gpu=1;



dice_res_ja=[];
fp=[];
fn=[];
dice_res_jarda=[];
dice_ja_jarda=[];


for img_num=1:length(names)
    
%     img_num
    
    name=names{img_num};
    name
    
%     name_orig=names_orig{img_num};
    
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
    
    save_unet_foci_detection_res_points=strrep(name,'data_','unet_foci_detection_res_points');
    save_unet_foci_detection_res_points=strrep(save_unet_foci_detection_res_points,'.tif','.mat');
    
    
    save_unet_foci_segmentation_res=strrep(name,'data_','unet_foci_segmentation_res');
    
    
    save_final_results_unet_control=strrep(name,'data_','final_results_unet_control');
    save_final_results_unet_control=strrep(save_final_results_unet_control,'.tif','');
    
    
    
    name_gt_ja=strrep(name,'man_nahodny_vzorek_tif','man_nahodny_vzorek_tif_ja');
    name_gt_ja=strrep(name_gt_ja,'.tif','_tecky.mat');
    
    name_gt_jarda=strrep(name,'man_nahodny_vzorek_tif','man_nahodny_vzorek_tif_jarda');
    name_gt_jarda=strrep(name_gt_jarda,'.tif','_tecky.mat');
    
    

    [a,b,c]=read_3d_rgb_tif(name);


    mask=imread(mask_name_split);
    
    
    s = regionprops(mask>0,'BoundingBox');
    bbs = cat(1,s.BoundingBox);

    
    d=10;
    th=5;
    proj='max';
    
    
    for cell_num =1:size(bbs,1)

        bb=round(bbs(cell_num,:));
        a_crop = a(bb(2):bb(2)+bb(5)-1,bb(1):bb(1)+bb(4)-1,bb(3):bb(3)+bb(6)-1);
        b_crop = b(bb(2):bb(2)+bb(5)-1,bb(1):bb(1)+bb(4)-1,bb(3):bb(3)+bb(6)-1);
        mask_crop = b(bb(2):bb(2)+bb(5)-1,bb(1):bb(1)+bb(4)-1,bb(3):bb(3)+bb(6)-1);
        
        

        drawnow;
    end
    


    load(name_gt_ja)
    gt_ja=tecky;
    
    load(name_gt_jarda)
    gt_jarda=tecky;
    
   
    
    d=matches_distance(res,gt_ja);
    dice=(2*d)/(size(res,1)+size(gt_ja,1));
    dice_res_ja=[dice_res_ja,dice];
    fp=[fp,max(size(res,1)-d,0)];
    fn=[fn,max(size(gt_ja,1)-d,0)];
    
    
    d=matches_distance(res,gt_jarda);
    dice=(2*d)/(size(res,1)+size(gt_jarda,1));
    dice_res_jarda=[dice_res_jarda,dice];
    
    d=matches_distance(gt_ja,gt_jarda);
    dice=(2*d)/(size(gt_ja,1)+size(gt_jarda,1));
    dice_ja_jarda=[dice_ja_jarda,dice];
    
    
    dice_res_jarda(end)
    
    med_dice=median(dice_res_ja);
    med_fp=median(fp);
    med_fn=median(fn);
    
    drawnow;
    
    
    
end

med_dice

figure()
y=[dice_res_ja',dice_res_jarda',dice_ja_jarda'];
boxplot(y)


