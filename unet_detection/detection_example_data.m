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

names={names(:).name};

mkdir('../res')


gpu=1;

ts=linspace(2,4,8);

ts=2.9;

for t_num=1:length(ts)
t=ts(t_num)

dice_res_ja=[];
fp=[];
fn=[];
dice_res_jarda=[];
dice_ja_jarda=[];


for img_num=1:20
    
    img_num;
    
    name=names{img_num};
    
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
    
    

    
    load(save_unet_foci_detection_res)
    
%     res_im=imread(name_mask_foci);
    res_im=imread(save_unet_foci_segmentation_res);
    
    tmp=imresize3(vys,size(res_im));
    
   
    res=regionprops3(res_im>0,'Centroid');
    res=res.Centroid;
    res=res(:,[1,2]);
    
    tmp=regionprops3(res_im>0,tmp,'MaxIntensity');
    tmp=tmp.MaxIntensity;
    tmp=tmp>t;

    res=res(tmp,:);
    
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
    
    
    med_dice=median(dice_res_ja);
    med_fp=median(fp);
    med_fn=median(fn);
    
    drawnow;
    
    
    
        
    [a,b,c]=read_3d_rgb_tif(name);
    [a,b,c]=preprocess_filters(a,b,c,gpu);
    rgb_2d=cat(3,norm_percentile(max(a,[],3),0.001),norm_percentile(max(b,[],3),0.001),norm_percentile(max(c,[],3),0.001));

    
    ms=10;
    
    lw=2;
    lwp=lw+1.5;
    figure(1)
    hold off
    imshow(rgb_2d)
    hold on
    if ~isempty(res)
        plot(res(:,1), res(:,2), 'kv','MarkerSize',ms,'LineWidth',lwp)
        plot(res(:,1), res(:,2), 'rv','MarkerSize',ms,'LineWidth',lw)
    end
    tmp=['../../res/detection_example_res' num2str(img_num) '_dice_' replace(num2str(dice_res_ja(end)),'.','_')];
    print_png_eps_svg(tmp)   
    
    
     figure(2)
    hold off
    imshow(rgb_2d)
    hold on
    if ~isempty(gt_ja)
        plot(gt_ja(:,1), gt_ja(:,2), 'k^','MarkerSize',ms,'LineWidth',lwp)
        plot(gt_ja(:,1), gt_ja(:,2), 'g^','MarkerSize',ms,'LineWidth',lw)
    end
    tmp=['../../res/detection_example_gt' num2str(img_num) '_dice_' replace(num2str(dice_res_ja(end)),'.','_')];
    print_png_eps_svg(tmp) 
    
     figure(3)
    hold off
    imshow(rgb_2d)
    hold on
    if ~isempty(res)
        plot(res(:,1), res(:,2), 'kv','MarkerSize',ms,'LineWidth',lwp)
        plot(res(:,1), res(:,2), 'rv','MarkerSize',ms,'LineWidth',lw)
    end
    if ~isempty(gt_ja)
        plot(gt_ja(:,1), gt_ja(:,2), 'k^','MarkerSize',ms,'LineWidth',lwp)
        plot(gt_ja(:,1), gt_ja(:,2), 'g^','MarkerSize',ms,'LineWidth',lw)
    end
    tmp=['../../res/detection_example_res_gt' num2str(img_num) '_dice_' replace(num2str(dice_res_ja(end)),'.','_')];
    print_png_eps_svg(tmp) 
    

    drawnow;
    
end

med_dice

figure(t_num)
y=[dice_res_ja',dice_res_jarda',dice_ja_jarda'];
boxplot(y,'Labels',{'Automatic vs Expert 1','Automatic vs Expert 2','Expert 1 vs Expert 2'})



ylabel('Dice coefficient')

mkdir('../../res')

print_png_eps_svg_fig('../../res/detection_dice_boxplot')


end






% 
% 
% 
% 
% t =
% 
%      1
% 
% 
% med_dice =
% 
%     0.6095
% 
% 
% t =
% 
%     1.2500
% 
% 
% med_dice =
% 
%     0.6349
% 
% 
% t =
% 
%     1.5000
% 
% 
% med_dice =
% 
%     0.6509
% 
% 
% t =
% 
%     1.7500
% 
% 
% med_dice =
% 
%     0.6536
% 
% 
% t =
% 
%      2
% 
% 
% med_dice =
% 
%     0.6742
% 
% 
% t =
% 
%     2.2500
% 
% 
% med_dice =
% 
%     0.6916
% 
% 
% t =
% 
%     2.5000
% 
% 
% med_dice =
% 
%     0.7059
% 
% 
% t =
% 
%     2.7500
% 
% 
% med_dice =
% 
%     0.7000
% 
% 
% t =
% 
%      3
% 
% 
% med_dice =
% 
%     0.7029
% 
% 
% t =
% 
%     3.2500
% 
% 
% med_dice =
% 
%     0.6667
% 
% 
% t =
% 
%     3.5000
% 
% 
% med_dice =
% 
%     0.6834
% 
% 
% t =
% 
%     3.7500
% 
% 
% med_dice =
% 
%     0.6464
% 
% 
% t =
% 
%      4
% 
% 
% med_dice =
% 
%     0.6519
% 
% 
% t =
% 
%     4.2500
% 
% 
% med_dice =
% 
%     0.5963
% 
% 
% t =
% 
%     4.5000
% 
% 
% med_dice =
% 
%     0.5533
% 
% 
% t =
% 
%     4.7500
% 
% 
% med_dice =
% 
%     0.5000
% 
% 
% t =
% 
%      5
% 
% 
% med_dice =
% 
%     0.4422
% 
% 
% t =
% 
%     5.2500
% 
% 
% med_dice =
% 
%     0.3494
% 
% 
% t =
% 
%     5.5000
% 
% 
% med_dice =
% 
%     0.3000
% 
% 
% t =
% 
%     5.7500
% 
% 
% med_dice =
% 
%     0.2146
% 
% 
% t =
% 
%      6
% 
% 
% med_dice =
% 
%    NaN
% 
% 
% t =
% 
%     6.2500