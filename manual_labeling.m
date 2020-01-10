clc;clear all;close all force;
addpath('utils')
addpath('3DNucleiSegmentation_training')
addpath('semiauto_klicker')

load('names_foci_sample.mat')
names_orig=names;

names=subdir('E:\foky_tmp\example_folder\*3D_*.tif');
% names=subdir('Z:\CELL_MUNI\foky\new_foci_detection\example_folder\*3D_*.tif');
names={names(:).name};

gpu=1;


for img_num=182:length(names)
    
    img_num
    
    name=names{img_num};
    
    name_orig=names_orig{img_num};
    
    name_mask=strrep(name,'3D_','mask_');
    
    name_mask_foci=strrep(name,'3D_','mask_foci_');
    
    
    save_control_seg=strrep(name,'3D_','control_seg');
    save_control_seg=strrep(save_control_seg,'.tif','');
    
    
    save_manual_label=strrep(name,'3D_','manual_label_');
    save_manual_label=strrep(save_manual_label,'.tif','.mat');
    
    
    
    [a,b,c]=read_3d_rgb_tif(name);
    
%     mask=read_mask(name_mask);
%     mask=split_nuclei(mask);
%     mask=balloon(mask,[20 20 8]);
%     shape=[5,5,2];
%     [X,Y,Z] = meshgrid(linspace(-1,1,shape(1)),linspace(-1,1,shape(2)),linspace(-1,1,shape(3)));
%     sphere=sqrt(X.^2+Y.^2+Z.^2)<1;
%     mask_conected=imerode(mask,sphere);
%     mask=imresize3(uint8(mask),size(a),'nearest')>0;
    

    [a,b,c]=preprocess_filters(a,b,c,gpu);
    
    rgb_2d=cat(3,norm_percentile(mean(a,3),0.001),norm_percentile(mean(b,3),0.001),norm_percentile(mean(c,3),0.001));
    
    
    mask_foci=imread(name_mask_foci);
    
    clear labels
    clear positions
    semiauto_appdes(a, b, c, zeros(size(mask_foci)), mask_foci,names_orig{img_num})
    
    save(save_manual_label,'labels','positions')
    
    drawnow
    
end
    
    
    
    
    
    