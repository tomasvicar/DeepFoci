clc;clear all;close all;
addpath('utils')
addpath('3DNucleiSegmentation_training')
addpath('unet_detection')

gpu=1;

% path='Z:\999992-nanobiomed\Konfokal\18-11-19 - gH2AX jadra\data_vsichni_pacienti\tif_4times';
% path='Z:\999992-nanobiomed\Konfokal\18-11-19 - gH2AX jadra\data_for_segmenttion_paper\data_ruzne_davky_tif';
path='Z:\999992-nanobiomed\Konfokal\18-11-19 - gH2AX jadra\data_for_segmenttion_paper\dva_pacienti_tif';


load('unet_detection/test3_value_aug_mult')


folders=dir(path);
folders_new={};
for k=3:length(folders)
    folders_new=[folders_new [path '/' folders(k).name]];
end
folders=folders_new;

folders=sort(folders);


for folder_num=1:length(folders)
    
    
    folder=folders{folder_num};

    
    disp([num2str(folder_num) '/' num2str(length(folders))])

    disp(folder)


    names=subdir([folder '/*3D*.tif']);
    names={names(:).name};


    length(names)
    for img_num=1:length(names)
        img_num
    
        name=names{img_num};


        name_mask=strrep(name,'3D_','mask_');
        mask_name_split=strrep(name,'3D_','mask_split');

        name_mask_foci=strrep(name,'3D_','mask_foci_');


        save_control_seg=strrep(name,'3D_','control_seg_foci');
        save_control_seg=strrep(save_control_seg,'.tif','');

        
        save_unet_foci_detection_res=strrep(name,'3D_','unet_foci_detection_res');
        save_unet_foci_detection_res=strrep(save_unet_foci_detection_res,'.tif','.mat');
        
        
        save_unet_foci_detection_res_points=strrep(name,'3D_','unet_foci_detection_res_points');
        save_unet_foci_detection_res_points=strrep(save_unet_foci_detection_res_points,'.tif','.mat');
        
        
        [a,b,c]=read_3d_rgb_tif(name);
         
        shape0=size(a);


        [a,b,c]=preprocess_filters(a,b,c,gpu);
        
        close all;
        
        imshow(max(a,[],3),[])

        [a,b,c]=preprocess_norm_resize_foci(a,b,c);

        shape1=size(a);
        
        factor=shape0./shape1;
        
        

        
        vys=predict_by_parts_detection(a,b,c,net);

        save(save_unet_foci_detection_res,'vys')
        
        h=0.3;
        d=12;
        t=1;


        [X,Y,Z] = meshgrid(linspace(-1,1,d),linspace(-1,1,d),linspace(-1,1,int16(d/3)));
        sphere=sqrt(X.^2+Y.^2+Z.^2)<1;

        tmp=imdilate(vys,sphere);
        tmp = imhmax(tmp,h);
        tmp = imregionalmax(tmp).*(vys>t);

        s = regionprops(tmp>0,'centroid');
        centroids = round(cat(1, s.Centroid));

        if isempty(centroids)
           centroids=zeros(0,3);
        end
        
        centroids(:,1)=centroids(:,1)*factor(1);
        centroids(:,2)=centroids(:,2)*factor(2);
        centroids(:,3)=centroids(:,3)*factor(3);
        
        
        hold on
        
        plot(centroids(:,1), centroids(:,2), 'ro','MarkerSize',3)
        plot(centroids(:,1), centroids(:,2), 'g*','MarkerSize',3)
        
        
        unet_foci_detection_res_points=centroids;
       
         
        
        
        save(save_unet_foci_detection_res_points,'unet_foci_detection_res_points')
        
        
        
    end


end






