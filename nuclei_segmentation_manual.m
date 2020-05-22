clc;clear all;close all;
addpath('utils')
addpath('3DNucleiSegmentation_training')

% load('names_foci_sample.mat')
% names_orig=names;

% names=subdir('..\example_folder\*3D_*.tif');
% names=subdir('Z:\CELL_MUNI\foky\new_foci_detection\example_folder\*3D_*.tif');
% names=subdir('E:\foky_tmp\example_folder\*3D_*.tif');
% names=subdir('F:\example_folder\*3D_*.tif');
% names=subdir('Z:\999992-nanobiomed\Konfokal\18-11-19 - gH2AX jadra\data_vsichni_pacienti\example_folder_used\*3D_*.tif');
names=subdir('E:\foky_tmp\man_nahodny_vzorek_tif\*data_*.tif');
names={names(:).name};

gpu=1;

load('dice_rot_new.mat')

for img_num=1:100
    
    img_num
    
    name=names{img_num};
    
%     name_orig=names_orig{img_num};
    
    name_mask=strrep(name,'data_','mask_');
    mask_name_split=strrep(name,'data_','mask_split');

   


  


   [a,b,c]=read_3d_rgb_tif(name);
   
   a=a(:,:,[2,4:end]);
   b=b(:,:,[2,4:end]);
   c=c(:,:,[2,4:end]);

   shape0=size(a) ;
   
   [a,b,c]=preprocess_filters(a,b,c,gpu);

   [a,b,c]=preprocess_norm_resize(a,b,c);

   mask=predict_by_parts(a,b,c,net);


   save_name=strrep(name,'data_','mask_');
   save_name_split=strrep(name,'data_','mask_split');

   save_control_seg=strrep(name,'data_','control_seg_');
   save_control_seg=strrep(save_control_seg,'.tif','');


   imwrite_uint16_3D(save_name,mask)




   mask=split_nuclei(mask);
   mask=balloon(mask,[20 20 8]);
   shape=[5,5,2];
   [X,Y,Z] = meshgrid(linspace(-1,1,shape(1)),linspace(-1,1,shape(2)),linspace(-1,1,shape(3)));
   sphere=sqrt(X.^2+Y.^2+Z.^2)<1;
   mask_conected=imerode(mask,sphere);
   mask=imresize3(uint8(mask),shape0,'nearest')>0;



   imwrite_uint16_3D(save_name_split,mask)


   mask=imresize3(bwlabeln(mask),size(a),'nearest');
   
   s = regionprops3(mask,"Centroid");
   centers = s.Centroid;
   mask=mask>0;


   mask2d=mask_2d_split(mask,3);
   rgb2d=cat(3,norm_percentile(mean(a,3),0.001),norm_percentile(mean(b,3),0.001),norm_percentile(mean(c,3),0.001));


   mask2d2=mask_2d_split(mask,2);
   rgb2d2=cat(3,norm_percentile(squeeze(mean(a,2)),0.001),norm_percentile(squeeze(mean(b,2)),0.001),norm_percentile(squeeze(mean(c,2)),0.001));


   mask2d1=mask_2d_split(mask,1);
   rgb2d1=cat(3,norm_percentile(squeeze(mean(a,1)),0.001),norm_percentile(squeeze(mean(b,1)),0.001),norm_percentile(squeeze(mean(c,1)),0.001));

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
   visboundaries(mask2d>0,'LineWidth',0.5,'Color','g','EnhanceVisibility',0)
   drawnow()
   print(save_control_seg,'-dpng')
    
end






