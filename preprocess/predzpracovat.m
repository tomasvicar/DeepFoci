function [a,b,c,maska,maska_krajena,barva,foky_rg,rg_odstranene,rg]=predzpracovat(soubor,net)
addpath('../funkce')

% soubor='E:\foky\na_clanek\pomdata\data_000.tif';
% soubor='E:\foky\na_clanek\trenovani_site_jadra\trenovaci_data_jadra\149data.mat';

%predzpracovat''':"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
[au,bu,cu]=nacteni_puvodni(soubor);
if contains(soubor,'2Gy_15_3_31_30min')||contains(soubor,'4Gy_U87_15_3_24_30min')
    ccu=bu;
    cu=bu;
    bu=ccu;
end

a=single(au);
b=single(bu);
c=single(cu);


%     [au,bu,cu]=nacteni_tif(soubor);
%
%     au=uint16(au);
%     bu=uint16(bu);
%     cu=uint16(cu);
%     load(soubor)


%     a=single(au);
%     b=single(bu);
%     c=single(cu);


barva=cat(3,norm_percentile(max(a,[],3),0.001),norm_percentile(max(b,[],3),0.001),norm_percentile(mean(c,3),0.001));


aa=(a-mean(a(:)))/std(a(:));
bb=(b-mean(b(:)))/std(b(:));
cc=(c-mean(c(:)))/std(c(:));




%     segnet
%     aa=imresize3(aa,[505 681 14]);
%     bb=imresize3(bb,[505 681 14]);
%     cc=imresize3(cc,[505 681 14]);
%
%     %     maska=imerode(maska,strel('disk',8));
%
%     cq=imerode(cc,strel('disk',8));
%
%
%     cc=cat(3,mean(cc,3),max(cq,[],3), (max(aa,[],3)+max(bb,[],3))/2);
%
%     load('net2.mat')
%     tic
%     bin=predict(net,cc);
%     bin=bin(:,:,2)>0.9;
%     toc
%
%     bin=fill_holes(bin,500);
%
%
%
%     bin=imresize(bin,size(a(:,:,1)),'nearest');
%     bin=imerode(bin,strel('disk',3));
%     [bin_krajeny,~]=krajeni_jader(bin,3);
%
%         bin_filtrace=bin_krajeny;
%
%     maska=bin_filtrace;
%
%     bin_krajeny=maska;
%
%     bin=bin_krajeny;
%
%     bin=nafouknuti(bin,20);
%
%
%     maska_krajena=bin;
%    maska_krajena = bwareafilt(maska_krajena,[3000 Inf]);
%






%     unet_binar

ccc=imresize3(cc,[505 681 25]);% [480 672 9];

cccq=imerode(ccc,strel('disk',10));

cc=cat(3,mean(ccc,3),max(ccc,[],3),std(ccc,1,3),sum(abs(diff(ccc,1,3)),3),mean(cccq,3),max(cccq,[],3),std(cccq,1,3),sum(abs(diff(cccq,1,3)),3),imresize( (max(aa,[],3)+max(bb,[],3))/2,[505 681]));


cc=cc(14:end-12,6:end-4,:);

bin=single(zeros([size(ccc,1),size(ccc,2)]));
bin0=predict(net,cc);
bin(14:end-12,6:end-4,:)=bin0(:,:,2);
bin=bin>0.90;

bin=fill_holes(bin,500);



bin=imresize(bin,size(a(:,:,1)),'nearest');
bin=imerode(bin,strel('disk',3));
[bin_krajeny,~]=krajeni_jader(bin,3);

bin_filtrace=bin_krajeny;

maska=bin_filtrace;

bin_krajeny=maska;

bin=bin_krajeny;

bin=nafouknuti(bin,25);


maska_krajena=bin;
maska_krajena = bwareafilt(maska_krajena,[3000 Inf]);








%
%
%
%
%
%
%
%     unet - DT
%     ccc=imresize3(cc,0.5);
%
%     cccq=imerode(ccc,strel('disk',10));
%
%     data=cat(3,mean(ccc,3),max(ccc,[],3),std(ccc,1,3),sum(abs(diff(ccc,1,3)),3),mean(cccq,3),max(cccq,[],3),std(cccq,1,3),sum(abs(diff(cccq,1,3)),3),imresize( (max(aa,[],3)+max(bb,[],3))/2,0.5));
%
%
%
% %     img_size=[512 688 11];
% %     lbl=nan*zeros([size(data(:,:,1)) 4]);
% %     for kk=1:4
% %
% %         if kk==1
% %             dataa=data(1:img_size(1),1:img_size(2),:);
% %         elseif kk==2
% %             dataa=data(end-img_size(1)+1:end,1:img_size(2),:);
% %         elseif kk==3
% %             dataa=data(1:img_size(1),end-img_size(2)+1:end,:);
% %         elseif kk==4
% %             dataa=data(end-img_size(1)+1:end,end-img_size(2)+1:end,:);
% %         end
% %
% %         lbl_tmp=predict(net,dataa);
% %
% %         orez=5;
% %
% %         if kk==1
% %             lbl(1:img_size(1)-orez,1:img_size(2)-orez,kk)=lbl_tmp(1:end-orez,1:end-orez);
% %         elseif kk==2
% %             lbl(end+orez-img_size(1)+1:end,1:img_size(2)-orez,kk)=lbl_tmp(1+orez:end,1:end-orez);
% %         elseif kk==3
% %             lbl(1:img_size(1)-orez,end+orez-img_size(2)+1:end,kk)=lbl_tmp(1:end-orez,1+orez:end);
% %         elseif kk==4
% %             lbl(end+orez-img_size(1)+1:end,end+orez-img_size(2)+1:end,kk)=lbl_tmp(1+orez:end,1+orez:end);
% %         end
% %
% %     end
%
%
%    img_size=[544/2 704/2 9];
%     lbl=nan*zeros([size(data(:,:,1)) 4]);
%     for kk=1:4
%
%         if kk==1
%             dataa=data(1:img_size(1),1:img_size(2),:);
%         elseif kk==2
%             dataa=data(end-img_size(1)+1:end,1:img_size(2),:);
%         elseif kk==3
%             dataa=data(1:img_size(1),end-img_size(2)+1:end,:);
%         elseif kk==4
%             dataa=data(end-img_size(1)+1:end,end-img_size(2)+1:end,:);
%         end
%
%         lbl_tmp=predict(net,dataa);
%
%         orez=3;
%
%         if kk==1
%             lbl(1:img_size(1)-orez,1:img_size(2)-orez,kk)=lbl_tmp(1:end-orez,1:end-orez);
%         elseif kk==2
%             lbl(end+orez-img_size(1)+1:end,1:img_size(2)-orez,kk)=lbl_tmp(1+orez:end,1:end-orez);
%         elseif kk==3
%             lbl(1:img_size(1)-orez,end+orez-img_size(2)+1:end,kk)=lbl_tmp(1:end-orez,1+orez:end);
%         elseif kk==4
%             lbl(end+orez-img_size(1)+1:end,end+orez-img_size(2)+1:end,kk)=lbl_tmp(1+orez:end,1+orez:end);
%         end
%
%     end
%
%
%
%
%
%     bin=nanmean(lbl,3);
%
%
% %     imshow(bin,[])
%     bin=medfilt2(bin,[5 5]);
%     bin=imgaussfilt(bin,4);
%     bin=imresize(bin,2);
%
% %     bin_tmp1=bwlabel(bin>0.1);
% %     bin_tmp2=bin>0.2;
% %     bin0=false(size(bin_tmp1));
% %     for k=1:max(bin_tmp1(:))
% %         b=bin_tmp1==k;
% %         if sum(sum(bin_tmp2(b)))>0
% %            bin0(b)=1;
% %         end
% %     end
%
%     bin0=bin>0.2;
%
%     bin=bin>0.6;
% %     imshow(bin,[])
%
%     bin=fill_holes(bin,1000);
%     bin=bwareafilt(bin,[1000 Inf]);
%
%     bin=imerode(bin,strel('disk',3));
%     [bin_krajeny,~]=krajeni_jader(bin,3);
%
%
%     bin_filtrace=bin_krajeny;
%
%
%
%     maska=bin_filtrace;
%
%     bin_krajeny=maska;
%
%     bin=bin_krajeny;
%
% %     bin=nafouknuti(bin,20);
%
%     D = bwdistgeodesic(bin0,bin);
%     D(isnan(D))=999999;
%     bin=double(watershed(D)).*double(bin0);
%
%     maska_krajena=bin>0;
%     maska_krajena = bwareafilt(maska_krajena,[3000 Inf]);
%
%     maska_krajena=nafouknuti(maska_krajena,15);
%
% %     figure()
% %     imshow(maska_krajena)
% %
%
%
%
%


























%prahovani mser
%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'''''


disp('filtry')

a=padarray(a,[1 1 0],'symmetric');
b=padarray(b,[1 1 0],'symmetric');
c=padarray(c,[1 1 0],'symmetric');
a=gpuArray(a);
b=gpuArray(b);
c=gpuArray(c);
for k=1:size(a,3)
    a(:,:,k)=medfilt2(a(:,:,k),[3 3]);
    b(:,:,k)=medfilt2(b(:,:,k),[3 3]);
    c(:,:,k)=medfilt2(c(:,:,k),[3 3]);
end
a=a(2:end-1,2:end-1,:);
b=b(2:end-1,2:end-1,:);
c=c(2:end-1,2:end-1,:);

a=imgaussfilt3(a,[2 2 2/3]);
b=imgaussfilt3(b,[2 2 2/3]);
c=imgaussfilt3(c,[2 2 2/3]);

a=gather(a);
b=gather(b);
c=gather(c);


[barvyv,maskyv,av,bv,cv,rohy]=bound_all(maska_krajena,maska_krajena,a,b,c,size(a,3));


foky_rg=false(size(a));
rg_odstranene=false(size(a));
ab_m_all=false(size(a));







for cislo_bunky=1:length(maskyv)
    mvv=maskyv{cislo_bunky};avv=av{cislo_bunky};bvv=bv{cislo_bunky};cvv=cv{cislo_bunky};roh=rohy{cislo_bunky};barvav=barvyv{cislo_bunky};
    
    
    %         a=avv;
    %         b=bvv;
    %
    %
    %
    %         avv=gather(a);
    %         bvv=gather(b);
    
    %         a=mat2gray(a);
    %         b=mat2gray(b);
    
    avv=norm_percentile(avv,0.0001);
    bvv=norm_percentile(bvv,0.0001);
    %
    %         a=gather(a);
    %         b=gather(b);
    %
    mvv=imdilate(mvv,strel('disk',9));
    ab=avv.*bvv;
    ab=gpuArray(ab);
    
    abb=imgaussfilt3(ab,[10,10,10/3]) ;
    abb=gather(abb);
    pom=ab>abb;
    pom2=avv>median(avv(mvv));
    pom3=bvv>median(bvv(mvv));
    
    %          pom=true(size(pom));
    %          pom2=true(size(pom));
    %          pom3=true(size(pom));
    
    % mvv=true(size(pom));
    
    % mvv=imdilate(mvv,strel('disk',9));
    
    popre=pom.*pom2.*pom3.*mvv;
    
    
    aa=uint8(mat2gray(ab)*255);
    
    popre=gather(popre);
    aa=gather(aa);
    %         aa(popre)=0;
    
    ab=gather(ab);
    
    disp('cervena')
    tic
    try
        r=vl_mser(aa,'MinDiversity',0.1,...
            'MaxVariation',0.8,...
            'Delta',1,...
            'MinArea', 50/ numel(aa),...
            'MaxArea',2400/ numel(aa));
    catch
        r=[] ;
    end
    
    M1 = zeros(size(aa)) ;
    for x=1:length(r)
        s = vl_erfill(aa,r(x)) ;
        M1(s) = M1(s) + 1;
    end
    
    wab=M1>0;
    toc
    
    
    %         ab=gather(ab);
    ab_m=imregionalmax(ab);
    
    ab_m=ab_m.*popre.*wab;
    
    
    
    
    
    
    
    s = regionprops(ab_m>0,'centroid');
    maximav = round(cat(1, s.Centroid));
    ab_m=zeros(size(ab_m)) ;
    for k=1:size(maximav,1)
        ab_m(maximav(k,2),maximav(k,1),maximav(k,3)) =1;
    end
    try
        maximavp=[maximav(:,1:2),maximav(:,3)*3];
    catch
        maximavp=[] ;
    end
    
    tic
    idx = rangesearch(maximavp,maximavp,9);
    toc
    tic
    pouzit=ones(1,size(maximav,1));
    for k=1:length(idx)
        akt=ab(maximav(k,2),maximav(k,1),maximav(k,3));
        ostatni=idx{k};
        for kk=2:length(ostatni)
            jiny=ab(maximav(ostatni(kk),2),maximav(ostatni(kk),1),maximav(ostatni(kk),3)) ;
            if akt<=jiny
                pouzit(k)=0;
                break;
            end
        end
    end
    
    toc
    
    maximav=maximav(find(pouzit),:);
    
    
    
    ab_m=zeros(size(ab_m)) ;
    for k=1:size(maximav,1)
        ab_m(maximav(k,2),maximav(k,1),maximav(k,3)) =1;
    end
    
    
    [ab_m_all]=insertmatrix(ab_m_all,ab_m,roh([1 2 3]));
    
    
    
    
    wab=wab.*popre;
    pom=avv.*bvv;
    pom=-pom;
    pom=imimposemin(pom,ab_m);
    wab_krajeny=watershed(pom)>0;
    wab_krajeny(wab==0)=0;
    wab_krajeny=imfill(wab_krajeny,'holes');
    
    tic
    D=bwdistsc(wab_krajeny==0,[1 1 3]);
    D=imhmin(-D,1);
    wab_krajeny=(wab_krajeny>0).*(watershed(D)>0);
    toc
    
    
    
    
    
    
    
    
    
    
    wab_krajeny_2=false(size(avv));
    wab_odpad=false(size(avv));
    l=bwlabeln(wab_krajeny);
    for k=1:max(l(:))
        fok=l==k;
        %         sum(ab_m(fok))
        if sum(ab_m(fok))~=0
            wab_krajeny_2(fok)=1;
            
        else
            wab_odpad(fok)=1;
        end
    end
    wab_krajeny=wab_krajeny_2;
    
    [foky_rg]=insertmatrix(foky_rg,wab_krajeny,roh([1 2 3]));
    [rg_odstranene]=insertmatrix(rg_odstranene,wab_odpad,roh([1 2 3]));
    
    
    
end


l=bwlabeln(foky_rg);


rg=regionprops3(l,a.*b,'MaxIntensity','MeanIntensity','VoxelIdxList','Volume','Centroid');
r=regionprops3(l,a,'MaxIntensity','MeanIntensity');
g=regionprops3(l,b,'MaxIntensity','MeanIntensity');
r.Properties.VariableNames{'MaxIntensity'} = 'MaxIntensityR';
r.Properties.VariableNames{'MeanIntensity'} = 'MeanIntensityR';


g.Properties.VariableNames{'MaxIntensity'} = 'MaxIntensityG';
g.Properties.VariableNames{'MeanIntensity'} = 'MeanIntensityG';

rg=[rg,r,g];









%
%       foky_rg=1;
%       rg_odstranene=1;
%       rg=1;






barva=[];

ap=max(a,[],3);
bp=max(b,[],3);
cp=max(c,[],3);
ap=norm_percentile(ap,0.0001);
bp=norm_percentile(bp,0.0001);
cp=norm_percentile(cp,0.0001);
barva.barva3=cat(3,ap,bp,cp);


ap=squeeze(max(a,[],2));
bp=squeeze(max(b,[],2));
cp=squeeze(max(c,[],2));
ap=norm_percentile(ap,0.0001);
bp=norm_percentile(bp,0.0001);
cp=norm_percentile(cp,0.0001);
barva.barva2=cat(3,ap,bp,cp);


ap=squeeze(max(a,[],1))';
bp=squeeze(max(b,[],1))';
cp=squeeze(max(c,[],1))';
ap=norm_percentile(ap,0.0001);
bp=norm_percentile(bp,0.0001);
cp=norm_percentile(cp,0.0001);
barva.barva1=cat(3,ap,bp,cp);



