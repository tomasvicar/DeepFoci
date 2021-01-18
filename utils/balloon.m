function mask=balloon(mask,shape)

    mask_conected=imdilate(mask,sphere(shape));
    
    D = bwdistgeodesic(mask_conected,mask,'quasi-euclidean');
    
    D(isnan(D))=-5;
    
    D=-D;
    
    D = imimposemin(D,mask);
    
    
    mask=(watershed(D)>0)&mask_conected;
    
    
    


end