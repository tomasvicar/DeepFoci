clc;clear all;close all;
addpath('../utils')

load('../names_foci_sample.mat')
names_orig=names;

% names=subdir('..\example_folder\*3D_*.tif');
% names=subdir('Z:\CELL_MUNI\foky\new_foci_detection\example_folder\*3D_*.tif');
names=subdir('E:\foky_tmp\example_folder\*3D_*.tif');
% names=subdir('F:\example_folder\*3D_*.tif');
names={names(:).name};

gpu=1;


for img_num=12:200
    
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
    
    
    save_features=strrep(name,'3D_','features_norm_vals_');
    save_features=strrep(save_features,'.tif','.mat');
    

    
    [a,b,c]=read_3d_rgb_tif(name);


    [a,b,c]=preprocess_filters(a,b,c,gpu);

   

    
    
    
    perc=0.0001;
    
    global_a=[double(prctile(a(:),perc*100)) double(prctile(a(:),100-perc*100))];
    global_b=[double(prctile(b(:),perc*100)) double(prctile(b(:),100-perc*100))];
    global_c=[double(prctile(c(:),perc*100)) double(prctile(c(:),100-perc*100))];
    
      
    mask=imread(mask_name_split);


    mask_foci=imread(name_mask_foci)>0;
    lbl_foci=bwlabeln(mask_foci);

     
    clear mask_foci

    lbl_mask=bwlabeln(mask);
    lbl_mask=imresize3(lbl_mask,size(a),'nearest');
    
    tmp_cell_a={};
    tmp_cell_b={};
    tmp_cell_c={};
    
    perc=0.0001*0.01;
    
    N=max(lbl_mask(:));
    for k=1:N
        tmp_cell_a=[tmp_cell_a, [double(prctile(a(lbl_mask==k),perc*100)) double(prctile(a(lbl_mask==k),100-perc*100))]];
        tmp_cell_b=[tmp_cell_b, [double(prctile(b(lbl_mask==k),perc*100)) double(prctile(b(lbl_mask==k),100-perc*100))]];
        tmp_cell_c=[tmp_cell_c, [double(prctile(c(lbl_mask==k),perc*100)) double(prctile(c(lbl_mask==k),100-perc*100))]];
    end
    norm_vals = regionprops3(lbl_foci,lbl_mask,'MaxIntensity');
    norm_vals.Properties.VariableNames={'cellNum'};
    cell_nums=[norm_vals{:,:}];
    
    cell_nums(cell_nums==0)=1;
    
    global_a=repmat({global_a},[length(cell_nums),1]);
    global_b=repmat({global_b},[length(cell_nums),1]);
    global_c=repmat({global_c},[length(cell_nums),1]);
    
    norm_vals = addvars(norm_vals,global_a,'NewVariableNames','globalA');
    norm_vals = addvars(norm_vals,global_b,'NewVariableNames','globalB');
    norm_vals = addvars(norm_vals,global_c,'NewVariableNames','globalC');
    
    tmp=[tmp_cell_a(cell_nums)]';
    tmp=reshape(tmp,length(tmp),1);
    norm_vals = addvars(norm_vals,tmp,'NewVariableNames','cellA');
    tmp=[tmp_cell_b(cell_nums)]';
    tmp=reshape(tmp,length(tmp),1);
    norm_vals = addvars(norm_vals,tmp,'NewVariableNames','cellB');
    tmp=[tmp_cell_c(cell_nums)]';
    tmp=reshape(tmp,length(tmp),1);
    norm_vals = addvars(norm_vals,tmp,'NewVariableNames','cellC');
    
    
    save(save_features,'norm_vals')
    
    drawnow;
end
    