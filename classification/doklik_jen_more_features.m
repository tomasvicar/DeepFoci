clc;clear all;close all force;
addpath('../funkce')

cesta='../../data_nahodna_preproces_2';

listing=subdir([cesta '/*data.mat']);
soubory={listing(:).name};

load('svm_7_vel_med_99p_p.mat')

prah=0;

for k=1:length(soubory)
    k
    
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
    

    
    [normy,barvyv1,barvyv2,barvyv3,maskyv,foky_rgv,av,bv,cv,rohy,ostrev,smaz_foky_rgv]=bound_all2(barva,maska_krajena,foky_rg,a,b,c,size(a,3),rg_odstranene);
    
    vysledek=zeros(1,size(rg,2));
    bunka=zeros(1,size(rg,2));
    
    featuress=zeros(size(rg,1),7);
    featuress_more=zeros(size(rg,1),19);
    
    
    
    
    
    
    
    
    for cislo_bunky=1:length(maskyv)
        
        mvv=maskyv{cislo_bunky};avv=av{cislo_bunky};bvv=bv{cislo_bunky};
        cvv=cv{cislo_bunky};roh=rohy{cislo_bunky};
        foky_rgvv=foky_rgv{cislo_bunky};
        ostrevv=ostrev{cislo_bunky}; normyv=normy{cislo_bunky};
        smaz_foky_rgvv=smaz_foky_rgv{cislo_bunky};
        barvav1=barvyv1{cislo_bunky};
        barvav2=barvyv2{cislo_bunky};
        barvav3=barvyv3{cislo_bunky};
        
        
        
        m_pom=zeros(size(maska_krajena));
        
        mvv0=mvv;
        mvv=mvv==1;
        
        [m_pom]=insertmatrix(m_pom,mvv,roh([1 2 3]));
        
        %         tic
        %         m_pom=imdilate(m_pom,strel('disk',12));
        m_pom=repmat(m_pom,[1 1 size(foky_rg,3)]);
        
        
        CC = bwconncomp(ones([3 3 3]));
        CC.ImageSize=size(m_pom);
        CC.NumObjects=size(rg,1);
        CC.PixelIdxList=rg.VoxelIdxList;
        
        
        s = regionprops(CC,m_pom,'MeanIntensity');
        ktere=[s.MeanIntensity]>0.5;
        %         toc
        tecky=rg.Centroid;
        
        
        
        
        
        tecky=tecky(find(ktere),:);
        
        tecky(:,1)=tecky(:,1)-roh(2);
        tecky(:,2)=tecky(:,2)-roh(1);
        
        
        
        data=rg(find(ktere),:);
        
        
        [features]=get_features(data,avv,bvv,ostrevv,mvv);
        
        [features_more]=get_features_more19(data,avv,bvv,ostrevv,mvv);
        
        
        featuress(find(ktere),:)=features;
        
        featuress_more(find(ktere),:)=features_more;
        
        vys_stare=[];
        cislo_snimku=k;
        cislo_bunky=cislo_bunky;
        pouzit=1;
        
        
        
        
%         uk_snimek=[ukladaci_cesta '/bunky' pom_cislo '/' num2str(k,'%03d') '-' num2str(cislo_bunky,'%03d') pom_cislo '.png'];
        
        uk_snimek=[slozka '/kontrola_bunka' num2str(cislo_bunky,'%03d') '.png'];
        
        
%         barva=cat(3,norm_percentile(max(a,[],3),0.001),norm_percentile(max(b,[],3),0.001),norm_percentile(mean(c,3),0.001));
    
%         normyv.norma=[double(prctile(a(:),perc*100)) double(prctile(a(:),100-perc*100))];
%         normyv.normb=
%         normyv.normc=
        
        
%         reset=1;
%         while reset
%             [vys,pouzit,prah,reset]=doklik_new(barvav1,barvav2,barvav3,foky_rgvv,data,tecky,prah,features,soubor_ulozit,smaz_foky_rgvv,mvv0,Mdl,uk_snimek,normyv,vys_stare,pouzit);
%             drawnow;
%         end
        
        clear vys prah pouzit
        
        load([slozka '/vys_bunka' num2str(cislo_bunky,'%03d') '.mat'],'vys', 'prah', 'pouzit')
        
        vys(vys==1)=0;
        vys(vys==2)=1;
        
        %         imwrite(snimek,)
        vyss=vys;
        if pouzit==0
            vyss=zeros(size(vys));
        end
        
        
        
        
        
        bunka(ktere>0)=cislo_bunky;
        
        if pouzit
            
            
            vys(vys==1)=2;
            vys(vys==0)=1;
            
            vysledek(ktere>0)=vys;
            
        else
            vysledek(ktere>0)=-1;
        end
        
        barvav.baravva1=barvav1;
        barvav.baravav2=barvav2;
        barvav.baravav3=barvav3;
        
         save([slozka '/vys_bunka' num2str(cislo_bunky,'%03d') '.mat'],'vys','vyss','pouzit','barvav','foky_rgvv','cislo_snimku','cislo_bunky','data','tecky','features','features_more','normyv','smaz_foky_rgvv','pouzit','soubor_ulozit','mvv0','prah')
%         save([ukladaci_cesta '/bunky' pom_cislo '/pom_data' pom_cislo '/' num2str(k,'%03d') '-' num2str(cislo_bunky,'%03d') '/vysledky_b' num2str(cislo_bunky,'%03d') pom_cislo  '.mat'],'vys','vyss','pouzit','barvav','foky_rgvv','cislo_snimku','cislo_bunky','data','tecky','features','normyv','smaz_foky_rgvv','pouzit','soubor_ulozit','mvv0','prah')
    end
    
    save([slozka '/vys_cele.mat'],'vysledek','bunka','featuress','featuress_more','rg')
%     save([ukladaci_cesta '/cele' pom_cislo '/pom_data' pom_cislo '/' num2str(k,'%03d') '/' num2str(k,'%03d') 'labely.mat'],'vysledek','bunka','featuress','rg')
    
    
end