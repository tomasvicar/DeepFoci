function [bin]=odstran_krajovky(bin,okraj1,prah)

o1=zeros(size(bin));
o2=zeros(size(bin));

okraj=okraj1;


o1(okraj,okraj:end-okraj)=1;
o1(end-okraj,okraj:end-okraj)=1;
% o1(okraj:end-okraj,okraj)=1;
% o1(okraj:end-okraj,end-okraj)=1;


% o2(okraj,okraj:end-okraj)=1;
% o2(end-okraj,okraj:end-okraj)=1;
o2(okraj:end-okraj,okraj)=1;
o2(okraj:end-okraj,end-okraj)=1;






l=bwlabel(bin>0);


vady=l(o1>0);

qq=unique(vady);
for kk=1:length(qq)
    k=qq(kk);
    if sum(vady==k)>(0.5*max(sum(l==k,1)))
        bin(l==k)=0;
    end
end


vady=l(o2>0);
qq=unique(vady);
for kk=1:length(qq)
    k=qq(kk);
    if sum(vady==k)>(prah*max(sum(l==k,2)))
        bin(l==k)=0;
    end
end



