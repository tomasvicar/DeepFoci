function bin=segmentace_jadra_special(a,b,c)




beru=nejostrejsi(a,21);

a=a(:,:,beru);
b=b(:,:,beru);
c=c(:,:,beru);


for k=1:size(c,3)
    cc(:,:,k)=medfilt2(c(:,:,k),[3 3],'symmetric');
end


% cc=imgaussfilt3(cc,[10 10 10/3]);
% aa=imgaussfilt3(a,[10 10 10/3]);
% bb=imgaussfilt3(b,[10 10 10/3]);


% 
% I=mat2gray(imgaussfilt(max(a,[],3),15));
% best_idx = RosinThreshold(hist(I(:),255));
% vysledek1 = imquantize(I,best_idx/255)==2;
% 
% 
% I=mat2gray(imgaussfilt(max(b,[],3),15));
% best_idx = RosinThreshold(hist(I(:),255));
% vysledek2 = imquantize(I,best_idx/255)==2;


cmean=mat2gray(mean(c,3));
I=imgaussfilt(cmean,10);
I=I-imgaussfilt(I,200);
level = graythresh(I(:));
vysledek=I>level;

I=imgaussfilt(cmean,2);

% vysledek=(sum(vysledek1,3)>0|sum(vysledek2,3)>0|sum(vysledek3,3)>0);
%     vysledek=vysledek3;
%     imshow(vysledek,[])


bin=vysledek;


bin=imdilate(bin,strel('disk',5));
bin=imerode(bin,strel('disk',5));
bin=imfill(bin,'holes');
bin=bwareafilt(bin,[8000 250000]);


vysvys=zeros(size(vysledek));
l=bwlabel(bin);
for kk=1:max(l(:))
    b=l==kk;
    b=imdilate(b,strel('disk',10));
    [bv,Iv,roh]=bound(b,I);
    
    vysledek=bv;
    
    %    vysledek = activecontour(Iv,vysledek,max(size(bv)),'Chan-Vese','SmoothFactor',2);
    for k=1:(max(size(bv))/30)
        vysledek = activecontour(Iv,vysledek,30,'Chan-Vese','SmoothFactor',2);
        figure(1);
        imshow(Iv,[])
        hold on;
        visboundaries(vysledek,'LineWidth',0.1)
        drawnow;
        hold off
    end
    
    
    [inderx,indexy]=ind2sub(size(vysledek),find(vysledek));
    
    pomx=inderx+roh(1);
    pomy=indexy+roh(2);
    ind=(pomx<1)|(pomx>size(vysvys,1))|(pomy<1)|(pomy>size(vysvys,2));
    pomx(ind==1)=[];
    pomy(ind==1)=[];
    
    
    pom=sub2ind(size(vysvys),pomx,pomy);
    
    vysvys(pom)=1;
    
    
end
bin=vysvys;

