clc;clear all;close all;
addpath('utils')
addpath('3DNucleiSegmentation_training')


% data_path = 'G:\Sdílené disky\martin_data\NHDF';
% save_path = 'G:\Sdílené disky\martin_data\NHDF_preprocess';
data_path = 'G:\Sdílené disky\martin_data\U87-MG';
save_path = 'G:\Sdílené disky\martin_data\U87-MG_preprocess';


gpu = 1;


file_names = subdir([data_path '/*01.ics']);

load('dice_rot_new.mat');
% net = tmp.net;
clear tmp;


for file_num = 1:length(file_names)
    
    file_name = file_names(file_num).name;


    [a,b,c]=read_ics_3_files(file_name);


    [af,bf,cf]=preprocess_filters(a,b,c,gpu);

%     [a,b,c]=preprocess_norm_resize(af,bf,cf);
% 
% 
%     mask=predict_by_parts(a,b,c,net);
% 
%     mask=split_nuclei(mask);
%     mask=balloon(mask,[20 20 8]);
% 
%     mask_conected=imerode(mask,sphere([5,5,2]));
%     mask=imresize3(uint8(mask),size(af),'nearest')>0;
% 
%     
%     save_name = replace(replace(file_name,data_path,save_path),'01.ics','mask.tif');
%     [save_path_tmp,~,~] = fileparts(save_name);
%     mkdir(save_path_tmp)
%     imwrite_uint16_3D(save_name,mask)
    
    save_name = replace(replace(file_name,data_path,save_path),'01.ics','mask.tif');
    [save_path_tmp,~,~] = fileparts(save_name);
    mask=imread(save_name);

    mask = bwlabeln(mask);
    bbs = regionprops3(mask,'BoundingBox');
    bbs = bbs.BoundingBox;
    
    for bb_num = 1:size(bbs,1)
        
        bb = bbs(bb_num,:);
        
        img_crop = apply_bb(cat(4,af,bf,cf),bb);
        mask_crop = apply_bb(cat(4,mask==bb_num),bb);
        img_crop = uint16(img_crop);

        
        
        rImg_main=max(img_crop(:,:,:,1),[],3);
        gImg_main=max(img_crop(:,:,:,2),[],3);
        bImg_main=max(img_crop(:,:,:,3),[],3);

        rImg_left=squeeze(max(img_crop(:,:,:,1),[],2));
        gImg_left=squeeze(max(img_crop(:,:,:,2),[],2));
        bImg_left=squeeze(max(img_crop(:,:,:,3),[],2));

        rImg_right=squeeze(max(img_crop(:,:,:,1),[],2));
        gImg_right=squeeze(max(img_crop(:,:,:,2),[],2));
        bImg_right=squeeze(max(img_crop(:,:,:,3),[],2));

        rImg_right=rImg_right(:,end:-1:1);
        gImg_right=gImg_right(:,end:-1:1);
        bImg_right=bImg_right(:,end:-1:1);

        rImg_down=squeeze(max(img_crop(:,:,:,1),[],1))';
        gImg_down=squeeze(max(img_crop(:,:,:,2),[],1))';
        bImg_down=squeeze(max(img_crop(:,:,:,3),[],1))';
        
        
        tmp = img_crop(:,:,:,1);
        p95_R = prctile(tmp(mask_crop),95);
        tmp = img_crop(:,:,:,2);
        p95_G = prctile(tmp(mask_crop),95);
        
        

        
        save([save_path_tmp '/cell' num2str(bb_num,'%03.f') '.mat'],'img_crop','mask_crop','bb',...
            'rImg_main','gImg_main','bImg_main',...
            'rImg_left','gImg_left','bImg_left',...
            'rImg_right','gImg_right','bImg_right',...
            'rImg_down','gImg_down','bImg_down',...
            'p95_R','p95_G','-v7.3')

        
    end
    
    
end




