function [data] = imread_4D_tif(filename)

    info=imfinfo(filename);
    data=zeros(info(1).Height,info(1).Width,length(info),info(1).SamplesPerPixel);
    
    for k=1:length(info)
        data(:,:,k,:)=imread(filename,k);
    end

end