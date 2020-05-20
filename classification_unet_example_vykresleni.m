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

load('unet_detection/test3_value_aug_mult.mat')




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
    
    name_2D=strrep(name,'3D_','2D_');
    
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
    
    
    
    
    save_unet_foci_detection_mask=strrep(name,'3D_','unet_foci_detection_mask');
    save_unet_foci_detection_mask=strrep(save_unet_foci_detection_mask,'.tif','.mat');
    
    
    save_unet_foci_detection_data=strrep(name,'3D_','unet_foci_detection_data');
    save_unet_foci_detection_data=strrep(save_unet_foci_detection_data,'.tif','.mat');
    
    
    save_unet_foci_detection_res=strrep(name,'3D_','unet_foci_detection_res');
    save_unet_foci_detection_res=strrep(save_unet_foci_detection_res,'.tif','.mat');
    
    save_unet_foci_detection_res_example=strrep(name,'3D_','unet_foci_detection_res_example');
    save_unet_foci_detection_res_example=strrep(save_unet_foci_detection_res_example,'.tif','');
    
    

    if img_num<240
        

    else
        
        load(save_unet_foci_detection_res)
        
        rgb_2d=imread(name_2D);
        
        rgb_2d=cat(3,norm_percentile(rgb_2d(:,:,1),0.005),norm_percentile(rgb_2d(:,:,2),0.005),norm_percentile(rgb_2d(:,:,3),0.005));
        
        
        rgb_2d=imresize(rgb_2d,[size(vys,1) size(vys,2)]);
        
        h=0.3;
        d=12;
        t=1;

        load(save_unet_foci_detection_res)

        [X,Y,Z] = meshgrid(linspace(-1,1,d),linspace(-1,1,d),linspace(-1,1,int16(d/3)));
        sphere=sqrt(X.^2+Y.^2+Z.^2)<1;

        tmp=imdilate(vys,sphere);
        tmp = imhmax(tmp,h);
        tmp = imregionalmax(tmp).*(vys>t);

        detection_results=false(size(tmp));
        s = regionprops(tmp>0,'centroid');
        centroids = round(cat(1, s.Centroid));
        for kp=1:size(centroids,1)
            detection_results(centroids(kp,2),centroids(kp,1),centroids(kp,3))=1;
        end


        s = regionprops(mask_points_foci>0,'centroid');
        centroids_gt = round(cat(1, s.Centroid));
        if isempty(centroids)
           centroids=zeros(0,3);
        end
        
        
        
        
        close all
        imshow(rgb_2d)
        hold on
        
        plot(centroids(:,1), centroids(:,2), 'ro','MarkerSize',3)
        plot(centroids(:,1), centroids(:,2), 'g*','MarkerSize',3)
        
        print(save_unet_foci_detection_res_example,'-dpng')
        drawnow;
        
    end
    
    
end

avg_acc=[];
for k = 1:max(cels_nums)
    
    tmp_res=res(cels_nums==k);
    tmp_gt=gt(cels_nums==k);
    avg_acc=[avg_acc,sum((tmp_res>0.5)==tmp_gt)/numel(tmp_gt)];
    
end

nanmean(avg_acc)