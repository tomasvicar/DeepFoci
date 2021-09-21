clc;clear all;close all force;
addpath('../utils')

% src_path = '..\..\data_test';
% dst_paht = '..\..\data_resave';
% gpu = 0;
% 
src_path = 'Z:\000000-My Documents\data_u87_nhdf_resaved';
dst_paht = 'Z:\000000-My Documents\data_u87_nhdf_resaved_for_training_norm_nofilters';
gpu = 1;


src_path = replace(src_path,'\','/');
dst_paht = replace(dst_paht,'\','/');



names_53BP1 = subdirx([src_path '/data_53BP1.tif']);


for img_num = 1:length(names_53BP1)
    
%     if img_num < 48
%         continue;
%     end

    disp([num2str(img_num) ' / ' num2str(length(names_53BP1))])
    
    name_53BP1 = names_53BP1{img_num};
    
    
    a = imread(name_53BP1);
    b = imread(replace(name_53BP1,'53BP1.tif','gH2AX.tif'));
    c = imread(replace(name_53BP1,'53BP1.tif','DAPI.tif'));
    
    lbls = jsondecode(fileread(replace(name_53BP1,'data_53BP1.tif','labels.json')));
    
    shape_old=size(a);
%     [a,b,c]=preprocess_filters(a,b,c,gpu);
    [a,b,c]=preprocess_resize_foci(a,b,c);
    shape_new=size(a);
    
    factor=shape_new./shape_old;

    
    
    positions_53BP1 = lbls.points_53BP1;
    positions_gH2AX = lbls.points_gH2AX;
    
    positions_53BP1_resize = round(positions_53BP1.*repmat(factor,[size(positions_53BP1,1),1]));
    positions_gH2AX_resize = round(positions_gH2AX.*repmat(factor,[size(positions_gH2AX,1),1]));
    
    
    
    mask_points_53BP1 = false(shape_new);
    mask_points_gH2AX = false(shape_new);
    
    shape_new_tmp = shape_new([2 1 3]);
    
    tmp = positions_53BP1_resize;
    if ~isempty(tmp)
        
        for k = 1:3
            tmp_tmp = tmp(:,k);
            tmp(tmp_tmp > shape_new_tmp(k),:) = [];
            tmp_tmp = tmp(:,k);
            tmp(tmp_tmp < 1 ,:) = [];
        end
        if ~isempty(tmp)
            positions_linear_53BP1 = sub2ind(shape_new,tmp(:,2),tmp(:,1),tmp(:,3));
            mask_points_53BP1(positions_linear_53BP1) = true;
        end
    end
    
    
    tmp = positions_gH2AX_resize;
    if ~isempty(tmp)
        
        for k = 1:3
            tmp_tmp = tmp(:,k);
            tmp(tmp_tmp > shape_new_tmp(k),:) = [];
            tmp_tmp = tmp(:,k);
            tmp(tmp_tmp < 1 ,:) = [];
        end
        if ~isempty(tmp)
            positions_linear_gH2AX = sub2ind(shape_new,tmp(:,2),tmp(:,1),tmp(:,3));
            mask_points_gH2AX(positions_linear_gH2AX) = true;
        end
    end
    

    perc = 0.0001;
    
    a_perc_0_0001 = [prctile(double(a(:)),perc*100) prctile(double(a(:)),100-perc*100)];
    a_std_mean = [std(double(a(:))) mean(double(a(:)))];
    
    b_perc_0_0001 = [prctile(double(b(:)),perc*100) prctile(double(b(:)),100-perc*100)];
    b_std_mean = [std(double(b(:))) mean(double(b(:)))];
    
    c_perc_0_0001 = [prctile(double(c(:)),perc*100) prctile(double(c(:)),100-perc*100)];
    c_std_mean = [std(double(c(:))) mean(double(c(:)))];
    
    
    name_53BP1 = replace(name_53BP1,'\','/');
    dst_folder = fileparts(replace(name_53BP1,src_path,dst_paht));
    
    mkdir(dst_folder)
     
    save_unet_foci_detection_mask_53BP1 = [dst_folder '/points_53BP1.mat'];
    save_unet_foci_detection_mask_gH2AX = [dst_folder '/points_gH2AX.mat'];
    
    save_unet_foci_detection_data_53BP1 = [dst_folder '/data_53BP1.mat']; 
    save_unet_foci_detection_data_gH2AX = [dst_folder '/data_gH2AX.mat'];
    save_unet_foci_detection_data_DAPI = [dst_folder '/data_DAPI.mat'];

    save(save_unet_foci_detection_data_53BP1,'a','a_perc_0_0001','a_std_mean','-v7.3')
    save(save_unet_foci_detection_data_gH2AX,'b','b_perc_0_0001','b_std_mean','-v7.3')
    save(save_unet_foci_detection_data_DAPI,'c','c_perc_0_0001','c_std_mean','-v7.3')
    
    
    save(save_unet_foci_detection_mask_53BP1,'mask_points_53BP1','-v7.3')
    save(save_unet_foci_detection_mask_gH2AX,'mask_points_gH2AX','-v7.3')
    

end
