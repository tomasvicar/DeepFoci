clc;clear all;close all;
addpath('utils')
addpath('3DNucleiSegmentation_training')

load('names_foci_sample.mat')
names_orig=names;

names=subdir('Y:\CELL_MUNI\foky\new_foci_detection\example_folder\*3D_*.tif');
names={names(:).name};



for img_num=3:length(names)
    
    name=names{img_num};
    
    name_orig=names_orig{img_num};
    
    name_mask=strrep(name,'3D_','mask_');
    
    [a,b,c]=read_3d_rgb_tif(name);
    
    mask=read_mask(name_mask);
    mask=split_nuclei(mask);
    mask=balloon(mask,[26 26 10]);
    mask=imresize3(uint8(mask),size(a),'nearest')>0;
    
    
    [a,b,c]=preprocess_filters(a,b,c);
    
    rgb_2d=cat(3,norm_percentile(mean(a,3),0.001),norm_percentile(mean(b,3),0.001),norm_percentile(mean(c,3),0.001));
    
    
    
    a=norm_percentile(a,0.00001);
    b=norm_percentile(b,0.00001);
    
    %    a_percentile=prctile(a(:),0.95*100);
    %    b_percentile=prctile(b(:),0.95*100);
    
    %    a(a<a_percentile)=a_percentile;
    %    b(b<b_percentile)=b_percentile;
    
    ab=a.*b;
    
    
    
    abb=imgaussfilt3(ab,[10,10,10/3]) ;
    foreground=ab>abb;
    
    
    
    
    ab_uint=uint8(mat2gray(ab)*255);
    ab_percentile=prctile(ab_uint(:),0.95*100);
    ab_uint(ab_uint<ab_percentile)=ab_percentile;
    ab_uint=ab_uint.*uint8(mask);
    
    
    tic
    %    try
    r=vl_mser(ab_uint,'MinDiversity',0.1,...
        'MaxVariation',0.8,...
        'Delta',1,...
        'MinArea', 50/ numel(ab),...
        'MaxArea',2400/ numel(ab));
    %     catch
    %         r=[] ;
    %     end
    
    M = zeros(size(ab_uint),'uint16') ;
    for x=1:length(r)
        s = vl_erfill(ab_uint,r(x)) ;
        M(s) = M(s) + 1;
    end
    
    
    toc
    
    
    imshow(rgb_2d)
    hold on
    visboundaries(sum(M,3)>0)
    
    
    drawnow;
    
    
    fdfsdfsdfdfsdf
    
end






