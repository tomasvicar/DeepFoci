clc;clear all;close all;
addpath('utils')


data_path = 'G:\Sdílené disky\martin_data\NHDF\NHDF_8h PI\IR 0,5Gy_8h PI';

path_save = 'G:\Sdílené disky\martin_data\NHDF\NHDF_8h PI\IR 0,5Gy_8h PI_labeled';



file_names = subdir([data_path '/*01.ics']);

tmp = load('dice_rot_new.mat');
net = tmp.net;
clear tmp;


for file_num = 1
    
    file_name = file_names(file_num).name;


    [a,b,c]=read_3d_rgb_tif(file_name);


    [af,bf,cf]=preprocess_filters(a,b,c,gpu);

    [a,b,c]=preprocess_norm_resize(af,bf,cf);


    mask=predict_by_parts(a,b,c,net);

    mask=split_nuclei(mask);
    mask=balloon(mask,[20 20 8]);

    mask_conected=imerode(mask,sphere([5,5,2]));
    mask=imresize3(uint8(mask),size(af),'nearest')>0;

    imshow5(mask)
   
   
    
    
end