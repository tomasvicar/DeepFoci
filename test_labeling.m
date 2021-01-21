clc;clear all;close all;
addpath('utils')

path = 'G:\Sdílené disky\martin_data\NHDF_preprocess\NHDF_8h PI\IR 0,5Gy_8h PI';


file_names = subdir([path '/cell*.mat']);


for file_num = 1%:length(file_names)
    
    load(file_names(file_num).name)
    
    img = img_crop(:,:,:,1);
    
    M = robust_3d_maxima_detector(img,[9 9 3],0,prctile(img(:),98));
    
     imshow(max(M,[],3),[])
    
    
    
    imshow(max(imregionalmax(img_crop(:,:,:,1)),[],3),[])
    
    imshow(imregionalmax(img_crop(:,:,:,1)),[])
    
    imshow( mat2gray(squeeze(max(img_crop,[],3))))
    
    imshow( mat2gray(squeeze(max(img_crop(:,:,:,1),[],3))))
    
    
end