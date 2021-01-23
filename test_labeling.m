clc;clear all;close all;
addpath('utils')

path = 'G:\Sdílené disky\martin_data\NHDF_preprocess\NHDF_30min PI\IR 0,5Gy_30min PI';


file_names = subdir([path '/cell*.mat']);


for file_num = 1%:length(file_names)
    
    tmp = load(file_names(file_num).name);
    
    img = tmp.img_crop(:,:,:,1);
    mask = tmp.mask_crop(:,:,:,1);
    

    M = robust_3d_maxima_detector(img,[9 9 3],prctile(img(mask),98)-prctile(img(mask),80),prctile(img(mask),98));
    
    figure;
    imshow(max(M,[],3),[])
    figure
    imshow(max(img,[],3),[])
    
    drawnow;
    
%     imshow(max(imregionalmax(img_crop(:,:,:,1)),[],3),[])
%     
%     imshow(imregionalmax(img_crop(:,:,:,1)),[])
%     
%     imshow( mat2gray(squeeze(max(img_crop,[],3))))
%     
%     imshow( mat2gray(squeeze(max(img_crop(:,:,:,1),[],3))))
    
    
end