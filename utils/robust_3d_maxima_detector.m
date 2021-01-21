function [M] = robust_3d_maxima_detector(img,dil,h,t)

    img1 = imdilate(img,sphere(dil));
    img1 = imhmax(img1,h);
    M = imregionalmax(img1);
    c = regionprops(M,'centroid');
    c = round(cat(1, c.Centroid));
    M = false(size(img));
    M(sub2ind(size(M),c(:,2),c(:,1),c(:,3))) = 1;
    M((M.*img)<=t)=0;
    


end

