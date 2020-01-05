function values = get_centroid_value(mask,img)



stats_tmp = regionprops3(mask,img,'Centroid');


c=round(cat(1,stats_tmp.Centroid));


values=img(sub2ind(size(img),c(:,2),c(:,1),c(:,3)));


end