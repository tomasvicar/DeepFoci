clc;clear all;close all;
addpath('utils')
addpath('3DNucleiSegmentation_training')


% path='Z:\999992-nanobiomed\Konfokal\18-11-19 - gH2AX jadra\data_vsichni_pacienti\tif_4times';
path='Z:\999992-nanobiomed\Konfokal\18-11-19 - gH2AX jadra\data_for_segmenttion_paper\data_ruzne_davky_tif';

gpu=1;


folders=dir(path);
folders_new={};
for k=3:length(folders)
    folders_new=[folders_new [path '/' folders(k).name]];
end
folders=folders_new;




for folder_num=1:length(folders)

    folder=folders{folder_num};
    
    disp([num2str(folder_num) '/' num2str(length(folders))])

    disp(folder)


    names=subdir([folder '/*3D*.tif']);
    names={names(:).name};


    load('dice_rot_new.mat')
    
    if folder_num<6
        continue
    end
        


    for img_num=1:length(names)
       img_num

       name=names{img_num};


       [a,b,c]=read_3d_rgb_tif(name);


       [af,bf,cf]=preprocess_filters(a,b,c,gpu);

       [a,b,c]=preprocess_norm_resize(af,bf,cf);

       mask=predict_by_parts(a,b,c,net);


       save_name=strrep(name,'3D_','mask_');
       save_name_split=strrep(name,'3D_','mask_split');
       
       save_control_seg=strrep(name,'3D_','control_seg_');
       save_control_seg=strrep(save_control_seg,'.tif','');


       imwrite_uint16_3D(save_name,mask)




       mask=split_nuclei(mask);
       mask=balloon(mask,[20 20 8]);
       shape=[5,5,2];
       [X,Y,Z] = meshgrid(linspace(-1,1,shape(1)),linspace(-1,1,shape(2)),linspace(-1,1,shape(3)));
       sphere=sqrt(X.^2+Y.^2+Z.^2)<1;
       mask_conected=imerode(mask,sphere);
       mask=imresize3(uint8(mask),size(af),'nearest')>0;
       
       
       
       imwrite_uint16_3D(save_name_split,mask)


       s = regionprops3(mask,"Centroid");
       centers = s.Centroid;


       mask2d=mask_2d_split(mask,3);
       rgb2d=cat(3,norm_percentile(mean(af,3),0.001),norm_percentile(mean(bf,3),0.001),norm_percentile(mean(cf,3),0.001));
    
       
       mask2d2=mask_2d_split(mask,2);
       rgb2d2=cat(3,norm_percentile(squeeze(mean(af,2)),0.001),norm_percentile(squeeze(mean(bf,2)),0.001),norm_percentile(squeeze(mean(cf,2)),0.001));
       
       
       mask2d1=mask_2d_split(mask,1);
       rgb2d1=cat(3,norm_percentile(squeeze(mean(af,1)),0.001),norm_percentile(squeeze(mean(bf,1)),0.001),norm_percentile(squeeze(mean(cf,1)),0.001));

       n=size(a,3);
       mask_corner=zeros([n,n]);
       rgb2d_corner=zeros([n,n,3]);
       
       tmp=cat(2,mask2d,mask2d2 );
       tmp2=cat(2,mask2d1',mask_corner);
       mask2d=cat(1,tmp,tmp2);
       
       
       tmp=cat(2,rgb2d,rgb2d2 );
       tmp2=cat(2,permute(rgb2d1,[2 1 3]),rgb2d_corner);
       rgb2d=cat(1,tmp,tmp2);
       
       close all;
       imshow(rgb2d)
       hold on
       visboundaries(mask2d,'LineWidth',0.5,'Color','g','EnhanceVisibility',0)
       drawnow()
       print(save_control_seg,'-dpng')


    end
    
end






