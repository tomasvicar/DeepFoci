clc;clear all;close all force;
addpath('../funkce')

cesta='../../../data_ruzne_davky\ruzne_davky_preproces';

listing=subdir([cesta '/*data.mat']);
soubory={listing(:).name};

load('logistic_21f_norm_whole.mat')

prah=0;

for k=136:length(soubory)%upravit 1 - pro pokraèování od jiného èísla
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
    
    
    
     reset=1;
    while reset
        [maska_krajena,reset]=malovatko_freehand(barva,maska_krajena,soubor_ulozit,a,b,c);
        drawnow
    end
    
    maska_krajena=bwareafilt(maska_krajena,[400 9999999999]);
    
%     save([ukladaci_cesta '/cele' pom_cislo '/pom_data' pom_cislo '/' num2str(k,'%03d') '/maska_upravena' pom_cislo '.mat'],'maska_krajena')
    save([slozka '/maska_upravena.mat' ],'maska_krajena')
    
    maska=maska_krajena>0;
    pom=barva.barva3;
    maskaa=maska-imerode(maska,strel('disk',3));
    maskaa=maskaa>0;
    pomm=pom(:,:,1);
    pomm(maskaa)=1;
    pom(:,:,1)=pomm;
    pomm=pom(:,:,2);
    pomm(maskaa)=0;
    pom(:,:,2)=pomm;
    pomm=pom(:,:,3);
    pomm(maskaa)=0;
    pom(:,:,3)=pomm;
    l=bwlabel(maska>0,4);
    s = regionprops(l,'centroid');
    centroids = cat(1, s.Centroid);
    for kq=1:size(centroids,1)
        pom= insertText(pom,centroids(kq,1:2),num2str(kq),'BoxOpacity',0,'FontSize',26);
    end
    pom=[ones([50,size(pom,2),3]);pom];
    pom= insertText(pom,[0 0],soubor,'BoxOpacity',0,'FontSize',20);
    
%     imwrite(pom,[ukladaci_cesta '/cele' pom_cislo '/' num2str(k,'%03d') '.tif'])
    imwrite(pom,[slozka '/kontrola_masky_cele.tif' ]);
    
    
    
    
    
    
end