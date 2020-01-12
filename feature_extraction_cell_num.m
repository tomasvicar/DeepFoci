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




for img_num=170:300
    
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
    
    
    save_features=strrep(name,'3D_','features_cellnum_');
    save_features=strrep(save_features,'.tif','.mat');
    
    
    [a,b,~]=read_3d_rgb_tif(name);
    
    mask=read_mask(name_mask);
    mask=split_nuclei(mask);
    mask=balloon(mask,[20 20 8]);
    shape=[5,5,2];
    [X,Y,Z] = meshgrid(linspace(-1,1,shape(1)),linspace(-1,1,shape(2)),linspace(-1,1,shape(3)));
    sphere=sqrt(X.^2+Y.^2+Z.^2)<1;
    mask_conected=imerode(mask,sphere);
    mask=imresize3(uint8(mask),size(a),'nearest')>0;
     
     
     mask_foci=imread(name_mask_foci)>0;
     
     lbl_foci=bwlabeln(mask_foci);
     
     clear mask_foci
     
     lbl_mask=bwlabeln(mask);
     
     
     cell_num = regionprops3(lbl_foci,lbl_mask,'MaxIntensity');
     cell_num.Properties.VariableNames={'cellNum'};

    save(save_features,'cell_num')
    
    
    

end
    
    
    
