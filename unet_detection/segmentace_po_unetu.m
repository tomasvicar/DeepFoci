clc;clear all;close all force;
% dbstop if error
% dbclear if error
addpath('../utils')
addpath('../3DNucleiSegmentation_training')

load('../names_foci_sample.mat')
names_orig=names;

% names=subdir('../..\example_folder\*3D_*.tif');
% names=subdir('Z:\CELL_MUNI\foky\new_foci_detection\example_folder\*3D_*.tif');
% names=subdir('E:\foky_tmp\example_folder\*3D_*.tif');
% names=subdir('F:\example_folder\*3D_*.tif');
names=subdir('Z:\999992-nanobiomed\Konfokal\18-11-19 - gH2AX jadra\data_vsichni_pacienti\example_folder_used\*3D_*.tif');
names={names(:).name};


gpu=1;

load('test3_value_aug_mult.mat')

tp=0;
fp=0;
fn=0;
for img_num=1:300
    
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
    
    
%     save_features=strrep(name,'3D_','features_window_');
    save_features=strrep(name,'3D_','features_window2_');
    save_features=strrep(save_features,'.tif','.mat');


    save_features_for_celnum=strrep(name,'3D_','features_cellnum_');
    save_features_for_celnum=strrep(save_features_for_celnum,'.tif','.mat');
    
    
    save_unet_foci_detection_mask=strrep(name,'3D_','unet_foci_detection_mask');
    save_unet_foci_detection_mask=strrep(save_unet_foci_detection_mask,'.tif','.mat');
    
    
    save_unet_foci_detection_data=strrep(name,'3D_','unet_foci_detection_data');
    save_unet_foci_detection_data=strrep(save_unet_foci_detection_data,'.tif','.mat');
    
    
    save_unet_foci_detection_res=strrep(name,'3D_','unet_foci_detection_res');
    save_unet_foci_detection_res=strrep(save_unet_foci_detection_res,'.tif','.mat');
    
    
    

    if img_num<240
        
    else
    
        load(save_unet_foci_detection_res_points)
        
        
        [a,b,c]=read_3d_rgb_tif(name);


        mask=imread(mask_name_split);

        [a,b,c]=preprocess_filters(a,b,c,gpu);

        rgb_2d=cat(3,norm_percentile(mean(a,3),0.001),norm_percentile(mean(b,3),0.001),norm_percentile(mean(c,3),0.001));



        a=norm_percentile(a,0.00001);
        b=norm_percentile(b,0.00001);
        
        ab=a.*b;
        ab_uint_whole=uint8(mat2gray(ab)*255).*uint8(mask);
        clear a b ab c

        result=zeros(size(ab_uint_whole),'uint16');

        
        s = regionprops(mask>0,'BoundingBox');
        bbs = cat(1,s.BoundingBox);
        
        
         for cell_num =1:size(bbs,1)

            bb=round(bbs(cell_num,:));
            ab_uint = ab_uint_whole(bb(2):bb(2)+bb(5)-1,bb(1):bb(1)+bb(4)-1,bb(3):bb(3)+bb(6)-1);

            tic
            %    try
            r=vl_mser(ab_uint,'MinDiversity',0.1,...
                'MaxVariation',0.8,...
                'Delta',1,...
                'MinArea', 50/ numel(ab_uint),...
                'MaxArea',2400/ numel(ab_uint));
            %     catch
            %         r=[] ;
            %     end

            M = zeros(size(ab_uint),'uint16') ;
            for x=1:length(r)
                s = vl_erfill(ab_uint,r(x)) ;
                M(s) = M(s) + 1;
            end

            shape=[9,9,3];
            [X,Y,Z] = meshgrid(linspace(-1,1,shape(1)),linspace(-1,1,shape(2)),linspace(-1,1,shape(3)));
            sphere=sqrt(X.^2+Y.^2+Z.^2)<1;

            dilated=imdilate(ab_uint,sphere);
            ab_maxima=imregionalmax(dilated);

            s = regionprops(ab_maxima>0,'Centroid');
            maxima = round(cat(1, s.Centroid));
            ab_maxima=false(size(ab_maxima)) ;
            for k=1:size(maxima,1)
                ab_maxima(maxima(k,2),maxima(k,1),maxima(k,3)) =1;
            end

            pom=-double(ab_uint);
            pom=imimposemin(pom,ab_maxima);
            wab_krajeny=watershed(pom)>0;
            wab_krajeny(M==0)=0;
            wab_krajeny=imfill(wab_krajeny,'holes');

            toc

            result(bb(2):bb(2)+bb(5)-1,bb(1):bb(1)+bb(4)-1,bb(3):bb(3)+bb(6)-1)=wab_krajeny;


        end

        wab_krajeny=result;

       
    end
    
end