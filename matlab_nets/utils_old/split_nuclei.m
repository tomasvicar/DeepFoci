function mask=split_nuclei(mask)

    vys=mask>0.5;
    vel=[13 13 5];
    [X,Y,Z] = meshgrid(linspace(-1,1,vel(1)),linspace(-1,1,vel(2)),linspace(-1,1,vel(3)));
    sphere=sqrt(X.^2+Y.^2+Z.^2)<1;
    
    D = -bwdist(vys==0);
    D = imhmin(D,5);
    D=watershed(D)>0;
    vys=(vys.*D)>0;
    vys=imclose(vys,sphere);
    vys = bwareaopen(vys,6000);
    mask=imfill(vys,'holes');
    
    
end


