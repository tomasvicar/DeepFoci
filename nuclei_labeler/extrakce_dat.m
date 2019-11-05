clc;clear all; close all;
addpath('utils')


% % 
% names=subdir('Y:\CELL_MUNI\foky\clanek\dalsi_data\*01.ics');
% 
% names={names(:).name};
% 
% rng(1)
% 
% r=randperm(length(names),300);
% 
% names=names(r);
% 
% save('names.mat','names')




load('names.mat')
cesta_save='Y:/CELL_MUNI/foky/clanek/3d_segmentace/data_na_labely';

% for k=1:300/10
%     mkdir(['data_na_labely/' num2str(k,'%03d')])
%     mkdir(['data_na_labely/' num2str(k,'%03d') '_norm'])
% end


citac=0;
for name=names
    citac=citac+1
    
    citac2=floor(citac/10)+1;
    
    name=name{1};
    
    
    [a,b,c]=nacteni_puvodni(name);

%     load(name{1});

    


    cesta_save
    
    for k=1:size(a,3)
    
%         name_save=[cesta_save '/' num2str(citac2,'%03d') '/data_' num2str(citac,'%03d') '_' num2str(k,'%03d') '.tif'];
%         imwrite_single(name_save,single(cat(3,a(:,:,k),b(:,:,k),c(:,:,k))))

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
    
        
%         figure(1)
%         imshow(single(cat(3,a(:,:,k),b(:,:,k),c(:,:,k))),[0 1])
%         hold off
%         name_save=[cesta_save '/' num2str(citac2,'%03d') '_norm/data_' num2str(citac,'%03d') '_' num2str(k,'%03d') '.tif'];
%         imwrite_single(name_save,single(cat(3,a(:,:,k),b(:,:,k),c(:,:,k))))

        name_save=[cesta_save '/data_norm_' num2str(citac,'%03d') '.tif'];
        tiff_stack_single_color(name_save,single(cat(3,a(:,:,k),b(:,:,k),c(:,:,k))),k)
        
    end
    
    if citac==4
        fasdfs=fsddsf
    end
    
end