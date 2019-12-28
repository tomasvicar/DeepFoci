function bin=nafouknuti(bin,kolik)


%     l=bwlabel(bin>0,4);
%     vrstvy=zeros([size(bin),max(l(:))]);
%     for k=1:max(l(:))
%         bunka=l==k;
% % 
% %         
%         vrstvy(:,:,k)=imdilate(bunka,strel('disk',20));
%     end
%     vahy=sum(vrstvy,3);
%     prekryv=imdilate(vahy>1,strel('square',3));
%     bin=vahy>0;
%     bin(prekryv)=0;

bin=bin>0;
% l=bwlabel(bin>0,4);
dil=imdilate(bin,strel('disk',kolik));

distik=bwdistgeodesic(dil,bin,'quasi-euclidean');
distik(dil==0)=Inf;

% imshow(,[])
bin=dil;
bin(watershed(distik)==0)=0;



