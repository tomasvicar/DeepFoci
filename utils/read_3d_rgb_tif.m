function [a,b,c]=read_3d_rgb_tif(name)
    
    info=imfinfo(name);
    for k=1:length(info)
        rgb=imread(name,k);
        if k == 1
            a=zeros(info(1).Height,info(1).Width,length(info),'like',rgb);
            b=zeros(info(1).Height,info(1).Width,length(info),'like',rgb);
            c=zeros(info(1).Height,info(1).Width,length(info),'like',rgb);
        end
        a(:,:,k)=rgb(:,:,1);
        b(:,:,k)=rgb(:,:,2);
        c(:,:,k)=rgb(:,:,3);
    end

end