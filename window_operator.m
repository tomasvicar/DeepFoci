function values = window_operator(img,lbl,sizes,fcn_handle)



stats_tmp = regionprops3(lbl,img,'Centroid');


c=round(cat(1,stats_tmp.Centroid));

if isempty(c)
    c=zeros(0,3);
end

rs=(sizes-1)/2;

c1=c(:,2);
c2=c(:,1);
c3=c(:,3);

c1(c1<(rs(1)+1))=(rs(1)+1);
c2(c2<(rs(2)+1))=(rs(2)+1);
c3(c3<(rs(3)+1))=(rs(3)+1);

c1(c1>(size(img,1)-rs(1)))=(size(img,1)-rs(1));
c2(c2>(size(img,2)-rs(2)))=(size(img,2)-rs(2));
c3(c3>(size(img,3)-rs(3)))=(size(img,3)-rs(3));


values=zeros(size(c,1),1);
for k=1:size(c,1)
    window=img(c1(k)-rs(1):c1(k)+rs(1),c2(k)-rs(2):c2(k)+rs(2),c3(k)-rs(3):c3(k)+rs(3));
    
    values(k)=fcn_handle(window);
    
    
end



end

