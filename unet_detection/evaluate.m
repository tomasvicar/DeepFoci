clc;clear all;close all force;
% dbstop if error
% dbclear if error
addpath('../utils')
addpath('../3DNucleiSegmentation_training')

load('../names_foci_sample.mat')
names_orig=names;

% names=subdir('../..\example_folder\*3D_*.tif');
% names=subdir('Z:\CELL_MUNI\foky\new_foci_detection\example_folder\*3D_*.tif');
% names=subdir('E:\foky_tmp\example_folder\*3D_*.tif');
% names=subdir('F:\example_folder\*3D_*.tif');
names=subdir('Z:\999992-nanobiomed\Konfokal\18-11-19 - gH2AX jadra\data_vsichni_pacienti\example_folder_used\*3D_*.tif');
names={names(:).name};


gpu=1;

load('test3_value_aug_mult.mat')

tp=0;
fp=0;
fn=0;
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
    
    
%     save_features=strrep(name,'3D_','features_window_');
    save_features=strrep(name,'3D_','features_window2_');
    save_features=strrep(save_features,'.tif','.mat');


    save_features_for_celnum=strrep(name,'3D_','features_cellnum_');
    save_features_for_celnum=strrep(save_features_for_celnum,'.tif','.mat');
    
    
    save_unet_foci_detection_mask=strrep(name,'3D_','unet_foci_detection_mask');
    save_unet_foci_detection_mask=strrep(save_unet_foci_detection_mask,'.tif','.mat');
    
    
    save_unet_foci_detection_data=strrep(name,'3D_','unet_foci_detection_data');
    save_unet_foci_detection_data=strrep(save_unet_foci_detection_data,'.tif','.mat');
    
    
    save_unet_foci_detection_res=strrep(name,'3D_','unet_foci_detection_res');
    save_unet_foci_detection_res=strrep(save_unet_foci_detection_res,'.tif','.mat');
    
    
    

    if img_num<240
        
    else
    
       h=0.5;
       d=15;
       t=1.4;

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
       
       d_t=10;
       
       if isempty(centroids)
           centroids=zeros(0,3);
       end
       if isempty(centroids_gt)
           centroids_gt=zeros(0,3);
       end
       
       D = pdist2(centroids,centroids_gt);
       
       
       D(D>d_t)=Inf;
       
       [assignment,cost]=munkres(D);
       
       fp=fp+sum(assignment==0);
       
       assignment(assignment==0)=[];
       
       tp=tp+length(assignment);
       
       ass_2 = 1:length(centroids_gt);
       
       ass_2(assignment)=[];
        
       
       fn=fn+length(ass_2);
        
       acc=tp/(tp+fp+fn)
       
       tp
       
       fp
       
       fn
       
    end
    
end