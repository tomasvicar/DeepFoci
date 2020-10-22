function mask=balloon(mask,shape)

    [X,Y,Z] = meshgrid(linspace(-1,1,shape(1)),linspace(-1,1,shape(2)),linspace(-1,1,shape(3)));
    sphere=sqrt(X.^2+Y.^2+Z.^2)<1;
    
    mask_conected=imdilate(mask,sphere);
    
    D = bwdistgeodesic(mask_conected,mask,'quasi-euclidean');
    
    D(isnan(D))=-5;
    
    D=-D;
    
    D = imimposemin(D,mask);
    
    
    mask=(watershed(D)>0)&mask_conected;
    
    
    


end