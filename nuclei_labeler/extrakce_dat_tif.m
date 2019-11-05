clc;clear all; close all;
addpath('utils')


% 
% names=subdir('Z:\999992-nanobiomed\Konfokal\18-11-19 - gH2AX jadra\data_vsichni_pacienti\tif\*.tif');
% 
% names={names(:).name};
% 
% rng(1)
% 
% r=randperm(length(names),300);
% 
% names=names(r);
% 
% save('names2.mat','names')




load('names2.mat')
cesta_save='../../../3d_segmentace_data/data_na_labely2';

% for k=1:300/10
%     mkdir(['data_na_labely/' num2str(k,'%03d')])
%     mkdir(['data_na_labely/' num2str(k,'%03d') '_norm'])
% end


citac=0;
for name=names
    citac=citac+1
    
    citac2=floor(citac/10)+1;
    
    name=name{1}
    
    

    
    [a,b,c]=read_3d_rgb_tif(name);

    
    for k=1:size(a,3)
    
        name_save=[cesta_save '/data_' num2str(citac,'%03d') '.tif'];
        tiff_stack_single_color(name_save,single(cat(3,a(:,:,k),b(:,:,k),c(:,:,k))),k)
        
    end
    
    
      
    
    a=medfilt3(double(a),[5 5 3]);
    b=medfilt3(double(b),[5 5 3]);
    c=medfilt3(double(c),[5 5 3]);
    
    a=imgaussfilt3(double(a),[2 2 1]);
    b=imgaussfilt3(double(b),[2 2 1]);
    c=imgaussfilt3(double(c),[2 2 1]);

    a=norm_percentile(a,0.0001);
    b=norm_percentile(b,0.0001);
    c=norm_percentile(c,0.0001);
    
    for k=1:size(a,3)
    
        name_save=[cesta_save '/data_norm_' num2str(citac,'%03d') '.tif'];
        tiff_stack_single_color(name_save,single(cat(3,a(:,:,k),b(:,:,k),c(:,:,k))),k)
        
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
