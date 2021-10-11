clc;clear all;close all;

clc;clear all;close all;
addpath('../utils')
addpath('../3DNucleiSegmentation_training')


path='C:\Data\Vicar\foci_new\data_u87_nhdf_resaved';

load('dice_rot_new.mat')
gpu = 1;


names_53BP1 = subdirx([path '\*data_53BP1.tif']);


rng(42)
names_53BP1 = names_53BP1(randperm(length(names_53BP1)));



for img_num=1:length(names_53BP1)

    
    
    name_53BP1 = names_53BP1{img_num};
    
    
    a = imread(name_53BP1);
    b = imread(replace(name_53BP1,'53BP1.tif','gH2AX.tif'));
    c0 = imread(replace(name_53BP1,'53BP1.tif','DAPI.tif'));


    [af,bf,cf]=preprocess_filters(a,b,c0,gpu);

    [a,b,c]=preprocess_norm_resize(af,bf,cf);

    mask0=predict_by_parts(a,b,c,net);


    mask=split_nuclei_hard(mask0);
    mask=balloon(mask,[20 20 8]);
    shape=[5,5,2];
    [X,Y,Z] = meshgrid(linspace(-1,1,shape(1)),linspace(-1,1,shape(2)),linspace(-1,1,shape(3)));
    sphere=sqrt(X.^2+Y.^2+Z.^2)<1;
    mask_conected=imerode(mask,sphere);
    mask=imresize3(uint8(mask),size(af),'nearest')>0;

    close all;
    figure()
    tmp1 = c0(:,:,25);
    tmp2 = zeros([size(tmp1),3]);
    tmp2(:,:,3) = norm_percentile(tmp1,0.01);
    imshow(tmp2,[])
    figure()
    imshow(mask0(:,:,25),[])
    figure()
    imshow(mask(:,:,25),[])
    
    
    imwrite(tmp2,['../../seg_examples/' num2str(img_num) 'dapi'  '.png' ])
    
    imwrite(mask0(:,:,25),['../../seg_examples/' num2str(img_num) 'mask0.png' ])
    
    imwrite(mask(:,:,25),['../../seg_examples/' num2str(img_num) 'mask.png' ])
    
    drawnow;
    
end