clc;clear all;close all force;
addpath('../funkce')

cesta='../../../klikac_novy/auto/poloauto_nahodny_vzorek_tif_processed_unet_erod';
% cesta='../../../data_ruzne_davky/ruzne_davky_preproces';

listing=subdir([cesta '/*data.mat']);
soubory={listing(:).name};

load('logistic_21f_norm_whole.mat')

prah=0;

for k=1:length(soubory)%upravit 1 - pro pokraèování od jiného èísla
    k
    
    tic
    
    soubor=soubory{k};
    name_data=soubor;
    name_vys=strrep(soubor,'data.mat','pomocna.mat');
    load(name_data)
    load(name_vys)
    
    slozka=strsplit(name_data,'\');
    slozka=join(slozka(1:end-1),'\');
    slozka=slozka{1};
    soubor_ulozit=slozka;
    
    a=single(au);
    b=single(bu);
    c=single(cu);
    
    
    
    clear maska_krajena
    load([slozka '/maska_upravena.mat' ])
    
    
    m=maska_krajena>0;
    
    ap=max(a,[],3);
    bp=max(b,[],3);
    cp=max(c,[],3);
    
    p=0.1;
    a_min =prctile(ap(:),p);
    b_min =prctile(bp(:),p);
    c_min =prctile(bp(:),p);
    a_max =prctile(ap(:),100-p);
    b_max =prctile(bp(:),100-p);
    c_max =prctile(cp(:),100-p);
    
    normy.norma=[double(a_min) double(a_max)];
    normy.normb=[double(b_min) double(b_max)];
    normy.normc=[double(c_min) double(c_max)];
    barva3=cat(3,mat2gray(ap,normy.norma),mat2gray(bp,normy.normb),mat2gray(cp,normy.normc));
    
    ap=squeeze(max(a,[],2));
    bp=squeeze(max(b,[],2));
    cp=squeeze(max(c,[],2));
    barva2=cat(3,mat2gray(ap,normy.norma),mat2gray(bp,normy.normb),mat2gray(cp,normy.normc));
    
    ap=squeeze(max(a,[],1))';
    bp=squeeze(max(b,[],1))';
    cp=squeeze(max(c,[],1))';
    barva1=cat(3,mat2gray(ap,normy.norma),mat2gray(bp,normy.normb),mat2gray(cp,normy.normc));
    
    
    
    
    m_pom=repmat(m,[1 1 size(foky_rg,3)]);
        

    CC = bwconncomp(ones([3 3 3]));
    CC.ImageSize=size(m_pom);
    CC.NumObjects=size(rg,1);
    CC.PixelIdxList=rg.VoxelIdxList;


    s = regionprops(CC,m_pom,'MeanIntensity');
    ktere=[s.MeanIntensity]>0.5;
    %         toc
    tecky=rg.Centroid;





    tecky=tecky(find(ktere),:);

 
    data=rg(find(ktere),:);


    featuress_cele21=zeros(size(rg,1),21);

    [features_cele21]=get_features_whole21(data,a,b,m);


    featuress_cele21(find(ktere),:)=features_cele21;


    smaz_foky_rg=false(size(a));
    
    uk_snimek=[slozka '/kontrola_nova.png'];
    
    
    cas_nacitani=toc;
    
    tic;
    reset=1;
%     while reset
%         [vys,prah,reset]=doklik_new(barva1,barva2,barva3,foky_rg,data,tecky,prah,features_cele21,soubor_ulozit,smaz_foky_rg,m,Mdl,uk_snimek,normy,Mdl_pom);
%         drawnow;
%     end

    prah=0;
    
    
    mu=Mdl_pom.mu;
    sig=Mdl_pom.sig;
    
    fea_te=features_cele21;
    
    fea_te=(fea_te-repmat(mu,[size(fea_te,1),1]))./repmat(sig,[size(fea_te,1),1]);

    beta=Mdl.Beta;
    bias=Mdl.Bias;
    lin_com=fea_te*beta+bias-prah;
    ex=exp(-lin_com);
    y=(1./(1+ex));
    vys=double(y>0.5);
    
    
    cas_klikani=toc;
    
    vys(vys==1)=2;
    vys(vys==0)=1;
    
    vysledek=zeros(1,size(rg,2));
    vysledek(ktere>0)=vys;
    cislo_snimku=k;
    
    save([slozka '/vys_cele_nove_auto.mat'],'vysledek','vys','featuress_cele21','data','rg','cislo_snimku','soubor_ulozit','prah')
%      save([slozka '/casy_nove.mat'],'cas_nacitani','cas_klikani');
end