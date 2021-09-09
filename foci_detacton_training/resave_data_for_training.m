clc;clear all;close all force;
addpath('../utils')

src_path = '..\..\data_test';
dst_paht = '..\..\data_resave';
gpu = 0;


src_path = replace(src_path,'\','/');
dst_paht = replace(dst_paht,'\','/');



names_53BP1 = subdirx([src_path '/data_53BP1.tif']);


for img_num = 1:length(names_53BP1)

    disp([num2str(img_num) ' / ' num2str(length(names_53BP1))])
    
    name_53BP1 = names_53BP1{img_num};
    
    
    a = imread(name_53BP1);
    b = imread(replace(name_53BP1,'53BP1.tif','gH2AX.tif'));
    c = imread(replace(name_53BP1,'53BP1.tif','DAPI.tif'));
    
    lbls = jsondecode(fileread(replace(name_53BP1,'data_53BP1.tif','labels.json')));
    
    shape_old=size(a);
    [a,b,c]=preprocess_filters(a,b,c,gpu);
    [a,b,c]=preprocess_resize_foci(a,b,c);
    shape_new=size(a);
    
    factor=shape_new./shape_old;

    
    
    positions_53BP1 = lbls.points_53BP1;
    positions_gH2AX = lbls.points_gH2AX;
    
    positions_53BP1_resize = round(positions_53BP1.*repmat(factor,[size(positions_53BP1,1),1]));
    positions_gH2AX_resize = round(positions_gH2AX.*repmat(factor,[size(positions_gH2AX,1),1]));
    
    
    
    mask_points_53BP1 = false(shape_new);
    mask_points_gH2AX = false(shape_new);
    
    
    positions_linear_53BP1 = sub2ind(shape_new,positions_53BP1_resize(:,2),positions_53BP1_resize(:,1),positions_53BP1_resize(:,3));
    mask_points_53BP1(positions_linear_53BP1) = true;
    
    positions_linear_gH2AX = sub2ind(shape_new,positions_gH2AX_resize(:,2),positions_gH2AX_resize(:,1),positions_gH2AX_resize(:,3));
    mask_points_gH2AX(positions_linear_gH2AX) = true;
    
    name_53BP1 = replace(name_53BP1,'\','/');
    dst_folder = fileparts(replace(name_53BP1,src_path,dst_paht));
    
    mkdir(dst_folder)
     
    save_unet_foci_detection_mask_53BP1 = [dst_folder '/points_53BP1.mat'];
    save_unet_foci_detection_mask_gH2AX = [dst_folder '/points_gH2AX.mat'];
    
    save_unet_foci_detection_data_53BP1 = [dst_folder '/data_53BP1.mat']; 
    save_unet_foci_detection_data_gH2AX = [dst_folder '/data_gH2AX.mat'];
    save_unet_foci_detection_data_DAPI = [dst_folder '/data_DAPI.mat'];

    save(save_unet_foci_detection_data_53BP1,'a','-v7.3')
    save(save_unet_foci_detection_data_gH2AX,'b','-v7.3')
    save(save_unet_foci_detection_data_DAPI,'c','-v7.3')
    
    
    save(save_unet_foci_detection_mask_53BP1,'mask_points_53BP1','-v7.3')
    save(save_unet_foci_detection_mask_gH2AX,'mask_points_gH2AX','-v7.3')
    

end
