function [c,v] = robust_3d_maxima_detector(img,mask,dil,h)

    img1 = imdilate(img,sphere_gui(dil));

    img1 = imhmax(img1,h);

    M = imregionalmax(img1);
    
    M(mask==0)=0;
    c = regionprops(M,'centroid');
    c = round(cat(1, c.Centroid));
    
    
    
    v = img(sub2ind(size(M),c(:,2),c(:,1),c(:,3)));


end

