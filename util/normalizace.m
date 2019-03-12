
function [anorm,bnorm,cnorm]=normalizace(a,b,c,maska,nejmene)

    apom=a(repmat(maska,[1 1 size(a,3)]));
     nn=100/numel(apom);
    nn(nn<0)=0;
    nn(nn>1)=1;
    hranice=[double(prctile(apom(:),nn*100)) double(prctile(apom(:),100*(1-(nn))))];
    if hranice(2)<nejmene
        hranice(2)=nejmene;
    end
    anorm=mat2gray(a,hranice);
    
    bpom=b(repmat(maska,[1 1 size(a,3)]));
    hranice=[double(prctile(bpom(:),nn*100)) double(prctile(bpom(:),100*(1-(nn))))];
    if hranice(2)<nejmene
        hranice(2)=nejmene;
    end
    bnorm=mat2gray(b,hranice);
    
    cnorm=mat2gray(c);