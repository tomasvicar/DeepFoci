function [foky_r,foky_g,maxima,hodnoty_maxim_r,hodnoty_maxim_g,velikosti_r,velikosti_g]=naprahovani_mser(barva,maska,a,b,c)



% disp('filtry')
% tic
% a=padarray(a,[1 1 0],'symmetric');
% b=padarray(b,[1 1 0],'symmetric');
% a=gpuArray(a);
% b=gpuArray(b);
% for k=1:size(a,3)
%     a(:,:,k)=medfilt2(a(:,:,k),[3 3]);
%     b(:,:,k)=medfilt2(b(:,:,k),[3 3]);
% end
% a=a(2:end-1,2:end-1,:);
% b=b(2:end-1,2:end-1,:);
% toc
% tic
%
% a=imgaussfilt3(a,[2 2 2/3]);
% b=imgaussfilt3(b,[2 2 2/3]);
% toc
% tic
% a=mat2gray(a);
% b=mat2gray(b);
% toc
% a=gather(a);
% b=gather(b);


[barvyv,maskyv,av,bv,cv,rohy]=bound_all(barva,maska,a,b,c,size(a,3));

foky_r=false(size(a));
foky_g=false(size(a));

maxima=[];
hodnoty_maxim_r=[];
hodnoty_maxim_g=[];

velikosti_r=[];
velikosti_g=[];


for cislo_bunky=1:length(maskyv)
    mvv=maskyv{cislo_bunky};avv=av{cislo_bunky};bvv=bv{cislo_bunky};cvv=cv{cislo_bunky};roh=rohy{cislo_bunky};barvav=barvyv{cislo_bunky};
    
    
    a=avv;
    b=bvv;
    
    
    disp('filtry')
    tic
    a=padarray(a,[1 1 0],'symmetric');
    b=padarray(b,[1 1 0],'symmetric');
    a=gpuArray(a);
    b=gpuArray(b);
    for k=1:size(a,3)
        a(:,:,k)=medfilt2(a(:,:,k),[3 3]);
        b(:,:,k)=medfilt2(b(:,:,k),[3 3]);
    end
    a=a(2:end-1,2:end-1,:);
    b=b(2:end-1,2:end-1,:);
    toc
    tic
    
    a=imgaussfilt3(a,[2 2 2/3]);
    b=imgaussfilt3(b,[2 2 2/3]);
    toc
    tic
    avv=gather(a);
    bvv=gather(b);
    
    a=mat2gray(a);
    b=mat2gray(b);
    toc
    a=gather(a);
    b=gather(b);
    
    
    disp('cervena')
    tic
    pom=a;
    aa=uint8(pom*255);
    tic
    [r,f]=vl_mser(aa,'MinDiversity',0.4,...
        'MaxVariation',0.4,...
        'Delta',3,...
        'MinArea', 50/ numel(aa),...
        'MaxArea',2400/ numel(aa));
    
    M1 = zeros(size(aa)) ;
    for x=1:length(r)
        s = vl_erfill(aa,r(x)) ;
        M1(s) = M1(s) + 1;
    end
    wa=M1>0;
    toc
    
    
    
    
    disp('zelena')
    tic
    pom=b;
    aa=uint8(pom*255);
    tic
    [r,f]=vl_mser(aa,'MinDiversity',0.4,...
        'MaxVariation',0.4,...
        'Delta',3,...
        'MinArea', 50/ numel(aa),...
        'MaxArea',2400/ numel(aa));
    
    M1 = zeros(size(aa)) ;
    for x=1:length(r)
        s = vl_erfill(aa,r(x)) ;
        M1(s) = M1(s) + 1;
    end
    wb=M1>0;
    toc
    
    
    
    
    
    ab=a.*b;
    
    ab_m=imregionalmax(ab);
    
    s = regionprops(ab_m,'centroid');
    maximav = round(cat(1, s.Centroid));
    
    hodnoty_maxim_rv=[];
    hodnoty_maxim_gv=[];
    for k=1:length(maximav)
        hodnoty_maxim_rv(k) = avv(maximav(k,2),maximav(k,1),maximav(k,3));
        hodnoty_maxim_gv(k) = bvv(maximav(k,2),maximav(k,1),maximav(k,3));
    end
    
    
    pom=a;
    pom=-pom;
    pom=imimposemin(pom,ab_m);
    wa_krajeny=watershed(pom)>0;
    wa_krajeny(wa==0)=0;
    
    
    pom=b;
    pom=-pom;
    pom=imimposemin(pom,ab_m);
    wb_krajeny=watershed(pom)>0;
    wb_krajeny(wb==0)=0;
%     ktere_a = la(maximav(k,1),maximav(k,2),maximav(k,3))
%     ktere_b = lb(maximav(k,1),maximav(k,2),maximav(k,3))
    
    velikosti_rv=[];
    velikosti_gv=[];
    la=bwlabeln(wa_krajeny);
    lb=bwlabeln(wb_krajeny);
    for k=1:length(maximav)
        ktere_a = la(maximav(k,2),maximav(k,1),maximav(k,3));
        ktere_b = lb(maximav(k,2),maximav(k,1),maximav(k,3));
        fok_a=la==ktere_a;
        fok_b=lb==ktere_b;
        
        if ktere_a==0
            velikosti_rv(k)=0;
        else
            velikosti_rv(k)=sum(fok_a(:));
        end
        
        if ktere_b==0
            velikosti_gv(k)=0;
        else
            velikosti_gv(k)=sum(fok_b(:));
        end
    end
    
    
    
    [foky_r]=insertmatrix(foky_r,wa,roh([1 2 3]));
    [foky_g]=insertmatrix(foky_g,wb,roh([1 2 3]));
    
    
    velikosti_r=[velikosti_r velikosti_rv];
    velikosti_g=[velikosti_g velikosti_gv];
    
    hodnoty_maxim_r=[hodnoty_maxim_r hodnoty_maxim_rv];
    hodnoty_maxim_g=[hodnoty_maxim_g hodnoty_maxim_gv];
    maxima=[maxima;maximav+roh];
    
end