function mask=read_mask(name)

    info=imfinfo(name);
    mask=zeros(info(1).Height,info(1).Width,length(info),'logical');
    for k=1:length(info)
        mask(:,:,k)=imread(name,k);
    end


end
