clc;clear all;close all;
addpath('utils')
addpath('3DNucleiSegmentation_training')


% data_path = 'G:\Sdílené disky\martin_data\NHDF';
% save_path = 'G:\Sdílené disky\martin_data\NHDF_preprocess';
% data_path = 'G:\Sdílené disky\martin_data\U87-MG';
% save_path = 'G:\Sdílené disky\martin_data\U87-MG_preprocess';

% data_path = 'G:\Sdílené disky\martin_data\U87-MG';
% save_path = 'G:\Sdílené disky\martin_data\U87-MG_merge2';

data_path = 'G:\Sdílené disky\martin_data\RAD51';
save_path = 'G:\Sdílené disky\martin_data\RAD51_merge';


gpu = 1;


file_names = subdir([data_path '/*02.ics']);






load('dice_rot_new.mat');
% net = tmp.net;
clear tmp;


for file_num = 1:20:length(file_names)
    
    file_name = file_names(file_num).name;


%     [a,b,c]=read_ics_3_files(file_name);
    [a,c]=read_ics_2_files(file_name);
    b = a;


    [af,bf,cf]=preprocess_filters(a,b,c,gpu);

    [a_tmp,b_tmp,c_tmp]=preprocess_norm_resize(af,bf,cf);


    mask=predict_by_parts(a_tmp,b_tmp,c_tmp,net);

    mask=split_nuclei(mask);
    mask=balloon(mask,[20 20 8]);

    mask_conected=imerode(mask,sphere([5,5,2]));
    mask=imresize3(uint8(mask),size(af),'nearest')>0;

    
    save_name = replace(replace(replace(file_name,data_path,save_path),'01.ics','mask.tif'),'02.ics','mask.tif');
    [save_path_tmp,~,~] = fileparts(save_name);
    mkdir(save_path_tmp)
    

    hold off
    imshow(max(c,[],3),[])
    hold on
    visboundaries(max(mask,[],3)>0)
    title(file_name)
    drawnow;
    print(['../kontrola/' num2str(file_num)],'-dpng')
    
    
end




