function [barvyv,maskyv,av,bv,cv,rohy]=bound_all(barva,maska,a,b,c,beru)
barvyv={};
maskyv={};
av={};
bv={};
cv={};
rohy={};
l=bwlabel(maska>0,4);
beruu=beru;
for k=1:max(l(:))

bunka=k==l;

% beru=nejostrejsi_pom(a,bunka,beruu);
beru=1:size(a,3);
if size(a,3)<=beruu
    beru=1:size(a,3);
end


   
bunka2=imdilate(bunka,strel('disk',10));

[x,y]=find(bunka2);

maskyv=[maskyv bunka(min(x):max(x),min(y):max(y))];
barvyv=[barvyv barva(min(x):max(x),min(y):max(y),:)];

av=[av a(min(x):max(x),min(y):max(y),beru)];
bv=[bv b(min(x):max(x),min(y):max(y),beru)];
cv=[cv c(min(x):max(x),min(y):max(y),beru)];
rohy=[rohy [min(x) min(y) beru(1)]];


end

end




function beru=nejostrejsi_pom(a,maska,kolik_beru)


ap=mat2gray(a);
for i=1:size(a,3)
    pom=ap(:,:,i);
    e(i)=entropy(double(pom(maska)));
end
e=medfilt1(e,5);
e=conv(e,ones(1,5),'same');
[kolik,nej]=max(e);
if nej>size(a,3)-floor(kolik_beru/2)
    beru=size(a,3)-kolik_beru+1:size(a,3);
elseif nej<ceil(kolik_beru/2)
    beru=1:kolik_beru;
else
    beru=nej-floor(kolik_beru/2):nej+floor(kolik_beru/2);
end


end
