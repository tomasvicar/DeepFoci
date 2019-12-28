clc;clear all;close all;

name='../nahodny_vzorek_tif/data_001';

name_data=[name '.tif'];
name_maska=[name '_maska.mat'];
name_tecky=[name '_tecky.mat'];

load(name_maska)
load(name_tecky)

info=imfinfo(name_data);

r=zeros(info(1).Height,info(1).Width,length(info));
g=zeros(info(1).Height,info(1).Width,length(info));
b=zeros(info(1).Height,info(1).Width,length(info));
for k=1:length(info)
    rgb=imread(name_data,k);
    r(:,:,k)=rgb(:,:,1);
    g(:,:,k)=rgb(:,:,2);
    b(:,:,k)=rgb(:,:,3);
end

r=max(r,[],3);
g=max(g,[],3);
b=max(b,[],3);

imshow(cat(3,mat2gray(r),mat2gray(g),mat2gray(b)),[])
hold on
for k=1:max(maska(:))
    cont=visboundaries(maska==k,'Color','r');
end

c=plot(tecky(:,1), tecky(:,2), 'ro');
cc=plot(tecky(:,1), tecky(:,2), 'b*');
ccc=plot(tecky(:,1), tecky(:,2), 'yx');
