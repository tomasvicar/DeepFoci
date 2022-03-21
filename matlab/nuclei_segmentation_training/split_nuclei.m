function mask=split_nuclei(mask,min_size,h)

    
    D = -bwdist(mask==0);
    D = imhmin(D,h);
    D=watershed(D)>0;
    mask=(mask.*D)>0;
    mask = bwareaopen(mask,min_size);
    mask=imfill(mask,'holes');
    
    
end
