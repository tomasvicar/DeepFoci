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


values=zeros(size(c,1),1);
for k=1:size(c,1)
    
    cc1=c1(k)-rs(1):c1(k)+rs(1);
    cc2=c2(k)-rs(2):c2(k)+rs(2);
    cc3=c3(k)-rs(3):c3(k)+rs(3);
    
    cc1(cc1<1)=1;
    cc2(cc2<1)=1;
    cc3(cc3<1)=1;

    cc1(cc1>size(img,1))=size(img,1);
    cc2(cc2>size(img,2))=size(img,2);
    cc3(cc3>size(img,3))=size(img,3);
    
    
    window=img(cc1,cc2,cc3);
    
    values(k)=fcn_handle(window);
    
    
end



end

