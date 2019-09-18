clc;clear all;close all;
addpath('utils')
addpath('3DNucleiSegmentation_training')

names=subdir('Z:\999992-nanobiomed\Konfokal\18-11-19 - gH2AX jadra\data_vsichni_pacienti\Pacient 19 (38-17)_tif/*3D*.tif');
names={names(:).name};



for img_num=1:length(names)
    
   name=names{img_num};
   
   name_mask=strrep(name,'3D_','mask'); 
   
   [a,b,c]=read_3d_rgb_tif(name);

   mask=read_mask(name_mask);

   
   [a,b,c]=preprocess_filters(a,b,c);
   
   a=norm_percentile(a,0.00001);
   b=norm_percentile(b,0.00001);
   
%    a_percentile=prctile(a(:),0.95*100);
%    b_percentile=prctile(b(:),0.95*100);
   
%    a(a<a_percentile)=a_percentile;
%    b(b<b_percentile)=b_percentile;
   
   ab=a.*b;
   
   ab_percentile=prctile(ab(:),0.95*100);
    
   abb=imgaussfilt3(ab,[10,10,10/3]) ;
   foreground=ab>abb;
   
   
   
   ab_uint=uint8(mat2gray(ab)*255);
   
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
    
    
    
   

   
   
end



function [a,b,c]=preprocess_filters(a,b,c)
    a=medfilt3(double(a),[5 5 1]);
    b=medfilt3(double(b),[5 5 1]);
    c=medfilt3(double(c),[5 5 1]);
    
    a=imgaussfilt3(double(a),[2 2 1]);
    b=imgaussfilt3(double(b),[2 2 1]);
    c=imgaussfilt3(double(c),[2 2 1]);
    
end

function mask=read_mask(name)

    info=imfinfo(name);
    mask=zeros(info(1).Height,info(1).Width,length(info),'logical');
    for k=1:length(info)
        mask(:,:,k)=imread(name,k);
    end


end

function [a,b,c]=read_3d_rgb_tif(name)

    info=imfinfo(name);
    a=zeros(info(1).Height,info(1).Width,length(info));
    b=zeros(info(1).Height,info(1).Width,length(info));
    c=zeros(info(1).Height,info(1).Width,length(info));
    for k=1:length(info)
        rgb=imread(name,k);
        a(:,:,k)=rgb(:,:,1);
        b(:,:,k)=rgb(:,:,2);
        c(:,:,k)=rgb(:,:,3);
    end

end