function [a,b,c]=nacteni_puvodni(data)

data=data(1:end-6);

nazev=[data '01.ics'];
addpath('bfmatlab')
bfopen(nazev)
r=ans{1};
for k=1:size(r,1)
    b(:,:,k)=r{k,1};
    
end

nazev=[data '02.ics'];
bfopen(nazev)
r=ans{1};
for k=1:size(r,1)
    a(:,:,k)=r{k,1};
    

end


nazev=[data '03.ics'];
bfopen(nazev)
r=ans{1};
for k=1:size(r,1)
    c(:,:,k)=r{k,1};
    
end


a=a(1:end-30,1:end-30,:);
b=b(1:end-30,1:end-30,:);
c=c(1:end-30,1:end-30,:);






