function [a,b,c]=nacteni_tif(name)


info=imfinfo(name);

r=zeros(info(1).Height,info(1).Width,length(info));
g=zeros(info(1).Height,info(1).Width,length(info));
b=zeros(info(1).Height,info(1).Width,length(info));
for k=1:length(info)
    rgb=imread(name,k);
    r(:,:,k)=rgb(:,:,1);
    g(:,:,k)=rgb(:,:,2);
    b(:,:,k)=rgb(:,:,3);
end
