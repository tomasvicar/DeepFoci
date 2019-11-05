clc;clear all; close all;
addpath('utils')
slozka='data_na_labely/001_norm';


names=subdir(slozka);
names={names.name};

citac=0;
for name=names
    citac=citac+1;
    
    img=imread(name{1});
    
    II=img(:,:,3);
    level = graythresh(II(:));
    bin=II>level;

    bin=imdilate(bin,strel('disk',5));
    bin=imerode(bin,strel('disk',5));
    bin=imfill(bin,'holes');
    bin=bwareafilt(bin,[8000 250000]);

    maska = activecontour(II,bin,100,'Chan-Vese','SmoothFactor',2);
    
    
    
    
    reset=1;
    while reset
        
        
        [maska,reset]=malovatko_freehand(img,maska,num2str(citac));
        
    end
    name_mask=name{1};
    name_mask=strrep(name_mask,'_norm\data_','_norm\mask_');
    name_mask=strrep(name_mask,'.tif','.png');
    
    imwrite(uint8((maska>0)*255),name_mask)
    
    
end

