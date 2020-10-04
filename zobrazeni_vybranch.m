clc;clear all;close all;

% [1660,1550,1604,1609,2119,2115];

% cisla= [1660,1609,2119];
% cisla= [1530];
% cisla= [2231,1670,1657];
cisla=[2135,1609,1680];
% cisla=[1528,2183,1550,1660,2135,2231,1596,1527,2212,1530,2228,2159,2247,1597];

T=readtable('../pca_cisla/tabulka.xlsx');

cisla_bunek=T.cislo_bunky;


a2d_all={};
b2d_all={};
c2d_all={};


for cislo = cisla

    
    row=find(cisla_bunek==cislo);
    
    drawnow;
    
    img_name = T{row,1};
    img_name=img_name{1};
    
    mask_name_split=strrep(img_name,'3D_','mask_split');
    L_nuc_mask=bwlabeln(imread(mask_name_split));
    
    
    nuc_num=T{row,2};
    
    
    [a,b,c]=read_3d_rgb_tif(img_name);


    [a,b,c]=preprocess_filters(a,b,c,1);
    
    
    s = regionprops(L_nuc_mask==nuc_num,'BoundingBox');
    bbs = cat(1,s.BoundingBox);
    
     bb=round(bbs(1,:));
    
     a = a(bb(2):bb(2)+bb(5)-1,bb(1):bb(1)+bb(4)-1,bb(3):bb(3)+bb(6)-1);
     b = b(bb(2):bb(2)+bb(5)-1,bb(1):bb(1)+bb(4)-1,bb(3):bb(3)+bb(6)-1);
     c = c(bb(2):bb(2)+bb(5)-1,bb(1):bb(1)+bb(4)-1,bb(3):bb(3)+bb(6)-1);
    
    
    a2d_all=[a2d_all,max(a,[],3)];
    b2d_all=[b2d_all,max(b,[],3)];
    c2d_all=[c2d_all,max(c,[],3)];

    
end

p=0.1;

tmp=[];
for k=1:length(a2d_all)
    tmpp=a2d_all{k};
    tmp=[tmp;tmpp(:)];
end


maxva=prctile(tmp,100-p);
minva=prctile(tmp,p);

tmp=[];
for k=1:length(a2d_all)
    tmpp=b2d_all{k};
    tmp=[tmp;tmpp(:)];
end

maxvb=prctile(tmp,100-p);
minvb=prctile(tmp,p);

tmp=[];
for k=1:length(a2d_all)
    tmpp=c2d_all{k};
    tmp=[tmp;tmpp(:)];
end
maxvc=prctile(tmp,100-p);
minvc=prctile(tmp,p);


maxva=350;
minva=100;


maxvb=250;
minva=100;

maxvc=180;
minva=100;

for cislo = 1:length(a2d_all)


    rgb=cat(3,mat2gray(a2d_all{cislo},[minva,maxva]),mat2gray(b2d_all{cislo},[minvb,maxvb]),mat2gray(c2d_all{cislo},[minvc,maxvc]));
    
    figure();
    imshow(rgb)
    
    title(num2str(cisla(cislo)))
    imwrite(uint8(rgb*255),['../pca_cisla/imgs/' num2str(cisla(cislo)) '.png'])
    
end
