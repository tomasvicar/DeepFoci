function [features]=get_features(data,avv,bvv,ostrevv,mvv)



pom=false(size(avv));
pom(:,:,ostrevv)=repmat(mvv,[1 1 length(ostrevv)]);
ap=avv(pom);
bp=bvv(pom);
abp=ap.*bp;


% meda=median(ap(:));
% medb=median(bp(:));
medab=median(abp(:));

maxa=data{:,7};
maxb=data{:,9};
maxab=maxa.*maxb;


pab1=data{:,4};
pab2=data{:,5};
% pa1=data{:,6};
% pa2=data{:,7};
% pb1=data{:,8};
% pb2=data{:,9};

pab1i=invprctile(abp(:),pab1);
pab2i=invprctile(abp(:),pab2);


% pa1=pa1/prctile(ap(:),99.999);
% pa2=pa2/prctile(ap(:),99.999);
% pb1=pb1/prctile(bp(:),99.999);
% pb2=pb2/prctile(bp(:),99.999);
pab1=pab1/prctile(abp(:),99.999);
pab2=pab2/prctile(abp(:),99.999);

features=[(data{:,1}).^(1/3),data{:,4:5}./medab,pab1,pab2,pab1i,pab2i];



