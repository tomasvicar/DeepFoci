clc;clear all;close all force;
addpath('../utils')

% src_path = '..\..\data_test';
% dst_paht = '..\..\data_resave';
% gpu = 0;

src_path = 'C:\Data\Vicar\foci_new\data_u87_nhdf_resaved';
dst_paht = 'C:\Data\Vicar\foci_new\data_u87_nhdf_resaved_foci_seg';

gpu = 1;


src_path = replace(src_path,'\','/');
dst_paht = replace(dst_paht,'\','/');


names_53BP1 = subdirx([src_path '/data_53BP1.tif']);



for img_num = 1:length(names_53BP1)


    name_53BP1 = names_53BP1{img_num};
    
    
    a = imread(name_53BP1);
    b = imread(replace(name_53BP1,'53BP1.tif','gH2AX.tif'));

    mask = imread(replace(name_53BP1,'data_53BP1.tif','mask.tif'));
    
    
    
    drawnow;
end