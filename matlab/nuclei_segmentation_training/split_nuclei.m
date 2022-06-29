function mask=split_nuclei(mask,min_size,minimal_hole_size,h)

    mask = ~bwareaopen(~mask,minimal_hole_size);
    mask0 = mask;

    D = -bwdist(mask==0);
    D = imhmin(D,h);
    D=watershed(D)>0;
    mask=(mask.*D)>0;
    mask = bwareaopen(mask,min_size);
    mask=imfill(mask,'holes');


    
    
    
end
