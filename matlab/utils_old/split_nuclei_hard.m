function mask=split_nuclei_hard(mask)

    vys_tmp=mask>0.5;
        vel=[13 13 5];
        [X,Y,Z] = meshgrid(linspace(-1,1,vel(1)),linspace(-1,1,vel(2)),linspace(-1,1,vel(3)));
        sphere=sqrt(X.^2+Y.^2+Z.^2)<1;

        D = -bwdistsc(vys_tmp==0,[1,1,3]);
        D = imhmin(D,3);
        D=watershed(D)>0;
        vys_tmp=(vys_tmp.*D)>0;
%         vys_tmp=imclose(vys_tmp,sphere);
        vys_tmp = bwareaopen(vys_tmp,6000);
        mask=imfill(vys_tmp,'holes');
    
    
end


