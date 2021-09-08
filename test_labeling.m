clc;clear all;close all;
addpath('utils')

% path = 'G:\Sdílené disky\martin_data\NHDF_preprocess\NHDF_30min PI\IR 0,5Gy_30min PI';
path = 'G:\Sdílené disky\martin_data\RAD51_merge';


file_names = subdir([path '/cell_orig*.mat']);


for file_num = 1:length(file_names)
    
    name = file_names(file_num).name;
    tmp = load(replace(name,'cell_orig','cell'));
    
    img = tmp.img_crop(:,:,:,1);
    mask = tmp.mask_crop(:,:,:,1);
    

%     M = robust_3d_maxima_detector(img,[9 9 3],prctile(img(mask),98)-prctile(img(mask),80),prctile(img(mask),98));
    
    hold off
    imshow(max(img,[],3),[])
    hold on
    visboundaries(max(mask,[],3)>0)
    
    drawnow;
    
%     imshow(max(imregionalmax(img_crop(:,:,:,1)),[],3),[])
%     
%     imshow(imregionalmax(img_crop(:,:,:,1)),[])
%     
%     imshow( mat2gray(squeeze(max(img_crop,[],3))))
%     
%     imshow( mat2gray(squeeze(max(img_crop(:,:,:,1),[],3))))
    
    
end