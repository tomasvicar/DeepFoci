function mask_2d_split=mask_2d_split(mask,osa)


mask_2d=squeeze(sum(mask,osa))>0;
s = regionprops(mask,'Centroid');
maxima = round(cat(1, s.Centroid));
mask_maxima=false([size(mask_2d,1),size(mask_2d,2)]) ;
for k=1:size(maxima,1)
    mask_maxima(maxima(k,2),maxima(k,1)) =1;
end
D = bwdistgeodesic(mask_2d,mask_maxima);
D(isnan(D))=Inf;
mask_2d_split=mask_2d.*(watershed(D)>0);


end