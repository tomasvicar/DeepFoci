function [normy,barvyv1,barvyv2,barvyv3,maskyv,foky_rv,av,bv,cv,rohy,ostrev,smaz_foky_rgv]=bound_all2(barva,maska,foky_r,a,b,c,beru,smaz_foky_rg)
barvyv1={};
barvyv2={};
barvyv3={};
maskyv={};
ostrev={};
smaz_foky_rgv={};
av={};
bv={};
cv={};
normy={};
foky_rv={};
rohy={};
l=bwlabel(maska>0,4);
beruu=beru;
for k=1:max(l(:))

bunka=k==l;




% tic
% ostre=nejostrejsi_pom(a,bunka,15);
% toc
% tic;
ostre=nejostrejsi_pom2(a,bunka,15);
% toc;
% ostre(1)
% ostre2(1)

% ostre=1;
% if size(a,3)<=beruu
    beru=1:size(a,3);
% end
ostrev=[ostrev,ostre];

   
bunka2=imdilate(bunka,strel('disk',3));

[x,y]=find(bunka2);

maskyv=[maskyv bunka(min(x):max(x),min(y):max(y))];
% barvyv3=[barvyv3 barva.barva3(min(x):max(x),min(y):max(y),:)];
% barvyv2=[barvyv2 barva.barva2(min(x):max(x),:,:)];
% barvyv1=[barvyv1 barva.barva1(:,min(y):max(y),:)];

avv=a(min(x):max(x),min(y):max(y),beru);
bvv=b(min(x):max(x),min(y):max(y),beru);
cvv=c(min(x):max(x),min(y):max(y),beru);
av=[av avv];
bv=[bv bvv];
cv=[cv c(min(x):max(x),min(y):max(y),beru)];
foky_rv=[foky_rv foky_r(min(x):max(x),min(y):max(y),beru)];
smaz_foky_rgv=[smaz_foky_rgv smaz_foky_rg(min(x):max(x),min(y):max(y),beru)];
rohy=[rohy [min(x) min(y) beru(1)]];



        ap=max(avv,[],3);
        bp=max(bvv,[],3);
        cp=max(cvv,[],3);
        [ap,norma]=norm_percentile(ap,0.001);
        [bp,normb]=norm_percentile(bp,0.001);
        [cp,normc]=norm_percentile(cp,0.001);
        barva3=cat(3,ap,bp,cp);
        
        
        ap=squeeze(max(avv,[],2));
        bp=squeeze(max(bvv,[],2));
        cp=squeeze(max(cvv,[],2));
        [ap,norma]=norm_percentile(ap,0.001);
        [bp,normb]=norm_percentile(bp,0.001);
        [cp,normc]=norm_percentile(cp,0.001);
        barva2=cat(3,ap,bp,cp);
        
        
        ap=squeeze(max(avv,[],1))';
        bp=squeeze(max(bvv,[],1))';
        cp=squeeze(max(cvv,[],1))';
        [ap,norma]=norm_percentile(ap,0.001);
        [bp,normb]=norm_percentile(bp,0.001);
        [cp,normc]=norm_percentile(cp,0.001);
        barva1=cat(3,ap,bp,cp);
        
        normyy.norma=norma;
        normyy.normb=normb;
        normyy.normc=normc;
        
        normy=[normy normyy];
        
barvyv3=[barvyv3 barva3];
barvyv2=[barvyv2 barva2];
barvyv1=[barvyv1 barva1];









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




function beru=nejostrejsi_pom2(a,maska,kolik_beru)


% ap=mat2gray(a);
% for i=1:size(a,3)
%     pom=ap(:,:,i);
%     e(i)=entropy(double(pom(maska)));
% end

s = regionprops(maska,'BoundingBox');
roi = cat(1, s.BoundingBox);

e = fmeasure(a,'LAPV',roi,maska);

e=medfilt1(e,3);
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










function FM = fmeasure(Image, Measure, ROI,ROI2)
%This function measures the relative degree of focus of 
%an image. It may be invoked as:
%
%   FM = fmeasure(IMAGE, METHOD, ROI)
%
%Where 
%   IMAGE,  is a grayscale image and FM is the computed
%           focus value.
%   METHOD, is the focus measure algorithm as a string.
%           see 'operators.txt' for a list of focus 
%           measure methods. 
%   ROI,    Image ROI as a rectangle [xo yo width heigth].
%           if an empty argument is passed, the whole
%           image is processed.
%
%  Said Pertuz
%  Jan/2016

ROI=floor(ROI);
ROI(ROI<1)=1;
if nargin>2 && ~isempty(ROI)
    Image = imcropm(Image, ROI);
    ROI2 = imcropm(ROI2, ROI);
    
end

        LAP = fspecial('laplacian');
        for k=1:size(Image,3)
%             ILAP=conv2_specm(Image(:,:,k), LAP);
            ILAP=conv2(Image(:,:,k), LAP,'same');
            pom=ILAP(ROI2);
            FM(k) = std(pom(:)).^2;
        end
        
 end
        

function I=imcropm(I,bb)
    I=I(bb(2):bb(2)+bb(4),bb(1):bb(1)+bb(3),:);
end


function y=conv2_specm(x,h)

%periodická
y=real(ifft2(fft2(x,size(x,1),size(x,2)).*fft2(h,size(x,1),size(x,2))));

y=circshift(y,floor(-1*[size(h)]/2));


% aperiodická

% y=real(ifft2(fft2(x,size(x,1)+size(h,1)-1,size(x,2)+size(h,2)-1).*fft2(h,size(x,1)+size(h,1)-1,size(x,2)+size(h,2)-1)));
% 
% y=y((size(h,1)-1)/2:size(y,1)-(size(h,1)-1)/2-1,(size(h,2)-1)/2:size(y,2)-(size(h,2)-1)/2-1);
% 


end















