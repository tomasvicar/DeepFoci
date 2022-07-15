clc;clear all; close all force;
addpath('utils')
addpath('../utils')


mkdir('../../res')

% 
folder1='../../3d_segmentace_data/data_na_labely';
folder2='../../3d_segmentace_data/data_na_labely2';



names1=subdir([folder1 '/mask_norm_*']);
names1={names1.name};

names2=subdir([folder2 '/mask_norm_*']);
names2={names2.name};

names=[names1 names2];

% 
% folder1='../../3d_segmentace_data/trenovaci_data_3';
% names=subdir([folder1 '/mask_norm_*']);
% names={names.name};


rng(1)

p = randperm(length(names));

names=names(p);


test_id=1:20;
valid_id=21:30;
train_id=41:1000;



load('dice_rot_new.mat')



segs=[];



for kkk=[test_id,valid_id]
    kkk
    
    name_mask=names{kkk};
    name=strrep(name_mask,'\mask_norm_','\data_');

    
    

    
    [a,b,c]=read_3d_rgb_tif(name);


   [af,bf,cf]=preprocess_filters(a,b,c,1);

   [a,b,c]=preprocess_norm_resize(af,bf,cf);

    vys=predict_by_parts(a,b,c,net);

   
   
    info=imfinfo(name_mask);
    mask=zeros(info(1).Height,info(1).Width,length(info));
    for k=1:length(info)
        rgb=imread(name_mask,k);
        mask(:,:,k)=rgb;
    end
    mask_full_size=mask;
    
    mask=imresize3(mask,[337  454   48],'nearest');
    
    
    vel=[13 13 5];
    [X,Y,Z] = meshgrid(linspace(-1,1,vel(1)),linspace(-1,1,vel(2)),linspace(-1,1,vel(3)));
    sphere=sqrt(X.^2+Y.^2+Z.^2)<1;
    
    
    mask_tmp=zeros(size(mask))>0;
    mask_tmp2=uint8(zeros(size(mask)));
    for k=1:4
        cells0=mask==k;
        cells=imerode(imclose(cells0,sphere),sphere);
%         imshow4(cat(2,cells,cells0))

        cells = bwareaopen(cells,6000);

        mask_tmp(cells)=1;
        mask_tmp2(imdilate(cells,sphere))=2;
    end
    mask_tmp2(mask_tmp>0)=1;
    mask=mask_tmp2;
    
    
    mask(mask==2)=0;
    
    mask=balloon(mask>0,[20 20 8]);
    
    
    vys=split_nuclei_hard(vys);

    vys=balloon(vys,[20 20 8]);
    
    
    
    
    data_to_save=uint16(cat(4,af,bf,cf));
    vys_to_save=imresize3(uint16(vys*255),size(af),'nearest');
    mask_to_save=imresize3(uint16(mask*255),size(af),'nearest');
    
    seg=seg_3d(vys,mask>0);
    segs=[segs seg];
    
    imwrite_uint16_4D(['../../res/segmentation_example_3ddata_' num2str(kkk) '_seg_' replace(num2str(seg),'.','_')],data_to_save)
    imwrite_uint16_3D(['../../res/segmentation_example_3dres_' num2str(kkk) '_seg_' replace(num2str(seg),'.','_')],vys_to_save)
    imwrite_uint16_3D(['../../res/segmentation_example_3dgt_' num2str(kkk) '_seg_' replace(num2str(seg),'.','_')],mask_to_save)
    

    
    
    slice=mean(cf(:,:,22:28),3);
    
    slice=mat2gray(slice,[prctile(slice(:),1),prctile(slice(:),99)]);
    shape=size(slice);
    rgb_slice=cat(3,zeros(size(slice)),zeros(size(slice)),slice);
    res_slice=vys(:,:,25);
    gt_slice=mask(:,:,25);
    
    res_slice=imresize(res_slice,shape,'nearest');
    gt_slice=imresize(gt_slice,shape,'nearest');
    res_slice=bwareaopen(res_slice,100);
    
    figure(1);
    hold off
    imshow(rgb_slice)
    hold on
    visboundaries(res_slice,'Color','r','LineWidth',1.5,'EnhanceVisibility',0);
    tmp=['../../res/segmentation_example_res_' num2str(kkk) '_seg_' replace(num2str(seg),'.','_') ];
    print_png_eps_svg(tmp)
    
    figure(2);
    hold off
    imshow(rgb_slice)
    hold on
    visboundaries(gt_slice,'Color','g','LineWidth',1.5,'EnhanceVisibility',0);
    tmp=['../../res/segmentation_example_gt_' num2str(kkk) '_seg_' replace(num2str(seg),'.','_')];
    print_png_eps_svg(tmp)    
    
    figure(3);
    hold off
    imshow(rgb_slice)
    hold on
    visboundaries(res_slice,'Color','r','LineWidth',1.5,'EnhanceVisibility',0);
    visboundaries(gt_slice,'Color','g','LineWidth',1.5,'EnhanceVisibility',0);
    tmp=['../../res/segmentation_example_gt_res' num2str(kkk) '_seg_' replace(num2str(seg),'.','_')];
    print_png_eps_svg(tmp)    
    
    segs
    drawnow;
end

mean(segs)



save('tmp.mat','segs')

load('tmp.mat')

figure()
y=segs;

boxplot(y)

ylabel('SEG score (object-wise Jaccard coefficient)')

print_png_eps_svg_fig('../../res/segmentation_seg_boxplot')


bins=5;

figure()
y=segs;
histogram(segs,bins)
xlim([0,1])

xlabel('SEG score (object-wise Jaccard coefficient)')

print_png_eps_svg_fig(['../../res/segmentation_seg_histogram_bins' num2str(bins)])






