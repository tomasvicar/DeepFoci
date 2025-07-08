function [data]=read_ics_3_files(name)


name_file=[name '01.ics'];%green
bfopen(name_file)
r=ans{1};
for k=1:size(r,1)
    b(:,:,k)=r{k,1};
    
end

name_file=[name '02.ics'];%red
bfopen(name_file)
r=ans{1};
for k=1:size(r,1)
    a(:,:,k)=r{k,1};
    

end


name_file=[name '03.ics'];%blue
bfopen(name_file)
r=ans{1};
for k=1:size(r,1)
    c(:,:,k)=r{k,1};
end



a=a(1:end-30,1:end-30,:);
b=b(1:end-30,1:end-30,:);
c=c(1:end-30,1:end-30,:);

data = {a,b,c};


